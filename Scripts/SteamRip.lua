-- to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local VERSION = "1.0.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/SteamRip.lua", VERSION)
function extractDomainNUC(url)
    local pattern = "^[^:]+://([^/]+)"
    local domain = string.match(url, pattern)

    return domain
end
local function isGofileLink(link)
    return string.find(link, "gofile")
end
local function isqiwilink(link)
    return string.find(link, "qiwi.gg")
end
local function isbuzzlink(link)
    return string.find(link, "buzzheavier.com")
end
local function ismegadblink(link)
    return string.find(link, "megadb.net")
end
local function endsWith(str, pattern)
    return string.sub(str, -string.len(pattern)) == pattern
end

local watchlink1 = ""
local watchlink2 = ""
local function substituteRomanNumerals(gameName)
    local romans = {
        [" I"] = " 1",
        [" II"] = " 2",
        [" III"] = " 3",
        [" IV"] = " 4",
        [" V"] = " 5",
        [" VI"] = " 6",
        [" VII"] = " 7",
        [" VIII"] = " 8",
        [" IX"] = " 9",
        [" X"] = " 10"
    }

    for numeral, substitution in pairs(romans) do
        if endsWith(gameName, numeral) then
            gameName = string.sub(gameName, 1, -string.len(numeral) - 1) .. substitution
        end
    end

    return gameName
end

local cfcookiessr = ""

local headers = {
	 ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15"
}

local function cfcallback(cookie, url)
if url == "https://steamrip.com/" then
cfcookiessr = cookie
local cfclearence = "cf_clearance=" .. tostring(cfcookiessr)
headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15",
   ["Cookie"] = cfclearence
}
communication.RefreshScriptResults()
end
end

local function webScrape1clickNUC(gameName)
    gameName = substituteRomanNumerals(gameName)
    gameName = gameName:gsub(":", "")
    local searchUrl = "https://steamrip.com/?s=" .. gameName
    searchUrl = searchUrl:gsub(" ", "%%20")

    local responseBody = http.get(searchUrl, headers)

    local gameNames = {}
    local gameLinks = {}

    local gameResultsL = HtmlWrapper.findAttribute(responseBody, "a", "class", "all-over-thumb-link", "href")
    local gameResultsN = HtmlWrapper.findAttribute(responseBody, "h2", "", "", "")
    local gameResults = {}

    for _, link in ipairs(gameResultsL) do
        table.insert(gameLinks, "https://steamrip.com/" .. link)
    end

    for _, name in ipairs(gameResultsN) do
        if name and name ~= "" then
            table.insert(gameNames, name)
        end
    end

    for i = 1, #gameLinks do
        local gameResponseBody = http.get(gameLinks[i], headers)

        if gameResponseBody then
        local version = ""
         local versionPattern = "<li>.-<strong>Version</strong>%s*:%s*(.-)</li>"
    local versionMatch = string.match(gameResponseBody, versionPattern)
    if versionMatch then
        version = string.gsub(versionMatch, "^%s*(.-)%s*$", "%1")
    end
    
    local size = ""
    -- Extract game size
    local sizePattern = "<li>.-<strong>Game Size:%s*</strong>%s*(.-)</li>"
    local sizeMatch = string.match(gameResponseBody, sizePattern)
    if sizeMatch then
        size = string.gsub(sizeMatch, "^%s*(.-)%s*$", "%1")
    end
            local gameResult = {
                name = "[" .. size .. "] " .. gameNames[i],
                links = {},
                tooltip  = "Size: " .. size .. " Version: " .. version,
                ScriptName = "SteamRip-Main"
            }

            local linksDL = HtmlWrapper.findAttribute(gameResponseBody, "a", "class", "shortc-button medium green ",
                "href")
            local linksDL2 = HtmlWrapper.findAttribute(gameResponseBody, "a", "class", "shortc-button medium purple ",
                "href")
            for _, serverLink in ipairs(linksDL) do
                if isGofileLink(serverLink) then
                    local serverName = "Download"
                    watchlink1 = "https:" .. serverLink
                    table.insert(gameResult.links, {
                        name = serverName,
                        link = "https:" .. serverLink,
                        addtodownloadlist = true
                    })
                end
                if isqiwilink(serverLink) then
                    local serverName = "2Clicks Download (kiwi)"
                    watchlink1 = "https:" .. serverLink
                    table.insert(gameResult.links, {
                        name = serverName,
                        link = "https:" .. serverLink,
                        addtodownloadlist = false
                    })
                end
                if isbuzzlink(serverLink) then
                    local serverName = "2Clicks Download (buzz)"
                    watchlink1 = "https:" .. serverLink
                    table.insert(gameResult.links, {
                        name = serverName,
                        link = "https:" .. serverLink,
                        addtodownloadlist = false
                    })
                end
                if ismegadblink(serverLink) then
                    local serverName = "2Clicks Download (megadb)"
                    watchlink1 = "https:" .. serverLink
                    table.insert(gameResult.links, {
                        name = serverName,
                        link = "https:" .. serverLink,
                        addtodownloadlist = false
                    })
                end
            end

            for _, serverLink2 in ipairs(linksDL2) do
                if isGofileLink(serverLink2) then
                    local serverName = "Download"
                    watchlink2 = "https:" .. serverLink2
                    table.insert(gameResult.links, {
                        name = serverName,
                        link = "https:" .. serverLink2,
                        addtodownloadlist = true
                    })
                end
                if isqiwilink(serverLink2) then
                    local serverName = "2Clicks Download (kiwi)"
                    watchlink2 = "https:" .. serverLink2
                    table.insert(gameResult.links, {
                        name = serverName,
                        link = "https:" .. serverLink2,
                        addtodownloadlist = false
                    })
                end
                if isbuzzlink(serverLink2) then
                    local serverName = "2Clicks Download (buzz)"
                    watchlink2 = "https:" .. serverLink2
                    table.insert(gameResult.links, {
                        name = serverName,
                        link = "https:" .. serverLink2,
                        addtodownloadlist = false
                    })
                end
                if ismegadblink(serverLink2) then
                    local serverName = "2Clicks Download (megadb)"
                    watchlink2 = "https:" .. serverLink2
                    table.insert(gameResult.links, {
                        name = serverName,
                        link = "https:" .. serverLink2,
                        addtodownloadlist = false
                    })
                end
            end

            table.insert(gameResults, gameResult)
        else
        end
    end

    return gameResults
