--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local VERSION = "1.2.3"

-- 🔧 CONFIG → NOW MENU-BASED
menu.add_input_text("PCSX2 EXE Path")
menu.add_input_text("PCSX2 Games Folder")

menu.set_text("PCSX2 EXE Path", "C:/PCSX2/pcsx2-qt.exe")
menu.set_text("PCSX2 Games Folder", "C:/PCSX2/")

settings.load()

local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36",
    ["Accept-Language"] = "en-US,en;q=0.9"
}

-- 🔄 GLOBALS
local gamename = ""
local imagelink = ""
local expectedurl = ""
local downloadedArchive = ""
local extractPathGlobal = ""
local coverImagePath = ""

-- ✅ SIMPLE HTTP fetch
local function getPage(url)
    local res = http.get(url, headers)
    if not res then
        return nil
    end
    return res
end

-- 🔤 CLEAN NAME
local function cleanGameName(gameName)
    local cleaned = gameName:gsub("%s*[%(%).%[%]:]+%s*", " ")
    cleaned = cleaned:gsub("%s+", " ")
    cleaned = cleaned:gsub("^%s+", ""):gsub("%s+$", "")
    return cleaned
end

-- 🔥 IGNORE TRASH FILES
local function isBadFile(name)
    name = name:lower()
    return name:find("bios") or name:find("scph") or name:find("vulkan") or name:find("cache")
end

-- 🔧 NORMALIZE PATH
local function normalizePath(p)
    return p:gsub("\\+", "\\")
end

-- 🔍 FIND GAME FILE (ISO/BIN/etc)
local function findGameFile(directory)
    directory = directory:gsub("/", "\\")
    if not file.exists(directory) then return nil end

    local priority = {".iso", ".bin", ".img", ".mdf", ".nrg", ".cue"}

    local files = file.list_directory(directory)
    if files then
        for _, extWanted in ipairs(priority) do
            for i = 1, #files do
                local fname = files[i]
                local ext = string.lower(file.get_extension(fname) or "")

                if ext == extWanted and not isBadFile(fname) then
                    if fname:match("^[A-Za-z]:\\") then
                        return normalizePath(fname)
                    else
                        return normalizePath(directory .. "\\" .. fname)
                    end
                end
            end
        end
    end

    local folders = file.listfolders(directory)
    if folders then
        for i = 1, #folders do
            local subdir = directory .. "\\" .. folders[i]
            local found = findGameFile(subdir)
            if found then return found end
        end
    end

    return nil
end

-- ✅ BULLETPROOF EXTRACT INFO
local function extractGameInfo(htmlContent)
    local size = htmlContent:match("File size:</strong>%s*([^<\n\r]+)") or "N/A"
    local date = htmlContent:match("Released:</strong>%s*([^<\n\r]+)") or "N/A"

    if size == "N/A" then
        size = htmlContent:match("Tamanho do arquivo:</strong>%s*([^<\n\r]+)") or size
        size = size:gsub("^%s*(.-)%s*$", "%1")
    end
    if date == "N/A" then
        date = htmlContent:match("Lançado:</strong>%s*([^<\n\r]+)") or date
        local jsonDate = htmlContent:match('"datePublished"%s*:%s*"([^"]+)"')
        if jsonDate then date = jsonDate end
        date = date:gsub("^%s*(.-)%s*$", "%1")
    end

    return size, date
end

local function formatSizeDisplay(size)
    if size == "N/A" then return "[?]" end
    return "[" .. size:gsub("%s+", "") .. "]"
end

-- extract mediafire links
local function extractMediaFireLinks(htmlContent)
    local links = {}
    local doc = html.parse(htmlContent)
    local allLinks = doc:css('a[href*="mediafire"]')

    for i = 1, #allLinks do
        local href = allLinks[i]:attr("href")
        if href then
            table.insert(links, {
                name = "Download (Mediafire)",
                link = href,
                addtodownloadlist = true
            })
        end
    end

    return links
end

