local version = client.GetVersionDouble()

local function changeFileExtension(fileName, newExtension)
    local name, ext = fileName:match("^(.+)(%..+)$")
    if name and ext then
        return name .. newExtension
    else
        return fileName .. newExtension
    end
end

if version < 4.00 then
   Notifications.push_error("Lua Script", "Program is outdated. Please update it to use the script!")
else
   Notifications.push_success("Lua Script", "Script is loaded and working!")
local statebool = false

    menu.add_input_text("Source link")
    menu.add_button("Add source")

local function onsourceadd()
local sourcelink = menu.get_text("Source link")
if sourcelink ~= "" then
-- Construct the rest of your Lua script
local luaScript = [[local function endsWith(str, pattern)
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
    gameName =substituteRomanNumerals(gameName)

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
    local response = http.get("]] .. sourcelink .. [[", headers)  -- Use the dynamic link here
    local gameResults = JsonWrapper.parse(response)["downloads"]
    local scriptname = JsonWrapper.parse(response)["name"]

    local results = search_game(gameResults, getgamename, scriptname)

    communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", requestfromsource)  -- on a game is selected in menu callback
end
]]
local fileName = Download.GetFileNameFromUrl(tostring(sourcelink))
local newFileName = changeFileExtension("[hydrasource] "..fileName, "")
client.create_script(newFileName, luaScript)
client.load_script(newFileName .. ".lua")
menu.set_text("Source link", "")
Notifications.push_success("Lua Script", "Script for that source has been created!")
end
end
client.add_callback("on_button_Add source", onsourceadd)
end








