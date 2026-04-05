--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
-- ============================================================
--  VBS Disabler / Revert  –  Project-GLD Lua Script
--  Mirrors the logic of VBS.cmd using GLD API:
--    • Buttons instead of keypresses
--    • Notifications instead of console prints
--    • system / system_output for registry / bcdedit work
-- ============================================================

local VERSION = "1.0"

menu.add_text("VBS Disabler")
menu.add_button("Disable VBS")
menu.add_button("Revert Changes")
menu.add_button("Check Status")
menu.add_check_box("Automatically Restart")
menu.set_bool("Automatically Restart", true)
menu.add_text("----------------------------")

--- Run a CMD/PowerShell command and return trimmed stdout.
local function shell(cmd)
    local out = system_output(cmd)
    if out then
        out = out:match("^%s*(.-)%s*$")  -- trim
    end
    return out or ""
end

--- Query a registry DWORD/SZ value; returns the token string or "".
local function reg_query(path, value)
    local raw = shell(string.format('reg query "%s" /v "%s" 2>nul', path, value))
    -- reg output: <path>    <type>    <data>
    local data = raw:match("%s+REG_%a+%s+(.-)%s*$")
    return data or ""
end

--- Set a registry DWORD.
local function reg_dword(path, name, val)
    system(string.format('reg add "%s" /v "%s" /t REG_DWORD /d %d /f >nul 2>&1', path, name, val))
end

--- Set a registry SZ.
local function reg_sz(path, name, val)
    system(string.format('reg add "%s" /v "%s" /t REG_SZ /d "%s" /f >nul 2>&1', path, name, val))
end

--- Delete a registry value.
local function reg_del(path, name)
    system(string.format('reg delete "%s" /v "%s" /f >nul 2>&1', path, name))
end

--- Delete a whole registry key.
local function reg_del_key(path)
    system(string.format('reg delete "%s" /f >nul 2>&1', path))
end

--- Check if a registry value exists (returns true/false).
local function reg_exists(path, name)
    local out = shell(string.format('reg query "%s" /v "%s" 2>nul', path, name))
    return out ~= ""
end

--- Run bcdedit and return output.
local function bcdedit(args)
    return shell("bcdedit " .. args .. " 2>nul")
end

local function ps(code)
    return shell(string.format('powershell -nop -c "%s" 2>nul', code))
end

--- Returns true when hypervisor is present.
local function hypervisor_present()
    local r = ps("(gcim Win32_ComputerSystem).HypervisorPresent")
    return r:lower() == "true"
end

--- Returns true when VT-x / SVM is enabled in BIOS.
local function vtx_enabled()
    if hypervisor_present() then return true end
    local r = ps("(Get-CimInstance -ClassName Win32_Processor).VirtualizationFirmwareEnabled")
    return r:lower() == "true"
end

--- Returns DSE state: 0=disabled, 1=testsigning, 2=enabled/normal, ""-unknown
local function dse_state()
    local code = table.concat({
        "$t=Add-Type -PassThru -MemberDefinition '[DllImport(\\\"ntdll.dll\\\")] public static extern uint NtQuerySystemInformation(int c,IntPtr b,uint s,out uint r);' -Name CI2 -Namespace w2;",
        "$p=[Runtime.InteropServices.Marshal]::AllocHGlobal(8);",
        "[Runtime.InteropServices.Marshal]::WriteInt32($p,8);",
        "$r=[uint32]0;",
        "$t::NtQuerySystemInformation(103,$p,8,[ref]$r)|Out-Null;",
        "$o=[uint32][Runtime.InteropServices.Marshal]::ReadInt32($p,4);",
        "if(-not($o -band 1)){0}elseif($o -band 2){1}else{2}",
    }, "")
    return ps(code)
end