-- slugify
local function slugifyGameName(gameName)
    local slug = gameName:lower()
    slug = slug:gsub("['`'']", "")
    slug = slug:gsub("[^%w%s-]", "")
    slug = slug:gsub("%s+", "-"):gsub("-+", "-")
    slug = slug:gsub("^-+", ""):gsub("-+$", "")
    return slug
end

-- get game page via slug
local function getGamePageBySlug(gameName)
    local slug = slugifyGameName(gameName)
    local platforms = {"playstation2", "playstation", "playstation3", "psp", "playstation1"}

    for _, platform in ipairs(platforms) do
        local url = "https://psxroms.pro/" .. platform .. "/" .. slug .. "/"
        local response = getPage(url)
        if response and not response:find("404") then
            return url, response
        end
    end

    return nil, nil
end

-- main search
local function searchPSXROMs(gameName)
    local cleanedName = cleanGameName(gameName)
    local results = {}

    local url, response = getGamePageBySlug(cleanedName)

    if url and response then
        local size, date = extractGameInfo(response)
        local links = extractMediaFireLinks(response)

        if #links > 0 then
            local result = {
                name = formatSizeDisplay(size) .. " " .. cleanedName,
                links = {},
                tooltip = size .. " | " .. date,
                ScriptName = "PSXROMs-Main"
            }

            for _, l in ipairs(links) do
                table.insert(result.links, {
                    name = l.name,
                    link = l.link,
                    addtodownloadlist = true
                })
            end

            table.insert(results, result)
        end
    end

    return results
end

-- build PCSX2 args
local function buildPCSX2Args(gameFilePath)
    local normalizedPath = normalizePath(gameFilePath)
    return '-fullscreen -batch -- "' .. normalizedPath .. '"'
end

-- add/update library
local function addGameToLibrary(gameFilePath)
    local args = buildPCSX2Args(gameFilePath)
    local id = GameLibrary.GetGameIdFromName(gamename)

    local pcsx2EXE = menu.get_text("PCSX2 EXE Path")

    if id == -1 then
        GameLibrary.addGame(pcsx2EXE, coverImagePath, gamename, args)
    else
        GameLibrary.changeGameinfo(id, pcsx2EXE, coverImagePath, gamename, args)
    end
end

-- download click
local function ondownloadclick(gamejson, downloadurl, scriptname)
    if scriptname ~= "PSXROMs-Main" then return end

    expectedurl = downloadurl

    local parsed = JsonWrapper.parse(gamejson)
    gamename = parsed.name

    local cover = parsed["cover"] and parsed["cover"]["url"]
    if cover and cover:sub(1,2) == "//" then cover = "https:" .. cover end
    imagelink = cover

    if imagelink and imagelink ~= "" then
        coverImagePath = Download.DownloadImage(imagelink)
    end
end

-- download completed → extract
local function ondownloadcompleted(path, url)
    if url ~= expectedurl then return end

    downloadedArchive = path

    local base = menu.get_text("PCSX2 Games Folder")
    local safeName = gamename:gsub("[^%w%s%-]", ""):gsub("%s+", " ")

    extractPathGlobal = base .. safeName .. "\\"

    zip.extract(path, extractPathGlobal:gsub("\\", "/"), false, "psxroms.pro")
end

-- extraction completed
local function onextractioncompleted(origin, path)
    if origin ~= downloadedArchive then return end

    local extractPath = normalizePath(extractPathGlobal)
    local gameFile = findGameFile(extractPath)

    if gameFile then
        addGameToLibrary(gameFile)
        Notifications.push_success("PSXROMs Script", "Game ready in library: " .. gamename)
    else
        Notifications.push_warning("PSXROMs Script", "No ISO found in extracted folder")
    end
end

-- init
if client.GetVersionDouble() >= 6.95 then
    Notifications.push_success("PSXROMs Script", "Loaded!")

    client.add_callback("on_scriptselected", function()
        local name = game.getgamename()
        local results = searchPSXROMs(name)
        communication.receiveSearchResults(results)
    end)

    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_extractioncompleted", onextractioncompleted)
end





