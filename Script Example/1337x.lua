
local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local regex = "<a href%s*=%s*\"(/torrent/[^\"]+)\""
local magnetRegex = "href%s*=%s*\"(magnet:[^\"]+)\""


local statebool = true


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
        name = torrentName,  -- Use the URL as the default name
        link = url,
        addtodownloadlist = statebool
    }

    for magnetMatch in htmlContent2:gmatch(magnetRegex) do
        searchResult.link = magnetMatch
        searchResult.name = torrentName  -- Use the URL as the name for magnet links
        table.insert(results, searchResult)
    end

    -- Only add URL results if no magnet links were found
    if searchResult.link == url then
        table.insert(results, searchResult)
    end
end

communication.receiveSearchResults(results)
end
client.add_callback("on_gameselected", request)--on a game is selected in menu callback

