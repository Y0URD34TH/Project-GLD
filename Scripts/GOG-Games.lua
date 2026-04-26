local VERSION = "1.0.3"
client.auto_script_update(
    "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/GOG-Games.lua",
    VERSION
)

local BASE_API = "https://gog-games.to/api/web"

local TRACKERS = table.concat({
    "udp://tracker.opentrackr.org:1337/announce",
    "udp://exodus.desync.com:6969/announce",
    "udp://open.stealth.si:80/announce",
    "udp://tracker-udp.gbitt.info:80/announce",
}, "&tr=")

local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15",
    ["Accept"]     = "application/json",
}


local function formatSize(bytes)
    local b = tonumber(bytes)
    if not b then return "Unknown" end
    if b >= 1073741824 then return string.format("%.2f GB", b / 1073741824) end
    if b >= 1048576    then return string.format("%.2f MB", b / 1048576) end
    return string.format("%.2f KB", b / 1024)
end

local function infohashToMagnet(infohash, title)
    if not infohash or infohash == "" then return nil end
    local enc = title:gsub("([^%w%-%.%_%~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    return "magnet:?xt=urn:btih:" .. infohash:lower()
        .. "&dn=" .. enc
        .. "&tr=" .. TRACKERS
end

local function slugFromName(name)
    return name:lower():gsub("[^%w%s]", ""):gsub("%s+", "_")
end

local function scrapeFilehostLinks(slug)
    local links = {}
    local pageHeaders = {
        ["User-Agent"] = headers["User-Agent"],
        ["Referer"]    = "https://gog-games.to/",
    }
    local source = http.get("https://gog-games.to/game/" .. slug, pageHeaders)
    if not source or #source < 200 then return links end
    local doc = html.parse(source)
    local filehosts = {
        "gofile.io", "1fichier.com", "pixeldrain.com",
        "buzzheavier.com", "datanodes.to", "mediafire.com", "mega.nz",
    }
    for _, a in ipairs(doc:css("a[href]")) do
        local href = a:attr("href") or ""
        for _, host in ipairs(filehosts) do
            if href:find(host, 1, true) then
                local label = (a:text() or ""):match("^%s*(.-)%s*$")
                if label == "" then label = host end
                table.insert(links, { link = href, name = label, addtodownloadlist = false })
                break
            end
        end
    end
    return links
end

-- Skip helper/system exes, return the real game exe
local function findGameExe(exeList, basePath)
    local skipPatterns = {
        "unins", "uninst", "crashreport", "support",
        "helper", "redist", "vcredist", "dxsetup", "setup",
    }
    for _, exe in ipairs(exeList) do
        local lower = exe:lower()
        local skip = false
        for _, pat in ipairs(skipPatterns) do
            if lower:find(pat) then skip = true; break end
        end
        if not skip then
            return basePath and (basePath .. "\\" .. exe) or exe
        end
    end
    if exeList[1] then
        return basePath and (basePath .. "\\" .. exeList[1]) or exeList[1]
    end
    return nil
end

-- Search common GOG install locations for a game folder matching the name
local function findInstalledGameExe(gname)
    local searchName = gname:lower():gsub("[^%w%s]", ""):gsub("%s+", " "):match("^%s*(.-)%s*$")
    local searchDirs = {
        "C:\\GOG Games",
        "C:\\Games",
        "C:\\Program Files\\GOG Games",
        "C:\\Program Files (x86)\\GOG Games",
        "D:\\GOG Games",
        "D:\\Games",
    }

    for _, dir in ipairs(searchDirs) do
        local folders = file.listfolders(dir)
        if folders then
            for _, folder in ipairs(folders) do
                local folderLower = folder:lower():gsub("[^%w%s]", ""):gsub("%s+", " "):match("^%s*(.-)%s*$")
                -- Check if folder name loosely matches game name
                local firstWord = searchName:match("^(%w+)")
                if firstWord and folderLower:find(firstWord, 1, true) then
                    local fullFolder = dir .. "\\" .. folder
                    local exes = file.listexecutables(fullFolder)
                    if exes and #exes >= 1 then
                        local exePath = findGameExe(exes, fullFolder)
                        if exePath then return exePath end
                    end
                    local exes2 = file.listexecutablesrecursive(fullFolder)
                    if exes2 and #exes2 >= 1 then
                        return findGameExe(exes2, nil)
                    end
                end
            end
        end
    end
    return nil
end


local expectedurl      = ""
local imagelink        = ""
local gamename         = ""
local installerProcess = nil   -- exe filename being watched (e.g. "setup_rimworld_(...).exe")
local watchingInstall  = false
local pollTick         = 0


if client.GetVersionDouble() < 2.14 then
    Notifications.push_error("GOG-Games", "Program is outdated. Please update GLD!")
else
    Notifications.push_success("GOG-Games", "GOG-Games Script v" .. VERSION .. " Loaded")

    -- Poll tasklist every ~120 frames; when installer process is gone, find + add game exe
    client.add_callback("on_present", function()
        if not watchingInstall or not installerProcess then return end

        pollTick = pollTick + 1
        if pollTick < 120 then return end  -- check roughly every 2 seconds
        pollTick = 0

        local tasklist = system_output("tasklist /FI \"IMAGENAME eq " .. installerProcess .. "\" /NH 2>NUL")
        if tasklist and tasklist:find(installerProcess, 1, true) then
            return  -- still running
        end

        -- Installer finished
        watchingInstall  = false
        installerProcess = nil

        sleep(3000)  -- give it a moment to finish writing files

        local exePath = findInstalledGameExe(gamename)
        if not exePath then
            Notifications.push_warning("GOG-Games", "Game installed but exe not found automatically. Please add manually.")
            return
        end

        local id = GameLibrary.GetGameIdFromName(gamename)
        if id == -1 then
            GameLibrary.addGame(exePath, Download.DownloadImage(imagelink), gamename, "")
        else
            GameLibrary.changeGameinfo(id, exePath)
        end
        Notifications.push_success("GOG-Games", "Game Successfully Installed!")
    end)

    local function scraper()
        local gname = game.getgamename()
        local slug  = slugFromName(gname)
        local results = {}

        local response = http.get(BASE_API .. "/query-game/" .. slug, headers)
        if not response or response == "" then
            Notifications.push_warning("GOG-Games", "No response from API for: " .. gname)
            communication.receiveSearchResults({})
            return
        end

        local ok, data = pcall(function() return JsonWrapper.parse(response) end)
        if not ok or not data or not data["game_info"] then
            Notifications.push_warning("GOG-Games", "Game not found: " .. gname)
            communication.receiveSearchResults({})
            return
        end

        local info  = data["game_info"]
        local files = data["files"] or {}
        local title = info["title"] or gname

        if #files == 0 then
            Notifications.push_warning("GOG-Games", "No files available for: " .. title)
            communication.receiveSearchResults({})
            return
        end

        local totalSize = 0
        for _, f in ipairs(files) do
            if f["type"] == "game" then
                totalSize = totalSize + (tonumber(f["size"]) or 0)
            end
        end
        local sizeStr = totalSize > 0 and formatSize(totalSize) or "Unknown"

        local coverUrl = ""
        if info["image"] and info["image"] ~= "" then
            coverUrl = "https://gog-games.to/image/game/cover/" .. info["image"]
        end

        local searchResult = {
            name       = "[" .. sizeStr .. "] " .. title,
            links      = {},
            tooltip    = "Size: " .. sizeStr .. " | Dev: " .. (info["developer"] or "?"),
            ScriptName = "GOG-Games",
            imageurl   = coverUrl,
        }

        local magnet = infohashToMagnet(info["infohash"], title)
        if magnet then
            table.insert(searchResult.links, {
                link              = magnet,
                name              = "Torrent [" .. sizeStr .. "]",
                addtodownloadlist = true,
            })
        end

        if #searchResult.links == 0 then
            Notifications.push_warning("GOG-Games", "No torrent available for: " .. title)
            communication.receiveSearchResults({})
            return
        end

        for _, fl in ipairs(scrapeFilehostLinks(slug)) do
            table.insert(searchResult.links, fl)
        end

        table.insert(results, searchResult)
        communication.receiveSearchResults(results)
        Notifications.push_success("GOG-Games", "Found: " .. title .. " (" .. #searchResult.links .. " links)")
    end

    local function ondownloadclick(gamejson, downloadurl, scriptname)
        if scriptname ~= "GOG-Games" then return end
        expectedurl = downloadurl
        local json = JsonWrapper.parse(gamejson)
        local coverImageUrl = json["cover"]["url"]
        if coverImageUrl and coverImageUrl:sub(1, 2) == "//" then
            coverImageUrl = "https:" .. coverImageUrl
        end
        if coverImageUrl then
            coverImageUrl = coverImageUrl:gsub("t_thumb", "t_cover_big")
        end
        gamename  = json.name
        imagelink = coverImageUrl
    end

    local function ondownloadcompleted(path, url)
        if expectedurl ~= url then return end
        path = path:gsub("\\", "/")

        local executables = file.listexecutables(path)
        if not executables or #executables == 0 then
            Notifications.push_warning("GOG-Games", "No executables found in download folder")
            return
        end

        local exeName = executables[1]
        local setupPath = (path .. "/" .. exeName):gsub("/", "\\")

        file.exec(setupPath, 0)
        Notifications.push_success("GOG-Games", "Installer launched! Waiting for it to finish...")

        -- Start watching for the process to exit
        installerProcess = exeName
        watchingInstall  = true
        pollTick         = 0
    end

    client.add_callback("on_scriptselected",    scraper)
    client.add_callback("on_downloadclick",     ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
end

