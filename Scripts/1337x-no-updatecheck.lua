local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
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

local regex = "<a href%s*=%s*\"(/torrent/[^\"]+)\""
local magnetRegex = "href%s*=%s*\"(magnet:[^\"]+)\""

local statebool = true

 local version = client.GetVersion()
 if version ~= "V1.00" then
  Notifications.push_error("Lua Script", "Program is Outdated Please Update to use that Script")
else
  Notifications.push_success("Lua Script", "1337x Script Loaded And Working")

menu.add_check_box("Disable Roman Numbers Conversion")
local romantonormalnumbers = true

local function checkboxstate()
if menu.get_bool("Disable Roman Numbers Conversion") then
romantonormalnumbers = false
else
romantonormalnumbers = true
end
end

local function request()
local gamename = game.getgamename()

if romantonormalnumbers then
gamename = substituteRomanNumerals(gamename)
end

local urlrequest = "https://www.1377x.to/category-search/" .. tostring(gamename) .. "/Games/1/"
urlrequest = urlrequest:gsub(" ", "%%20")

local htmlContent = http.get(urlrequest, headers)

local results = {}

for match in htmlContent:gmatch(regex) do
    local url = "https://1377x.to" .. match
	local torrentName = url:match("/([^/]+)/$")
    local htmlContent2 = http.get(url, headers)

    local searchResult = {
        name = torrentName,  
        links = {
            { name = "Download", link = url }
        },
		ScriptName = "1337x2"
    }

    for magnetMatch in htmlContent2:gmatch(magnetRegex) do
        searchResult.links = {
            { name = "Download", link = magnetMatch, addtodownloadlist = statebool}
        }
        searchResult.name = torrentName  
        table.insert(results, searchResult)
    end

    if searchResult.link == url then
        table.insert(results, searchResult)
    end
end

communication.receiveSearchResults(results)
end
client.add_callback("on_gameselected", request)--on a game is selected in menu callback
client.add_callback("on_present", checkboxstate)--on present
end










