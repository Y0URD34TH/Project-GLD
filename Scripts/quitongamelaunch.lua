--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
menu.add_check_box("Enable quit on game launch")
menu.set_bool("Enable quit on game launch", true)
settings.load()
local function gamelaunchc(info)
if menu.get_bool("Enable quit on game launch") then
client.quit()
end
end

client.add_callback("on_gamelaunch", gamelaunchc)












