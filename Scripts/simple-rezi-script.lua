menu.add_check_box("Should Add Donwload to Manager When Click in Download")--menu checkbox
   --set true if you want to start the download in the program downloader
   --set false if you want to open the link in your default browser
local statebool = false
local function GetMenuState()
    statebool = menu.get_bool("Should Add Donwload to Manager When Click in Download")
end
local function request()
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
            ["accept"] = "application/json"
        }

        local response = http.post(link, params, headers)

        local gameResults = JsonWrapper.parse(response)["hits"]

        local results = {}

        for _, result in ipairs(gameResults) do
            local searchResult = {
                name = result.title,
                link = result.link,
				addtodownloadlist = statebool
            }
            table.insert(results, searchResult)
        end
        communication.receiveSearchResults(results)
end
client.add_callback("on_present", GetMenuState)--updtae constantly the checkbox state
client.add_callback("on_gameselected", request)--on a game is selected in menu callback







