--1.16
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end

local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local version = "1.16"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/1337x.lua", headers)

if checkVersion(githubversion, version) then
else
    Notifications.push_warning("Script Outdated", "The Script Is Outdated Please Update")
end

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

local version = client.GetVersion()
if version ~= "V1.02" then
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "1337x Script Loaded and Working")

    menu.add_check_box("Disable Roman Numbers Conversion 1337x")
    local romantonormalnumbers = true

    local function checkboxcall()
        romantonormalnumbers = not menu.get_bool("Disable Roman Numbers Conversion 1337x")
    end

    local function request1337x()
        local gamename = game.getgamename()

        if not gamename then
            print("Error: Failed to retrieve game name.")
            return
        end

        if romantonormalnumbers then
            gamename = substituteRomanNumerals(gamename)
        end

        local urlrequest = "https://www.1377x.to/category-search/" .. tostring(gamename) .. "/Games/1/"
        urlrequest = urlrequest:gsub(" ", "%%20")

        local htmlContent = http.get(urlrequest, headers)
        if not htmlContent then
            print("Error: Failed to retrieve HTML content for URL: " .. urlrequest)
            return
        end

        local results = {}
        local searchResult -- Declare the searchResult variable outside the loop

        for match in htmlContent:gmatch(regex) do
            local url = "https://1377x.to" .. match
            local torrentName = url:match("/([^/]+)/$")
            if not torrentName then
                print("Error: Failed to extract torrent name from URL: " .. url)
                break
            end

            local htmlContent2 = http.get(url, headers)
            if not htmlContent2 then
                print("Error: Failed to retrieve HTML content for URL: " .. url)
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
            print("No results found.")
        end
    end

    client.add_callback("on_gameselected", request1337x) -- Callback when a game is selected in the menu
    client.add_callback("on_present", checkboxcall) -- Callback when a game is selected in the menu
end






