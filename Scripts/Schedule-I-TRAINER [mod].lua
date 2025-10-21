-- to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
if client.GetVersionDouble() < 4.80 then
    Notifications.push_error("Schedule I Trainer", "This Script needs Project GLD V4.80+")
else
    function get_exe_name(path)
        return path:match("[^\\/]+$")
    end

    function get_directory(path)
        return path:match("^(.*)[\\/]")
    end

    local function EnableTrainer(info)
        if info.name == "SCH1" or info.name == "Schedule" or info.name == "Schedule I" or info.name == "Schedule i" or info.name ==
            "schedule i" or info.name == "Schedule 1" or info.name == "schedule" or info.name == "schedule 1" then

            local processname = get_exe_name(info.exePath)
            local mainpath = get_directory(info.exePath)
            local dllpath = mainpath .. "\\Schedule420.dll"

            if file.exists(dllpath) then
                if dll.inject(processname, dllpath, 10000) then
                    Notifications.push_success("Schedule420", "Successfully Enabled")
                end

            else
                Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Schedule420/refs/heads/main/Schedule%20I.dll",
                    dllpath)

                if dll.inject(processname, dllpath, 10000) then
                    Notifications.push_success("Schedule420", "Successfully Enabled")
                end
            end
        end
    end

    client.add_callback("on_gamelaunch", EnableTrainer)
end