--- Returns KVA shadow state: "1" if mitigation is running.
local function kva_required()
    local code = table.concat({
        "$d=Add-Type -MemberDefinition '[DllImport(\\\"ntdll.dll\\\")] public static extern int NtQuerySystemInformation(uint a,IntPtr b,uint c,IntPtr d);' -Name n -Namespace w -PassThru;",
        "$p=[Runtime.InteropServices.Marshal]::AllocHGlobal(4);",
        "$r=[Runtime.InteropServices.Marshal]::AllocHGlobal(4);",
        "$ret=$d::NtQuerySystemInformation(196,$p,4,$r);",
        "if($ret -eq 0){$f=[uint32][Runtime.InteropServices.Marshal]::ReadInt32($p);",
        "if(($f -band 0x01)-ne 0 -or (($f -band 0x20)-ne 0 -and ($f -band 0x10)-ne 0)){1}else{0}}else{0}",
    }, "")
    return ps(code) == "1"
end

--- HVCI running (SecurityServicesRunning == 2)
local function hvci_running()
    local r = ps("(Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\\Microsoft\\Windows\\DeviceGuard).SecurityServicesRunning")
    return r == "2"
end

--- Credential Guard running (SecurityServicesRunning == 1)
local function cg_running()
    local r = ps("(Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\\Microsoft\\Windows\\DeviceGuard).SecurityServicesRunning")
    return r == "1"
end

--- VBS status from DeviceGuard WMI (1 or 2 = running)
local function vbs_wmi_status()
    local r = ps("(Get-CimInstance -ClassName Win32_DeviceGuard -Namespace root\\Microsoft\\Windows\\DeviceGuard).VirtualizationBasedSecurityStatus")
    return r == "1" or r == "2"
end

--- BitLocker protection on system drive
local function bitlocker_on()
    local r = ps("(Get-BitLockerVolume -MountPoint $env:SystemDrive).ProtectionStatus")
    return r == "On"
end

local function faceit_present()
    return file.exists("C:\\Program Files\\FACEIT AC\\")
end

local function ok(title, msg)   Notifications.push_success(title, msg) end
local function err(title, msg)  Notifications.push_error(title, msg)   end
local function warn(title, msg) Notifications.push_warning(title, msg) end
local function info(title, msg) Notifications.push(title, msg)         end

