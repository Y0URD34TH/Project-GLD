input.InitializeVirtualGamePad()

local MENU_KEY_RUN = "BST Keybind"
local MENU_KEY_RUN_2 = "Armor keybind"
local MENU_KEY_RUN_3 = "Securoserv Keybind"
local MENU_KEY_RUN_4 = "MC Keybind"
local MENU_KEY_RUN_5 = "Cayo Quick Start Keybind"
local MENU_KEY_RUN_6 = "Bribe Cops keybind"
local MENU_KEY_RUN_7 = "Ghost org keybind"
local MENU_KEY_RUN_8 = "Buy ammo keybind"
local MENU_KEY_RUN_9 = "Buy ammo (rockets) keybind"
local MENU_INPUT_INT_NAME = "Macro key delay"
local MENU_INPUT_INT_NAME2 = "Macro hold delay"
-- =========================
-- MENU SETUP
-- =========================
menu.add_check_box("Enable GTA 5 Macros")
menu.add_keybind(MENU_KEY_RUN, VK.F3)
menu.add_keybind(MENU_KEY_RUN_2, VK.F4)
menu.add_keybind(MENU_KEY_RUN_3, VK.F5)
menu.add_keybind(MENU_KEY_RUN_4, VK.F6)
menu.add_keybind(MENU_KEY_RUN_5, VK.F11)
menu.add_keybind(MENU_KEY_RUN_6, VK.F10)
menu.add_keybind(MENU_KEY_RUN_7, VK.F9)
menu.add_keybind(MENU_KEY_RUN_8, VK.F8)
menu.add_keybind(MENU_KEY_RUN_9, VK.F7)
menu.add_input_int(MENU_INPUT_INT_NAME, 1, 100)
menu.add_input_int(MENU_INPUT_INT_NAME2, 150, 1000)
menu.set_int(MENU_INPUT_INT_NAME, 25)
menu.set_int(MENU_INPUT_INT_NAME2, 375)
menu.set_bool("Enable GTA 5 Macros", true)
settings.load()
-- =========================
-- MACRO
-- =========================

-- // bst macro
local function run_macro()
    -- Press and hold SELECT (BACK) for 1.5 seconds
    input.SendVirtualGamePadKeyPress(GP.BACK, menu.get_int(MENU_INPUT_INT_NAME2))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))   
end

--// armor macro
local function run_macro_2()
    -- Press and hold SELECT (BACK) for 1.5 seconds
    input.SendVirtualGamePadKeyPress(GP.BACK, menu.get_int(MENU_INPUT_INT_NAME2))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))  
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
end


 -- Ceo macro
local function run_macro_3()
    -- Press and hold SELECT (BACK) for 1.5 seconds
    input.SendVirtualGamePadKeyPress(GP.BACK, menu.get_int(MENU_INPUT_INT_NAME2))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
end

-- // mc maccro
local function run_macro_4()
    -- Press and hold SELECT (BACK) for 1.5 seconds
    input.SendVirtualGamePadKeyPress(GP.BACK, menu.get_int(MENU_INPUT_INT_NAME2))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME)) 
end

local function run_macro_5()
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.B, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.B, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.B, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.B, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))    
end

local function run_macro_6()
    -- Press and hold SELECT (BACK) for 1.5 seconds
    input.SendVirtualGamePadKeyPress(GP.BACK, menu.get_int(MENU_INPUT_INT_NAME2))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))  
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))  
end

local function run_macro_7()
    -- Press and hold SELECT (BACK) for 1.5 seconds
    input.SendVirtualGamePadKeyPress(GP.BACK, menu.get_int(MENU_INPUT_INT_NAME2))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_UP, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(4096, menu.get_int(MENU_INPUT_INT_NAME))  
end

local function run_macro_8()
    input.SendVirtualGamePadKeyPress(GP.BACK, menu.get_int(MENU_INPUT_INT_NAME2))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_LEFT, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME))  
    sleep(menu.get_int(MENU_INPUT_INT_NAME))       
    input.SendVirtualGamePadKeyPress(GP.B, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))     
    input.SendVirtualGamePadKeyPress(GP.B, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))     
    input.SendVirtualGamePadKeyPress(GP.B, menu.get_int(MENU_INPUT_INT_NAME))  
end

local function run_macro_9()
    input.SendVirtualGamePadKeyPress(GP.BACK, menu.get_int(MENU_INPUT_INT_NAME2))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_RIGHT, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.DPAD_DOWN, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))
    input.SendVirtualGamePadKeyPress(GP.A, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))       
    input.SendVirtualGamePadKeyPress(GP.B, menu.get_int(MENU_INPUT_INT_NAME))
    sleep(menu.get_int(MENU_INPUT_INT_NAME))     
    input.SendVirtualGamePadKeyPress(GP.B, menu.get_int(MENU_INPUT_INT_NAME)) 
    sleep(menu.get_int(MENU_INPUT_INT_NAME))     
    input.SendVirtualGamePadKeyPress(GP.B, menu.get_int(MENU_INPUT_INT_NAME))     
end

-- =========================
-- MAIN LOOP
-- =========================
client.add_callback("on_present", function()
   if menu.get_bool("Enable GTA 5 Macros") then
    local key_run = menu.get_keybind(MENU_KEY_RUN)
    if input.is_key_pressed(key_run) then
        run_macro()
    end

    local key_run_2 = menu.get_keybind(MENU_KEY_RUN_2)
    if input.is_key_pressed(key_run_2) then
        run_macro_2()
    end

    local key_run_3 = menu.get_keybind(MENU_KEY_RUN_3)
    if input.is_key_pressed(key_run_3) then
        run_macro_3()
    end
	
    local key_run_4 = menu.get_keybind(MENU_KEY_RUN_4)
    if input.is_key_pressed(key_run_4) then
        run_macro_4()
    end
	
    local key_run_5 = menu.get_keybind(MENU_KEY_RUN_5)
    if input.is_key_pressed(key_run_5) then
        run_macro_5()
    end
	
    local key_run_6 = menu.get_keybind(MENU_KEY_RUN_6)
    if input.is_key_pressed(key_run_6) then
        run_macro_6()
    end
	
    local key_run_7 = menu.get_keybind(MENU_KEY_RUN_7)
    if input.is_key_pressed(key_run_7) then
        run_macro_7()
    end
	
    local key_run_8 = menu.get_keybind(MENU_KEY_RUN_8)
    if input.is_key_pressed(key_run_8) then
        run_macro_8()
    end
       
    local key_run_9 = menu.get_keybind(MENU_KEY_RUN_9)
    if input.is_key_pressed(key_run_9) then
        run_macro_9()
    end
   end
end)





