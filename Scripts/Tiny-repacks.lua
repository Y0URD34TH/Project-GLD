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
        gameName = string.gsub(gameName, numeral, substitution)
    end

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

    local lower_no_symbols = replace_symbol(lower_input, "")
    table.insert(variations, lower_no_symbols)

    local lower_no_symbols_no_roman = replace_symbol(lower_input_no_roman, "")
    table.insert(variations, lower_no_symbols_no_roman)

    local lower_no_symbols_spaces_to_dot = replace_symbol(lower_spaces_to_dot, "")
    table.insert(variations, lower_no_symbols_spaces_to_dot)

    local lower_no_symbols_spaces_to_dot_no_roman = replace_symbol(lower_spaces_to_dot_no_roman, "")
    table.insert(variations, lower_no_symbols_spaces_to_dot_no_roman)

    local lower_no_symbols2 = replace_symbol2(lower_input, "")
    table.insert(variations, lower_no_symbols2)

    local lower_no_symbols_no_roman2 = replace_symbol2(lower_input_no_roman, "")
    table.insert(variations, lower_no_symbols_no_roman2)

    local lower_no_symbols_spaces_to_dot2 = replace_symbol2(lower_spaces_to_dot, "")
    table.insert(variations, lower_no_symbols_spaces_to_dot2)

    local lower_no_symbols_spaces_to_dot_no_roman2 = replace_symbol2(lower_spaces_to_dot_no_roman, "")
    table.insert(variations, lower_no_symbols_spaces_to_dot_no_roman2)

    return variations
end

local function search_game(downloads, game_name, name_script)
    local results = {}
    local variations = generateVariations(game_name)

    for _, download in ipairs(downloads) do
        local lower_title = download.title:lower()
        local lower_title_variations = generateVariations(lower_title)
        local matched = false
        for _, variation in ipairs(variations) do
            if lower_title:find(variation) then
                matched = true
                break
            end
            for _, title_variation in ipairs(lower_title_variations) do
                if title_variation:find(variation) then
                    matched = true
                    break
                end
            end
            if matched then break end
        end

        if matched then
            local patchresult = {
                name = "[" .. download.fileSize .. "] " .. download.title,
                links = {},
                tooltip = "Size: " .. download.fileSize .. " | Upload Date: " .. download.uploadDate,
                ScriptName = name_script
            }
            for index, uri in ipairs(download.uris) do
                table.insert(patchresult.links, { name = "Download Option " .. tostring(index), link = uri, addtodownloadlist = true })       
            end
            table.insert(results, patchresult)
        end
    end

    return results
end

local version = client.GetVersionDouble()

if version < 2.14 then
   Notifications.push_error("Lua Script", "Program is Outdated Please Update to use that Script")
else
local statebool = false

local function requestfromsource()
    local getgamename = game.getgamename()

    local headers = {
     ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    local response = http.get("https://hydralinks.cloud/sources/tinyrepacks.json", headers)  -- Use the dynamic link here
    local gameResults = JsonWrapper.parse(response)["downloads"]
    local scriptname = JsonWrapper.parse(response)["name"]

    local results = search_game(gameResults, getgamename, scriptname)

    communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", requestfromsource)  -- on a game is selected in menu callback
end
