local VERSION = "1.0.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/Online-Fix.lua", VERSION)

local BASE_URL = "online-fix.me"

local headers = {
    ["User-Agent"] = xor_decrypt("3012071411111C5248534D5D552A141319120A0E5D33295D4C4D534D465D2A14134B49465D054B49545D3C0D0D11182A181F36140952484E4A534E4B5D553635293031515D111416185D3A181E1612545D3E150F121018524C494F534D534D534D5D2E1C1B1C0F1452484E4A534E4B"),
    ["Referer"] = xor_decrypt("1509090D0E475252121311141318501B140553101852"),
    ["Cookie"] = xor_decrypt("19111822080E180F22141940484D4C4B4A4548465D191118220D1C0E0E0A120F19404B4A4E4D1E4B4A454F4A1B1B4A18194B1F4C4F48184545444F4A4A454E19481C46")
}

-- Function to parse bencode and get file size from torrent data
local function getTorrentFileSize(torrentData)
    if not torrentData or torrentData == "" then
        return "Unknown"
    end

    local totalBytes = 0

    -- Find ALL occurrences of 6:lengthi<number>e
    for size in torrentData:gmatch("6:lengthi(%d+)e") do
        totalBytes = totalBytes + tonumber(size)
    end

    if totalBytes == 0 then
        return "Unknown"
    end

    -- Convert bytes to readable format
    if totalBytes < 1024 then
        return string.format("%.0f B", totalBytes)
    elseif totalBytes < 1024 * 1024 then
        return string.format("%.2f KB", totalBytes / 1024)
    elseif totalBytes < 1024 * 1024 * 1024 then
        return string.format("%.2f MB", totalBytes / (1024 * 1024))
    else
        return string.format("%.2f GB", totalBytes / (1024 * 1024 * 1024))
    end
end

-- Function to convert torrent file to magnet
local function torrentToMagnet(torrentUrl)
    local torrentData = http.get(torrentUrl, headers)
    
    if not torrentData or torrentData == "" then
        return nil, "Failed to download torrent file", "Unknown"
    end
    
    local fileSize = getTorrentFileSize(torrentData)
    local magnetLink = Download.TorrentContentToMagnet(torrentData)
    
    return magnetLink, nil, fileSize
end

-- Function to extract version from game page
local function extractVersion(gameHtml)
    -- Try multiple patterns for version extraction
    local patterns = {
        "Версия игры: Build (%d+)",
        "Версия игры: (%d+%.%d+%.%d+)",
        "Версия игры: v(%d+%.%d+%.%d+)",
        "Версия: Build (%d+)",
        "Build (%d+)",
        "v(%d+%.%d+%.%d+)"
    }
    
    for _, pattern in ipairs(patterns) do
        local version = gameHtml:match(pattern)
        if version then
            return version
        end
    end
    
    return ""
end

-- Function to extract upload date
local function extractUploadDate(gameHtml)
    -- Try to find the last update date
    local patterns = {
        "Обновлено: <time datetime=\"([^\"]+)\">",
        "<time datetime=\"([^\"]+)\">(%d+%s+%w+%s+%d+)",
        "datetime=\"([^\"]+)\""
    }
    
    for _, pattern in ipairs(patterns) do
        local datetime, displayDate = gameHtml:match(pattern)
        if datetime then
            -- Extract just the date part (YYYY-MM-DD)
            local date = datetime:match("(%d%d%d%d%-%d%d%-%d%d)")
            if date then
                return date
            end
        end
    end
    
    return "Unknown"
end

