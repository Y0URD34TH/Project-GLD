-- to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local VERSION = "1.2.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/SteamRip.lua",
    VERSION)

-- File hosting service detection functions
local function isGofileLink(link)
    return string.find(link, "gofile")
end

local function isVikingFileLink(link)
    -- Support both vikingfile.com and vik1ngfile.site
    return string.find(link, "vikingfile%.com") or string.find(link, "vik1ngfile%.site")
end

local function isQiwiLink(link)
    return string.find(link, "qiwi%.gg")
end

local function isBuzzLink(link)
    return string.find(link, "buzzheavier%.com")
end

local function isMegaDBLink(link)
    return string.find(link, "megadb%.net")
end

local function isMegaUpLink(link)
    return string.find(link, "megaup%.net")
end

local function isMediafireLink(link)
    return string.find(link, "mediafire%.com") or string.find(link, "download%d*%.mediafire%.com")
end

local function isPixeldrainLink(link)
    return string.find(link, "pixeldrain%.com")
end

-- Get display name for file host
local function getFileHostName(link)
    if isGofileLink(link) then
        return "Download (Gofile)"
    elseif isVikingFileLink(link) then
        return "Download (VikingFile)"
    elseif isQiwiLink(link) then
        return "Download (Qiwi)"
    elseif isBuzzLink(link) then
        return "Download (Buzzheavier)"
    elseif isMegaDBLink(link) then
        return "Download (MegaDB)"
    elseif isMegaUpLink(link) then
        return "Download (MegaUp)"
    elseif isMediafireLink(link) then
        return "Download (Mediafire)"
    elseif isPixeldrainLink(link) then
        return "Download (Pixeldrain)"
    else
        return "Download"
    end
end

local function shouldAutoDownload(link)
    return isGofileLink(link) or 
           isMediafireLink(link) or 
           isPixeldrainLink(link) or 
           isVikingFileLink(link) or 
           isQiwiLink(link) or 
           isBuzzLink(link) or 
           isMegaDBLink(link) or 
           isMegaUpLink(link)
end

local function endsWith(str, pattern)
    return string.sub(str, -string.len(pattern)) == pattern
end

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

local headers = {
    ["User-Agent"] =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15"
}


local function webScrapeSteamRip(gameName)
    gameName = substituteRomanNumerals(gameName)
    gameName = gameName:gsub(":", "")
    local searchUrl = "https://steamrip.com/?s=" .. gameName:gsub(" ", "%%20")

    local responseBody = http.get(searchUrl, headers)
    if not responseBody then
        return {}
    end

    local gameResults = {}

    -- Parse search results page
    local searchDoc = html.parse(responseBody)

    -- Find all game card links
    local gameLinks = searchDoc:css('a.all-over-thumb-link')

    -- Find all game titles
    local gameTitles = searchDoc:css('h2')

    -- Build list of game names (filter out empty ones)
    local gameNames = {}
    for i = 1, #gameTitles do
        local titleText = gameTitles[i]:text()
        if titleText and titleText ~= "" then
            -- Clean up whitespace
            titleText = titleText:gsub("^%s*(.-)%s*$", "%1")
            table.insert(gameNames, titleText)
        end
    end

    -- Process each game
    for i = 1, #gameLinks do
        local gameLink = "https://steamrip.com/" .. gameLinks[i]:attr("href")

        if gameLink and gameNames[i] then
            -- Fetch game detail page
            local gameResponseBody = http.get(gameLink, headers)

            if gameResponseBody then
                local gameDoc = html.parse(gameResponseBody)
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
                -- Create game result
                local gameResult = {
                    name = "[" .. size .. "] " .. gameNames[i],
                    links = {},
                    tooltip = "Size: " .. size .. "\nVersion: " .. version,
                    ScriptName = "SteamRip-Main"
                }

                -- Find all download links (green and purple buttons)
                local greenButtons = gameDoc:css('a.shortc-button.medium.green')
                local purpleButtons = gameDoc:css('a.shortc-button.medium.purple')

                -- Process green buttons
                for j = 1, #greenButtons do
                    local href = greenButtons[j]:attr("href")
                    if href then
                        -- Add protocol if missing
                        if href:sub(1, 2) == "//" then
                            href = "https:" .. href
                        end

                        -- Check which file host and add appropriate link
                        if isGofileLink(href) or isVikingFileLink(href) or isQiwiLink(href) or
                            isBuzzLink(href) or isMegaDBLink(href) or isMegaUpLink(href) or
                            isMediafireLink(href) or isPixeldrainLink(href) then
                            table.insert(gameResult.links, {
                                name = getFileHostName(href),
                                link = href,
                                addtodownloadlist = shouldAutoDownload(href)
                            })
                        end
                    end
                end

                -- Process purple buttons
                for j = 1, #purpleButtons do
                    local href = purpleButtons[j]:attr("href")
                    if href then
                        -- Add protocol if missing
                        if href:sub(1, 2) == "//" then
                            href = "https:" .. href
                        end

                        -- Check which file host and add appropriate link
                        if isGofileLink(href) or isVikingFileLink(href) or isQiwiLink(href) or
                            isBuzzLink(href) or isMegaDBLink(href) or isMegaUpLink(href) or
                            isMediafireLink(href) or isPixeldrainLink(href) then
                            table.insert(gameResult.links, {
                                name = getFileHostName(href),
                                link = href,
                                addtodownloadlist = shouldAutoDownload(href)
                            })
                        end
                    end
                end

                -- Only add if we found links
                if #gameResult.links > 0 then
                    table.insert(gameResults, gameResult)
                end
            end
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

    local function searchSteamRip()
        settings.save()
        local gamename = game.getgamename()
        local results = webScrapeSteamRip(gamename)
        communication.receiveSearchResults(results)
    end

    local imagelink = ""
    local gamename = ""
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
            local installDir = menu.get_text("SteamRip Game Dir") .. "/" .. gamenametopath .. "/"
            path = path:gsub("\\", "/")
            pathcheck = path
            zip.extract(path, installDir, false)
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
                        Notifications.push_success("SteamRip Script", "Game Successfully Installed!")
                    else
                        GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                        Notifications.push_success("SteamRip Script", "Game Successfully Installed!")
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
                            Notifications.push_success("SteamRip Script", "Game Successfully Installed!")
                        else
                            GameLibrary.changeGameinfo(gameidl, firstExecutable)
                            Notifications.push_success("SteamRip Script", "Game Successfully Installed!")
                        end
                    end
                end
            end
        end
    end

    -- Register all callbacks
    client.add_callback("on_scriptselected", searchSteamRip)
    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_extractioncompleted", onextractioncompleted)
end
