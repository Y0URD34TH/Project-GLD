--this one follow the list rules and only start when u clicck in it
local function main()
    local getgamename = game.getgamename()
    getgamename = getgamename:gsub(" ", "+")
    local results = {}
    local mtable = { name = "Main",
            links = {},
            ScriptName = "img&vids"
            }
            table.insert(mtable.links,{ name = "Game Trailers", link = "https://www.youtube.com/results?search_query=" .. getgamename .. "+trailer", addtodownloadlist = false })
            table.insert(mtable.links,{ name = "Game Images", link = "https://www.google.com/search?q=".. getgamename .. "+gameplay&tbm=isch", addtodownloadlist = false })
            table.insert(mtable.links,{ name = "Gameplay Videos", link = "https://www.youtube.com/results?search_query=" .. getgamename .. "+gameplay", addtodownloadlist = false })
    
    table.insert(results, mtable)
    communication.receiveSearchResults(results)
end

client.add_callback("on_scriptselected", main)--on a game is selected in menu callback





