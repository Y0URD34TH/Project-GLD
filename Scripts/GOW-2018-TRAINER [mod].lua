--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
if client.GetVersionDouble() < 4.80 then
   Notifications.push_error("GOW 2018 Trainer", "This Script needs Project GLD V4.80+")
else

local files = {
    { url = "https://github.com/Y0URD34TH/God-of-War-4-2018-Cheat/raw/main/libcurl.dll", path = "libcurl.dll" },
    { url = "https://github.com/Y0URD34TH/God-of-War-4-2018-Cheat/raw/main/lua53.dll", path = "lua53.dll" },
    { url = "https://github.com/Y0URD34TH/God-of-War-4-2018-Cheat/raw/main/zlib1.dll", path = "zlib1.dll" }
}

function get_exe_name(path)
    return path:match("[^\\/]+$")
end

function get_directory(path)
    return path:match("^(.*)[\\/]")
end

local function EnableTrainer(info)

if info.name == "GOW" 
    or info.name == "GOW 2018" 
    or info.name == "GoW" 
    or info.name == "GoW 2018"
    or info.name == "God of War" 
    or info.name == "God of War 2018"
then

local processname = get_exe_name(info.exePath)
local mainpath = get_directory(info.exePath)
local dllpath = mainpath .. "\\GOW\\cheat.dll"

if file.exists(dllpath) then

for _, File in ipairs(files) do
    if not file.Exists(File.path) then
        Download.DirectDownload(File.url, mainpath .. File.path)
    end
end

if dll.inject(processname, dllpath, 10000) then
    Notifications.push_success("GOW 2018 Trainer", "Successfully Enabled")
end

else
for _, File in ipairs(files) do
    if not file.Exists(File.path) then
        Download.DirectDownload(File.url, mainpath .. File.path)
    end
end

Download.DirectDownload("https://github.com/Y0URD34TH/God-of-War-4-2018-Cheat/raw/main/GOW4Cheat.dll", dllpath)

if dll.inject(processname, dllpath, 10000) then
    Notifications.push_success("GOW 2018 Trainer", "Successfully Enabled")
end
end
end
end

client.add_callback("on_gamelaunch", EnableTrainer)
end



