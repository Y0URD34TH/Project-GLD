local VERSION = "1.2.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/AnkerGames.lua", VERSION)

-- Track multiple pending downloads
local pendingResolvers = {} -- Table to track browser instances by URL

local function scrapAnkerGames(gameName, name_script)
    Notifications.push_warning("Anker Script", "Downloads takes 10 seconds to add and more 10 to start!")
    local searchUrl = "https://ankergames.net/search/" .. gameName:gsub(" ", "%%20")
    local headers = {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    }
    local resp = http.get(searchUrl, headers)
    if not resp then
        return {}
    end
    
    local results = {}
    
    -- Parse the search results page
    local doc = html.parse(resp)
    
    -- Find all game cards using CSS selector
    local gameCards = doc:css('a[aria-label*="View details"]')
    
    for i = 1, #gameCards do
        local card = gameCards[i]
        local href = card:attr("href")
        local ariaLabel = card:attr("aria-label")
        
        if href and ariaLabel then
            -- Extract title from aria-label (format: "Title - View details")
            local title = ariaLabel:match("(.+)%s*%-%s*View details")
            
            if title and href:match("^https://ankergames%.net/game/") then
                -- Fetch the game details page
                local resp2 = http.get(href, headers)
                if resp2 then
                    local gameDoc = html.parse(resp2)
                    
                    -- Extract version
                    local version = nil
                    local versionNodes = gameDoc:css('[class*="animate-glow"]')
                    for j = 1, #versionNodes do
                        local versionText = versionNodes[j]:text()
                        local v = versionText:match("V%s*([%d%.]+)")
                        if v then
                            version = v
                            break
                        end
                    end
                    
                    -- Extract size (looking for GB/MB spans)
                    local size = nil
                    local sizeSpans = gameDoc:css('span')
                    for j = 1, #sizeSpans do
                        local sizeText = sizeSpans[j]:text()
                        local s = sizeText:match("([%d%.]+%s*[MG]B)")
                        if s then
                            size = s
                            break
                        end
                    end
                    
                    -- Extract Release Group
                    local release_group = nil
                    local rgLinks = gameDoc:css('a[href*="/release-group/"]')
                    if #rgLinks > 0 then
                        release_group = rgLinks[1]:text()
                    end
                    
                    -- Build tooltip with extracted information
                    local tooltip_parts = {}
                    
                    if version then
                        table.insert(tooltip_parts, "Version: V " .. version)
                    end
                    
                    if size then
                        table.insert(tooltip_parts, "Size: " .. size)
                    end
                    
                    if release_group then
                        table.insert(tooltip_parts, "Release Group: " .. release_group)
                    end
                    
                    local tooltip = table.concat(tooltip_parts, "\n")
                    
                    -- Use size in name if available, otherwise use empty brackets
                    local displayName = size and "[".. size .."] "..title or title
                    
                    local patchresult = {
                        name = displayName,
                        links = {},
                        tooltip = tooltip,
                        ScriptName = name_script
                    }
                    
                    table.insert(patchresult.links, {
                        name = "Download",
                        link = href,
                        addtodownloadlist = true
                    })
                    
                    table.insert(results, patchresult)
                end
            end
        end
    end
    
    return results
end

