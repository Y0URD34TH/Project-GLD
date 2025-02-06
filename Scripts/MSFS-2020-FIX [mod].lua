--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
if client.GetVersionDouble() < 4.80 then
Notifications.push_error("MSFS 2020 Fix", "This Script needs Project GLD V4.80+")
else
local packagepath = ""
menu.add_input_text("HLM_Packages\nPath")
menu.set_text("HLM_Packages Path", packagepath)
settings.load()
Notifications.push_warning("MSFS 2020 Fix", "Make sure to enable lua file read/write on settings!")
local function TriggerUpdate(info)
packagepath = menu.get_text("HLM_Packages\nPath")

if (info.name == "Microsoft Flight Simulator" 
    or info.name == "Microsoft Flight Simulator 2020" 
    or info.name == "MSFS" 
    or info.name == "MSFS 2020") 
   and packagepath ~= "" then

if file.exists(packagepath) then
local pathtodelete = packagepath .. "\\Official\\OneStore\\fs-base-history"

if file.exists(pathtodelete)then
file.delete(pathtodelete)
Notifications.push_success("MSFS 2020 Fix", "Update Successfully triggered")
end

end
end

settings.save()
end

client.add_callback("on_gamelaunch", TriggerUpdate)
end

