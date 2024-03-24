--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local version = client.GetVersionDouble()

if version < 2.14 then
   Notifications.push_error("Lua Script", "Program is outdated. Please update the app to use this script!")
else
   Notifications.push_success("Lua Script", "gog-games script is loaded and working!")
local statebool = false

local function requestgog()
    local link = "https://raw.githubusercontent.com/qiracy/list/main/gog-games.to.json"
    local getgamename = game.getgamename()

    local headers = {
     ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }
    local response = http.get(link, headers)
    local gameResults = JsonWrapper.parse(response)[getgamename]

    local results = {}
    local downloadsresult = {
        name = "[Game] " .. getgamename,
        links = {},
        ScriptName = "gog-games"
    }
    
    if gameResults["Game Download Links"] then
        for servern, slink in pairs(gameResults["Game Download Links"]) do       
            table.insert(downloadsresult.links, { name = servern, link = slink, addtodownloadlist = false })       
        end
    end

    table.insert(results, downloadsresult)

    if gameResults["Patch/Other Download Links"] then
        local patchresult = {
            name = "[Patch/Other] " .. getgamename,
            links = {},
            ScriptName = "gog-games"
        }

        for servern, slink in pairs(gameResults["Patch/Other Download Links"]) do       
            table.insert(patchresult.links, { name = servern, link = slink, addtodownloadlist = false })       
        end

        table.insert(results, patchresult)
    end

    if gameResults["Goodies Download Links"] then
        local goodiesresult = {
            name = "[Goodies] " .. getgamename,
            links = {},
            ScriptName = "gog-games"
        }

        for servern, slink in pairs(gameResults["Goodies Download Links"]) do       
            table.insert(goodiesresult.links, { name = servern, link = slink, addtodownloadlist = false })       
        end

        table.insert(results, goodiesresult)
    end

    communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", requestgog)--on a game is selected in menu callback
end
