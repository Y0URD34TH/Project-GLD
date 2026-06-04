-- Project GLD Provider Script: AnkerGames
local VERSION = "1.3.1"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/AnkerGames.lua", VERSION)

local searchprovider = "ankergames.net"
local BASE_URL = "https://ankergames.net"
local version = client.GetVersionDouble()
local pendingResolvers = {}
local imagelink = ""
local gamename = ""
local expectedurl = ""
local pathcheck = ""
local defaultdir = "C:/Games"
local pass = ""
local session_headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
    ["Accept"] = "application/json, text/html",
    ["X-Requested-With"] = "XMLHttpRequest"
}

-- ============================================================================
-- UTILITIES
-- ============================================================================
local function updateSession()
    local response = http.get(BASE_URL .. "/csrf-token", session_headers)
    if not response or response == "" then return false end
    
    local success, parsedData = pcall(JsonWrapper.parse, response)
    if success and parsedData and parsedData.token then
        session_headers["X-CSRF-TOKEN"] = parsedData.token
        return true
    end
    return false
end

local function sanitize(str)
    if not str then return "" end
    return str:lower():gsub("[%s%p]", "")
end

-- ============================================================================
-- PHASE 1: SEARCH LOGIC
-- ============================================================================
local function ankergamessearch()
    settings.save()
    updateSession()
    Notifications.push_success("AnkerGames", "Mr. Ghost's AnkerGames Script loaded.")
    
    local getgamename = game.getgamename()
    if not getgamename or getgamename == "" then 
        return 
    end
    
    local encodedName = getgamename:gsub(" ", "%%20")
    local searchUrl = BASE_URL .. "/search/" .. encodedName
    local htmlContent = http.get(searchUrl, session_headers)
    
    if not htmlContent then
        Notifications.push_error("AnkerGames", "Failed to retrieve search results.")
        return
    end
    
    local results = {}
    local cleanedQuery = sanitize(getgamename)
    local doc = html.parse(htmlContent)
    
    local gameCards = doc:css('article[listing]')
    
    for i = 1, #gameCards do
        local card = gameCards[i]
        local listingJson = card:attr("listing")
        
        if listingJson then
            local json = listingJson:gsub("&quot;", '"'):gsub("\\/", "/")
            local name = json:match('"title":"([^"]+)"')
            local slug = json:match('"slug":"([^"]+)"')
            local version = json:match('"vote_average":"([^"]+)"')
            local size = json:match('"runtime":"([^"]+)"')
            
            if name and slug then
                if sanitize(name):find(cleanedQuery, 1, true) or cleanedQuery:find(sanitize(name), 1, true) then
                    local tooltip = "Version: " .. (version or "N/A") .. "\nSize: " .. (size or "N/A")
                    local displayName = (size and "[".. size .."] " or "") .. name
                    
                    local searchResult = {
                        name = displayName,
                        links = {},
                        tooltip = tooltip,
                        ScriptName = "AnkerGames"
                    }
                    
                    table.insert(searchResult.links, {
                        name = "Download",
                        link = BASE_URL .. "/game/" .. slug,
                        addtodownloadlist = true
                    })
                    
                    table.insert(results, searchResult)
                end
            end
        end
    end
    
    if #results > 0 then
        communication.receiveSearchResults(results)
    else
        Notifications.push("AnkerGames", "No matching games found.")
    end
end

-- ============================================================================
-- PHASE 2: DOWNLOAD ENGINE
-- ============================================================================
local function ondownloadclick(gamejson, url, scriptname)    
    if scriptname == "AnkerGames" then
        local success, jsonResults = pcall(JsonWrapper.parse, gamejson)
        if success and jsonResults then
            local coverImageUrl = nil
            if jsonResults["cover"] and jsonResults["cover"]["url"] then
                coverImageUrl = jsonResults["cover"]["url"]
            elseif jsonResults.coverurl then
                coverImageUrl = jsonResults.coverurl
            end
            
            if coverImageUrl and coverImageUrl:sub(1, 2) == "//" then
                coverImageUrl = "https:" .. coverImageUrl
            end
            if coverImageUrl then
                coverImageUrl = coverImageUrl:gsub("t_thumb", "t_cover_big")
            end

            gamename = jsonResults.name or ""
            imagelink = coverImageUrl or ""
        end
    end
end

local function onbeforedownload(url)
    if url:match("^https://ankergames%.net/game/") then
        Notifications.push_warning("AnkerGames", "Download will start in few seconds.")
        local browserName = "AnkerResolver_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
        local resolverBrowser = browser.CreateBrowser(browserName, url)
        browser.set_visible(false, browserName)
        pendingResolvers[resolverBrowser:GetID()] = {
            originalUrl = url,
            name = browserName
        }
        return "cancel", nil, nil
    end
    return nil, nil, nil
end