local function do_disable()
    -- 1. VT-x / SVM check
    if not vtx_enabled() then
        err("VBS Disabler", "Virtualization (VT-x/SVM) is NOT enabled in BIOS. Enable it first.")
        return
    end

    -- 2. FACEIT check
    if faceit_present() then
        err("VBS Disabler", "FACEIT Anti-Cheat detected uninstall it before proceeding.")
        return
    end

    local dg_exists = reg_exists("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard", "EnableVirtualizationBasedSecurity")
        or shell('reg query "HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard" /s 2>nul') ~= ""

    local anything_disabled = false
    local had_error         = false

    -- Helper: disable a named feature via registry
    local function disable_feature(display, track_key, action_fn, undo_fn)
        local already = action_fn()   -- returns true if already disabled
        if already then return end    -- nothing to do

        -- track
        reg_dword("HKLM\\SOFTWARE\\ManageVBS", track_key, 1)
        undo_fn()                     -- do the actual disable

        -- verify by re-running action check (simple: just trust errorlevel)
        anything_disabled = true
        ok("VBS Disabler", display .. " disabled successfully.")
    end

    -- 3. Windows Hello
    local wh_val = reg_query("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\WindowsHello", "Enabled")
    if wh_val == "0x1" then
        reg_dword("HKLM\\SOFTWARE\\ManageVBS", "WindowsHello", 1)
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\WindowsHello", "Enabled", 0)
        anything_disabled = true
        ok("VBS Disabler", "Windows Hello Protection disabled.")
    end

    -- 4. Enhanced Sign-in Security (SecureBiometrics)
    local sb_val = reg_query("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\SecureBiometrics", "Enabled")
    local sbs_val = reg_query("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios", "SecureBiometrics")
    if sb_val == "0x1" then
        reg_dword("HKLM\\SOFTWARE\\ManageVBS", "SecureBiometrics", 1)
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\SecureBiometrics", "Enabled", 0)
        if sbs_val == "0x1" then
            reg_dword("HKLM\\SOFTWARE\\ManageVBS", "SecureBiometricsScenario", 1)
            reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios", "SecureBiometrics", 0)
        end
        anything_disabled = true
        ok("VBS Disabler", "Enhanced Sign-in Security disabled.")
    end

    -- 5. Virtualization-based Security (VBS)
    local vbs_val = reg_query("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard", "EnableVirtualizationBasedSecurity")
    local rpsf_val = reg_query("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard", "RequirePlatformSecurityFeatures")
    if vbs_val == "0x1" then
        reg_dword("HKLM\\SOFTWARE\\ManageVBS", "VBS", 1)
        if rpsf_val ~= "" then
            reg_sz("HKLM\\SOFTWARE\\ManageVBS", "RequirePlatformSecurityFeatures", rpsf_val)
            reg_del("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard", "RequirePlatformSecurityFeatures")
        end
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard", "EnableVirtualizationBasedSecurity", 0)
        anything_disabled = true
        ok("VBS Disabler", "Virtualization-based Security disabled.")
    end

    -- 6. System Guard
    local sg_val = reg_query("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\SystemGuard", "Enabled")
    if sg_val == "0x1" then
        reg_dword("HKLM\\SOFTWARE\\ManageVBS", "SystemGuard", 1)
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\SystemGuard", "Enabled", 0)
        anything_disabled = true
        ok("VBS Disabler", "System Guard disabled.")
    end

    -- 7. Memory Integrity / HVCI
    local hvci_cfg = reg_query("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\HypervisorEnforcedCodeIntegrity", "Enabled")
    if hvci_running() or hvci_cfg == "0x1" then
        reg_dword("HKLM\\SOFTWARE\\ManageVBS", "HVCI", 1)
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\HypervisorEnforcedCodeIntegrity", "Enabled", 0)
        anything_disabled = true
        ok("VBS Disabler", "Memory Integrity (HVCI) disabled.")
    end

    -- 8. Credential Guard
    if cg_running() then
        reg_dword("HKLM\\SOFTWARE\\ManageVBS", "CredentialGuard", 1)
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Lsa", "LsaCfgFlags", 0)
        reg_dword("HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceGuard", "LsaCfgFlags", 0)
        anything_disabled = true
        ok("VBS Disabler", "Credential Guard disabled.")
    end
    local cg_scenario = reg_query("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\CredentialGuard", "Enabled")
    if cg_scenario == "0x1" then
        reg_dword("HKLM\\SOFTWARE\\ManageVBS", "CredentialGuardScenario", 1)
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\CredentialGuard", "Enabled", 0)
        anything_disabled = true
        ok("VBS Disabler", "Credential Guard Scenarios disabled.")
    end

    -- 9. KVA Shadow
    if kva_required() then
        local kv1 = reg_query("HKLM\\System\\CurrentControlSet\\Control\\Session Manager\\Memory Management", "FeatureSettingsOverride")
        local kv2 = reg_query("HKLM\\System\\CurrentControlSet\\Control\\Session Manager\\Memory Management", "FeatureSettingsOverrideMask")
        if not (kv1 == "0x2" and kv2 == "0x3") then
            reg_dword("HKLM\\SOFTWARE\\ManageVBS", "KVAShadow", 1)
            reg_dword("HKLM\\System\\CurrentControlSet\\Control\\Session Manager\\Memory Management", "FeatureSettingsOverride", 2)
            reg_dword("HKLM\\System\\CurrentControlSet\\Control\\Session Manager\\Memory Management", "FeatureSettingsOverrideMask", 3)
            anything_disabled = true
            ok("VBS Disabler", "KVA Shadow disabled.")
        end
    end

    -- 10. Windows Hypervisor
    local hyp_bcd = bcdedit("/enum {current}"):match("hypervisorlaunchtype%s+(%S+)")
    local hyp_needed = false
    if hyp_bcd then
        local h = hyp_bcd:lower()
        if h == "auto" or h == "on" then hyp_needed = true end
    else
        if vbs_wmi_status() and hypervisor_present() then hyp_needed = true end
    end
    if hyp_needed then
        reg_dword("HKLM\\SOFTWARE\\ManageVBS", "Hypervisor", 1)
        if hyp_bcd then
            reg_sz("HKLM\\SOFTWARE\\ManageVBS", "HypervisorLaunchType", hyp_bcd)
        end
        system("bcdedit /set hypervisorlaunchtype off >nul 2>&1")
        anything_disabled = true
        ok("VBS Disabler", "Windows Hypervisor disabled.")
    end

    -- 11. BitLocker suspend (1 reboot)
    local dse = dse_state()
    if dse ~= "1" then
        if bitlocker_on() then
            system("manage-bde -protectors -disable %SystemDrive% -rebootcount 1 >nul 2>&1")
            info("VBS Disabler", "BitLocker suspended for 1 reboot (encryption still active).")
        end
        -- Schedule Startup Settings (F7 prompt)
        system("bcdedit /set {current} onetimeadvancedoptions on >nul 2>&1")
    end

    -- 12. Summary
    if not anything_disabled then
        if dse == "0" then
            info("VBS Disabler", "All VBS features + DSE are already disabled. Nothing to do.")
        elseif dse == "1" then
            info("VBS Disabler", "All VBS features are disabled. Test Signing is already active.")
        else
            info("VBS Disabler", "All VBS features already disabled. A restart will open Startup Settings for driver signature enforcement. (Press F7 to disable)")
            info("VBS Disabler", "A restart will automatically  happen in 5 seconds")
            sleep(5000)
            system("shutdown /r /t 0")
        end
        return
    end
    if menu.get_bool("Automatically Restart") then
       warn("VBS Disabler", "Done! On boot press F7 in Startup Settings to disable driver signature enforcement.")
       info("VBS Disabler", "A restart will automatically happen in 5 seconds")
       sleep(5000)
       system("shutdown /r /t 0")
    else
       warn("VBS Disabler", "Done! Restart your PC. On boot press F7 in Startup Settings to disable driver signature enforcement.")
    end
