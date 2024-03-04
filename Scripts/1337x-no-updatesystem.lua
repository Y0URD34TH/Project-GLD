--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.MD
local cfcookies = ""
local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local headers2 = {
}

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

local regex = ""
local magnetRegex = "href%s*=%s*\"(magnet:[^\"]+)\""
local provider = 0
local searchprovider = ""
local version = client.GetVersionDouble()

if version < 3.52 then
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "1337x Script Loaded and Working")


    menu.add_combo_box("1337x Provider(1)", { "original", "2nd original", "mirror", "2nd mirror", "onion" })
	menu.add_check_box("Roman Numbers Conversion 1337x-NS")
    local romantonormalnumbers = true
    menu.set_bool("Roman Numbers Conversion 1337x-NS", true)

    local function checkboxcallNUC()
        provider = menu.get_int("1337x Provider(1)")
        if provider == 0 then
          regex = "<a href%s*=%s*\"(/torrent/[^\"]+)\""
          searchprovider = "1337x.to"
        end
        if provider == 1 then
          regex = "<a href%s*=%s*\"(/torrent/[^\"]+)\""
          searchprovider = "x1337x.ws"
        end
        if provider == 2 then
          regex = "<a href%s*=%s*\"(/torrent/[^\"]+)\""
          searchprovider = "1377x.to"
        end
        if provider == 3 then
          regex = "<a href%s*=%s*\"(/torrent/[^\"]+)\""
          searchprovider = "1337xx.to"
        end
        if provider == 4 then
          regex = "<a href%s*=%s*\"(//l337xdarkkaqfwzntnfk5bmoaroivtl6xsbatabvlb52umg6v3ch44yd.onion.ly/torrent/[^\"]+)\""
          searchprovider = "l337xdarkkaqfwzntnfk5bmoaroivtl6xsbatabvlb52umg6v3ch44yd.onion.ly"
        end
        romantonormalnumbers = menu.get_bool("Roman Numbers Conversion 1337x-NS")
    end
local function cfcallback(cookie, url)
if url == "https://".. searchprovider then
cfcookies = cookie
local cfclearence = "cf_clearance=" .. tostring(cfcookies)
headers2 = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15",
    ["Cookie"] = cfclearence
}

communication.RefreshScriptResults()
end
end
    local function request1337xNUC()
        if provider == 0 or provider == 1 then
        if cfcookies == nil or cfcookies == "" then
        http.CloudFlareSolver("https://".. searchprovider)
        else
        local gamename = game.getgamename()

        if not gamename then
            return
        end

        if romantonormalnumbers then
            gamename = substituteRomanNumerals(gamename)
        end

        local urlrequest = "https://" .. searchprovider .. "/category-search/" .. tostring(gamename) .. "/Games/1/"
        urlrequest = urlrequest:gsub(" ", "%%20")
        local htmlContent = http.get(urlrequest, headers2)

        if not htmlContent then
            return
        end

        local results = {}
        local searchResult -- Declare the searchResult variable outside the loop

        for match in htmlContent:gmatch(regex) do
       local url = ""
        if provider == 4 then
            url = "https:" .. match
        else
            url = "https://" .. searchprovider .. match
        end
            local torrentName = url:match("/([^/]+)/$")
            if not torrentName then
                break
            end

            local htmlContent2 = http.get(url, headers2)
            if not htmlContent2 then
                break
            end

            searchResult = {
                name = torrentName,
                links = {},
                ScriptName = "1337x2"
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
        else
        local gamename = game.getgamename()

        if not gamename then
            return
        end

        if romantonormalnumbers then
            gamename = substituteRomanNumerals(gamename)
        end

        local urlrequest = "https://" .. searchprovider .. "/category-search/" .. tostring(gamename) .. "/Games/1/"
        urlrequest = urlrequest:gsub(" ", "%%20")
        local htmlContent = http.get(urlrequest, headers)
        if not htmlContent then
            return
        end

        local results = {}
        local searchResult -- Declare the searchResult variable outside the loop

        for match in htmlContent:gmatch(regex) do
       local url = ""
        if provider == 4 then
            url = "https:" .. match
        else
            url = "https://" .. searchprovider .. match
        end
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
                ScriptName = "1337x2"
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
end

    client.add_callback("on_scriptselected", request1337xNUC) -- Callback when a game is selected in the menu
    client.add_callback("on_present", checkboxcallNUC)
    client.add_callback("on_cfdone", cfcallback)
end






























































