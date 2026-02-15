-- to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local VERSION = "1.2.0"
local BASE_URL = "https://atopgames.com/"
client.auto_script_update(
    "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/Atop-Games.lua",
    VERSION)

local function extractPageandTitle(html)
    local posts = {}
    
    -- Parse HTML document
    local doc = html.parse(html)
    
    -- Find all post title elements
    local postTitles = doc:css('h2.post-title')
    
    for i = 1, #postTitles do
        local h2 = postTitles[i]
        -- Get the link inside the h2
        local links = h2:children()
        
        for j = 1, #links do
            local link = links[j]
            if link:tag() == "a" then
                local href = link:attr("href")
                local title = link:text()
                
                if href and title then
                    table.insert(posts, {
                        href = href,
                        title = title:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
                    })
                end
            end
        end
    end

    return posts
end

local function extractGameDetailsRobust(html)
    local details = {
        size = "",
        version = "",
        release_group = "",
        genre = "",
        developer = "",
        platform = "",
        game_type = ""
    }
    
    -- Parse HTML document
    local doc = html.parse(html)
    
    -- Find all list items
    local listItems = doc:css('li')
    
    for i = 1, #listItems do
        local liText = listItems[i]:text()
        
        -- Extract Game Size
        if liText:find("Game Size") then
            local size = liText:match("Game Size%s*:?%s*(.+)")
            if size then
                details.size = size:gsub("^%s*(.-)%s*$", "%1")
            end
        end
        
        -- Extract Version
        if liText:find("Version") then
            local version = liText:match("Version%s*:?%s*(.+)")
            if version then
                details.version = version:gsub("^%s*(.-)%s*$", "%1")
                -- Remove leading colon if present
                details.version = details.version:gsub("^:%s*", "")
            end
        end
        
        -- Extract Released By
        if liText:find("Released By") then
            local release_group = liText:match("Released By%s*:?%s*(.+)")
            if release_group then
                details.release_group = release_group:gsub("^%s*(.-)%s*$", "%1")
            end
        end
        
        -- Extract Genre
        if liText:find("Genre") then
            local genre = liText:match("Genre%s*:?%s*(.+)")
            if genre then
                details.genre = genre:gsub("^%s*(.-)%s*$", "%1")
            end
        end
        
        -- Extract Developer
        if liText:find("Developer") then
            local developer = liText:match("Developer%s*:?%s*(.+)")
            if developer then
                details.developer = developer:gsub("^%s*(.-)%s*$", "%1")
            end
        end
        
        -- Extract Platform
        if liText:find("Platform") then
            local platform = liText:match("Platform%s*:?%s*(.+)")
            if platform then
                details.platform = platform:gsub("^%s*(.-)%s*$", "%1")
            end
        end
        
        -- Extract Game Type
        if liText:find("Game Type") then
            local game_type = liText:match("Game Type%s*:?%s*(.+)")
            if game_type then
                details.game_type = game_type:gsub("^%s*(.-)%s*$", "%1")
            end
        end
    end

    return details
end

local function isFrom1Fichier(url)
    return url:find("1fichier") ~= nil
end

local function isFrombuzz(url)
    return url:find("buzzheavier") ~= nil
end

local function extractDomain(url)
    -- Check if it's a magnet link
    if url:match("^magnet:") then
        return "Torrent"
    end

    -- Extract domain from URL
    local domain = url:match("^https?://([^/]+)") or url:match("^//([^/]+)")
    if domain then
        -- Remove www. prefix if present
        domain = domain:gsub("^www%.", "")
    end
    return domain or "Unknown"
end

