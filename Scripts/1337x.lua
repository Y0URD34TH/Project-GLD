--1.18
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end

local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local version = "1.18"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/1337x.lua", headers)
local outdated = false
if checkVersion(githubversion, version) then
outdated = false
else
outdated = true
    Notifications.push_warning("Script Outdated", "The Script Is Outdated Please Update")
end

local scriptsfolder = client.GetScriptsPath()

local function endsWith(str, pattern)
    return string.sub(str, -string.len(pattern)) == pattern
end

local function substituteRomanNumerals(gameName)
    local romans = {
        [" I"] = " 1",
        [" II"] = " 2",
        [" III"] = " 3",
        [" IV"] = " 4",
        [" V"] = " 5",
        [" VI"] = " 6",
        [" VII"] = " 7",
        [" VIII"] = " 8",
        [" IX"] = " 9",
        [" X"] = " 10"
    }

    for numeral, substitution in pairs(romans) do
        if endsWith(gameName, numeral) then
            gameName = string.sub(gameName, 1, -string.len(numeral) - 1) .. substitution
        end
    end

    return gameName
end

local regex = "<a href%s*=%s*\"(/torrent/[^\"]+)\""
local magnetRegex = "href%s*=%s*\"(magnet:[^\"]+)\""
local provider = 0
local searchprovider = ""
local version = client.GetVersionDouble()

if version < 2.14 then
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
	if outdated then 
	menu.add_button("Update 1337x")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/1337x.lua", scriptsfolder .. "1337x.lua")
	   client.unload_script("1337x.lua")
	   client.load_script("1337x.lua")
    end
	client.add_callback("on_button_Update 1337x", updatebutton)
	end
else
    Notifications.push_success("Lua Script", "1337x Script Loaded and Working")

    if outdated then 
	menu.add_button("Update 1337x")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/1337x.lua", scriptsfolder .. "1337x.lua")
	   client.unload_script("1337x.lua")
	   client.load_script("1337x.lua")
    end
	client.add_callback("on_button_Update 1337x", updatebutton)
	end
	menu.add_combo_box("1337x Provider(2)", { "1337x.to", "1377x.to", "1337x.so", "1337x.st" , "x1337x.ws", "x1337x.eu", "x1337x.se" })
    menu.add_check_box("Roman Numbers Conversion 1337x")
    local romantonormalnumbers = true
    menu.set_bool("Roman Numbers Conversion 1337x", true)

    local function checkboxcall()
	    provider = menu.get_int("1337x Provider(2)")
        if provider == 0 then
          searchprovider = "1337x.to"
        end
        if provider == 1 then
          searchprovider = "1377x.to"
        end
        if provider == 2 then
          searchprovider = "1337x.so"
        end
        if provider == 3 then
          searchprovider = "1337x.st"
        end
        if provider == 4 then
          searchprovider = "x1337x.ws"
        end
        if provider == 5 then
          searchprovider = "x1337x.eu"
        end
        if provider == 6 then
          searchprovider = "x1337x.se"
        end
        romantonormalnumbers = menu.get_bool("Roman Numbers Conversion 1337x")
    end

    local function request1337x()
        local gamename = game.getgamename()

        if not gamename then
            return
        end

        if romantonormalnumbers then
            gamename = substituteRomanNumerals(gamename)
        end

        local urlrequest = "https://www." .. searchprovider .. "/category-search/" .. tostring(gamename) .. "/Games/1/"
        urlrequest = urlrequest:gsub(" ", "%%20")

        local htmlContent = http.get(urlrequest, headers)
        if not htmlContent then
            return
        end

        local results = {}
        local searchResult -- Declare the searchResult variable outside the loop

        for match in htmlContent:gmatch(regex) do
            local url = "https://" .. searchprovider .. match
            local torrentName = url:match("/([^/]+)/$")
            if not torrentName then
                break
            end

            local htmlContent2 = http.get(url, headers)
            if not htmlContent2 then
                break
            end

            searchResult = {
                name = torrentName,
                links = {},
                ScriptName = "1337x"
            }

            for magnetMatch in htmlContent2:gmatch(magnetRegex) do
                searchResult.links[#searchResult.links + 1] = {
                    name = "Download",
                    link = magnetMatch,
                    addtodownloadlist = true
                }
                -- No need to continue the loop if a magnet link is found
                break
            end

            if next(searchResult.links) == nil then
                searchResult.links[#searchResult.links + 1] = {
                    name = "Download",
                    link = url
                }
            end

            results[#results + 1] = searchResult
        end

        if next(results) ~= nil then
            communication.receiveSearchResults(results)
        else
            print("Results Search", "No results found.")
        end
    end

    client.add_callback("on_scriptselected", request1337x) -- Callback when a game is selected in the menu
    client.add_callback("on_present", checkboxcall) -- Callback when a game is selected in the menu
end


















