-- to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local VERSION = "1.0.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/%5Bbackup%5D%20SteamRip.lua", VERSION)
local sourcelink = "https://hydralinks.pages.dev/sources/steamrip.json"
local function endsWith(str, pattern)
    return string.sub(str, -string.len(pattern)) == pattern
end

function replace_spaces(input, replacement)
    return string.gsub(input, " ", replacement)
end

function replace_symbol(input, replacement)
    input = string.gsub(input, "'", replacement)
    return string.gsub(input, "’", replacement)
end

function replace_symbol2(input, replacement)
    return string.gsub(input, ":", replacement)
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

local function substituteRomanNumerals(gameName)
    local romans = {
        [" i"] = " 1",
        [" ii"] = " 2",
        [" iii"] = " 3",
        [" iv"] = " 4",
        [" v"] = " 5",
        [" vi"] = " 6",
        [" vii"] = " 7",
        [" viii"] = " 8",
        [" ix"] = " 9",
        [" x"] = " 10"
    }

    for numeral, substitution in pairs(romans) do
        if endsWith(gameName, numeral) then
            gameName = string.sub(gameName, 1, -string.len(numeral) - 1) .. substitution
        end
    end

    return gameName
end
local function substituteRomanNumeralsFromEntireString(gameName)
    local romans = {
        [" i([^a-zA-Z0-9])"] = " 1%1",
        [" ii([^a-zA-Z0-9])"] = " 2%1",
        [" iii([^a-zA-Z0-9])"] = " 3%1",
        [" iv([^a-zA-Z0-9])"] = " 4%1",
        [" v([^a-zA-Z0-9])"] = " 5%1",
        [" vi([^a-zA-Z0-9])"] = " 6%1",
        [" vii([^a-zA-Z0-9])"] = " 7%1",
        [" viii([^a-zA-Z0-9])"] = " 8%1",
        [" ix([^a-zA-Z0-9])"] = " 9%1",
        [" x([^a-zA-Z0-9])"] = " 10%1"
    }

    for numeral, substitution in pairs(romans) do
        gameName = gameName:gsub(numeral, substitution)
    end

    -- Handle cases where Roman numerals are at the beginning or end of the string
    gameName = substituteRomanNumerals(gameName)

    return gameName
end

