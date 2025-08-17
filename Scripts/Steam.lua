--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local version = client.GetVersionDouble()

if version < 3.50 then
    Notifications.push_error("Lua Script", "Program is Outdated Please Update to use that Script")
else
Notifications.push_success("Lua Script", "Steam Script Loaded And Working")

local function main()
local getgamename = game.getgamename()
local gameid = SteamApi.GetAppID(getgamename)
local results = {}
local mtable = { name = "Main",
        links = {},
        ScriptName = "Steam"
}
table.insert(mtable.links, { name = "View on Browser", link = "https://store.steampowered.com/app/" ..gameid .. "/", addtodownloadlist = false })
table.insert(mtable.links, { name = "Open in Steam Client", link = "steam://rungameid/"..gameid, addtodownloadlist = false })
table.insert(mtable.links, { name = "Show Page on Steam Client", link = "steam://store/"..gameid, addtodownloadlist = false })
table.insert(results, mtable)
communication.receiveSearchResults(results)
end

client.add_callback("on_scriptselected", main)--on a game is selected in menu callback
end