local function requestOnlineFix()
    local gamename = game.getgamename()
    if not gamename or gamename == "" then 
        return 
    end

    -- Initial Search
    local searchUrl = "https://" .. BASE_URL .. "/index.php?do=search&subaction=search&story=" .. gamename:gsub(" ", "+")
    local searchHtml = http.get(searchUrl, headers)
    
    if not searchHtml or searchHtml == "" then 
        return 
    end

    -- Extract Game Page URL
    local gameUrlMatch = searchHtml:match('href="([^"]*/games/[^"]*)"')
    if not gameUrlMatch then 
        return 
    end

    local finalGameUrl = gameUrlMatch
    if not finalGameUrl:find("http") then
        finalGameUrl = "https://" .. BASE_URL .. gameUrlMatch
    end

    -- Get the game page
    local gameHtml = http.get(finalGameUrl, headers)
    if not gameHtml or gameHtml == "" then 
        return 
    end
    
    -- Extract version and upload date from game page
    local version = extractVersion(gameHtml)
    local uploadDate = extractUploadDate(gameHtml)
    
    local results = {}
    local foundLinks = 0
    local processedTorrents = {}

    -- Extract all links from the page
    for link in gameHtml:gmatch('href="([^"]+)"') do
        -- Check for torrent folders
        if link:find("/torrents/") and link:find("http") then
            local folderHtml = http.get(link, headers)
            if folderHtml then
                -- Look for .torrent file links
                for torrentFile in folderHtml:gmatch('href="([^"]*%.torrent)"') do
                    -- Avoid duplicates
                    if not processedTorrents[torrentFile] then
                        processedTorrents[torrentFile] = true
                        
                        -- Make sure URL is absolute
                        if not torrentFile:find("http") then
                            torrentFile = link .. torrentFile
                        end
                        
                        foundLinks = foundLinks + 1
                        
                        -- Try to convert to magnet and get file size
                        local magnetLink, err, fileSize = torrentToMagnet(torrentFile)
                        
                        local downloadInfo = {
                            title = gamename,
                            fileSize = fileSize,
                            uploadDate = uploadDate,
                            version = version
                        }
                        
                        if magnetLink and magnetLink:find("magnet:") then
                            table.insert(results, {
                                name = "[" .. downloadInfo.fileSize .. "] " .. downloadInfo.title .. " " .. downloadInfo.version,
                                links = {{
                                    name = "Download",
                                    link = magnetLink,
                                    addtodownloadlist = true
                                }},
                                ScriptName = "Online-Fix",
                                tooltip = "Size: " .. downloadInfo.fileSize .. " | Upload Date: " .. downloadInfo.uploadDate .. " | Version: " .. downloadInfo.version
                            })
                        else
                            -- Fallback to torrent file
                            table.insert(results, {
                                name = "[" .. downloadInfo.fileSize .. "] " .. downloadInfo.title .. " " .. downloadInfo.version,
                                links = {{
                                    name = "Download Torrent",
                                    link = torrentFile,
                                    addtodownloadlist = false
                                }},
                                ScriptName = "Online-Fix",
                                tooltip = "Size: " .. downloadInfo.fileSize .. " | Upload Date: " .. downloadInfo.uploadDate .. " | Version: " .. downloadInfo.version
                            })
                        end
                    end
                end
            end
        end
    end

    -- Send results to GLD
    if #results > 0 then
        communication.receiveSearchResults(results)
     end
end
 local imagelink = ""
    local gamename = ""
    local gamepath = ""
    local extractpath = ""
    local expectedurl = ""
    local defaultdir = "C:/Games"
    local function ondownloadclick(gamejson, downloadurl, scriptname)
        if scriptname == "Online-Fix" then
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
            defaultdir = menu.get_text("OFix Game Dir") .. "/" .. gamenametopath .. "/"
            -- if url == watchlink2 or url == watchlink1 then
            path = path:gsub("\\", "/")       
            local zipfiles = file.listcompactedfiles(path) -- Returns a vector

                -- Get the first executable (assuming executables[1] exists)
            if zipfiles and #zipfiles >= 1 then
                 local firstcompactedfile = zipfiles[1]
                 local fullextractionpath = path .. "/" .. firstcompactedfile
                 pathcheck = fullextractionpath
                 zip.extract(fullextractionpath, defaultdir, true, "online-fix.me")
            end
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
                       Notifications.push_success("Online-Fix Script", "Game Successfully Installed!")
                    else
                       GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                       Notifications.push_success("Online-Fix Script", "Game Successfully Installed!")
                    end
                else
                    local executables2 = file.listexecutablesrecursive(fullFolderPath) -- Returns a vector
                    if executables2 and #executables2 >= 1 then
                        local firstExecutable = executables2[1]
                        local gameidl = GameLibrary.GetGameIdFromName(gamename)
                        if gameidl == -1 then
                           local imagePath = Download.DownloadImage(imagelink)
                           GameLibrary.addGame(firstExecutable, imagePath, gamename, "")
                           Notifications.push_success("Online-Fix Script", "Game Successfully Installed!")
                        else
                           GameLibrary.changeGameinfo(gameidl, firstExecutable)
                           Notifications.push_success("Online-Fix Script", "Game Successfully Installed!")  
                        end
                    end
                end
            end
        end
    end
-- Register the callback for when script is selected in search
if client.GetVersionDouble() >= 6.96 then
    menu.add_input_text("OFix Game Dir")
    menu.set_text("OFix Game Dir", defaultdir)
    client.add_callback("on_scriptselected", requestOnlineFix)
    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_extractioncompleted", onextractioncompleted)
    Notifications.push_success("Online-Fix", "Script v" .. VERSION .. " loaded")
end