local function generateVariations(input)
    local variations = {}

    -- Original variations
    table.insert(variations, input)
    local lower_input = input:lower()
    table.insert(variations, lower_input)
    local lower_input_no_roman = substituteRomanNumeralsFromEntireString(lower_input)
    table.insert(variations, lower_input_no_roman)
    local lower_spaces_to_dot = replace_spaces(lower_input, ".")
    table.insert(variations, lower_spaces_to_dot)
    local lower_spaces_to_dot_no_roman = replace_spaces(lower_input_no_roman, ".")
    table.insert(variations, lower_spaces_to_dot_no_roman)
    local lower_spaces_to_dot1 = replace_symbol(lower_input, ".")
    table.insert(variations, lower_spaces_to_dot1)
    local lower_no_symbols = replace_symbol(lower_input, "")
    table.insert(variations, lower_no_symbols)
    local lower_no_symbols_no_roman = replace_symbol(lower_input_no_roman, "")
    table.insert(variations, lower_no_symbols_no_roman)
    local lower_no_symbols_spaces_to_dot = replace_spaces(lower_no_symbols, ".")
    table.insert(variations, lower_no_symbols_spaces_to_dot)
    local lower_no_symbols_spaces_to_dot_no_roman = replace_spaces(lower_no_symbols_no_roman, ".")
    table.insert(variations, lower_no_symbols_spaces_to_dot_no_roman)
    local lower_no_symbols2 = replace_symbol2(lower_input, "")
    table.insert(variations, lower_no_symbols2)
    local lower_no_symbols_no_roman2 = replace_symbol2(lower_input_no_roman, "")
    table.insert(variations, lower_no_symbols_no_roman2)
    local lower_no_symbols_spaces_to_dot2 = replace_spaces(lower_no_symbols2, ".")
    table.insert(variations, lower_no_symbols_spaces_to_dot2)
    local lower_no_symbols_spaces_to_dot_no_roman2 = replace_spaces(lower_no_symbols_no_roman2, ".")
    table.insert(variations, lower_no_symbols_spaces_to_dot_no_roman2)

    -- Additional variations combining existing ones
    -- Combine lower_input_no_roman with lower_spaces_to_dot
    local combined1 = replace_spaces(lower_input_no_roman, ".")
    table.insert(variations, combined1)

    -- Combine lower_no_symbols with lower_no_symbols_no_roman
    local combined2 = replace_symbol(lower_no_symbols, "")
    table.insert(variations, combined2)

    -- Combine lower_no_symbols with replace_symbol2
    local combined22 = replace_symbol2(lower_no_symbols, "")
    table.insert(variations, combined22)

    -- Combine lower_spaces_to_dot with lower_no_symbols_no_roman2
    local combined3 = replace_spaces(lower_spaces_to_dot, "")
    table.insert(variations, combined3)

    -- Combine lower_no_symbols_spaces_to_dot with lower_no_symbols_spaces_to_dot_no_roman2
    local combined4 = replace_spaces(lower_no_symbols_spaces_to_dot, "")
    table.insert(variations, combined4)

    -- Combine lower_no_symbols_no_roman with lower_no_symbols2
    local combined5 = replace_symbol(lower_no_symbols_no_roman, "")
    table.insert(variations, combined5)

    -- Combine lower_no_symbols_no_roman with replace_symbol2
    local combined52 = replace_symbol2(lower_no_symbols_no_roman, "")
    table.insert(variations, combined52)

    -- Combine lower_spaces_to_dot_no_roman with lower_no_symbols_spaces_to_dot2
    local combined6 = replace_spaces(lower_spaces_to_dot_no_roman, "")
    table.insert(variations, combined6)

    -- Combine lower_no_symbols_spaces_to_dot_no_roman with lower_no_symbols_spaces_to_dot_no_roman2
    local combined7 = replace_spaces(lower_no_symbols_spaces_to_dot_no_roman, "")
    table.insert(variations, combined7)

    -- Combine lower_no_symbols_spaces_to_dot_no_roman with lower_no_symbols_spaces_to_dot2
    local combined8 = replace_spaces(lower_no_symbols_spaces_to_dot_no_roman, "")
    table.insert(variations, combined8)

    -- Combine lower_no_symbols_spaces_to_dot with lower_no_symbols_spaces_to_dot_no_roman2
    local combined9 = replace_spaces(lower_no_symbols_spaces_to_dot, "")
    table.insert(variations, combined9)

    -- Combine lower_no_symbols_spaces_to_dot_no_roman with lower_no_symbols_no_roman2
    local combined10 = replace_spaces(lower_no_symbols_spaces_to_dot_no_roman, "")
    table.insert(variations, combined10)

    -- Combine lower_no_symbols_no_roman with lower_no_symbols_spaces_to_dot2
    local combined11 = replace_symbol(lower_no_symbols_no_roman, "")
    table.insert(variations, combined11)

    -- Combine lower_no_symbols_no_roman with replace_symbol2
    local combined112 = replace_symbol2(lower_no_symbols_no_roman, "")
    table.insert(variations, combined112)

    -- Combine lower_no_symbols_spaces_to_dot with lower_no_symbols2
    local combined12 = replace_spaces(lower_no_symbols_spaces_to_dot, "")
    table.insert(variations, combined12)

    -- Combine lower_no_symbols_no_roman2 with lower_no_symbols_spaces_to_dot_no_roman2
    local combined13 = replace_spaces(lower_no_symbols_no_roman2, "")
    table.insert(variations, combined13)

    -- Combine lower_spaces_to_dot with lower_spaces_to_dot_no_roman
    local combined14 = replace_spaces(lower_spaces_to_dot, ".")
    table.insert(variations, combined14)

    -- Combine lower_spaces_to_dot with lower_no_symbols_spaces_to_dot
    local combined15 = replace_spaces(lower_spaces_to_dot, ".")
    table.insert(variations, combined15)

    -- Combine lower_spaces_to_dot with lower_no_symbols_spaces_to_dot_no_roman
    local combined16 = replace_spaces(lower_spaces_to_dot, ".")
    table.insert(variations, combined16)

    -- Combine lower_spaces_to_dot_no_roman with lower_no_symbols_spaces_to_dot_no_roman
    local combined17 = replace_spaces(lower_spaces_to_dot_no_roman, ".")
    table.insert(variations, combined17)

    -- Combine lower_spaces_to_dot_no_roman with lower_no_symbols_spaces_to_dot_no_roman2
    local combined18 = replace_spaces(lower_spaces_to_dot_no_roman, ".")
    table.insert(variations, combined18)

    -- Combine lower_spaces_to_dot_no_roman with lower_no_symbols_spaces_to_dot
    local combined19 = replace_spaces(lower_spaces_to_dot_no_roman, ".")
    table.insert(variations, combined19)

    return variations
