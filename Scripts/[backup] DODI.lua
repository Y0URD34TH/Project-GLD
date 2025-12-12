--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local VERSION = "1.0.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/%5Bbackup%5D%20DODI.lua", VERSION)
local sourcelink = "https://hydralinks.pages.dev/sources/dodi.json"
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

    gameName = substituteRomanNumerals(gameName)

    return gameName
end

local function generateVariations(input)
    local variations = {}

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

    local combined1 = replace_spaces(lower_input_no_roman, ".")
    table.insert(variations, combined1)
    local combined2 = replace_symbol(lower_no_symbols, "")
    table.insert(variations, combined2)
    local combined22 = replace_symbol2(lower_no_symbols, "")
    table.insert(variations, combined22)
    local combined3 = replace_spaces(lower_spaces_to_dot, "")
    table.insert(variations, combined3)
    local combined4 = replace_spaces(lower_no_symbols_spaces_to_dot, "")
    table.insert(variations, combined4)
    local combined5 = replace_symbol(lower_no_symbols_no_roman, "")
    table.insert(variations, combined5)
    local combined52 = replace_symbol2(lower_no_symbols_no_roman, "")
    table.insert(variations, combined52)
    local combined6 = replace_spaces(lower_spaces_to_dot_no_roman, "")
    table.insert(variations, combined6)
    local combined7 = replace_spaces(lower_no_symbols_spaces_to_dot_no_roman, "")
    table.insert(variations, combined7)
    local combined8 = replace_spaces(lower_no_symbols_spaces_to_dot_no_roman, "")
    table.insert(variations, combined8)
    local combined9 = replace_spaces(lower_no_symbols_spaces_to_dot, "")
    table.insert(variations, combined9)
    local combined10 = replace_spaces(lower_no_symbols_spaces_to_dot_no_roman, "")
    table.insert(variations, combined10)
    local combined11 = replace_symbol(lower_no_symbols_no_roman, "")
    table.insert(variations, combined11)
    local combined112 = replace_symbol2(lower_no_symbols_no_roman, "")
    table.insert(variations, combined112)
    local combined12 = replace_spaces(lower_no_symbols_spaces_to_dot, "")
    table.insert(variations, combined12)
    local combined13 = replace_spaces(lower_no_symbols_no_roman2, "")
    table.insert(variations, combined13)
    local combined14 = replace_spaces(lower_spaces_to_dot, ".")
    table.insert(variations, combined14)
    local combined15 = replace_spaces(lower_spaces_to_dot, ".")
    table.insert(variations, combined15)
    local combined16 = replace_spaces(lower_spaces_to_dot, ".")
    table.insert(variations, combined16)
    local combined17 = replace_spaces(lower_spaces_to_dot_no_roman, ".")
    table.insert(variations, combined17)
    local combined18 = replace_spaces(lower_spaces_to_dot_no_roman, ".")
    table.insert(variations, combined18)
    local combined19 = replace_spaces(lower_spaces_to_dot_no_roman, ".")
    table.insert(variations, combined19)

    return variations
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
                local domain = extractDomain(uri)
                table.insert(patchresult.links, { name = "Download in " .. domain, link = uri, addtodownloadlist = true })
            end
            table.insert(results, patchresult)
        end
    end

    return results
end

local version = client.GetVersionDouble()
if version < 6.95 then
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "Dodi Script Loaded and Working")
    local imagelink = ""
    local gamename = ""
    local gamepath = ""
    local extractpath = ""
    local shouldrunsetup = false
    
    local function requestfromsource()
        local getgamename = game.getgamename()

        local headers = {
         ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
        }
        local response = http.get(sourcelink, headers)
        local gameResults = JsonWrapper.parse(response)["downloads"]
        local scriptname = "Dodi 1"

        local results = search_game(gameResults, getgamename, scriptname)

        communication.receiveSearchResults(results)
    end
    
    local function ondownloadclick(gamejson, downloadurl, scriptname)
        shouldrunsetup = false
        if scriptname == "Dodi 1" then
            shouldrunsetup = true
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
    
       local function setupcompleted(from, destination)
                local executables = file.listexecutables(destination) -- Returns a vector

                -- Get the first executable (assuming executables[1] exists)
                if executables and #executables >= 1 then
                    local firstExecutable = executables[1]

                    local fullExecutablePath = destination .. "\\" .. firstExecutable

                    local gameidl = GameLibrary.GetGameIdFromName(gamename)
                    if gameidl == -1 then
                       local imagePath = Download.DownloadImage(imagelink)
                       GameLibrary.addGame(fullExecutablePath, imagePath, gamename, "")
                       Notifications.push_success("DODI Script", "Game Successfully Installed!")
                    else
                       GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                       Notifications.push_success("DODI Script", "Game Successfully Installed!")
                    end
                else
                    local executables2 = file.listexecutablesrecursive(destination) -- Returns a vector
                    if executables2 and #executables2 >= 1 then
                        local firstExecutable = executables2[1]
                        local gameidl = GameLibrary.GetGameIdFromName(gamename)
                        if gameidl == -1 then
                           local imagePath = Download.DownloadImage(imagelink)
                           GameLibrary.addGame(firstExecutable, imagePath, gamename, "")
                           Notifications.push_success("DODI Script", "Game Successfully Installed!")
                        else
                           GameLibrary.changeGameinfo(gameidl, firstExecutable)
                           Notifications.push_success("DODI Script", "Game Successfully Installed!")  
                        end
                    end
                end
    end
    
    local function ondownloadcompleted(path, url)
        if shouldrunsetup then            
            local gamenametopath = gamename:gsub(":", "")
            path = path:gsub("\\", "/")
            
            local executables = file.listexecutables(path)
            if #executables == 0 then
                Notifications.push_warning("Dodi Script", "No executables found in download folder")
                return
            end           
            
            local setupFound = false
            for _, exe in ipairs(executables) do
                if exe:lower():find("setup") then
                    local setupPath = path .. "/" .. exe
                    exec(setupPath, 5000, "", true, "Setup.tmp")
                    Notifications.push_success("Dodi Script", "Setup.exe launched successfully!")
                    client.add_callback("on_setupcompleted", setupcompleted)
                    setupFound = true
                    break
                end
            end
            
            if not setupFound then
                Notifications.push_warning("Dodi Script", "No valid setup executable found")
            end
        end        
    end
    
    client.add_callback("on_scriptselected", requestfromsource)
    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
end







