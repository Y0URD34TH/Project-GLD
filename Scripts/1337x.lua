--to view exaples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.MD

local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local regex = "<a href%s*=%s*\"(/torrent/[^\"]+)\""
local magnetRegex = "href%s*=%s*\"(magnet:[^\"]+)\""

local statebool = true

 local version = client.GetVersion()
 if version ~= "V0.99" then
  Notifications.push_error("Lua Script", "Program is Outdated Please Update to use that Script")
else
  Notifications.push_success("Lua Script", "1337x Script Loaded And Working")
local function request()
local gamename = game.getgamename()
local urlrequest = "https://www.1377x.to/search/" .. tostring(gamename) .. "/1/"
urlrequest = urlrequest:gsub(" ", "%%20")
local htmlContent = http.get(urlrequest, headers)

local results = {}

for match in htmlContent:gmatch(regex) do
    local url = "https://1377x.to" .. match
	local torrentName = url:match("/([^/]+)/$")
    local htmlContent2 = http.get(url, headers)

    local searchResult = {
        name = torrentName,  
        link = url,
        addtodownloadlist = statebool,
		ScriptName = "1337x"
    }

    for magnetMatch in htmlContent2:gmatch(magnetRegex) do
        searchResult.link = magnetMatch
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
end