end

local function isFrom1Fichier(url)
    return url:find("1fichier") ~= nil
end

local function search_game(downloads, game_name, name_script)
    local results = {}
    local game_name_variations = generateVariations(game_name)

    for _, download in ipairs(downloads) do
        local lower_title = download.title:lower()
        local lower_title_variations = generateVariations(lower_title)

        local add_result = false
        for _, game_variation in ipairs(game_name_variations) do
            for _, title_variation in ipairs(lower_title_variations) do
                if title_variation:find(game_variation, 1, true) then
                    add_result = true
                    break
                end
            end
            if add_result then
                break
            end
        end

        if add_result then
            local patchresult = {
                name = "[" .. download.fileSize .. "] " .. download.title,
                links = {},
                tooltip = "Size: " .. download.fileSize .. " | Upload Date: " .. download.uploadDate,
                ScriptName = name_script
            }
            for index, uri in ipairs(download.uris) do
                if not isFrom1Fichier(uri) then
                    local domain = extractDomain(uri)
                    table.insert(patchresult.links, { name = "Download in " .. domain, link = uri, addtodownloadlist = true })               
                end
            end
            table.insert(results, patchresult)
        end
    end

    return results
end

local version = client.GetVersionDouble()
local defaultdir = "C:/Games"
if version < 6.95 then -- 3.50
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "1click Script Loaded and Working")
    menu.add_input_text("1click Game Dir")
    menu.set_text("1click Game Dir", defaultdir)
    settings.load()
    local function click1NUC()
        settings.save()
        local getgamename = game.getgamename()

        local headers = {
            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }
        local response = http.get(sourcelink, headers) -- Use the dynamic link here
        local gameResults = JsonWrapper.parse(response)["downloads"]
        local scriptname = "1click"

        local results = search_game(gameResults, getgamename, scriptname)

        communication.receiveSearchResults(results)
    end
    local imagelink = ""
    local gamename = ""
    local gamepath = ""
    local extractpath = ""
    local shouldprogressextraction = false
    local function ondownloadclick(gamejson, downloadurl, scriptname)
        shouldprogressextraction = false
        if scriptname == "1click" then
            shouldprogressextraction = true
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
        if shouldprogressextraction then
            local gamenametopath = gamename
            gamenametopath = gamenametopath:gsub(":", "")
            defaultdir = menu.get_text("1click Game Dir") .. "/" .. gamenametopath .. "/"
            -- if url == watchlink2 or url == watchlink1 then
            path = path:gsub("\\", "/")
            pathcheck = path
            zip.extract(path, defaultdir, false)
            -- end
        end
        settings.save()
    end
    local function onextractioncompleted(origin, path)
        if shouldprogressextraction then
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
                       Notifications.push_success("1Click Script", "Game Successfully Installed!")
                    else
                       GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                       Notifications.push_success("1Click Script", "Game Successfully Installed!")
                    end
                else
                    local executables2 = file.listexecutablesrecursive(fullFolderPath) -- Returns a vector
                    if executables2 and #executables2 >= 1 then
                        local firstExecutable = executables2[1]
                        local gameidl = GameLibrary.GetGameIdFromName(gamename)
                        if gameidl == -1 then
                           local imagePath = Download.DownloadImage(imagelink)
                           GameLibrary.addGame(firstExecutable, imagePath, gamename, "")
                           Notifications.push_success("1Click Script", "Game Successfully Installed!")
                        else
                           GameLibrary.changeGameinfo(gameidl, firstExecutable)
                           Notifications.push_success("1Click Script", "Game Successfully Installed!")  
                        end
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
end









