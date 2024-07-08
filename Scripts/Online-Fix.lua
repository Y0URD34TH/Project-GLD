local sourcelink = "https://hydralinks.cloud/sources/onlinefix.json"
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

local version = client.GetVersionDouble()

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
  for _, download in ipairs(downloads) do
    local lower_title = download.title:lower()
    if lower_title:find(lower_game_name) or lower_title:find(lower_game_name_no_roman) or lower_title:find(lower_spaces_to_dot) or lower_title:find(lower_spaces_to_dot_no_roman) or lower_title:find(lower_no_symbols_spaces_to_dot_no_roman) or lower_title:find(lower_no_symbols_spaces_to_dot) or lower_title:find(lower_no_symbols_no_roman) or lower_title:find(lower_no_symbols) then
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

if version < 2.14 then
   Notifications.push_error("Lua Script", "Program is outdated. Please update it to use the script!")
else
local statebool = false

local function requestfromsource()
    local getgamename = game.getgamename()

    local headers = {
     ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    local response = http.get(sourcelink, headers)  -- Use the dynamic link here
    local gameResults = JsonWrapper.parse(response)["downloads"]
    local scriptname = JsonWrapper.parse(response)["name"]

    local results = search_game(gameResults, getgamename, scriptname)

    communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", requestfromsource)  -- on a game is selected in menu callback
end