local version = client.GetVersionDouble()
local defaultdir = "C:/Games"
if version < 6.95 then -- 3.50
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "Anker Script Loaded and Working")
    menu.add_input_text("Anker Game Dir")
    menu.set_text("Anker Game Dir", defaultdir)
    settings.load()
    
    local function ankersearch()
        settings.save()
        local getgamename = game.getgamename()
        local scriptname = "AnkerGames"

        local results = scrapAnkerGames(getgamename, scriptname)

        communication.receiveSearchResults(results)
    end
    
    local imagelink = ""
    local gamename = ""
    local gamepath = ""
    local extractpath = ""
    local expectedurl = ""
    
    local function ondownloadclick(gamejson, downloadurl, scriptname)       
        if scriptname == "AnkerGames" then
            Notifications.push_warning("Anker Script", "YOUR DOWNLOAD WILL START IN 10 SECONDS")
            Notifications.push_warning("Anker Script", "DONT PANICK WAIT THE 10 SECONDS!")
            expectedurl = downloadurl
        end
        local jsonResults = JsonWrapper.parse(gamejson)
        local coverImageUrl = jsonResults["cover"]["url"]

        if coverImageUrl and coverImageUrl:sub(1, 2) == "//" then
            coverImageUrl = "https:" .. coverImageUrl
        end
        if coverImageUrl then
            coverImageUrl = coverImageUrl:gsub("t_thumb", "t_cover_big")
        end

        local jsonName = JsonWrapper.parse(gamejson).name
        gamename = jsonName
        imagelink = coverImageUrl
    end
    
    -- Download resolver for Anker Games
    local function on_beforedownload(url)
        -- Check if this is an Anker Games URL
        if url:match("^https://ankergames%.net/game/") then
            Notifications.push_warning("Anker Resolver", "Resolving download link...")
            
            -- Generate unique browser name for this download
            local browserName = "AnkerResolver_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
            
            -- Create hidden browser for this download
            local resolverBrowser = browser.CreateBrowser(browserName, url)
            browser.set_visible(false, browserName)

            pendingResolvers[resolverBrowser:GetID()] = {
                originalUrl = url,
                resolved = false
            }
            
            -- Cancel the original download - we'll resolve it first
            return "cancel", nil, nil
        end
        
        -- Not an Anker Games URL, let it proceed normally
        return nil, nil, nil
    end
    
    -- Handle browser load completion for resolvers
    local function on_browserloaded(browserID)
        -- Get browser name to check if it's one of our resolvers
        local resolverBrowser = browser.GetBrowserByID(browserID)
        if not resolverBrowser then
            return
        end
                
        -- Check if this is one of our pending resolvers
        if pendingResolvers[browserID] and not pendingResolvers[browserID].resolved then
            local resolverInfo = pendingResolvers[browserID]
            
            -- Mark as resolved to prevent multiple executions
            resolverInfo.resolved = true
            
            -- Execute the automation script to click download buttons
            local fullAutomation = [=[
                // Click main button
                document.querySelector('button[class*="bg-[var(--primary-color)]"]')?.click();
                
                // Wait for modal then click download
                let attempts = 0;
                const tryClick = setInterval(() => {
                    const btn = document.querySelector('a.download-button');
                    if (btn && !btn.disabled) {
                        btn.click();
                        clearInterval(tryClick);
                    } else if (attempts++ > 10) { // 10 attempts (about 2 seconds)
                        clearInterval(tryClick);
                        console.error('Failed to find active download button');
                    }
                }, 200);
            ]=]
            
            resolverBrowser:ExecuteJavaScriptOnMainFrame(fullAutomation)
            resolverBrowser:ExecuteJavaScriptOnFocusedFrame(fullAutomation)
            Notifications.push_success("Anker Resolver", "Automation script executed!")
        end
    end
    
    -- Handle browser downloads (when the real download link is triggered)
    local function on_browserbeforedownload(browserID, downloadUrl, suggestedName, size)
        local resolverBrowser = browser.GetBrowserByID(browserID)
        if not resolverBrowser then
            return nil
        end
                
        -- Check if this download came from one of our resolvers
        if pendingResolvers[browserID] then
            local resolverInfo = pendingResolvers[browserID]
            
            -- Add the resolved download with the original URL for tracking
            Download.SetHistoryUrl(downloadUrl, resolverInfo.originalUrl)
            
            Notifications.push_success("Anker Resolver", "Download link resolved successfully!")
            
            -- Close the resolver browser
            resolverBrowser:CloseBrowser()
            
            -- Clean up resolver tracking
            pendingResolvers[browserID] = nil
            
            -- Return original URL for history tracking
            return resolverInfo.originalUrl
        end
        
        return nil
    end
    
    local pathcheck = ""
    local function ondownloadcompleted(path, url)
        if expectedurl == url then
            local gamenametopath = gamename
            gamenametopath = gamenametopath:gsub(":", "")
            defaultdir = menu.get_text("Anker Game Dir") .. "/" .. gamenametopath .. "/"
            path = path:gsub("\\", "/")
            pathcheck = path
            zip.extract(path, defaultdir, false)
        end
        settings.save()
    end
    
    local function onextractioncompleted(origin, path)
        if pathcheck == origin then
            path = path:gsub("/", "\\")
            local folders = file.listfolders(path)

            local secondFolder = folders[1]
            if secondFolder then
                local fullFolderPath = path .. "\\" .. secondFolder

                local executables = file.listexecutables(fullFolderPath) -- Returns a vector

                -- Get the first executable (assuming executables[1] exists)
                if executables and #executables >= 1 then
                    local firstExecutable = executables[1]

                    local fullExecutablePath = fullFolderPath .. "\\" .. firstExecutable
                    local gameidl = GameLibrary.GetGameIdFromName(gamename)
                    if gameidl == -1 then
                        local imagePath = Download.DownloadImage(imagelink)
                        GameLibrary.addGame(fullExecutablePath, imagePath, gamename, "")
                        Notifications.push_success("Anker Script", "Game Successfully Installed!")
                    else
                        GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                        Notifications.push_success("Anker Script", "Game Successfully Installed!")
                    end
                else
                    local executables2 = file.listexecutablesrecursive(fullFolderPath) -- Returns a vector
                    if executables2 and #executables2 >= 1 then
                        local firstExecutable = executables2[1]
                        local gameidl = GameLibrary.GetGameIdFromName(gamename)
                        if gameidl == -1 then
                            local imagePath = Download.DownloadImage(imagelink)
                            GameLibrary.addGame(firstExecutable, imagePath, gamename, "")
                            Notifications.push_success("Anker Script", "Game Successfully Installed!")
                        else
                            GameLibrary.changeGameinfo(gameidl, firstExecutable)
                            Notifications.push_success("Anker Script", "Game Successfully Installed!")
                        end
                    end
                end
            end
        end
    end
    
    -- Register all callbacks
    client.add_callback("on_scriptselected", ankersearch)
    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_beforedownload", on_beforedownload)
    client.add_callback("on_browserloaded", on_browserloaded)
    client.add_callback("on_browserbeforedownload", on_browserbeforedownload)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_extractioncompleted", onextractioncompleted)
end