local function onbrowserloaded(browserID)
    local resolverBrowser = browser.GetBrowserByID(browserID)
    if not resolverBrowser then return end
            
    if pendingResolvers[browserID] then
        local fastFetchAutomation = [=[
            if (document.title.includes("Just a moment") || document.title.includes("Cloudflare")) {
            } else {
                let match = document.body.innerHTML.match(/generateDownloadUrl\(\s*(\d+)\s*\)/);
                if (match && match[1]) {
                    let downloadId = match[1];
                    let token = document.querySelector('meta[name="csrf-token"]')?.content || '';
                    
                    fetch('/generate-download-url/' + downloadId, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': token,
                            'X-Requested-With': 'XMLHttpRequest'
                        },
                        body: JSON.stringify({'g-recaptcha-response': 'development-mode'})
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data && data.download_url) {
                            // Triggers GLD's interceptor immediately
                            window.location.href = data.download_url;
                        }
                    }).catch(err => console.error(err));
                }
            }
        ]=]
        resolverBrowser:ExecuteJavaScriptOnMainFrame(fastFetchAutomation)
    end
end

local function onbrowserbeforedownload(browserID, downloadUrl, suggestedName, size)
    local resolverBrowser = browser.GetBrowserByID(browserID)
    if not resolverBrowser then return nil end
            
    if pendingResolvers[browserID] then
        local resolverInfo = pendingResolvers[browserID]
        
	expectedurl = resolverInfo.originalUrl
        Download.SetHistoryUrl(downloadUrl, resolverInfo.originalUrl)
        
        resolverBrowser:CloseBrowser()
        pendingResolvers[browserID] = nil
        
        return resolverInfo.originalUrl
    end
    return nil
end

-- ============================================================================
-- PHASE 3: EXTRACTION LOGIC
-- ============================================================================
local function ondownloadcompleted(path, url)
    if expectedurl == url then
        local gamenametopath = gamename
        gamenametopath = gamenametopath:gsub(":", "")
        defaultdir = menu.get_text("AnkerGames Dir") .. "/" .. gamenametopath .. "/"
        path = path:gsub("\\", "/")
        pathcheck = path
	pass = menu.get_text("Password AnkerGames")
        local deleteafterextraction = menu.get_bool("Delete After Extraction AnkerGames")
        zip.extract(path, defaultdir, deleteafterextraction, pass)
	settings.save()
    end
end

local function onextractioncompleted(origin, path)
    if pathcheck == origin then
        path = path:gsub("/", "\\")
        local folders = file.listfolders(path)

        local secondFolder = folders[1]
        if secondFolder then
            local fullFolderPath = path .. "\\" .. secondFolder
            local executables = file.listexecutables(fullFolderPath)

            if executables and #executables >= 1 then
                local firstExecutable = executables[1]
                local fullExecutablePath = fullFolderPath .. "\\" .. firstExecutable
                local gameidl = GameLibrary.GetGameIdFromName(gamename)
                if gameidl == -1 then
                    local imagePath = Download.DownloadImage(imagelink)
                    GameLibrary.addGame(fullExecutablePath, imagePath, gamename, "")
                    Notifications.push_success("AnkerGames", "Game Successfully Installed!")
                else
                    GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                    Notifications.push_success("AnkerGames", "Game Successfully Installed!")
                end
            else
                local executables2 = file.listexecutablesrecursive(fullFolderPath)
                if executables2 and #executables2 >= 1 then
                    local firstExecutable = executables2[1]
                    local gameidl = GameLibrary.GetGameIdFromName(gamename)
                    if gameidl == -1 then
                        local imagePath = Download.DownloadImage(imagelink)
                        GameLibrary.addGame(firstExecutable, imagePath, gamename, "")
                        Notifications.push_success("AnkerGames", "Game Successfully Installed!")
                    else
                        GameLibrary.changeGameinfo(gameidl, firstExecutable)
                        Notifications.push_success("AnkerGames", "Game Successfully Installed!")
                    end
                end
            end
        end
    end
end

-- ============================================================================
-- INITIALIZATION & EVENT REGISTRATION
-- ============================================================================
if version < 7.00 then
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "AnkerGames Script Loaded and Working")
    menu.add_text("=== AnkerGames ===")
    menu.add_input_text("AnkerGames Dir")
    menu.set_text("AnkerGames Dir", defaultdir)
    menu.add_input_text("Password AnkerGames")
    menu.set_text("Password AnkerGames", "")
    menu.add_check_box("Delete After Extraction AnkerGames")
    menu.add_text("===============")
    settings.load()
    
    client.add_callback("on_scriptselected", ankergamessearch)
    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_beforedownload", onbeforedownload)
    client.add_callback("on_browserloaded", onbrowserloaded)
    client.add_callback("on_browserbeforedownload", onbrowserbeforedownload)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_extractioncompleted", onextractioncompleted)
end