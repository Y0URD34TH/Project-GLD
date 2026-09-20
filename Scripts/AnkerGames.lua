local VERSION = "1.5.5"
client.auto_script_update(
    "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/AnkerGames.lua",
    VERSION
)

local searchprovider = "ankergames.net"
local BASE_URL = "https://ankergames.net"
local version = client.GetVersionDouble()
local cfCookiesAnker = ""

local session_headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15",
    ["Accept"] = "application/json, text/html",
    ["X-Requested-With"] = "XMLHttpRequest"
}

local pendingResolvers = {}
local imagelink = ""
local gamename = ""
local expectedurl = ""
local pathcheck = ""
local defaultdir = "C:/Games"
local pass = ""

-- ============================================================================
-- PHASE 1: SEARCH LOGIC
-- ============================================================================

local function updateSession()
    
    local response = http.get(BASE_URL .. "/csrf-token", session_headers)

    if not response or response == "" then
        return false
    end

    local success, parsedData = pcall(JsonWrapper.parse, response)

    if success and parsedData and parsedData.token then
        session_headers["X-CSRF-TOKEN"] = parsedData.token
        return true
    end

    return false
end

local function sanitize(str)
    if not str then
        return ""
    end

    return str:lower():gsub("[%s%p]", "")
end

local function ankersearch()
    settings.save()

    updateSession()

    Notifications.push_success(
        "AnkerGames",
        "Mr. Ghost's AnkerGames Script loaded."
    )

    local getgamename = game.getgamename()

    if not getgamename or getgamename == "" then
        return
    end

    local encodedName = getgamename:gsub(" ", "%%20")
    local searchUrl = BASE_URL .. "/search/" .. encodedName

    local htmlContent = http.get(searchUrl, session_headers)

    if not htmlContent or htmlContent == "" then
        Notifications.push_error(
            "AnkerGames",
            "Failed to retrieve search results."
        )
        return
    end

    local topThisWeekPos = htmlContent:find("Top this week", 1, true)
    if topThisWeekPos then
        htmlContent = htmlContent:sub(1, topThisWeekPos - 1)
    end

    local results = {}
    local doc = html.parse(htmlContent)

    -- Recursively collect all text from a node and its descendants.
    -- Needed because the size/year live in <span> children of the <p>,
    -- so node:text() on the <p> alone returns nothing.
    local function collectText(node)
        local parts = {}
        local function walk(n)
            local txt = n:text()
            if txt and txt ~= "" then
                table.insert(parts, txt)
            end
            local kids = n:children()
            if kids then
                for i = 1, #kids do
                    walk(kids[i])
                end
            end
        end
        walk(node)
        return table.concat(parts, " ")
    end

    local function scanNodeForMeta(node, meta)
        local tag = node:tag()

        if tag == "p" then
            local txt = collectText(node)
            if meta.year == "" then
                local y = txt:match("(%d%d%d%d)")
                if y then meta.year = y end
            end
            if meta.size == "" then
                local s = txt:match("(%d+%.%d+%s*GB)")
                if not s then s = txt:match("(%d+%.%d+%s*MB)") end
                if s then meta.size = s end
            end
            if meta.version == "" then
                local v = txt:match("(V%s+[%d%.]+)")
                if v then meta.version = v end
            end
        elseif tag == "span" then
            if meta.version == "" then
                local t = node:attr("title")
                if t and t:match("^%s*V%s") then
                    meta.version = t:match("^%s*(.-)%s*$") or t
                else
                    local txt = node:text() or ""
                    local v = txt:match("^%s*(V%s+[%d%.]+)%s*$")
                    if v then meta.version = v end
                end
            end
        end

        local kids = node:children()
        if kids then
            for i = 1, #kids do
                scanNodeForMeta(kids[i], meta)
            end
        end
    end

    local gameLinks = doc:css('a[href*="/game/"][title]')

    for i = 1, #gameLinks do
        local link = gameLinks[i]

        local title = link:attr("title")
        local href = link:attr("href")

        if title and href then
            local slug = href:match("/game/([^/?#]+)")

            if slug then
                -- Walk up from <a> to the enclosing <article> card.
                local card = link:parent()
                for _ = 1, 4 do
                    if card and card:tag() ~= "article" then
                        local up = card:parent()
                        if up then card = up else break end
                    else
                        break
                    end
                end

                local meta = { version = "", size = "", year = "" }

                if card then
                    scanNodeForMeta(card, meta)
                end

                -- Build display name: "Title [Size] "
                local displayName
                if meta.size ~= "" then
                    displayName =  " [" .. meta.size .. "] " .. title
                else
                    displayName = title .. " "
                end

                -- Build tooltip: version | size | year
                local tooltipParts = {}
                if meta.version ~= "" then
                    table.insert(tooltipParts, meta.version)
                end
                if meta.size ~= "" then
                    table.insert(tooltipParts, meta.size)
                end
                if meta.year ~= "" then
                    table.insert(tooltipParts, meta.year)
                end

                local tooltip = table.concat(tooltipParts, " | ")
                if tooltip == "" then
                    tooltip = "AnkerGames"
                end

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

    if #results > 0 then
        communication.receiveSearchResults(results)
    else
        Notifications.push(
            "AnkerGames",
            "No matching games found."
        )
    end
