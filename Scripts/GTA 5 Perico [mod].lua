local RULE_BASE = "GLD_Block_GTAO"
local BLOCK_IP  = "192.81.241.171"

local enabled = false
local MENU_ENABLE_NAME = "Firewall Block GTA Online IP"
local MENU_KEY_ON  = "Enable Block Key"
local MENU_KEY_OFF = "Disable Block Key"

-- =========================
-- MENU SETUP
-- =========================
menu.add_check_box(MENU_ENABLE_NAME)
menu.set_bool(MENU_ENABLE_NAME, true)
menu.add_keybind(MENU_KEY_ON, VK.F8)
menu.add_keybind(MENU_KEY_OFF, VK.F9)


-- =========================
-- FIREWALL HELPERS
-- =========================
local function rule_exists(rule_name)
    local out = system_output(
        'netsh advfirewall firewall show rule name="' .. rule_name .. '"'
    )
    return out and out:find("Rule Name", 1, true) ~= nil
end

local function ensure_rule(rule_name, direction)
    if not rule_exists(rule_name) then
        system(
            'netsh advfirewall firewall add rule ' ..
            'name="' .. rule_name .. '" ' ..
            'dir=' .. direction .. ' action=block remoteip=' .. BLOCK_IP
        )
    end
end

local function enable_block()
    ensure_rule(RULE_BASE .. "_OUT", "out")
    ensure_rule(RULE_BASE .. "_IN", "in")

    system('netsh advfirewall firewall set rule name="' .. RULE_BASE .. '_OUT" new enable=yes')
    system('netsh advfirewall firewall set rule name="' .. RULE_BASE .. '_IN" new enable=yes')

    Notifications.push_success(
        "Firewall",
        "Blocked ALL traffic to " .. BLOCK_IP
    )
    beep()
    enabled = true
end

local function disable_block()
    system('netsh advfirewall firewall set rule name="' .. RULE_BASE .. '_OUT" new enable=no')
    system('netsh advfirewall firewall set rule name="' .. RULE_BASE .. '_IN" new enable=no')

    Notifications.push_warning(
        "Firewall",
        "Unblocked ALL traffic to " .. BLOCK_IP
    )
    beep()
    enabled = false
end

-- =========================
-- MAIN LOOP
-- =========================
client.add_callback("on_present", function()

    -- feature disabled via menu
    if not menu.get_bool(MENU_ENABLE_NAME) then
        return
    end

    local key_on  = menu.get_keybind(MENU_KEY_ON)
    local key_off = menu.get_keybind(MENU_KEY_OFF)

    if input.is_key_pressed(key_on) and not enabled then
        enable_block()
    end

    if input.is_key_pressed(key_off) and enabled then
        disable_block()
    end
end)


