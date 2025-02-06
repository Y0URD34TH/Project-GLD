--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
if client.GetVersionDouble() < 4.80 then
Notifications.push_error("DLL Injector", "This Script needs Project GLD V4.80+")
else
local processname = ""
local dllpath = ""
local dlllink = ""
local delay = 0

function get_exe_name(path)
    return path:match("[^\\/]+$")
end

local games = GameLibrary.GetGameList()
local gameNames = {}

for _, mgame in ipairs(games) do
    table.insert(gameNames, mgame.name)
end

menu.add_text("----DLL Injector----")
menu.add_input_text("Process Name") --ex: GoW.exe
menu.set_text("Process Name", processname)
menu.add_input_text("DLL Path")
menu.set_text("DLL Path", dllpath)
menu.add_input_text("DLL Link")
menu.set_text("DLL Link", dlllink)

menu.add_combo_box("Auto Inject", gameNames)
menu.add_check_box("Enable Auto Inject")

menu.add_input_int("Injection delay ms")

menu.add_button("Inject by Path")
menu.add_button("Inject by Link")
menu.add_text("---------------------")

menu.set_int("Injection delay ms", delay)
settings.load()
Notifications.push_warning("DLL Injector", "Make sure to enable lua file read/write on settings!")

local function dllinjectbypath()
processname = menu.get_text("Process Name")
dllpath = menu.get_text("DLL Path")
delay = menu.get_int("Injection delay ms")

if file.exists(dllpath) then
if dll.inject(processname, dllpath, delay) then
    Notifications.push_success("DLL Injector", "Successfully Injected")
end

settings.save()
end
end

local function dllinjectbylink()
processname = menu.get_text("Process Name")
dlllink = menu.get_text("DLL Link")
delay = menu.get_int("Injection delay ms")

Download.DirectDownload(dlllink, "downloaded.dll")

if file.exists("downloaded.dll") then
if dll.inject(processname, "downloaded.dll", delay) then
    Notifications.push_success("DLL Injector", "Successfully Injected")
end

settings.save()
end
end

local function autoinject(info)
dllpath = menu.get_text("DLL Path")
delay = menu.get_int("Injection delay ms")
local gameselected = menu.get_int("Auto Inject")
local isEnabled = menu.get_bool("Enable Auto Inject")

if info.id == games[gameselected + 1].id and isEnabled then -- + 1 at the gameselected cause lua is base 1 not 0.
local pname = get_exe_name(info.exePath)
if dll.inject(pname, dllpath, delay) then
    Notifications.push_success("DLL Injector", "Successfully Injected")
end

settings.save()
end
end

client.add_callback("on_button_Inject by Path", dllinjectbypath)
client.add_callback("on_button_Inject by Link", dllinjectbylink)
client.add_callback("on_gamelaunch", autoinject)

end





