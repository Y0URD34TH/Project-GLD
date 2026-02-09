local VERSION = "1.0.1"
client.auto_script_update(
    "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/Online-Fix.lua",
    VERSION
)

local BASE_URL = "online-fix.me"

local headers = {
    ["User-Agent"] = xor_decrypt("3012071411111C5248534D5D552A141319120A0E5D33295D4C4D534D465D2A14134B49465D054B49545D3C0D0D11182A181F36140952484E4A534E4B5D553635293031515D111416185D3A181E1612545D3E150F121018524C494F534D534D534D5D2E1C1B1C0F1452484E4A534E4B"),
    ["Referer"]   = xor_decrypt("1509090D0E475252121311141318501B140553101852"),
    ["Cookie"]    = xor_decrypt("19111822080E180F22141940484D4C4B4A4548465D191118220D1C0E0E0A120F19404B4A4E4D1E4B4A454F4A1B1B4A18194B1F4C4F48184545444F4A4A454E19481C46")
}

-- Helpers

local function getTorrentFileSize(torrentData)
    if not torrentData or torrentData == "" then return "Unknown" end
    local total = 0
    for size in torrentData:gmatch("6:lengthi(%d+)e") do
        total = total + tonumber(size)
    end
    if total == 0 then return "Unknown" end
    if total < 1024 then return total .. " B" end
    if total < 1024^2 then return string.format("%.2f KB", total / 1024) end
    if total < 1024^3 then return string.format("%.2f MB", total / 1024^2) end
    return string.format("%.2f GB", total / 1024^3)
end

local function torrentToMagnet(torrentUrl)
    local data = http.get(torrentUrl, headers)
    if not data or data == "" then return nil, nil, "Unknown" end
    return Download.TorrentContentToMagnet(data), nil, getTorrentFileSize(data)
end

local function extractVersion(html)
    local patterns = {
        "Версия игры: Build (%d+)",
        "Версия игры: (%d+%.%d+%.%d+)",
        "Build (%d+)",
        "v(%d+%.%d+%.%d+)"
    }
    for _, p in ipairs(patterns) do
        local v = html:match(p)
        if v then return v end
    end
    return ""
end

local function extractUploadDate(html)
    local dt = html:match('datetime="(%d%d%d%d%-%d%d%-%d%d)"')
    return dt or "Unknown"
end

local function getReadableNameFromTorrent(url)
    local name = url:gsub("%?.*$", ""):match("([^/]+%.torrent)$")
    if not name then return "Unknown" end
    return name
        :gsub("%%20", " ")
        :gsub("%%5B", "[")
        :gsub("%%5D", "]")
        :gsub("%%28", "(")
        :gsub("%%29", ")")
        :gsub("%.torrent$", "")
end

-- SEARCH