end

-- ============================================================================
-- PHASE 2: HYBRID FAST-FETCH RESOLVER
-- ============================================================================

local function ondownloadclick(gamejson, downloadurl, scriptname)       
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

local function on_beforedownload(url)
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

local function on_browserloaded(browserID)
    local resolverBrowser = browser.GetBrowserByID(browserID)
    if not resolverBrowser then return end
            
    if pendingResolvers[browserID] then
        local fastFetchAutomation = [=[
            if (document.title.includes("Just a moment") || document.title.includes("Cloudflare")) {
                // Let Cloudflare finish solving before proceeding
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
                            window.location.href = data.download_url;
                        }
                    }).catch(err => console.error(err));
                }
            }
        ]=]
        resolverBrowser:ExecuteJavaScriptOnMainFrame(fastFetchAutomation)
    end
end

local function on_browserbeforedownload(browserID, downloadUrl, suggestedName, size)
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
        defaultdir = menu.get_text("Anker Game Dir") .. "/" .. gamenametopath .. "/"
        path = path:gsub("\\", "/")
        pathcheck = path
        pass = menu.get_text("Pass")
        local deleteafterextraction = menu.get_bool("Delete After Extraction")
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
                    Notifications.push_success("Anker Script", "Game Successfully Installed!")
                else
                    GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                    Notifications.push_success("Anker Script", "Game Successfully Installed!")
                end
            else
                local executables2 = file.listexecutablesrecursive(fullFolderPath)
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

-- ============================================================================
-- INITIALIZATION & EVENT REGISTRATION
-- ============================================================================

if version < 7.00 then
    Notifications.push_error(
        "Lua Script",
        "Program is Outdated. Please Update to use this Script"
    )
else
    Notifications.push_success(
        "Lua Script",
        "Anker Script Loaded and Working"
    )

    menu.add_input_text("Anker Game Dir")
    menu.set_text("Anker Game Dir", defaultdir)

    menu.add_input_text("Pass")
    menu.set_text("Pass", "")

    menu.add_check_box("Delete After Extraction")

    settings.load()

    client.add_callback(
        "on_scriptselected",
        ankersearch
    )

    client.add_callback(
        "on_downloadclick",
        ondownloadclick
    )

    client.add_callback(
        "on_beforedownload",
        on_beforedownload
    )

    client.add_callback(
        "on_browserloaded",
        on_browserloaded
    )

    client.add_callback(
        "on_browserbeforedownload",
        on_browserbeforedownload
    )

    client.add_callback(
        "on_downloadcompleted",
        ondownloadcompleted
    )

    client.add_callback(
        "on_extractioncompleted",
        onextractioncompleted
    )
    

end





