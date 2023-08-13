--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
settings.load()
menu.add_text("Settings Manager:")
menu.add_button("Save Settings")
menu.add_button("Load Settings")

local function save()
settings.save()
end

local function Load()
settings.load()
end

client.add_callback("on_button_Save Settings", save)
client.add_callback("on_button_Load Settings", Load)

