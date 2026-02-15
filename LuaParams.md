# Project-GLD Lua API Documentation

**Version:** 6.99+  
**Last Updated:** February 2026

## Table of Contents

1. [Overview](#overview)
2. [Core Libraries](#core-libraries)
3. [Global Functions](#global-functions)
4. [Namespace Reference](#namespace-reference)
   - [client](#client-namespace)
   - [notifications](#notifications-namespace)
   - [menu](#menu-namespace)
   - [utils](#utils-namespace)
   - [http](#http-namespace)
   - [file](#file-namespace)
   - [game](#game-namespace)
   - [browser](#browser-namespace)
   - [communication](#communication-namespace)
   - [SteamApi](#steamapi-namespace)
   - [Download](#download-namespace)
   - [GameLibrary](#gamelibrary-namespace)
   - [settings](#settings-namespace)
   - [zip](#zip-namespace)
   - [dll](#dll-namespace)
   - [gldconsole](#gldconsole-namespace)
   - [save](#save-namespace)
   - [input](#input-namespace)
   - [VK](#vk-virtual-keys)
   - [base64](#base64-namespace)
5. [HTML/XML Parsing](#htmlxml-parsing)
6. [JSON Parsing](#json-parsing)
7. [Callback System](#callback-system)
8. [Types Reference](#types-reference)

---

## Overview

Project-GLD provides a comprehensive Lua scripting API built on top of Sol2, enabling full control over the game launcher's functionality. The API exposes browser control, file operations, HTTP requests, UI manipulation, and more.

### Key Features

- **CEF Browser Integration** - Create and control Chromium browsers
- **HTTP Client** - Make web requests with custom headers
- **File System Operations** - Read, write, and manipulate files
- **UI Customization** - Create menus with various control types
- **Download Management** - Handle file downloads with resume support
- **Steam Integration** - Query Steam API for game data
- **DLL Injection** - Inject mods and tools into games
- **Save Management** - Backup, restore, and sync game saves
- **Input Simulation** - Send keyboard and mouse events

### Important Notes

- **sol::this_state arguments** are automatically hidden from Lua
- **Optional parameters** are indicated with `= default_value`
- **sol::nil** indicates deprecated/unavailable functions
- All Lua standard libraries are available (base, string, math, table, debug, package, os, coroutine, io, utf8, bit32)

---

## Core Libraries

All standard Lua libraries are available:
- `base` - Core Lua functions
- `string` - String manipulation
- `math` - Mathematical functions
- `table` - Table operations
- `debug` - Debug utilities
- `package` - Module system
- `os` - Operating system functions
- `coroutine` - Coroutine support
- `io` - Input/output
- `utf8` - UTF-8 utilities
- `bit32` - Bitwise operations

---

## Global Functions

### print
```lua
print(...)
```
Prints to console (only when debugging is active).

**Parameters:**
- `...` - Variable number of arguments to print

**Example:**
```lua
print("Hello", "World", 123)
```

---

### exec
```lua
exec(execpath, delay, commandline, isinnosetup, innoproccess)
```
Execute an external program.

**Parameters:**
- `execpath` (string) - Path to executable
- `delay` (int, optional) - Delay in milliseconds before execution (default: 0)
- `commandline` (string, optional) - Command line arguments (default: "")
- `isinnosetup` (bool, optional) - Whether the executable is an Inno Setup installer (default: false)
- `innoproccess` (string, optional) - Process name to monitor for Inno Setup (default: "")

**Example:**
```lua
exec("C:\\Games\\MyGame.exe", 1000, "--fullscreen", false, "")
```

---

### system
```lua
system(command, delay)
```
Execute a system command (CMD command).

**Parameters:**
- `command` (string) - Command to execute
- `delay` (int, optional) - Delay in milliseconds before execution (default: 0)

**Example:**
```lua
system("tasklist", 0)
```

---

### system_output
```lua
local result = system_output(command, delay)
```
Execute a system command and capture its output.

**Parameters:**
- `command` (string) - Command to execute
- `delay` (int, optional) - Delay in milliseconds (default: 0)

**Returns:**
- `string` - Command output

**Example:**
```lua
local output = system_output("ipconfig", 0)
print(output)
```

---

### sleep
```lua
sleep(ms)
```
Pause execution for a specified duration.

**Parameters:**
- `ms` (int) - Milliseconds to sleep

**Example:**
```lua
sleep(1000)  -- Wait 1 second
```

---

### beep
```lua
beep(frequency, duration)
```
Play a system beep sound.

**Parameters:**
- `frequency` (int, optional) - Frequency in Hz (default: 1000)
- `duration` (int, optional) - Duration in milliseconds (default: 500)

**Example:**
```lua
beep(440, 1000)  -- A4 note for 1 second
```

---

### xor_decrypt
```lua
local plaintext = xor_decrypt(hex)
```
Decrypt a hex-encoded XOR encrypted string.

**Parameters:**
- `hex` (string) - Hex-encoded encrypted string

**Returns:**
- `string` - Decrypted plaintext

**Example:**
```lua
local decrypted = xor_decrypt("48656C6C6F")
```

---

### xor_encrypt
```lua
local encrypted = xor_encrypt(plain)
```
Encrypt a string using XOR encryption and return as hex.

**Parameters:**
- `plain` (string) - Plaintext to encrypt

**Returns:**
- `string` - Hex-encoded encrypted string

**Example:**
```lua
local encrypted = xor_encrypt("Hello")
```

---

### __nil_callback
```lua
__nil_callback()
```
Placeholder function for nil callbacks. Used internally by the system.

---

## Namespace Reference

## client Namespace

The `client` namespace handles core application functionality including script management, callbacks, and system information.

### client.add_callback
```lua
client.add_callback(eventname, func)
```
Register a callback function for a specific event.

**Parameters:**
- `eventname` (string) - Name of the event (see [Callback System](#callback-system))
- `func` (function) - Callback function to execute

**Example:**
```lua
client.add_callback("on_gamesearch", function()
    print("Game search triggered")
end)
```

---

### client.load_script
```lua
client.load_script(name)
```
Load and execute a Lua script.

**Parameters:**
- `name` (string) - Script name (without .lua extension)

**Example:**
```lua
client.load_script("myscript")
```

---

### client.unload_script
```lua
client.unload_script(name)
```
Unload a currently running script.

**Parameters:**
- `name` (string) - Script name to unload

**Example:**
```lua
client.unload_script("myscript")
```

---

### client.create_script
```lua
client.create_script(name, data)
```
Create a new script file with the given content.

**Parameters:**
- `name` (string) - Script filename
- `data` (string) - Lua code content

**Example:**
```lua
client.create_script("helper.lua", [[
    function greet()
        print("Hello!")
    end
]])
```

---

### client.auto_script_update
```lua
client.auto_script_update(scripturl, scriptversion)
```
Enable automatic script updates from a remote URL.

**Parameters:**
- `scripturl` (string) - URL to download script from
- `scriptversion` (string) - Local version string (expects `local VERSION = "x.x.x"` in script)

**Example:**
```lua
local VERSION = "1.0.0"
client.auto_script_update("https://example.com/script.lua", VERSION)
```

---

### client.log
```lua
client.log(title, text)
```
Write a log entry to the application log.

**Parameters:**
- `title` (string) - Log title
- `text` (string) - Log message

**Example:**
```lua
client.log("Script Started", "Initialization complete")
```

---

### client.quit
```lua
client.quit()
```
Exit the application.

**Example:**
```lua
client.quit()
```

---

### client.GetVersion
```lua
local version = client.GetVersion()
```
Get the current application version as a string.

**Returns:**
- `string` - Version string (e.g., "2.15")

**Example:**
```lua
local ver = client.GetVersion()
print("Version: " .. ver)
```

---

### client.GetVersionFloat
```lua
local version = client.GetVersionFloat()
```
Get the current application version as a float.

**Returns:**
- `float` - Version number

**Example:**
```lua
local ver = client.GetVersionFloat()
if ver >= 2.15 then
    print("Version check passed")
end
```

---

### client.GetVersionDouble
```lua
local version = client.GetVersionDouble()
```
Get the current application version as a double.

**Returns:**
- `double` - Version number

**Example:**
```lua
local ver = client.GetVersionDouble()
```

---

### client.CleanSearchTextureCache
```lua
client.CleanSearchTextureCache()
```
Clear the texture cache for search results.

**Example:**
```lua
client.CleanSearchTextureCache()
```

---

### client.CleanLibraryTextureCache
```lua
client.CleanLibraryTextureCache()
```
Clear the texture cache for the game library.

**Example:**
```lua
client.CleanLibraryTextureCache()
```

---

### client.GetScriptsPath
```lua
local path = client.GetScriptsPath()
```
Get the path to the scripts directory.

**Returns:**
- `string` - Full path to scripts folder

**Example:**
```lua
local scriptsPath = client.GetScriptsPath()
print("Scripts located at: " .. scriptsPath)
```

---

### client.GetDefaultSavePath
```lua
local path = client.GetDefaultSavePath()
```
Get the default save file path.

**Returns:**
- `string` - Default save path

**Example:**
```lua
local savePath = client.GetDefaultSavePath()
```

---

### client.GetScreenHeight
```lua
local height = client.GetScreenHeight()
```
Get the screen height in pixels.

**Returns:**
- `int` - Screen height

**Example:**
```lua
local h = client.GetScreenHeight()
```

---

### client.GetScreenWidth
```lua
local width = client.GetScreenWidth()
```
Get the screen width in pixels.

**Returns:**
- `int` - Screen width

**Example:**
```lua
local w = client.GetScreenWidth()
```

---

## notifications Namespace

The `notifications` namespace provides functions to display toast notifications to the user.

### notifications.push
```lua
notifications.push(title, text)
```
Display a standard notification.

**Parameters:**
- `title` (string) - Notification title
- `text` (string) - Notification message

**Example:**
```lua
notifications.push("Download Complete", "Your file is ready")
```

---

### notifications.push_success
```lua
notifications.push_success(title, text)
```
Display a success notification (typically green).

**Parameters:**
- `title` (string) - Notification title
- `text` (string) - Notification message

**Example:**
```lua
notifications.push_success("Success", "Installation completed successfully")
```

---

### notifications.push_error
```lua
notifications.push_error(title, text)
```
Display an error notification (typically red).

**Parameters:**
- `title` (string) - Notification title
- `text` (string) - Notification message

**Example:**
```lua
notifications.push_error("Error", "Failed to connect to server")
```

---

### notifications.push_warning
```lua
notifications.push_warning(title, text)
```
Display a warning notification (typically yellow).

**Parameters:**
- `title` (string) - Notification title
- `text` (string) - Notification message

**Example:**
```lua
notifications.push_warning("Warning", "Low disk space detected")
```

---

## menu Namespace

The `menu` namespace allows scripts to create custom UI elements and interact with user settings.

### menu.set_dpi
```lua
menu.set_dpi(dpi)
```
Set the UI DPI scaling.

**Parameters:**
- `dpi` (double) - DPI scale factor

**Example:**
```lua
menu.set_dpi(1.5)
```

---

### menu.set_visible
```lua
menu.set_visible(visible)
```
Show or hide the menu.

**Parameters:**
- `visible` (bool) - true to show, false to hide

**Example:**
```lua
menu.set_visible(true)
```

---

### menu.is_main_window_active
```lua
local active = menu.is_main_window_active()
```
Check if the main window is currently active.

**Returns:**
- `bool` - true if main window is active

**Example:**
```lua
if menu.is_main_window_active() then
    print("Window is focused")
end
```

---

### menu.next_line
```lua
menu.next_line()
```
Add a line break in the menu layout.

**Example:**
```lua
menu.add_button("Button 1")
menu.next_line()
menu.add_button("Button 2")
```

---

### menu.add_check_box
```lua
menu.add_check_box(name)
```
Add a checkbox control to the menu.

**Parameters:**
- `name` (string) - Unique identifier for the checkbox

**Example:**
```lua
menu.add_check_box("enable_feature")
```

---

### menu.add_button
```lua
menu.add_button(name)
```
Add a button control to the menu. Use `on_button_` + name callback to handle clicks.

**Parameters:**
- `name` (string) - Button label and identifier

**Example:**
```lua
menu.add_button("Download")

client.add_callback("on_button_Download", function()
    print("Download button clicked")
end)
```

---

### menu.add_text
```lua
menu.add_text(text)
```
Add static text to the menu.

**Parameters:**
- `text` (string) - Text to display

**Example:**
```lua
menu.add_text("Configuration Options:")
```

---

### menu.add_input_text
```lua
menu.add_input_text(name)
```
Add a text input field to the menu.

**Parameters:**
- `name` (string) - Unique identifier for the input

**Example:**
```lua
menu.add_input_text("username")
```

---

### menu.add_input_int
```lua
menu.add_input_int(name, min, max)
```
Add an integer input field to the menu.

**Parameters:**
- `name` (string) - Unique identifier
- `min` (int) - Minimum value
- `max` (int) - Maximum value

**Example:**
```lua
menu.add_input_int("max_downloads", 1, 10)
```

---

### menu.add_input_float
```lua
menu.add_input_float(name, min, max)
```
Add a floating-point input field to the menu.

**Parameters:**
- `name` (string) - Unique identifier
- `min` (float) - Minimum value
- `max` (float) - Maximum value

**Example:**
```lua
menu.add_input_float("volume", 0.0, 1.0)
```

---

### menu.add_combo_box
```lua
menu.add_combo_box(name, labels)
```
Add a dropdown combo box to the menu.

**Parameters:**
- `name` (string) - Unique identifier
- `labels` (table) - Array of string options

**Example:**
```lua
menu.add_combo_box("quality", {"Low", "Medium", "High", "Ultra"})
```

---

### menu.add_slider_int
```lua
menu.add_slider_int(name, min, max)
```
Add an integer slider to the menu.

**Parameters:**
- `name` (string) - Unique identifier
- `min` (int) - Minimum value
- `max` (int) - Maximum value

**Example:**
```lua
menu.add_slider_int("connections", 1, 16)
```

---

### menu.add_slider_float
```lua
menu.add_slider_float(name, min, max)
```
Add a floating-point slider to the menu.

**Parameters:**
- `name` (string) - Unique identifier
- `min` (float) - Minimum value
- `max` (float) - Maximum value

**Example:**
```lua
menu.add_slider_float("opacity", 0.0, 1.0)
```

---

### menu.add_color_picker
```lua
menu.add_color_picker(name)
```
Add a color picker control to the menu.

**Parameters:**
- `name` (string) - Unique identifier

**Example:**
```lua
menu.add_color_picker("theme_color")
```

---

### menu.add_keybind
```lua
menu.add_keybind(name, default_key)
```
Add a keybind control to the menu.

**Parameters:**
- `name` (string) - Unique identifier
- `default_key` (int) - Default virtual key code

**Example:**
```lua
menu.add_keybind("hotkey", 0x70)  -- F1 key
```

---

### Getters

### menu.get_bool
```lua
local value = menu.get_bool(name)
```
Get the value of a checkbox.

**Returns:**
- `bool` - Checkbox state

**Example:**
```lua
if menu.get_bool("enable_feature") then
    -- Feature is enabled
end
```

---

### menu.get_text
```lua
local value = menu.get_text(name)
```
Get the value of a text input.

**Returns:**
- `string` - Input text

**Example:**
```lua
local username = menu.get_text("username")
```

---

### menu.get_int
```lua
local value = menu.get_int(name)
```
Get the value of an integer input or slider.

**Returns:**
- `int` - Integer value

**Example:**
```lua
local maxDl = menu.get_int("max_downloads")
```

---

### menu.get_float
```lua
local value = menu.get_float(name)
```
Get the value of a float input or slider.

**Returns:**
- `float` - Float value

**Example:**
```lua
local volume = menu.get_float("volume")
```

---

### menu.get_color
```lua
local color = menu.get_color(name)
```
Get the value of a color picker.

**Returns:**
- `Color` - Color object

**Example:**
```lua
local color = menu.get_color("theme_color")
```

---

### menu.get_keybind
```lua
local key = menu.get_keybind(name)
```
Get the virtual key code of a keybind.

**Returns:**
- `int` - Virtual key code

**Example:**
```lua
local hotkey = menu.get_keybind("hotkey")
```

---

### Setters

### menu.set_bool
```lua
menu.set_bool(name, value)
```
Set the value of a checkbox.

**Parameters:**
- `name` (string) - Checkbox identifier
- `value` (bool) - New state

**Example:**
```lua
menu.set_bool("enable_feature", true)
```

---

### menu.set_text
```lua
menu.set_text(name, value)
```
Set the value of a text input.

**Parameters:**
- `name` (string) - Input identifier
- `value` (string) - New text

**Example:**
```lua
menu.set_text("username", "Player1")
```

---

### menu.set_int
```lua
menu.set_int(name, value)
```
Set the value of an integer input or slider.

**Parameters:**
- `name` (string) - Input identifier
- `value` (int) - New value

**Example:**
```lua
menu.set_int("max_downloads", 5)
```

---

### menu.set_float
```lua
menu.set_float(name, value)
```
Set the value of a float input or slider.

**Parameters:**
- `name` (string) - Input identifier
- `value` (float) - New value

**Example:**
```lua
menu.set_float("volume", 0.8)
```

---

### menu.set_color
```lua
menu.set_color(name, value)
```
Set the value of a color picker.

**Parameters:**
- `name` (string) - Color picker identifier
- `value` (Color) - New color

**Example:**
```lua
menu.set_color("theme_color", Color)
```

---

### menu.set_keybind
```lua
menu.set_keybind(name, value)
```
Set the virtual key code of a keybind.

**Parameters:**
- `name` (string) - Keybind identifier
- `value` (int) - Virtual key code

**Example:**
```lua
menu.set_keybind("hotkey", 0x71)  -- F2 key
```

---

## utils Namespace

The `utils` namespace provides utility functions for console management, logging, and time operations.

### utils.AttachConsole
```lua
utils.AttachConsole()
```
Attach a console window for debugging output.

**Example:**
```lua
utils.AttachConsole()
```

---

### utils.DetachConsole
```lua
utils.DetachConsole()
```
Detach and close the console window.

**Example:**
```lua
utils.DetachConsole()
```

---

### utils.ConsolePrint
```lua
utils.ConsolePrint(logToFile, fmt, ...)
```
Print formatted text to console (requires AttachConsole first).

**Parameters:**
- `logToFile` (bool) - Whether to also log to file
- `fmt` (string) - Format string
- `...` - Format arguments

**Example:**
```lua
utils.AttachConsole()
utils.ConsolePrint(true, "Value: %d", 42)
```

---

### utils.GetTimeString
```lua
local time = utils.GetTimeString()
```
Get current time as a formatted string.

**Returns:**
- `string` - Time string

**Example:**
```lua
local time = utils.GetTimeString()
print("Current time: " .. time)
```

---

### utils.GetTimestamp
```lua
local timestamp = utils.GetTimestamp()
```
Get current timestamp as a string.

**Returns:**
- `string` - Timestamp string

**Example:**
```lua
local ts = utils.GetTimestamp()
```

---

### utils.GetTimeUnix
```lua
local unix = utils.GetTimeUnix()
```
Get current Unix timestamp.

**Returns:**
- `int` - Unix timestamp (seconds since epoch)

**Example:**
```lua
local now = utils.GetTimeUnix()
```

---

### utils.Log
```lua
utils.Log(fmt, ...)
```
Write to Project-GLD.log file. Consider using `gldconsole.print` instead for better logging.

**Parameters:**
- `fmt` (string) - Format string
- `...` - Format arguments

**Example:**
```lua
utils.Log("Script error: %s", errorMsg)
```

---

## http Namespace

The `http` namespace provides HTTP client functionality for making web requests.

### http.get
```lua
local response = http.get(link, headers)
```
Perform an HTTP GET request.

**Parameters:**
- `link` (string) - URL to request
- `headers` (table) - Optional table of headers

**Returns:**
- `string` - Response body

**Example:**
```lua
local response = http.get("https://api.example.com/data", {
    ["User-Agent"] = "Project-GLD/2.15",
    ["Accept"] = "application/json"
})
```

---

### http.post
```lua
local response = http.post(link, body, headers)
```
Perform an HTTP POST request.

**Parameters:**
- `link` (string) - URL to request
- `body` (string) - Request body
- `headers` (table) - Optional table of headers

**Returns:**
- `string` - Response body

**Example:**
```lua
local response = http.post("https://api.example.com/submit", 
    '{"key":"value"}',
    {["Content-Type"] = "application/json"}
)
```

---

### http.put
```lua
local response = http.put(link, body, headers)
```
Perform an HTTP PUT request.

**Parameters:**
- `link` (string) - URL to request
- `body` (string) - Request body
- `headers` (table) - Optional table of headers

**Returns:**
- `string` - Response body

**Example:**
```lua
local response = http.put("https://api.example.com/update/123", '{"data":"updated"}', {})
```

---

### http.patch
```lua
local response = http.patch(link, body, headers)
```
Perform an HTTP PATCH request.

**Parameters:**
- `link` (string) - URL to request
- `body` (string) - Request body
- `headers` (table) - Optional table of headers

**Returns:**
- `string` - Response body

**Example:**
```lua
local response = http.patch("https://api.example.com/resource/1", '{"field":"value"}', {})
```

---

### http.delete
```lua
local response = http.delete(link, headers)
```
Perform an HTTP DELETE request.

**Parameters:**
- `link` (string) - URL to request
- `headers` (table) - Optional table of headers

**Returns:**
- `string` - Response body

**Example:**
```lua
local response = http.delete("https://api.example.com/item/456", {})
```

---

### http.head
```lua
local response = http.head(link, headers)
```
Perform an HTTP HEAD request.

**Parameters:**
- `link` (string) - URL to request
- `headers` (table) - Optional table of headers

**Returns:**
- `string` - Response headers

**Example:**
```lua
local headers = http.head("https://example.com/file.zip", {})
```

---

### http.options
```lua
local response = http.options(link, headers)
```
Perform an HTTP OPTIONS request.

**Parameters:**
- `link` (string) - URL to request
- `headers` (table) - Optional table of headers

**Returns:**
- `string` - Response body

**Example:**
```lua
local options = http.options("https://api.example.com", {})
```

---

### http.request
```lua
local response = http.request(method, link, body, headers)
```
Perform a custom HTTP request.

**Parameters:**
- `method` (string) - HTTP method (GET, POST, etc.)
- `link` (string) - URL to request
- `body` (string) - Request body
- `headers` (table) - Optional table of headers

**Returns:**
- `string` - Response body

**Example:**
```lua
local response = http.request("CUSTOM", "https://api.example.com", "", {})
```

---

### http.CloudFlareSolver
```lua
http.CloudFlareSolver(url)
```
Solve Cloudflare challenges and obtain cookies. Results are returned via the `on_cfdone` callback.

**Parameters:**
- `url` (string) - URL protected by Cloudflare

**Important:** Use the following User-Agent with the returned cookie:
`Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15`

**Example:**
```lua
client.add_callback("on_cfdone", function(cookie, url)
    print("Cloudflare solved for: " .. url)
    print("Cookie: " .. cookie)
    
    -- Now make requests with the cookie
    local response = http.get(url, {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15",
        ["Cookie"] = cookie
    })
end)

http.CloudFlareSolver("https://protected-site.com")
```

---

### http.byetresolver
```lua
local result = http.byetresolver(url)
```
Alternative resolver for protected URLs.

**Parameters:**
- `url` (string) - URL to resolve

**Returns:**
- `string` - Resolved content

**Example:**
```lua
local content = http.byetresolver("https://example.com")
```

---

## file Namespace

The `file` namespace provides comprehensive file system operations.

### file.append
```lua
file.append(path, data)
```
Append data to a file.

**Parameters:**
- `path` (string) - File path
- `data` (string) - Data to append

**Example:**
```lua
file.append("C:\\log.txt", "New log entry\n")
```

---

### file.write
```lua
file.write(path, data)
```
Write data to a file (overwrites existing content).

**Parameters:**
- `path` (string) - File path
- `data` (string) - Data to write

**Example:**
```lua
file.write("C:\\config.json", '{"setting":true}')
```

---

### file.read
```lua
local content = file.read(path)
```
Read the entire contents of a file.

**Parameters:**
- `path` (string) - File path

**Returns:**
- `string` - File contents

**Example:**
```lua
local config = file.read("C:\\config.json")
local data = JsonWrapper.parse(config)
```

---

### file.delete
```lua
file.delete(path)
```
Delete a file.

**Parameters:**
- `path` (string) - File path

**Example:**
```lua
file.delete("C:\\temp\\cache.tmp")
```

---

### file.exists
```lua
local exists = file.exists(path)
```
Check if a file or directory exists.

**Parameters:**
- `path` (string) - File or directory path

**Returns:**
- `bool` - true if exists

**Example:**
```lua
if file.exists("C:\\Games\\game.exe") then
    print("Game is installed")
end
```

---

### file.exec
```lua
file.exec(execpath, delay, commandline, isinnosetup, innoproccess)
```
Execute a file. Same as global `exec` function.

**Parameters:**
- `execpath` (string) - Path to executable
- `delay` (int, optional) - Delay in milliseconds (default: 0)
- `commandline` (string, optional) - Command line arguments (default: "")
- `isinnosetup` (bool, optional) - Inno Setup installer flag (default: false)
- `innoproccess` (string, optional) - Process name for Inno Setup (default: "")

**Example:**
```lua
file.exec("C:\\Setup.exe", 0, "/SILENT", true, "setup.exe")
```

---

### file.listfolders
```lua
local folders = file.listfolders(path)
```
List all folders in a directory.

**Parameters:**
- `path` (string) - Directory path

**Returns:**
- `table` - Array of folder names

**Example:**
```lua
local folders = file.listfolders("C:\\Games")
for _, folder in ipairs(folders) do
    print(folder)
end
```

---

### file.listexecutables
```lua
local exes = file.listexecutables(path)
```
List all executable files in a directory.

**Parameters:**
- `path` (string) - Directory path

**Returns:**
- `table` - Array of executable filenames

**Example:**
```lua
local exes = file.listexecutables("C:\\Games\\MyGame")
```

---

### file.listexecutablesrecursive
```lua
local exes = file.listexecutablesrecursive(path)
```
Recursively list all executable files in a directory and subdirectories.

**Parameters:**
- `path` (string) - Directory path

**Returns:**
- `table` - Array of executable file paths

**Example:**
```lua
local allExes = file.listexecutablesrecursive("C:\\Games")
```

---

### file.listcompactedfiles
```lua
local archives = file.listcompactedfiles(path)
```
List all compressed archive files (zip, rar, 7z, tar, etc.) in a directory.

**Parameters:**
- `path` (string) - Directory path

**Returns:**
- `table` - Array of archive filenames

**Example:**
```lua
local archives = file.listcompactedfiles("C:\\Downloads")
```

---

### file.getusername
```lua
local username = file.getusername
```
Get the current Windows username (note: this is a property, not a function).

**Returns:**
- `string` - Windows username

**Example:**
```lua
local user = file.getusername
print("Current user: " .. user)
```

---

### file.create_directory
```lua
file.create_directory(path)
```
Create a new directory.

**Parameters:**
- `path` (string) - Directory path to create

**Example:**
```lua
file.create_directory("C:\\Games\\MyGame\\Saves")
```

---

### file.copy_file
```lua
file.copy_file(src, dst)
```
Copy a file from source to destination.

**Parameters:**
- `src` (string) - Source file path
- `dst` (string) - Destination file path

**Example:**
```lua
file.copy_file("C:\\game.cfg", "C:\\backup\\game.cfg")
```

---

### file.move_file
```lua
file.move_file(src, dst)
```
Move a file from source to destination.

**Parameters:**
- `src` (string) - Source file path
- `dst` (string) - Destination file path

**Example:**
```lua
file.move_file("C:\\temp\\file.txt", "C:\\final\\file.txt")
```

---

### file.get_filename
```lua
local filename = file.get_filename(path)
```
Extract the filename from a path.

**Parameters:**
- `path` (string) - Full file path

**Returns:**
- `string` - Filename with extension

**Example:**
```lua
local name = file.get_filename("C:\\Games\\game.exe")
-- Returns: "game.exe"
```

---

### file.get_extension
```lua
local ext = file.get_extension(path)
```
Extract the file extension from a path.

**Parameters:**
- `path` (string) - File path

**Returns:**
- `string` - File extension (without dot)

**Example:**
```lua
local ext = file.get_extension("document.pdf")
-- Returns: "pdf"
```

---

### file.get_parent_path
```lua
local parent = file.get_parent_path(path)
```
Get the parent directory of a path.

**Parameters:**
- `path` (string) - File or directory path

**Returns:**
- `string` - Parent directory path

**Example:**
```lua
local parent = file.get_parent_path("C:\\Games\\MyGame\\game.exe")
-- Returns: "C:\\Games\\MyGame"
```

---

### file.list_directory
```lua
local items = file.list_directory(path)
```
List all items (files and folders) in a directory.

**Parameters:**
- `path` (string) - Directory path

**Returns:**
- `table` - Lua table containing directory contents

**Example:**
```lua
local items = file.list_directory("C:\\Games")
```

---

## game Namespace

The `game` namespace provides functions for interacting with game information within search results.

### game.getgamename
```lua
local name = game.getgamename()
```
Get the name of the currently selected game (must be called from within game page context).

**Returns:**
- `string` - Game name

**Example:**
```lua
client.add_callback("on_gameselected", function()
    local gameName = game.getgamename()
    print("Selected game: " .. gameName)
end)
```

---

## browser Namespace

The `browser` namespace provides functions to create and manage CEF (Chromium Embedded Framework) browser instances.

### browser.CreateBrowser
```lua
local browserInstance = browser.CreateBrowser(browser_name, browser_url)
```
Create a new browser instance. Browser names are unique - only one browser per name can exist.

**Parameters:**
- `browser_name` (string) - Unique identifier for the browser
- `browser_url` (string) - Initial URL to load

**Returns:**
- `GLDBrowser*` - Browser instance

**Example:**
```lua
local myBrowser = browser.CreateBrowser("resolver", "https://example.com")
```

---

### browser.GetBrowserByName
```lua
local browserInstance = browser.GetBrowserByName(name)
```
Retrieve an existing browser instance by name.

**Parameters:**
- `name` (string) - Browser identifier

**Returns:**
- `GLDBrowser*` - Browser instance or nil

**Example:**
```lua
local myBrowser = browser.GetBrowserByName("resolver")
if myBrowser then
    myBrowser:ChangeBrowserURL("https://newurl.com")
end
```

---

### browser.GetBrowserByID
```lua
local browserInstance = browser.GetBrowserByID(id)
```
Retrieve an existing browser instance by ID.

**Parameters:**
- `id` (int) - Browser ID

**Returns:**
- `GLDBrowser*` - Browser instance or nil

**Example:**
```lua
local browserInstance = browser.GetBrowserByID(1)
```

---

### browser.set_visible
```lua
browser.set_visible(visible, browser_name)
```
Show or hide a browser window.

**Parameters:**
- `visible` (bool) - true to show, false to hide
- `browser_name` (string) - Browser identifier

**Example:**
```lua
browser.set_visible(true, "resolver")
```

---

### browser.IsBrowserVisible
```lua
local visible = browser.IsBrowserVisible(browser_name)
```
Check if a browser is currently visible.

**Parameters:**
- `browser_name` (string) - Browser identifier

**Returns:**
- `bool` - true if visible

**Example:**
```lua
if browser.IsBrowserVisible("resolver") then
    print("Browser is shown to user")
end
```

---

### browser.EnableCaptchaDetection
```lua
browser.EnableCaptchaDetection(browser_name)
```
Enable automatic CAPTCHA detection (default is on).

**Parameters:**
- `browser_name` (string) - Browser identifier

**Example:**
```lua
browser.EnableCaptchaDetection("resolver")
```

---

### browser.DisableCaptchaDetection
```lua
browser.DisableCaptchaDetection(browser_name)
```
Disable automatic CAPTCHA detection. Use if stuck on Cloudflare "Just a moment" page.

**Parameters:**
- `browser_name` (string) - Browser identifier

**Example:**
```lua
browser.DisableCaptchaDetection("resolver")
```

---

### browser.IsCaptchaDetectionOn
```lua
local enabled = browser.IsCaptchaDetectionOn(browser_name)
```
Check if CAPTCHA detection is enabled.

**Parameters:**
- `browser_name` (string) - Browser identifier

**Returns:**
- `bool` - true if enabled

**Example:**
```lua
if browser.IsCaptchaDetectionOn("resolver") then
    print("CAPTCHA detection is active")
end
```

---

## GLDBrowser Type

The `GLDBrowser` type represents a CEF browser instance with full control over navigation, content, and behavior.

### Properties

#### burl
```lua
local url = browserInstance.burl
```
Current browser URL (property).

#### name
```lua
local name = browserInstance.name
```
Browser instance name (property).

#### is_rendering
```lua
local rendering = browserInstance.is_rendering
```
Whether the browser is currently rendering (property).

### Browser State Methods

#### HasBrowser
```lua
local has = browserInstance:HasBrowser()
```
Check if browser instance is valid.

**Returns:**
- `bool` - true if browser exists

---

#### CanGoBack
```lua
local can = browserInstance:CanGoBack()
```
Check if browser can navigate backwards.

**Returns:**
- `bool` - true if back navigation is possible

---

#### CanGoForward
```lua
local can = browserInstance:CanGoForward()
```
Check if browser can navigate forwards.

**Returns:**
- `bool` - true if forward navigation is possible

---

#### IsLoading
```lua
local loading = browserInstance:IsLoading()
```
Check if page is currently loading.

**Returns:**
- `bool` - true if loading

---

#### GetID
```lua
local id = browserInstance:GetID()
```
Get the browser's unique ID.

**Returns:**
- `int` - Browser ID

---

### Navigation Methods

#### ChangeBrowserURL
```lua
browserInstance:ChangeBrowserURL(url)
```
Navigate to a new URL.

**Parameters:**
- `url` (string) - URL to navigate to

**Example:**
```lua
myBrowser:ChangeBrowserURL("https://example.com")
```

---

#### ReloadBrowserPage
```lua
browserInstance:ReloadBrowserPage()
```
Reload the current page.

**Example:**
```lua
myBrowser:ReloadBrowserPage()
```

---

#### ReloadIgnoreCache
```lua
browserInstance:ReloadIgnoreCache()
```
Reload the current page, ignoring cache.

**Example:**
```lua
myBrowser:ReloadIgnoreCache()
```

---

#### GoBackBrowser
```lua
browserInstance:GoBackBrowser()
```
Navigate backwards in history.

**Example:**
```lua
if myBrowser:CanGoBack() then
    myBrowser:GoBackBrowser()
end
```

---

#### GoForwardBrowser
```lua
browserInstance:GoForwardBrowser()
```
Navigate forwards in history.

**Example:**
```lua
if myBrowser:CanGoForward() then
    myBrowser:GoForwardBrowser()
end
```

---

#### CancelLoading
```lua
browserInstance:CancelLoading()
```
Cancel the current page load.

**Example:**
```lua
myBrowser:CancelLoading()
```

---

#### CloseBrowser
```lua
local closed = browserInstance:CloseBrowser()
```
Close and destroy the browser instance.

**Returns:**
- `bool` - true if successfully closed

**Example:**
```lua
myBrowser:CloseBrowser()
```

---

#### BrowserUrl
```lua
local url = browserInstance:BrowserUrl()
```
Get the current URL.

**Returns:**
- `string` - Current URL

**Example:**
```lua
local currentUrl = myBrowser:BrowserUrl()
```

---

### Content Methods

#### GetPageTitle
```lua
local title = browserInstance:GetPageTitle()
```
Get the current page title.

**Returns:**
- `string` - Page title

**Example:**
```lua
local title = myBrowser:GetPageTitle()
```

---

#### GetBrowserSource
```lua
browserInstance:GetBrowserSource(callback)
```
Get the page source HTML asynchronously.

**Parameters:**
- `callback` (function) - Callback function that receives the HTML source

**Example:**
```lua
myBrowser:GetBrowserSource(function(source)
    print("Page source length: " .. #source)
    -- Parse HTML here
    local doc = html.parse(source)
end)
```

---

### JavaScript Execution

#### ExecuteJavaScriptOnMainFrame
```lua
browserInstance:ExecuteJavaScriptOnMainFrame(javascript_code)
```
Execute JavaScript in the main frame.

**Parameters:**
- `javascript_code` (string) - JavaScript code to execute

**Example:**
```lua
myBrowser:ExecuteJavaScriptOnMainFrame([[
    document.querySelector('#username').value = 'testuser';
    document.querySelector('#submit').click();
]])
```

---

#### ExecuteJavaScriptOnFocusedFrame
```lua
browserInstance:ExecuteJavaScriptOnFocusedFrame(javascript_code)
```
Execute JavaScript in the currently focused frame.

**Parameters:**
- `javascript_code` (string) - JavaScript code to execute

**Example:**
```lua
myBrowser:ExecuteJavaScriptOnFocusedFrame("alert('Hello from focused frame');")
```

---

### Clipboard Operations

#### Copy
```lua
browserInstance:Copy()
```
Copy selected content to clipboard.

---

#### Cut
```lua
browserInstance:Cut()
```
Cut selected content to clipboard.

---

#### Paste
```lua
browserInstance:Paste()
```
Paste from clipboard.

---

#### PasteAsPlainText
```lua
browserInstance:PasteAsPlainText()
```
Paste from clipboard as plain text.

---

#### Undo
```lua
browserInstance:Undo()
```
Undo last action.

---

#### Redo
```lua
browserInstance:Redo()
```
Redo last undone action.

---

#### SelectAll
```lua
browserInstance:SelectAll()
```
Select all content on the page.

---

### View Control

#### ZoomIn
```lua
browserInstance:ZoomIn()
```
Increase zoom level.

---

#### ZoomOut
```lua
browserInstance:ZoomOut()
```
Decrease zoom level.

---

#### ZoomReset
```lua
browserInstance:ZoomReset()
```
Reset zoom to 100%.

---

#### MuteAudio
```lua
browserInstance:MuteAudio(mute)
```
Mute or unmute browser audio.

**Parameters:**
- `mute` (bool) - true to mute, false to unmute

---

#### Print
```lua
browserInstance:Print()
```
Open print dialog.

---

#### Resize
```lua
browserInstance:Resize()
```
Trigger browser resize event.

---

#### ViewSource
```lua
browserInstance:ViewSource()
```
Show page source in new window.

---

#### SavePageAs
```lua
browserInstance:SavePageAs()
```
Open save page dialog.

---

### Search Operations

#### Find
```lua
browserInstance:Find(searchText, forward, matchCase, findNext)
```
Search for text on the page.

**Parameters:**
- `searchText` (string) - Text to find
- `forward` (bool) - Search direction (true = forward)
- `matchCase` (bool) - Case-sensitive search
- `findNext` (bool) - Find next occurrence

**Example:**
```lua
myBrowser:Find("download", true, false, false)
```

---

#### StopFinding
```lua
browserInstance:StopFinding(clearSelection)
```
Stop the current find operation.

**Parameters:**
- `clearSelection` (bool) - Whether to clear the selection

---

### Download Operations

#### AddDownload
```lua
browserInstance:AddDownload(url)
```
Add a URL to the download queue.

**Parameters:**
- `url` (string) - URL to download

**Example:**
```lua
myBrowser:AddDownload("https://example.com/file.zip")
```

---

#### DownloadImage
```lua
browserInstance:DownloadImage(imageUrl)
```
Download an image.

**Parameters:**
- `imageUrl` (string) - Image URL

**Example:**
```lua
myBrowser:DownloadImage("https://example.com/image.jpg")
```

---

### Developer Tools

#### ShowDevTools
```lua
browserInstance:ShowDevTools()
```
Open developer tools window.

---

#### CloseDevTools
```lua
browserInstance:CloseDevTools()
```
Close developer tools window.

---

#### InspectElementAt
```lua
browserInstance:InspectElementAt(x, y)
```
Inspect element at specific coordinates.

**Parameters:**
- `x` (int) - X coordinate
- `y` (int) - Y coordinate

---

### Popup Management

#### OpenBrowserPopup
```lua
browserInstance:OpenBrowserPopup(url, title)
```
Open a popup window.

**Parameters:**
- `url` (string) - URL for popup
- `title` (string) - Popup window title

---

### Local Storage

#### ClearLocalStorage
```lua
browserInstance:ClearLocalStorage()
```
Clear all local storage data.

---

#### SetCustomLocalStorageValueForURL
```lua
browserInstance:SetCustomLocalStorageValueForURL(url, key, value)
```
Set a custom local storage value for a URL.

**Parameters:**
- `url` (string) - Target URL
- `key` (string) - Storage key
- `value` (string) - Storage value

---

#### RemoveCustomLocalStorageValueForURL
```lua
browserInstance:RemoveCustomLocalStorageValueForURL(url, key)
```
Remove a custom local storage value.

**Parameters:**
- `url` (string) - Target URL
- `key` (string) - Storage key

---

## communication Namespace

The `communication` namespace handles communication between scripts and the UI.

### communication.receiveSearchResults
```lua
communication.receiveSearchResults(resultsTable)
```
Send search results to be displayed in the UI.

**Parameters:**
- `resultsTable` (table) - Lua table containing search results

**Example:**
```lua
local results = {
    {name = "Game 1", image = "url1"},
    {name = "Game 2", image = "url2"}
}
communication.receiveSearchResults(results)
```

---

### communication.RefreshScriptResults
```lua
communication.RefreshScriptResults()
```
Refresh the display of search results.

**Example:**
```lua
communication.RefreshScriptResults()
```

---

## SteamApi Namespace

The `SteamApi` namespace provides functions to interact with Steam's API.

### SteamApi.GetAppID
```lua
local appid = SteamApi.GetAppID(name)
```
Get Steam App ID from game name.

**Parameters:**
- `name` (string) - Game name

**Returns:**
- `string` - Steam App ID

**Example:**
```lua
local appid = SteamApi.GetAppID("Counter-Strike 2")
print("App ID: " .. appid)
```

---

### SteamApi.GetSystemRequirements
```lua
local requirements = SteamApi.GetSystemRequirements(appid)
```
Get system requirements for a Steam game.

**Parameters:**
- `appid` (string) - Steam App ID

**Returns:**
- `string` - System requirements (JSON format)

**Example:**
```lua
local reqs = SteamApi.GetSystemRequirements("730")
local data = JsonWrapper.parse(reqs)
```

---

### SteamApi.GetGameData
```lua
local gameData = SteamApi.GetGameData(appid)
```
Get comprehensive game data from Steam.

**Parameters:**
- `appid` (string) - Steam App ID

**Returns:**
- `string` - Game data (JSON format)

**Example:**
```lua
local data = SteamApi.GetGameData("730")
local parsed = JsonWrapper.parse(data)
```

---

### SteamApi.OpenSteam
```lua
SteamApi.OpenSteam()
```
Launch the Steam client.

**Example:**
```lua
SteamApi.OpenSteam()
```

---

### SteamApi.IsSteamRunning
```lua
local running = SteamApi.IsSteamRunning()
```
Check if Steam is currently running.

**Returns:**
- `bool` - true if Steam is running

**Example:**
```lua
if not SteamApi.IsSteamRunning() then
    SteamApi.OpenSteam()
end
```

---

## Download Namespace

The `Download` namespace manages file downloads with resume support and multi-connection capabilities.

### Download.DownloadFile
```lua
Download.DownloadFile(downloadurl)
```
Download a file to the default download path.

**Parameters:**
- `downloadurl` (string) - URL to download

**Example:**
```lua
Download.DownloadFile("https://example.com/file.zip")
```

---

### Download.GetFileNameFromUrl
```lua
local filename = Download.GetFileNameFromUrl(url)
```
Extract filename from a URL.

**Parameters:**
- `url` (string) - URL

**Returns:**
- `string` - Extracted filename

**Example:**
```lua
local name = Download.GetFileNameFromUrl("https://example.com/files/game.zip")
-- Returns: "game.zip"
```

---

### Download.DirectDownload
```lua
Download.DirectDownload(downloadurl, downloadpath)
```
Download a file to a specific path.

**Parameters:**
- `downloadurl` (string) - URL to download
- `downloadpath` (string) - Full destination path

**Example:**
```lua
Download.DirectDownload("https://example.com/file.zip", "C:\\Downloads\\file.zip")
```

---

### Download.DownloadImage
```lua
local imagePath = Download.DownloadImage(imageurl)
```
Download an image and return its local path.

**Parameters:**
- `imageurl` (string) - Image URL

**Returns:**
- `string` - Local path to downloaded image

**Example:**
```lua
local imgPath = Download.DownloadImage("https://example.com/cover.jpg")
```

---

### Download.ChangeDownloadPath
```lua
Download.ChangeDownloadPath(path)
```
Change the default download directory.

**Parameters:**
- `path` (string) - New download directory path

**Example:**
```lua
Download.ChangeDownloadPath("D:\\Games\\Downloads")
```

---

### Download.GetDownloadPath
```lua
local path = Download.GetDownloadPath()
```
Get the current default download path.

**Returns:**
- `string` - Download directory path

**Example:**
```lua
local dlPath = Download.GetDownloadPath()
```

---

### Download.ChangeMaxActiveDownloads
```lua
Download.ChangeMaxActiveDownloads(maxdownloads)
```
Set maximum number of simultaneous downloads.

**Parameters:**
- `maxdownloads` (int) - Maximum active downloads

**Example:**
```lua
Download.ChangeMaxActiveDownloads(3)
```

---

### Download.GetMaxActiveDownloads
```lua
local max = Download.GetMaxActiveDownloads()
```
Get the maximum number of simultaneous downloads.

**Returns:**
- `int` - Maximum active downloads

**Example:**
```lua
local max = Download.GetMaxActiveDownloads()
```

---

### Download.SetMaxConnections
```lua
Download.SetMaxConnections(maxconnections)
```
Set maximum connections per download.

**Parameters:**
- `maxconnections` (int) - Maximum connections

**Example:**
```lua
Download.SetMaxConnections(8)
```

---

### Download.GetMaxConnections
```lua
local max = Download.GetMaxConnections()
```
Get the maximum connections per download.

**Returns:**
- `int` - Maximum connections

**Example:**
```lua
local max = Download.GetMaxConnections()
```

---

### Download.TorrentContentToMagnet
```lua
local magnet = Download.TorrentContentToMagnet(torrentcontent)
```
Convert torrent file content to magnet link.

**Parameters:**
- `torrentcontent` (string) - Raw torrent file content

**Returns:**
- `string` - Magnet link

**Example:**
```lua
local torrentData = file.read("C:\\file.torrent")
local magnet = Download.TorrentContentToMagnet(torrentData)
```

---

### Download.TorrentToMagnet
```lua
local magnet = Download.TorrentToMagnet(filepath)
```
Convert torrent file to magnet link.

**Parameters:**
- `filepath` (string) - Path to torrent file

**Returns:**
- `string` - Magnet link

**Example:**
```lua
local magnet = Download.TorrentToMagnet("C:\\file.torrent")
```

---

### Download.SetHistoryUrl
```lua
Download.SetHistoryUrl(url, ogurl)
```
Set download history URL for resume support. Use this when resolving downloads to enable resume functionality if the app is closed.

**Parameters:**
- `url` (string) - Resolved download URL
- `ogurl` (string) - Original unresolved URL

**Example:**
```lua
-- In on_beforedownload callback
Download.SetHistoryUrl(resolvedUrl, originalUrl)
```

---

## GameLibrary Namespace

The `GameLibrary` namespace manages the user's game library.

### GameLibrary.launch
```lua
local success = GameLibrary.launch(id)
```
Launch a game from the library.

**Parameters:**
- `id` (int) - Game ID

**Returns:**
- `bool` - true if successfully launched

**Example:**
```lua
local gameId = GameLibrary.GetGameIdFromName("My Game")
if GameLibrary.launch(gameId) then
    print("Game launched")
end
```

---

### GameLibrary.close
```lua
GameLibrary.close()
```
Close the currently running game.

**Example:**
```lua
GameLibrary.close()
```

---

### GameLibrary.addGame
```lua
GameLibrary.addGame(exePath, imagePath, gamename, commandline, disableigdbid)
```
Add a game to the library.

**Parameters:**
- `exePath` (string) - Path to game executable
- `imagePath` (string) - Path to game cover image
- `gamename` (string) - Display name
- `commandline` (string) - Launch arguments
- `disableigdbid` (bool, optional) - Disable IGDB lookup (default: false)

**Example:**
```lua
GameLibrary.addGame(
    "C:\\Games\\MyGame\\game.exe",
    "C:\\Games\\MyGame\\cover.jpg",
    "My Awesome Game",
    "--fullscreen",
    false
)
```

---

### GameLibrary.changeGameinfo
```lua
GameLibrary.changeGameinfo(id, exePath, imagePath, gamename, commandline)
```
Update game information in the library.

**Parameters:**
- `id` (int) - Game ID
- `exePath` (string, optional) - New executable path (default: "")
- `imagePath` (string, optional) - New image path (default: "")
- `gamename` (string, optional) - New name (default: "")
- `commandline` (string, optional) - New arguments (default: "")

**Example:**
```lua
local id = GameLibrary.GetGameIdFromName("My Game")
GameLibrary.changeGameinfo(id, "", "C:\\new_cover.jpg", "Updated Name", "")
```

---

### GameLibrary.removeGame
```lua
GameLibrary.removeGame(id)
```
Remove a game from the library.

**Parameters:**
- `id` (int) - Game ID

**Example:**
```lua
local id = GameLibrary.GetGameIdFromName("Old Game")
GameLibrary.removeGame(id)
```

---

### GameLibrary.GetGameIdFromName
```lua
local id = GameLibrary.GetGameIdFromName(name)
```
Get game ID by name.

**Parameters:**
- `name` (string) - Game name

**Returns:**
- `int` - Game ID (or -1 if not found)

**Example:**
```lua
local id = GameLibrary.GetGameIdFromName("Counter-Strike 2")
```

---

### GameLibrary.GetGameNameFromId
```lua
local name = GameLibrary.GetGameNameFromId(id)
```
Get game name by ID.

**Parameters:**
- `id` (int) - Game ID

**Returns:**
- `string` - Game name

**Example:**
```lua
local name = GameLibrary.GetGameNameFromId(5)
```

---

### GameLibrary.GetGamePath
```lua
local path = GameLibrary.GetGamePath(id)
```
Get the executable path for a game.

**Parameters:**
- `id` (int) - Game ID

**Returns:**
- `string` - Path to game executable

**Example:**
```lua
local path = GameLibrary.GetGamePath(5)
```

---

### GameLibrary.GetGameList
```lua
local games = GameLibrary.GetGameList()
```
Get all games in the library.

**Returns:**
- `table` - Array of game information tables

**Example:**
```lua
local games = GameLibrary.GetGameList()
for _, game in ipairs(games) do
    print(game.name, game.exePath)
end
```

---

## settings Namespace

The `settings` namespace manages application settings persistence.

### settings.save
```lua
settings.save()
```
Save current settings to disk.

**Example:**
```lua
settings.save()
```

---

### settings.load
```lua
settings.load()
```
Load settings from disk.

**Example:**
```lua
settings.load()
```

---

## zip Namespace

The `zip` namespace handles archive extraction.

### zip.extract
```lua
zip.extract(source, destination, deleteaftercomplete, pass)
```
Extract a compressed archive. Completion is signaled via the `on_extractioncompleted` callback.

**Parameters:**
- `source` (string) - Path to archive file
- `destination` (string) - Extraction destination
- `deleteaftercomplete` (bool) - Delete archive after extraction
- `pass` (string) - Archive password (empty string if no password)

**Example:**
```lua
client.add_callback("on_extractioncompleted", function(origin, destination)
    print("Extracted: " .. origin)
    print("To: " .. destination)
end)

zip.extract("C:\\Downloads\\game.zip", "C:\\Games\\", false, "")
```

---

## dll Namespace

The `dll` namespace provides DLL injection capabilities for modding and tool integration.

### dll.inject
```lua
local success = dll.inject(processexename, dllpath, delay)
```
Inject a 64-bit DLL into a running process.

**Parameters:**
- `processexename` (string) - Target process name (e.g., "game.exe")
- `dllpath` (string) - Path to DLL file
- `delay` (int) - Delay in milliseconds before injection

**Returns:**
- `bool` - true if injection succeeded

**Example:**
```lua
sleep(5000)  -- Wait for game to start
local success = dll.inject("game.exe", "C:\\Mods\\trainer.dll", 1000)
if success then
    notifications.push_success("Mod Loaded", "Trainer injected successfully")
end
```

---

### dll.injectx86
```lua
local success = dll.injectx86(processexename, dllpath, delay)
```
Inject a 32-bit DLL into a running process.

**Parameters:**
- `processexename` (string) - Target process name
- `dllpath` (string) - Path to 32-bit DLL file
- `delay` (int) - Delay in milliseconds

**Returns:**
- `bool` - true if injection succeeded

**Example:**
```lua
local success = dll.injectx86("game32.exe", "C:\\Mods\\mod32.dll", 500)
```

---

### dll.innohook
```lua
local success = dll.innohook(processname)
```
Hook into an Inno Setup installer to extract files. Results are returned via the `on_setupcompleted` callback.

**Parameters:**
- `processname` (string) - Installer process name

**Returns:**
- `bool` - true if hook succeeded

**Example:**
```lua
client.add_callback("on_setupcompleted", function(from, to)
    print("Installer extracted from: " .. from)
    print("To: " .. to)
end)

dll.innohook("setup.exe")
```

---

## gldconsole Namespace

The `gldconsole` namespace provides the recommended logging interface for scripts.

### gldconsole.print
```lua
gldconsole.print(fmt)
```
Print a message to the GLD console (recommended over `utils.Log`).

**Parameters:**
- `fmt` (string) - Message to log

**Example:**
```lua
gldconsole.print("Script initialized")
gldconsole.print("Processing: " .. filename)
```

---

### gldconsole.show
```lua
gldconsole.show()
```
Show the console window.

**Example:**
```lua
gldconsole.show()
```

---

### gldconsole.close
```lua
gldconsole.close()
```
Close the console window.

**Example:**
```lua
gldconsole.close()
```

---

## save Namespace

The `save` namespace manages game save file backup, restore, and cloud sync operations.

### save.Backup
```lua
save.Backup(name)
```
Backup saves for a specific game.

**Parameters:**
- `name` (string) - Game name

**Example:**
```lua
save.Backup("Elden Ring")
```

---

### save.Restore
```lua
save.Restore(name)
```
Restore saves for a specific game.

**Parameters:**
- `name` (string) - Game name

**Example:**
```lua
save.Restore("Elden Ring")
```

---

### save.BackupAll
```lua
save.BackupAll()
```
Backup saves for all games.

**Example:**
```lua
save.BackupAll()
```

---

### save.RestoreAll
```lua
save.RestoreAll()
```
Restore saves for all games.

**Example:**
```lua
save.RestoreAll()
```

---

### save.Download
```lua
save.Download(name)
```
Download saves from cloud for a specific game.

**Parameters:**
- `name` (string) - Game name

**Example:**
```lua
save.Download("Dark Souls III")
```

---

### save.Upload
```lua
save.Upload(name)
```
Upload saves to cloud for a specific game.

**Parameters:**
- `name` (string) - Game name

**Example:**
```lua
save.Upload("Dark Souls III")
```

---

### save.UploadAll
```lua
save.UploadAll()
```
Upload all game saves to cloud.

**Example:**
```lua
save.UploadAll()
```

---

### save.DownloadAll
```lua
save.DownloadAll()
```
Download all game saves from cloud.

**Example:**
```lua
save.DownloadAll()
```

---

### save.RefreshBackup
```lua
save.RefreshBackup()
```
Refresh the backup saves list.

**Example:**
```lua
save.RefreshBackup()
```

---

### save.RefreshRestore
```lua
save.RefreshRestore()
```
Refresh the restore saves list.

**Example:**
```lua
save.RefreshRestore()
```

---

### save.RefreshCloud
```lua
save.RefreshCloud()
```
Refresh the cloud saves list.

**Example:**
```lua
save.RefreshCloud()
```

---

### save.RefreshAll
```lua
save.RefreshAll()
```
Refresh all save lists.

**Example:**
```lua
save.RefreshAll()
```

---

### save.GetBackupGamesList
```lua
local games = save.GetBackupGamesList()
```
Get list of games with local backups.

**Returns:**
- `table` - Array of game names

**Example:**
```lua
local games = save.GetBackupGamesList()
for _, game in ipairs(games) do
    print("Backup available: " .. game)
end
```

---

### save.GetRestoreGamesList
```lua
local games = save.GetRestoreGamesList()
```
Get list of games that can be restored.

**Returns:**
- `string` - Game names (format TBD)

**Example:**
```lua
local games = save.GetRestoreGamesList()
```

---

### save.GetCloudGamesList
```lua
local games = save.GetCloudGamesList()
```
Get list of games with cloud saves.

**Returns:**
- `table` - Array of game names

**Example:**
```lua
local cloudGames = save.GetCloudGamesList()
```

---

## input Namespace

The `input` namespace provides keyboard and mouse input simulation and detection.

### Keyboard Input Detection

#### input.is_key_down
```lua
local down = input.is_key_down(vk_code)
```
Check if a key is currently pressed.

**Parameters:**
- `vk_code` (int) - Virtual key code

**Returns:**
- `bool` - true if key is down

**Example:**
```lua
if input.is_key_down(VK.VK_CONTROL) then
    print("Control key is held")
end
```

---

#### input.is_key_pressed
```lua
local pressed = input.is_key_pressed(vk_code)
```
Check if a key was just pressed (single detection).

**Parameters:**
- `vk_code` (int) - Virtual key code

**Returns:**
- `bool` - true if key was just pressed

**Example:**
```lua
if input.is_key_pressed(VK.VK_F5) then
    print("F5 pressed")
end
```

---

#### input.get_key_state
```lua
local state = input.get_key_state(vk_code)
```
Get the state of a key.

**Parameters:**
- `vk_code` (int) - Virtual key code

**Returns:**
- `short` - Key state value

**Example:**
```lua
local state = input.get_key_state(VK.VK_CAPITAL)
```

---

#### input.is_key_toggled
```lua
local toggled = input.is_key_toggled(vk_code)
```
Check if a toggle key is active (e.g., Caps Lock, Num Lock).

**Parameters:**
- `vk_code` (int) - Virtual key code

**Returns:**
- `bool` - true if toggled on

**Example:**
```lua
if input.is_key_toggled(VK.VK_CAPITAL) then
    print("Caps Lock is ON")
end
```

---

### Keyboard Input Simulation

#### input.key_press
```lua
input.key_press(vk_code, delay, delay2)
```
Simulate a key press (down then up).

**Parameters:**
- `vk_code` (int) - Virtual key code
- `delay` (int, optional) - Delay before press in ms (default: 0)
- `delay2` (int, optional) - Hold duration in ms (default: 50)

**Example:**
```lua
input.key_press(VK.VK_RETURN, 0, 50)  -- Press Enter
```

---

#### input.key_down
```lua
input.key_down(vk_code, delay)
```
Simulate key down event.

**Parameters:**
- `vk_code` (int) - Virtual key code
- `delay` (int, optional) - Delay before press in ms (default: 0)

**Example:**
```lua
input.key_down(VK.VK_SHIFT, 0)
```

---

#### input.key_up
```lua
input.key_up(vk_code, delay)
```
Simulate key up event.

**Parameters:**
- `vk_code` (int) - Virtual key code
- `delay` (int, optional) - Delay before release in ms (default: 0)

**Example:**
```lua
input.key_up(VK.VK_SHIFT, 0)
```

---

### Mouse Operations

#### input.get_mouse_pos
```lua
local pos = input.get_mouse_pos()
```
Get current mouse position.

**Returns:**
- `table` - Table with `x` and `y` coordinates

**Example:**
```lua
local pos = input.get_mouse_pos()
print("Mouse at: " .. pos.x .. ", " .. pos.y)
```

---

#### input.set_mouse_pos
```lua
input.set_mouse_pos(x, y)
```
Set mouse cursor position.

**Parameters:**
- `x` (int) - X coordinate
- `y` (int) - Y coordinate

**Example:**
```lua
input.set_mouse_pos(100, 200)
```

---

#### input.mouse_click
```lua
input.mouse_click(button, delay, delay2)
```
Simulate a mouse click.

**Parameters:**
- `button` (int, optional) - Mouse button (0=left, 1=right, 2=middle, default: 0)
- `delay` (int, optional) - Delay before click in ms (default: 0)
- `delay2` (int, optional) - Hold duration in ms (default: 50)

**Example:**
```lua
input.mouse_click(0, 0, 50)  -- Left click
input.mouse_click(1, 0, 50)  -- Right click
```

---

#### input.mouse_down
```lua
input.mouse_down(button, delay)
```
Simulate mouse button down event.

**Parameters:**
- `button` (int, optional) - Mouse button (default: 0)
- `delay` (int, optional) - Delay in ms (default: 0)

**Example:**
```lua
input.mouse_down(0, 0)  -- Left button down
```

---

#### input.mouse_up
```lua
input.mouse_up(button, delay)
```
Simulate mouse button up event.

**Parameters:**
- `button` (int, optional) - Mouse button (default: 0)
- `delay` (int, optional) - Delay in ms (default: 0)

**Example:**
```lua
input.mouse_up(0, 0)  -- Left button up
```

---

#### input.mouse_wheel
```lua
input.mouse_wheel(delta, delay)
```
Simulate mouse wheel scroll.

**Parameters:**
- `delta` (int) - Scroll amount (positive=up, negative=down)
- `delay` (int, optional) - Delay in ms (default: 0)

**Example:**
```lua
input.mouse_wheel(120, 0)   -- Scroll up
input.mouse_wheel(-120, 0)  -- Scroll down
```

---

## VK (Virtual Keys)

The `VK` table contains all Windows virtual key codes for use with input functions. Access keys via `VK.VK_*`.

### Common Virtual Keys

```lua
-- Letters
VK.VK_A through VK.VK_Z  -- 0x41 to 0x5A

-- Numbers
VK.VK_0 through VK.VK_9  -- 0x30 to 0x39

-- Function Keys
VK.VK_F1 through VK.VK_F24  -- 0x70 to 0x87

-- Control Keys
VK.VK_BACK         -- Backspace
VK.VK_TAB          -- Tab
VK.VK_RETURN       -- Enter
VK.VK_SHIFT        -- Shift
VK.VK_CONTROL      -- Ctrl
VK.VK_MENU         -- Alt
VK.VK_PAUSE        -- Pause
VK.VK_CAPITAL      -- Caps Lock
VK.VK_ESCAPE       -- Esc
VK.VK_SPACE        -- Space

-- Navigation
VK.VK_PRIOR        -- Page Up
VK.VK_NEXT         -- Page Down
VK.VK_END          -- End
VK.VK_HOME         -- Home
VK.VK_LEFT         -- Left Arrow
VK.VK_UP           -- Up Arrow
VK.VK_RIGHT        -- Right Arrow
VK.VK_DOWN         -- Down Arrow

-- Editing
VK.VK_INSERT       -- Insert
VK.VK_DELETE       -- Delete

-- Numpad
VK.VK_NUMPAD0 through VK.VK_NUMPAD9
VK.VK_MULTIPLY     -- Numpad *
VK.VK_ADD          -- Numpad +
VK.VK_SUBTRACT     -- Numpad -
VK.VK_DECIMAL      -- Numpad .
VK.VK_DIVIDE       -- Numpad /

-- Lock Keys
VK.VK_NUMLOCK      -- Num Lock
VK.VK_SCROLL       -- Scroll Lock

-- Windows Keys
VK.VK_LWIN         -- Left Windows key
VK.VK_RWIN         -- Right Windows key
```

**Example Usage:**
```lua
-- Check if Ctrl+S is pressed
if input.is_key_down(VK.VK_CONTROL) and input.is_key_pressed(VK.VK_S) then
    print("Save shortcut detected")
end

-- Simulate Alt+F4
input.key_down(VK.VK_MENU, 0)
input.key_press(VK.VK_F4, 0, 50)
input.key_up(VK.VK_MENU, 0)
```

---

## base64 Namespace

The `base64` namespace provides base64 encoding and decoding utilities.

### base64.encode
```lua
local encoded = base64.encode(in)
```
Encode a string to base64.

**Parameters:**
- `in` (string) - String to encode

**Returns:**
- `string` - Base64 encoded string

**Example:**
```lua
local encoded = base64.encode("Hello World")
print(encoded)  -- SGVsbG8gV29ybGQ=
```

---

### base64.decode
```lua
local decoded = base64.decode(in)
```
Decode a base64 string.

**Parameters:**
- `in` (string) - Base64 encoded string

**Returns:**
- `string` - Decoded string

**Example:**
```lua
local decoded = base64.decode("SGVsbG8gV29ybGQ=")
print(decoded)  -- Hello World
```

---

### base64.encode_shifted
```lua
local encoded = base64.encode_shifted(in)
```
Encode a string to base64 with a custom shift (obfuscation).

**Parameters:**
- `in` (string) - String to encode

**Returns:**
- `string` - Shifted base64 encoded string

**Example:**
```lua
local encoded = base64.encode_shifted("Secret")
```

---

### base64.decode_shifted
```lua
local decoded = base64.decode_shifted(in)
```
Decode a shifted base64 string.

**Parameters:**
- `in` (string) - Shifted base64 string

**Returns:**
- `string` - Decoded string

**Example:**
```lua
local decoded = base64.decode_shifted(encoded)
```

---

## HTML/XML Parsing

Project-GLD provides modern HTML and XML parsing capabilities using lexbor and libxml2.

### HTML Parsing

#### html.parse
```lua
local doc = html.parse(html)
```
Parse an HTML string into a document object.

**Parameters:**
- `html` (string) - HTML string to parse

**Returns:**
- `HtmlDocument` - Document object

**Example:**
```lua
local htmlContent = [[
<html>
<body>
    <div class="content">
        <h1>Title</h1>
        <p>Paragraph</p>
    </div>
</body>
</html>
]]

local doc = html.parse(htmlContent)
```

---

### HtmlDocument Methods

#### doc:css
```lua
local nodes = doc:css(selector)
```
Select elements using CSS selectors.

**Parameters:**
- `selector` (string) - CSS selector

**Returns:**
- `table` - Array of HtmlNode objects

**Example:**
```lua
local nodes = doc:css("div.content h1")
for i, node in ipairs(nodes) do
    print(node:text())
end
```

---

#### doc:root
```lua
local root = doc:root()
```
Get the root element.

**Returns:**
- `HtmlNode` - Root node

**Example:**
```lua
local root = doc:root()
```

---

#### doc:body
```lua
local body = doc:body()
```
Get the body element.

**Returns:**
- `HtmlNode` - Body node

**Example:**
```lua
local body = doc:body()
```

---

### HtmlNode Methods

#### node:tag
```lua
local tagName = node:tag()
```
Get the element's tag name.

**Returns:**
- `string` - Tag name (lowercase)

**Example:**
```lua
local tag = node:tag()  -- "div", "p", "span", etc.
```

---

#### node:text
```lua
local text = node:text()
```
Get the text content of the node.

**Returns:**
- `string` - Text content

**Example:**
```lua
local text = node:text()
print("Content: " .. text)
```

---

#### node:attr
```lua
local value = node:attr(name)
```
Get an attribute value.

**Parameters:**
- `name` (string) - Attribute name

**Returns:**
- `string` or `nil` - Attribute value if exists

**Example:**
```lua
local href = node:attr("href")
local className = node:attr("class")
```

---

#### node:parent
```lua
local parent = node:parent()
```
Get the parent node.

**Returns:**
- `HtmlNode` - Parent node

**Example:**
```lua
local parent = node:parent()
```

---

#### node:children
```lua
local children = node:children()
```
Get child nodes.

**Returns:**
- `table` - Array of HtmlNode objects

**Example:**
```lua
local children = node:children()
for i, child in ipairs(children) do
    print(child:tag())
end
```

---

### HTML Parsing Example

```lua
-- Fetch and parse a web page
local response = http.get("https://example.com/downloads", {})
local doc = html.parse(response)

-- Find all download links
local links = doc:css("a.download-link")
for i, link in ipairs(links) do
    local url = link:attr("href")
    local title = link:text()
    print("Found: " .. title .. " - " .. url)
end

-- Navigate DOM structure
local content = doc:css("div#main-content")[1]
if content then
    local heading = content:children()[1]
    print("First heading: " .. heading:text())
end
```

---

### XML Parsing

#### xml.parse
```lua
local doc = xml.parse(xml)
```
Parse an XML string into a document object.

**Parameters:**
- `xml` (string) - XML string to parse

**Returns:**
- `XmlDocument` - Document object

**Example:**
```lua
local xmlContent = [[
<?xml version="1.0"?>
<root>
    <item id="1">Value</item>
</root>
]]

local doc = xml.parse(xmlContent)
```

---

### XmlDocument Methods

#### doc:xpath
```lua
local nodes = doc:xpath(expr)
```
Query using XPath expressions.

**Parameters:**
- `expr` (string) - XPath expression

**Returns:**
- `table` - Array of XmlNode objects

**Example:**
```lua
local nodes = doc:xpath("//item[@id='1']")
for i, node in ipairs(nodes) do
    print(node:text())
end
```

---

#### doc:root
```lua
local root = doc:root()
```
Get the root element.

**Returns:**
- `XmlNode` - Root node

**Example:**
```lua
local root = doc:root()
```

---

### XmlNode Methods

#### node:name
```lua
local name = node:name()
```
Get the element name.

**Returns:**
- `string` - Element name

**Example:**
```lua
local name = node:name()
```

---

#### node:text
```lua
local text = node:text()
```
Get the text content.

**Returns:**
- `string` - Text content

**Example:**
```lua
local text = node:text()
```

---

#### node:attr
```lua
local value = node:attr(name)
```
Get an attribute value.

**Parameters:**
- `name` (string) - Attribute name

**Returns:**
- `string` or `nil` - Attribute value

**Example:**
```lua
local id = node:attr("id")
```

---

### Legacy HTML Parser (Deprecated)

The old Gumbo-based parser is still available but deprecated. Use `html.parse()` instead.

```lua
-- DEPRECATED - Use html.parse() instead
local result = HtmlWrapper.findAttribute(htmlString, elementTagName, 
    elementTermKey, elementTermValue, desiredResultKey)
```

---

## JSON Parsing

### JsonWrapper.parse
```lua
local data = JsonWrapper.parse(jsonString)
```
Parse a JSON string into a Lua table.

**Parameters:**
- `jsonString` (string) - JSON string to parse

**Returns:**
- `table` or `sol::object` - Parsed data

**Example:**
```lua
local jsonText = '{"name":"Game","version":1.5,"tags":["action","rpg"]}'
local data = JsonWrapper.parse(jsonText)

print(data.name)      -- "Game"
print(data.version)   -- 1.5
print(data.tags[1])   -- "action"
```

---

## Callback System

Project-GLD uses an event-driven callback system. Register callbacks using `client.add_callback(eventname, function)`.

### Available Callbacks

#### on_launch
```lua
client.add_callback("on_launch", function()
    -- Called when GLD is launched
    -- Warning: May be called before script is fully loaded
end)
```

---

#### on_present
```lua
client.add_callback("on_present", function()
    -- Main application loop - called every frame
    -- Use for continuous operations
end)
```

---

#### on_gameselected
```lua
client.add_callback("on_gameselected", function()
    -- Called when a game is selected in search
end)
```

---

#### on_gamelaunch
```lua
client.add_callback("on_gamelaunch", function(gameInfo)
    -- Called when a game is launched
    -- gameInfo: GameInfo object with properties:
    --   - id (string)
    --   - name (string)
    --   - initoptions (string)
    --   - imagePath (string)
    --   - exePath (string)
end)
```

**Example:**
```lua
client.add_callback("on_gamelaunch", function(gameInfo)
    print("Launching: " .. gameInfo.name)
    print("Executable: " .. gameInfo.exePath)
end)
```

---

#### on_gamesearch
```lua
client.add_callback("on_gamesearch", function()
    -- Called when a game search is performed
end)
```

---

#### on_extractioncompleted
```lua
client.add_callback("on_extractioncompleted", function(origin, destination)
    -- Called when zip.extract completes
    -- origin: Source archive file path (string)
    -- destination: Extraction destination path (string)
end)
```

**Example:**
```lua
client.add_callback("on_extractioncompleted", function(origin, dest)
    print("Extracted: " .. origin)
    print("To: " .. dest)
    notifications.push_success("Extract Complete", "Files ready")
end)
```

---

#### on_downloadclick
```lua
client.add_callback("on_downloadclick", function(item, url, scriptname)
    -- Called when download button is clicked in game page
    -- item: JSON data as string
    -- url: Download URL (string)
    -- scriptname: Name of script handling download (string)
end)
```

**Example:**
```lua
client.add_callback("on_downloadclick", function(item, url, scriptname)
    local data = JsonWrapper.parse(item)
    print("Download requested: " .. url)
end)
```

---

#### on_cfdone
```lua
client.add_callback("on_cfdone", function(cookie, url)
    -- Called when http.CloudFlareSolver completes
    -- cookie: Cloudflare cookie string
    -- url: Original URL that was solved (string)
end)
```

**Example:**
```lua
client.add_callback("on_cfdone", function(cookie, url)
    print("Cloudflare cookie: " .. cookie)
    -- Use cookie in subsequent requests
    local response = http.get(url, {
        ["Cookie"] = cookie,
        ["User-Agent"] = "Mozilla/5.0 ... ProjectGLD/2.15"
    })
end)
```

---

#### on_downloadcompleted
```lua
client.add_callback("on_downloadcompleted", function(path, url)
    -- Called when a download finishes
    -- path: Local file path where file was saved (string)
    -- url: Original download URL (string)
end)
```

**Example:**
```lua
client.add_callback("on_downloadcompleted", function(path, url)
    print("Downloaded to: " .. path)
    
    -- Auto-extract if it's an archive
    if path:match("%.zip$") then
        local dest = path:gsub("%.zip$", "\\")
        zip.extract(path, dest, true, "")
    end
end)
```

---

#### on_setupcompleted
```lua
client.add_callback("on_setupcompleted", function(from, to)
    -- Called when dll.innohook completes
    -- from: Source file being extracted (string)
    -- to: Destination path (string)
end)
```

**Example:**
```lua
client.add_callback("on_setupcompleted", function(from, to)
    print("Inno Setup extracted from: " .. from)
    print("To: " .. to)
end)
```

---

#### on_captchasolved
```lua
client.add_callback("on_captchasolved", function(browserID)
    -- Called when CAPTCHA is solved in a browser
    -- browserID: Browser ID (int)
end)
```

**Example:**
```lua
client.add_callback("on_captchasolved", function(browserID)
    local browser = browser.GetBrowserByID(browserID)
    print("CAPTCHA solved in: " .. browser.name)
end)
```

---

#### on_captchadetected
```lua
client.add_callback("on_captchadetected", function(browserID)
    -- Called when CAPTCHA is detected in a browser
    -- browserID: Browser ID (int)
end)
```

---

#### on_scriptselected
```lua
client.add_callback("on_scriptselected", function()
    -- Called when a script is selected in search tab
end)
```

---

#### on_quit
```lua
client.add_callback("on_quit", function()
    -- Called when GLD is exiting
    -- Warning: Only use if absolutely necessary
end)
```

---

#### on_browserloaded
```lua
client.add_callback("on_browserloaded", function(browserID)
    -- Called when browser finishes loading a page
    -- Equivalent to CefLoadHandler::OnLoadEnd
    -- browserID: Browser ID (int)
end)
```

**Example:**
```lua
client.add_callback("on_browserloaded", function(browserID)
    local browser = browser.GetBrowserByID(browserID)
    browser:GetBrowserSource(function(html)
        -- Process page content
        local doc = html.parse(html)
    end)
end)
```

---

#### on_browserconsolemessage
```lua
client.add_callback("on_browserconsolemessage", function(browserID, message)
    -- Called when browser outputs console message
    -- browserID: Browser ID (int)
    -- message: Console message content (string)
end)
```

---

#### on_beforedownload
```lua
client.add_callback("on_beforedownload", function(url)
    -- Called before download starts - for download resolvers
    -- url: Original download URL (string)
    -- Return: returnurl (string), name (string), headers (table)
    -- Return nil to keep original values
    -- Return "cancel" as URL to cancel download
    
    return resolvedUrl, filename, headers
end)
```

**Example:**
```lua
client.add_callback("on_beforedownload", function(url)
    if url:match("example.com") then
        -- Resolve the download
        local browser = browser.CreateBrowser("resolver", url)
        
        -- Wait for redirect and get final URL
        sleep(3000)
        local finalUrl = browser:BrowserUrl()
        browser:CloseBrowser()
        
        -- Set history for resume support
        Download.SetHistoryUrl(finalUrl, url)
        
        return finalUrl, "file.zip", {}
    end
    
    return nil, nil, nil  -- Don't modify
end)
```

---

#### on_browserbeforeresourceload
```lua
client.add_callback("on_browserbeforeresourceload", function(browserID, url, method, referrer, resourceType)
    -- Called before browser loads a resource
    -- browserID: Browser ID (int)
    -- url: Resource URL (string)
    -- method: HTTP method (string)
    -- referrer: Referrer URL (string)
    -- resourceType: Type of resource (string)
end)
```

---

#### on_browserbeforedownload
```lua
client.add_callback("on_browserbeforedownload", function(browserID, url, suggestedName, size)
    -- Called when browser initiates a download
    -- browserID: Browser ID (int)
    -- url: Download URL (string)
    -- suggestedName: Suggested filename (string)
    -- size: File size if known (string)
    -- Return: originalUrl (string) - needed for resolvers
    
    return originalUrl
end)
```

---

#### on_button_[name]
```lua
client.add_callback("on_button_Download", function()
    -- Called when menu button is clicked
    -- Replace [name] with actual button name
end)
```

**Example:**
```lua
menu.add_button("Start Download")

client.add_callback("on_button_Start Download", function()
    Download.DownloadFile("https://example.com/file.zip")
end)
```

---

## Types Reference

### GameInfo

Object containing game information.

**Properties:**
- `id` (string) - Unique game identifier
- `name` (string) - Display name
- `initoptions` (string) - Initialization options
- `imagePath` (string) - Path to game cover image
- `exePath` (string) - Path to game executable

---

### Color

Object representing an RGB color (exact structure TBD).

---

## Complete Example Scripts

### Example 1: Simple Download Script

```lua
-- Register for game search event
client.add_callback("on_gamesearch", function()
    -- Create search results
    local results = {
        {
            name = "My Game",
            image = "https://example.com/cover.jpg",
            downloadUrl = "https://example.com/download"
        }
    }
    
    -- Send to UI
    communication.receiveSearchResults(results)
end)

-- Handle download click
client.add_callback("on_downloadclick", function(item, url, scriptname)
    gldconsole.print("Starting download: " .. url)
    Download.DownloadFile(url)
end)

-- Handle completion
client.add_callback("on_downloadcompleted", function(path, url)
    notifications.push_success("Complete", "Downloaded to: " .. path)
    
    -- Auto-extract
    if path:match("%.zip$") then
        local dest = path:gsub("%.zip$", "\\")
        zip.extract(path, dest, true, "")
    end
end)

-- Handle extraction
client.add_callback("on_extractioncompleted", function(origin, dest)
    notifications.push_success("Extracted", "Ready to play!")
    
    -- Find game executable
    local exes = file.listexecutablesrecursive(dest)
    if #exes > 0 then
        GameLibrary.addGame(exes[1], "", "My Game", "", false)
    end
end)
```

---

### Example 2: Download Resolver with Browser

```lua
-- Resolve protected downloads
client.add_callback("on_beforedownload", function(url)
    if not url:match("mycdn.com") then
        return nil, nil, nil  -- Not our CDN
    end
    
    gldconsole.print("Resolving: " .. url)
    
    -- Create hidden browser
    local resolver = browser.CreateBrowser("resolver_" .. os.time(), url)
    browser.set_visible(false, resolver.name)
    
    -- Wait for page to load and redirect
    sleep(5000)
    
    -- Get final URL
    local finalUrl = resolver:BrowserUrl()
    gldconsole.print("Resolved to: " .. finalUrl)
    
    -- Clean up
    resolver:CloseBrowser()
    
    -- Set history for resume
    Download.SetHistoryUrl(finalUrl, url)
    
    return finalUrl, nil, {}
end)
```

---

### Example 3: Web Scraper with HTML Parser

```lua
client.add_callback("on_gamesearch", function()
    local searchTerm = game.getgamename()
    
    -- Fetch search results page
    local html = http.get("https://example.com/search?q=" .. searchTerm, {
        ["User-Agent"] = "Mozilla/5.0 ..."
    })
    
    -- Parse HTML
    local doc = html.parse(html)
    
    -- Find all game entries
    local games = doc:css("div.game-item")
    local results = {}
    
    for i, gameDiv in ipairs(games) do
        local title = gameDiv:css("h2.title")[1]:text()
        local image = gameDiv:css("img")[1]:attr("src")
        local link = gameDiv:css("a.download")[1]:attr("href")
        
        table.insert(results, {
            name = title,
            image = image,
            downloadUrl = link
        })
    end
    
    communication.receiveSearchResults(results)
end)
```

---

### Example 4: Cloudflare Solver

```lua
-- Handle protected URLs
client.add_callback("on_beforedownload", function(url)
    if url:match("protected-site.com") then
        gldconsole.print("Solving Cloudflare...")
        http.CloudFlareSolver(url)
        
        -- Will continue in on_cfdone callback
        return "cancel", nil, {}  -- Cancel for now
    end
    return nil, nil, nil
end)

-- Cloudflare solved
client.add_callback("on_cfdone", function(cookie, url)
    gldconsole.print("Cloudflare solved!")
    
    -- Now download with cookie
    local response = http.get(url, {
        ["Cookie"] = cookie,
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15"
    })
    
    -- Parse to find real download link
    local doc = html.parse(response)
    local dlLink = doc:css("a#download-button")[1]:attr("href")
    
    Download.DownloadFile(dlLink)
end)
```

---

### Example 5: Menu Configuration

```lua
-- Create configuration menu
menu.add_text("Download Settings")
menu.next_line()

menu.add_slider_int("max_connections", 1, 16)
menu.set_int("max_connections", 8)

menu.add_slider_int("max_downloads", 1, 5)
menu.set_int("max_downloads", 3)

menu.add_check_box("auto_extract")
menu.set_bool("auto_extract", true)

menu.add_button("Apply Settings")

-- Handle button click
client.add_callback("on_button_Apply Settings", function()
    local connections = menu.get_int("max_connections")
    local downloads = menu.get_int("max_downloads")
    local autoExtract = menu.get_bool("auto_extract")
    
    Download.SetMaxConnections(connections)
    Download.ChangeMaxActiveDownloads(downloads)
    
    notifications.push_success("Settings Applied", 
        string.format("Connections: %d, Downloads: %d", connections, downloads))
end)
```

---

## Best Practices

1. **Error Handling**: Always wrap risky operations in `pcall`:
```lua
local success, result = pcall(function()
    return http.get(url, {})
end)

if success then
    -- Process result
else
    gldconsole.print("Error: " .. tostring(result))
end
```

2. **Resource Cleanup**: Always close browsers and files when done:
```lua
local browser = browser.CreateBrowser("temp", url)
-- ... use browser ...
browser:CloseBrowser()
```

3. **User Feedback**: Keep users informed:
```lua
gldconsole.print("Processing download...")
notifications.push("Status", "Please wait...")
```

4. **Logging**: Use `gldconsole.print` for debugging:
```lua
gldconsole.print("Debug: " .. variableName)
```

5. **Settings Persistence**: Save important settings:
```lua
menu.set_int("last_used", value)
settings.save()
```

---

## Troubleshooting

### Common Issues

**Browser not loading:**
- Check if URL is valid
- Ensure network access is allowed
- Try disabling CAPTCHA detection for Cloudflare pages

**Download not starting:**
- Verify URL is accessible
- Check if download resolver is needed
- Ensure download path exists

**HTML parsing returns empty:**
- Verify page loaded completely
- Check if JavaScript rendering is required
- Try using browser.GetBrowserSource instead of http.get

**Script not executing:**
- Check for syntax errors
- Verify callbacks are registered before events fire
- Use gldconsole.print for debugging

---

## Version History

- **6.99**: Current version with full CEF integration, HTML/XML parsers
- Earlier versions: See legacy documentation

---

## Additional Resources

- Project-GLD Forums: [Link TBD]
- Example Scripts Repository: [Link TBD]
- Community Discord: [Link TBD]

---

**End of Documentation**