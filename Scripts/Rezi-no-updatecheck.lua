local function plug()
    local link = "https://search.rezi.one/indexes/rezi/search"
    local getgamename = game.getgamename()
    local gamename = "\"" .. getgamename .. "\""
    local params = [[{
        "q": ]] .. tostring(gamename) .. [[,
        "limit": 20
    }]]
    
	local headers = {
        ["Authorization"] = "Bearer e2a1974678b37386fef69bb3638a1fb36263b78a8be244c04795ada0fa250d3d",
        ["Content-Type"] = "application/json",
        ["accept"] = "application/json",
    }
    
	local response = http.post(link, params, headers)
    local gameResults = JsonWrapper.parse(response)["hits"]
    
	local results = {}
    
	for Key, value in ipairs(gameResults) do
        table.insert(results, {
            name = value.title,
            links = {
                { name = "Download", link = value.link, addtodownloadlist = false }
            },
            ScriptName = "Rezi2"
        })
   	end
    
	communication.receiveSearchResults(results)
end

client.add_callback("on_gameselected", plug)

