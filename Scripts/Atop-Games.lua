-- to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local VERSION = "1.0.0"
local BASE_URL = "https://atopgames.com/"
client.auto_script_update(
    "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/Atop-Games.lua",
    VERSION)

local function extractPageandTitle(html)
    local posts = {}
    for href, title in html:gmatch('<h2%s+class="post%-title"%s*><a%s+href="([^"]+)"[^>]*>([^<]+)</a>') do
        table.insert(posts, {
            href = href,
            title = title
        })
    end

    return posts
end

local function extractGameDetailsRobust(html)
    local details = {}

    -- Function to extract any detail by label
    local function extractDetail(label)
        local patterns = {
            '<li><strong>' .. label .. '%s*</strong>%s*:?%s*([^<]+)</li>',
            '<li><strong>' .. label .. ':</strong>%s*([^<]+)</li>',
            '<li>.-<strong>' .. label .. '.-</strong>.-([^<]+)</li>'
        }

        for _, pattern in ipairs(patterns) do
            local value = html:match(pattern)
            if value then
                return value:gsub("^%s*(.-)%s*$", "%1")
            end
        end
        return nil
    end

    -- Extract specific details
    details.size = extractDetail("Game Size")
    details.version = extractDetail("Version")
    details.release_group = extractDetail("Released By")
    details.genre = extractDetail("Genre")
    details.developer = extractDetail("Developer")
    details.platform = extractDetail("Platform")
    details.game_type = extractDetail("Game Type")

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
        local pageResponse = http.get(BASE_URL .. page.href, headers)
        if not pageResponse then
            return {}
        end
        local details = extractGameDetailsRobust(pageResponse)
        local gameResult = {
            name       = "[" .. details.size .. "] " .. page.title,
            links      = {},
            tooltip    = "Size: " ..
                details.size .. " Version: " .. (details.version or "N/A") .. " Released By: " .. (details.release_group or "Unknown"),
            ScriptName = "Atop-Games"
        }
        local linksDL = HtmlWrapper.findAttribute(pageResponse, "a", "class", "shortc-button small blue ",
            "href")
        for _, serverLink in ipairs(linksDL) do
            local domain = extractDomain("https:" .. serverLink)
            if not isFrom1Fichier("https:" .. serverLink) then
                if isFrombuzz("https:" .. serverLink) then
                    table.insert(gameResult.links,
                        { name = "Download in " .. domain, link = "https:" .. serverLink, addtodownloadlist = false })
                else
                    table.insert(gameResult.links,
                        { name = "Download in " .. domain, link = "https:" .. serverLink, addtodownloadlist = true })
                end
            end
        end
        table.insert(result, gameResult)
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
local gamepath = ""
local extractpath = ""
local expectedurl = ""
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
        -- if url == watchlink2 or url == watchlink1 then
        path = path:gsub("\\", "/")
        pathcheck = path
        zip.extract(path, defaultdir, false)
        -- end
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
                    Notifications.push_success("Atop Script", "Game Successfully Installed!")
                else
                    GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                    Notifications.push_success("Atop Script", "Game Successfully Installed!")
                end
            else
                local executables2 = file.listexecutablesrecursive(fullFolderPath) -- Returns a vector
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

client.add_callback("on_downloadclick", ondownloadclick)
client.add_callback("on_downloadcompleted", ondownloadcompleted)
client.add_callback("on_extractioncompleted", onextractioncompleted)
client.add_callback("on_scriptselected", atop)