end

local function do_revert()
    local had_error  = false
    local any_done   = false
    local dse        = dse_state()

    -- check if anything was tracked
    local tracked = shell('reg query "HKLM\\SOFTWARE\\ManageVBS" 2>nul')
    if tracked == "" and dse ~= "0" then
        info("VBS Disabler", "Nothing to revert – no previous changes tracked.")
        return
    end

    -- Windows Hypervisor
    local rv_hyp  = reg_query("HKLM\\SOFTWARE\\ManageVBS", "Hypervisor")
    local rv_htype = reg_query("HKLM\\SOFTWARE\\ManageVBS", "HypervisorLaunchType")
    if rv_hyp == "0x1" then
        if rv_htype == "" then
            system("bcdedit /deletevalue {current} hypervisorlaunchtype >nul 2>&1")
        else
            system(string.format("bcdedit /set hypervisorlaunchtype %s >nul 2>&1", rv_htype))
        end
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "Hypervisor")
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "HypervisorLaunchType")
        ok("VBS Revert", "Windows Hypervisor re-enabled.")
        any_done = true
    end

    -- VBS
    local rv_vbs  = reg_query("HKLM\\SOFTWARE\\ManageVBS", "VBS")
    local rv_rpsf = reg_query("HKLM\\SOFTWARE\\ManageVBS", "RequirePlatformSecurityFeatures")
    if rv_vbs == "0x1" then
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard", "EnableVirtualizationBasedSecurity", 1)
        if rv_rpsf ~= "" then
            -- rv_rpsf is hex like 0x1 → convert
            local n = tonumber(rv_rpsf, 16) or tonumber(rv_rpsf)
            if n then reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard", "RequirePlatformSecurityFeatures", n) end
        end
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "VBS")
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "RequirePlatformSecurityFeatures")
        ok("VBS Revert", "Virtualization-based Security re-enabled.")
        any_done = true
    end

    -- HVCI
    local rv_hvci = reg_query("HKLM\\SOFTWARE\\ManageVBS", "HVCI")
    if rv_hvci == "0x1" then
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\HypervisorEnforcedCodeIntegrity", "Enabled", 1)
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "HVCI")
        ok("VBS Revert", "Memory Integrity (HVCI) re-enabled.")
        any_done = true
    end

    -- Windows Hello
    local rv_wh = reg_query("HKLM\\SOFTWARE\\ManageVBS", "WindowsHello")
    if rv_wh == "0x1" then
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\WindowsHello", "Enabled", 1)
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "WindowsHello")
        ok("VBS Revert", "Windows Hello Protection re-enabled.")
        any_done = true
    end

    -- SecureBiometrics
    local rv_sb  = reg_query("HKLM\\SOFTWARE\\ManageVBS", "SecureBiometrics")
    local rv_sbs = reg_query("HKLM\\SOFTWARE\\ManageVBS", "SecureBiometricsScenario")
    if rv_sb == "0x1" then
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\SecureBiometrics", "Enabled", 1)
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "SecureBiometrics")
        ok("VBS Revert", "Enhanced Sign-in Security re-enabled.")
        any_done = true
    end
    if rv_sbs == "0x1" then
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios", "SecureBiometrics", 1)
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "SecureBiometricsScenario")
        any_done = true
    end

    -- System Guard
    local rv_sg = reg_query("HKLM\\SOFTWARE\\ManageVBS", "SystemGuard")
    if rv_sg == "0x1" then
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\SystemGuard", "Enabled", 1)
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "SystemGuard")
        ok("VBS Revert", "System Guard re-enabled.")
        any_done = true
    end

    -- Credential Guard
    local rv_cg = reg_query("HKLM\\SOFTWARE\\ManageVBS", "CredentialGuard")
    if rv_cg == "0x1" then
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Lsa", "LsaCfgFlags", 2)
        -- remove policy override if present
        if reg_exists("HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceGuard", "LsaCfgFlags") then
            reg_del("HKLM\\SOFTWARE\\Policies\\Microsoft\\Windows\\DeviceGuard", "LsaCfgFlags")
        end
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "CredentialGuard")
        ok("VBS Revert", "Credential Guard re-enabled.")
        any_done = true
    end
    local rv_cgs = reg_query("HKLM\\SOFTWARE\\ManageVBS", "CredentialGuardScenario")
    if rv_cgs == "0x1" then
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\CredentialGuard", "Enabled", 1)
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "CredentialGuardScenario")
        ok("VBS Revert", "Credential Guard Scenarios re-enabled.")
        any_done = true
    end

    -- VBS UEFI Lock
    local rv_vbsl = reg_query("HKLM\\SOFTWARE\\ManageVBS", "VBSLocked")
    if rv_vbsl == "0x1" then
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard", "Locked", 1)
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "VBSLocked")
        ok("VBS Revert", "VBS UEFI Lock re-enabled.")
        any_done = true
    end

    -- HVCI UEFI Lock
    local rv_hvcil = reg_query("HKLM\\SOFTWARE\\ManageVBS", "HVCILocked")
    if rv_hvcil == "0x1" then
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\HypervisorEnforcedCodeIntegrity", "Locked", 1)
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "HVCILocked")
        ok("VBS Revert", "HVCI UEFI Lock re-enabled.")
        any_done = true
    end

    -- CG UEFI Lock
    local rv_cgl = reg_query("HKLM\\SOFTWARE\\ManageVBS", "CGLocked")
    if rv_cgl == "0x1" then
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard", "EnableVirtualizationBasedSecurity", 1)
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard", "RequirePlatformSecurityFeatures", 3)
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Lsa", "LsaCfgFlags", 1)
        reg_dword("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\CredentialGuard", "Enabled", 1)
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "CGLocked")
        ok("VBS Revert", "Credential Guard UEFI Lock re-enabled.")
        any_done = true
    end

    -- KVA Shadow
    local rv_kva = reg_query("HKLM\\SOFTWARE\\ManageVBS", "KVAShadow")
    if rv_kva == "0x1" then
        reg_del("HKLM\\System\\CurrentControlSet\\Control\\Session Manager\\Memory Management", "FeatureSettingsOverride")
        reg_del("HKLM\\System\\CurrentControlSet\\Control\\Session Manager\\Memory Management", "FeatureSettingsOverrideMask")
        reg_del("HKLM\\SOFTWARE\\ManageVBS", "KVAShadow")
        ok("VBS Revert", "KVA Shadow (Meltdown mitigation) re-enabled.")
        any_done = true
    end

    -- Cleanup tracking key if empty
    local remaining = shell('reg query "HKLM\\SOFTWARE\\ManageVBS" 2>nul | findstr /i "REG_" | findstr /vi "UEFILockAgreed"')
    if remaining == "" then
        reg_del_key("HKLM\\SOFTWARE\\ManageVBS")
    end

    if any_done then
        if menu.get_bool("Automatically Restart") then
           warn("VBS Revert", "All tracked changes reverted.")
           system("shutdown /r /t 0")
        else
           warn("VBS Revert", "All tracked changes reverted. Restart your PC to apply.")
        end
    else
        info("VBS Revert", "Nothing was reverted (no tracked changes found).")
    end
