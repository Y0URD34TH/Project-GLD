--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local version = client.GetVersionDouble()
local function endsWith(str, pattern)
    return string.sub(str, -string.len(pattern)) == pattern
end

function replace_spaces(input, replacement)
    return string.gsub(input, " ", replacement)
end

function replace_symbol(input, replacement)
    return string.gsub(input, "'", replacement)
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
-- Function to search for game names with different transformations
local function search_game(downloads, game_name, name_script)
    local results = {}
    local lower_game_name = game_name:lower()
    local lower_game_name_no_roman = substituteRomanNumerals(lower_game_name)
    local lower_spaces_to_dot = replace_spaces(lower_game_name, ".")
    local lower_spaces_to_dot_no_roman = replace_spaces(lower_game_name_no_roman, ".")
    local lower_no_symbols = replace_symbol(lower_game_name, "")
    local lower_no_symbols_no_roman = replace_symbol(lower_game_name_no_roman, "")
    local lower_no_symbols_spaces_to_dot = replace_symbol(lower_spaces_to_dot, "")
    local lower_no_symbols_spaces_to_dot_no_roman = replace_symbol(lower_spaces_to_dot_no_roman, "")

    for gameKey, gameData in pairs(downloads) do
        local lower_title = gameKey:lower()
        if lower_title:find(lower_game_name) or
           lower_title:find(lower_game_name_no_roman) or
           lower_title:find(lower_spaces_to_dot) or
           lower_title:find(lower_spaces_to_dot_no_roman) or
           lower_title:find(lower_no_symbols_spaces_to_dot_no_roman) or
           lower_title:find(lower_no_symbols_spaces_to_dot) or
           lower_title:find(lower_no_symbols_no_roman) or
           lower_title:find(lower_no_symbols) then

            local downloadsresult = {
                name = "[Game] " .. gameKey,
                links = {},
                ScriptName = name_script
            }

            if gameData["Game Download Links"] then
                for servern, slink in pairs(gameData["Game Download Links"]) do       
                    table.insert(downloadsresult.links, { name = servern, link = slink, addtodownloadlist = false })       
                end
            end

            table.insert(results, downloadsresult)

            if gameData["Patch/Other Download Links"] then
                local patchresult = {
                    name = "[Patch/Other] " .. gameKey,
                    links = {},
                    ScriptName = name_script
                }

                for servern, slink in pairs(gameData["Patch/Other Download Links"]) do       
                    table.insert(patchresult.links, { name = servern, link = slink, addtodownloadlist = false })       
                end

                table.insert(results, patchresult)
            end

            if gameData["Goodies Download Links"] then
                local goodiesresult = {
                    name = "[Goodies] " .. gameKey,
                    links = {},
                    ScriptName = name_script
                }

                for servern, slink in pairs(gameData["Goodies Download Links"]) do       
                    table.insert(goodiesresult.links, { name = servern, link = slink, addtodownloadlist = false })       
                end

                table.insert(results, goodiesresult)
            end
        end
    end

    return results
end
if version < 2.14 then
   Notifications.push_error("Lua Script", "Program is outdated. Please update it to use the script!")
else
   Notifications.push_success("Lua Script", "Gog-games script is loaded and working!")
local statebool = false

local function requestgog()
    local link = "https://raw.githubusercontent.com/qiracy/list/main/gog-games.to.json"
    local getgamename = game.getgamename()

    local headers = {
     ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    local response = http.get(link, headers)
    local gameResults = JsonWrapper.parse(response)

    local results = search_game(gameResults, getgamename, "gog-games[ddl]")

    communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", requestgog)--on a game is selected in menu callback
end
