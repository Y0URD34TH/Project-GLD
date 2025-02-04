--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
menu.add_button("Attach Console")
menu.add_button("Detach Console")

local function Attach()
utils.AttachConsole() --change to Attach when updated
end

local function Detach()
utils.DetachConsole()
end

client.add_callback("on_button_Attach Console", Attach)
client.add_callback("on_button_Detach Console", Detach)
