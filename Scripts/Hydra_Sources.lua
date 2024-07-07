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
  for _, download in ipairs(downloads) do
    local lower_title = download.title:lower()
    if lower_title:find(lower_game_name) or lower_title:find(lower_game_name_no_roman) then
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
client.add_callback("on_button_Add Source", onsourceadd)
end