local function webScrapeAtop(gameName)
    local searchUrl = "https://atopgames.com/?s=" .. gameName
    searchUrl = searchUrl:gsub(" ", "+")
    local headers = {
        ["User-Agent"] =
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    local response = http.get(searchUrl, headers)
    if not response then
        return {}
    end
    
    local all_pages = extractPageandTitle(response)
    local result = {}
    
    for i, page in ipairs(all_pages) do
        local pageUrl = page.href
        
        -- Ensure full URL
        if not pageUrl:find("^https?://") then
            pageUrl = BASE_URL .. pageUrl
        end
        
        local pageResponse = http.get(pageUrl, headers)
        if not pageResponse then
            goto continue
        end
        
        local details = extractGameDetailsRobust(pageResponse)
        local gameResult = {
            name       = "[" .. details.size .. "] " .. page.title,
            links      = {},
            tooltip    = "Size: " ..
                details.size .. " | Version: " .. details.version .. " | Released By: " .. details.release_group,
            ScriptName = "Atop-Games"
        }
        
        -- Parse page for download links using HTML parser
        local pageDoc = html.parse(pageResponse)
        
        -- Find all download buttons with class "shortc-button small blue"
        local downloadButtons = pageDoc:css('a.shortc-button.small.blue')
        
        for j = 1, #downloadButtons do
            local serverLink = downloadButtons[j]:attr("href")
            
            if serverLink then
                -- Add protocol if missing
                if serverLink:sub(1, 2) == "//" then
                    serverLink = "https:" .. serverLink
                elseif not serverLink:find("^https?://") then
                    serverLink = "https:" .. serverLink
                end
                
                local domain = extractDomain(serverLink)
                
                -- Skip 1fichier links
                if not isFrom1Fichier(serverLink) then
                    if isFrombuzz(serverLink) then
                        -- Buzzheavier links need manual download
                        table.insert(gameResult.links, {
                            name = "Download in " .. domain,
                            link = serverLink,
                            addtodownloadlist = false
                        })
                    else
                        -- Other links can auto-download
                        table.insert(gameResult.links, {
                            name = "Download in " .. domain,
                            link = serverLink,
                            addtodownloadlist = true
                        })
                    end
                end
            end
        end
        
        -- Only add game result if it has download links
        if #gameResult.links > 0 then
            table.insert(result, gameResult)
        end
        
        ::continue::
    end
    
    return result
end

local function atop()
    local gamename = game.getgamename()
    local results = webScrapeAtop(gamename)
    communication.receiveSearchResults(results)
end

local imagelink = ""
local gamename = ""
local expectedurl = ""
local defaultdir = "C:/Games"

local function ondownloadclick(gamejson, downloadurl, scriptname)
    if scriptname == "Atop-Games" then
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

local pathcheck = ""

local function ondownloadcompleted(path, url)
    if expectedurl == url then
        local gamenametopath = gamename
        gamenametopath = gamenametopath:gsub(":", "")
        defaultdir = menu.get_text("Atop Game Dir") .. "/" .. gamenametopath .. "/"
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
            local executables = file.listexecutables(fullFolderPath)

            -- Get the first executable
            if executables and #executables >= 1 then
                local firstExecutable = executables[1]
                local fullExecutablePath = fullFolderPath .. "\\" .. firstExecutable
                local gameidl = GameLibrary.GetGameIdFromName(gamename)
                
                if gameidl == -1 then
                    local imagePath = Download.DownloadImage(imagelink)
                    GameLibrary.addGame(fullExecutablePath, imagePath, gamename, "")
                    Notifications.push_success("Atop Script", "Game Successfully Installed!")
                else
                    GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                    Notifications.push_success("Atop Script", "Game Successfully Installed!")
                end
            else
                -- Try recursive search
                local executables2 = file.listexecutablesrecursive(fullFolderPath)
                if executables2 and #executables2 >= 1 then
                    local firstExecutable = executables2[1]
                    local gameidl = GameLibrary.GetGameIdFromName(gamename)
                    
                    if gameidl == -1 then
                        local imagePath = Download.DownloadImage(imagelink)
                        GameLibrary.addGame(firstExecutable, imagePath, gamename, "")
                        Notifications.push_success("Atop Script", "Game Successfully Installed!")
                    else
                        GameLibrary.changeGameinfo(gameidl, firstExecutable)
                        Notifications.push_success("Atop Script", "Game Successfully Installed!")
                    end
                end
            end
        end
    end
end

-- Initialize menu
local version = client.GetVersionDouble()
if version >= 6.95 then
    Notifications.push_success("Lua Script", "Atop-Games Script Loaded and Working")
    menu.add_input_text("Atop Game Dir")
    menu.set_text("Atop Game Dir", defaultdir)
    settings.load()
    
    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_extractioncompleted", onextractioncompleted)
    client.add_callback("on_scriptselected", atop)
else
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
end