end

local function do_status()
    local lines = {}

    -- VT-x
    local vtx = vtx_enabled()
    table.insert(lines, "VT-x/SVM: " .. (vtx and "Enabled" or "DISABLED (enable in BIOS!)"))

    -- Hypervisor
    local hyp_bcd = bcdedit("/enum {current}"):match("hypervisorlaunchtype%s+(%S+)") or "not set"
    table.insert(lines, "Hypervisor BCD: " .. hyp_bcd)

    -- DSE
    local dse = dse_state()
    local dse_txt = ({["0"]="DSE Disabled", ["1"]="Test Signing ON", ["2"]="DSE Enabled (normal)"})[dse] or "unknown"
    table.insert(lines, "DSE: " .. dse_txt)

    -- VBS
    local vbs_val = reg_query("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard", "EnableVirtualizationBasedSecurity")
    table.insert(lines, "VBS registry: " .. (vbs_val == "0x1" and "Enabled" or (vbs_val == "0x0" and "Disabled" or "Not set")))

    -- HVCI
    local hvci_val = reg_query("HKLM\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\HypervisorEnforcedCodeIntegrity", "Enabled")
    table.insert(lines, "HVCI registry: " .. (hvci_val == "0x1" and "Enabled" or (hvci_val == "0x0" and "Disabled" or "Not set")))

    -- Credential Guard
    local cg_val = reg_query("HKLM\\SYSTEM\\CurrentControlSet\\Control\\Lsa", "LsaCfgFlags")
    table.insert(lines, "Credential Guard LSA: " .. (cg_val ~= "" and cg_val or "Not set"))

    -- FACEIT
    table.insert(lines, "FACEIT AC: " .. (faceit_present() and "DETECTED" or "Not found"))

    -- BitLocker
    table.insert(lines, "BitLocker: " .. (bitlocker_on() and "Protected (will be auto-suspended)" or "Off / Not protecting"))

    -- ManageVBS tracking key
    local tracked = shell('reg query "HKLM\\SOFTWARE\\ManageVBS" 2>nul')
    table.insert(lines, "Tracked changes: " .. (tracked ~= "" and "Yes (Revert available)" or "None"))

    info("VBS Status", table.concat(lines, "\n"))
end

client.add_callback("on_button_Disable VBS", function()
    do_disable()
end)

client.add_callback("on_button_Revert Changes", function()
    do_revert()
end)

client.add_callback("on_button_Check Status", function()
    do_status()
end)

gldconsole.print("[VBS Disabler] Script loaded v" .. VERSION .. " – use the menu buttons.")