local function requestOnlineFix()
    local searchName = game.getgamename()
    if not searchName or searchName == "" then return end

    local queryWords = {}
    for word in searchName:lower():gmatch("%w+") do
        table.insert(queryWords, word)
    end
    if #queryWords == 0 then return end

    local results = {}
    local processed = {}

    local searchUrl =
        "https://" .. BASE_URL ..
        "/index.php?do=search&subaction=search&story=" ..
        searchName:gsub(" ", "+")

    local searchHtml = http.get(searchUrl, headers)
    if not searchHtml or searchHtml == "" then
        communication.receiveSearchResults({})
        Notifications.push_warning("Online-Fix", "No results found for \"" .. searchName .. "\"")
        return
    end

    local gamePages = {}
    for url in searchHtml:gmatch('href="([^"]*/games/[^"]*)"') do
        if not url:find("http") then
            url = "https://" .. BASE_URL .. url
        end
        gamePages[url] = true
    end
    
    for gameUrl in pairs(gamePages) do
        local gameHtml = http.get(gameUrl, headers)
        if gameHtml then
            local version = extractVersion(gameHtml)
            local uploadDate = extractUploadDate(gameHtml)

            for folder in gameHtml:gmatch('href="([^"]+/torrents/[^"]*)"') do
                if not folder:find("http") then
                    folder = "https://" .. BASE_URL .. folder
                end

                local folderHtml = http.get(folder, headers)
                if folderHtml then
                    for torrent in folderHtml:gmatch('href="([^"]+%.torrent)"') do
                        if not torrent:find("http") then
                            torrent = folder .. torrent
                        end

                        if not processed[torrent] then
                            processed[torrent] = true

                            local magnet, _, size = torrentToMagnet(torrent)
                            local name = getReadableNameFromTorrent(torrent)

                            -- FILTER
                            local include = false
                            local lowerName = name:lower()
                            for _, word in ipairs(queryWords) do
                                if lowerName:find(word, 1, true) then
                                    include = true
                                    break
                                end
                            end
                            if not include then
                                goto continue
                            end

                            table.insert(results, {
                                name = "[" .. size .. "] " .. name .. (version ~= "" and (" | " .. version) or ""),
                                links = {{
                                    name = magnet and "Download (Magnet)" or "Download Torrent",
                                    link = magnet or torrent,
                                    addtodownloadlist = magnet ~= nil
                                }},
                                ScriptName = "Online-Fix",
                                tooltip =
                                    "Size: " .. size ..
                                    " | Upload Date: " .. uploadDate ..
                                    (version ~= "" and (" | Version: " .. version) or "")
                            })
                        end
                        ::continue::
                    end
                end
            end
        end
    end

    if #results > 0 then
        communication.receiveSearchResults(results)
    else
        communication.receiveSearchResults({})
        Notifications.push_warning("Online-Fix", "No results found for \"" .. searchName .. "\"")
    end
end

-- DOWNLOAD / INSTALL

local imagelink, gamename, expectedurl = "", "", ""
local defaultdir = "C:/Games"
local pathcheck = ""

local function ondownloadclick(gamejson, downloadurl, scriptname)
    if scriptname ~= "Online-Fix" then return end
    expectedurl = downloadurl
    local json = JsonWrapper.parse(gamejson)
    gamename = json.name
    imagelink = json.cover and json.cover.url or ""
    if imagelink:sub(1,2) == "//" then imagelink = "https:" .. imagelink end
    imagelink = imagelink:gsub("t_thumb", "t_cover_big")
end

local function ondownloadcompleted(path, url)
    if url ~= expectedurl then return end
    local safe = gamename:gsub(":", "")
    local target = menu.get_text("OFix Game Dir") .. "/" .. safe .. "/"
    path = path:gsub("\\", "/")
    local archives = file.listcompactedfiles(path)
    if archives and archives[1] then
        local full = path .. "/" .. archives[1]
        pathcheck = full
        zip.extract(full, target, true, "online-fix.me")
    end
    settings.save()
end

local function onextractioncompleted(origin, path)
    if origin ~= pathcheck then return end
    path = path:gsub("/", "\\")
    local folders = file.listfolders(path)
    if not folders or not folders[1] then return end
    local base = path .. "\\" .. folders[1]
    local exe = file.listexecutables(base)
    exe = exe and exe[1] or file.listexecutablesrecursive(base)[1]
    if not exe then return end

    local id = GameLibrary.GetGameIdFromName(gamename)
    if id == -1 then
        GameLibrary.addGame(exe, Download.DownloadImage(imagelink), gamename, "")
    else
        GameLibrary.changeGameinfo(id, exe)
    end
    Notifications.push_success("Online-Fix", "Game Successfully Installed!")
end

-- ======================================================

if client.GetVersionDouble() >= 6.96 then
    menu.add_input_text("OFix Game Dir")
    menu.set_text("OFix Game Dir", defaultdir)

    client.add_callback("on_scriptselected", requestOnlineFix)
    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_extractioncompleted", onextractioncompleted)

    Notifications.push_success("Online-Fix", "Script v" .. VERSION .. " loaded")
end