end
local version = client.GetVersionDouble()
local defaultdir = "C:/Games"
if version < 6.95 then
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "SteamRip Script Loaded and Working")
    menu.add_input_text("SteamRip Game Dir")
    menu.set_text("SteamRip Game Dir", defaultdir)
    settings.load()
    local function click1NUC()
    if cfcookiessr == nil or cfcookiessr == "" then
        http.CloudFlareSolver("https://steamrip.com/")
    else
        settings.save()
        local gamenameNUC = game.getgamename()
        local resultsNUC = webScrape1clickNUC(gamenameNUC)
        communication.receiveSearchResults(resultsNUC)
        end
    end
    local imagelink = ""
    local gamename = ""
    local gamepath = ""
    local extractpath = ""
    local expectedurl = ""
    local function ondownloadclick(gamejson, downloadurl, scriptname)
        if scriptname == "SteamRip-Main" then
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
            defaultdir = menu.get_text("SteamRip Game Dir") .. "/" .. gamenametopath .. "/"
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
                       Notifications.push_success("2Clicks Script", "Game Successfully Installed!")
                    else
                       GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                       Notifications.push_success("2Clicks Script", "Game Successfully Installed!")
                    end
                else
                    if executables2 and #executables2 >= 1 then
                        local firstExecutable = executables2[1]

                        local gameidl = GameLibrary.GetGameIdFromName(gamename)
                        if gameidl == -1 then
                           local imagePath = Download.DownloadImage(imagelink)
                           GameLibrary.addGame(firstExecutable, imagePath, gamename, "")
                           Notifications.push_success("2Clicks Script", "Game Successfully Installed!")
                        else
                           GameLibrary.changeGameinfo(gameidl, firstExecutable)
                           Notifications.push_success("2Clicks Script", "Game Successfully Installed!")  
                        end
                    end
                end
            end
        end
    end
    client.add_callback("on_scriptselected", click1NUC)
    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_extractioncompleted", onextractioncompleted)
    client.add_callback("on_cfdone", cfcallback)
end























