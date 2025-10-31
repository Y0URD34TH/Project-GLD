# Project-GLD Lua API Documentation

Complete reference for the Project-GLD Lua scripting API.

## Table of Contents

- [Introduction](#introduction)
- [Global Functions](#global-functions)
- [Custom Types](#custom-types)
- [Client API](#client-api)
- [Menu API](#menu-api)
- [Notifications API](#notifications-api)
- [Utils API](#utils-api)
- [HTTP API](#http-api)
- [File API](#file-api)
- [Game API](#game-api)
- [DLL API](#dll-api)
- [Browser API](#browser-api)
- [Communication API](#communication-api)
- [Steam API](#steam-api)
- [Download API](#download-api)
- [Game Library API](#game-library-api)
- [Settings API](#settings-api)
- [Zip API](#zip-api)
- [GLD Console API](#gld-console-api)
- [Save API](#save-api)
- [Event Callbacks](#event-callbacks)

---

## Introduction

Project-GLD exposes a comprehensive Lua API for creating scripts and extensions. This documentation covers all available functions, types, and callbacks.

### Important Notes

- For using AI to make scripts please send (copy and paste) to your AI our compact documentation of lua ready for AI: https://github.com/Y0URD34TH/Project-GLD/blob/main/Ai-Lua.txt 
- **Optional Parameters**: Parameters with default values (e.g., `int delay = 0`) are optional in Lua
- **sol::this_state**: These C++ parameters are automatically handled and not visible in Lua
- **Disabled Functions**: The following standard Lua functions are disabled for security:
  - `collectgarbage`
  - `dofile`
  - `load`
  - `loadfile`
  - `pcall`
  - `xpcall`
  - `getmetatable`
  - `setmetatable`

---

## Global Functions

### print()
```lua
print(stringtoprint)
```
Prints a string to the output.

**Parameters:**
- `stringtoprint` (string): The text to print

**Example:**
```lua
print("Hello from Project-GLD!")
```

---

### exec()
```lua
exec(execpath, delay, commandline, isinnosetup, innoproccess)
```
Executes an external program.

**Parameters:**
- `execpath` (string): Path to the executable
- `delay` (number, optional): Delay in milliseconds before execution (default: 0)
- `commandline` (string, optional): Command line arguments (default: "")
- `isinnosetup` (boolean, optional): Whether this is an Inno Setup installer (default: false)
- `innoproccess` (string, optional): Inno Setup process name (default: "")

**Example:**
```lua
exec("C:\\Games\\game.exe", 1000, "-windowed")
```

---

### sleep()
```lua
sleep(milliseconds)
```
Pauses script execution for the specified duration.

**Parameters:**
- `milliseconds` (number): Duration to sleep in milliseconds

**Example:**
```lua
sleep(500) -- Wait half a second
```

---

## Custom Types

### JsonWrapper

Wrapper for JSON parsing functionality.

#### JsonWrapper.parse()
```lua
JsonWrapper.parse(jsonString)
```
Parses a JSON string and returns a Lua object.

**Parameters:**
- `jsonString` (string): Valid JSON string

**Returns:**
- (object): Parsed JSON as Lua table/object

**Example:**
```lua
local data = JsonWrapper.parse('{"name":"Game","version":1.0}')
print(data.name) -- "Game"
```

---

### HtmlWrapper

Wrapper for HTML parsing functionality.

#### HtmlWrapper.findAttribute()
```lua
HtmlWrapper.findAttribute(htmlString, elementTagName, elementTermKey, elementTermValue, desiredResultKey)
```
Finds and extracts attributes from HTML elements.

**Parameters:**
- `htmlString` (string): HTML content to parse
- `elementTagName` (string): HTML tag to search for (e.g., "div", "a")
- `elementTermKey` (string): Attribute name to match (e.g., "class", "id")
- `elementTermValue` (string): Value of the attribute to match
- `desiredResultKey` (string): Attribute to extract from matched element

**Returns:**
- (table): Table containing the found attributes

**Example:**
```lua
local html = '<div class="game-link"><a href="/game/123" id="download">Download</a></div>'
local result = HtmlWrapper.findAttribute(html, "a", "id", "download", "href")
-- Returns the href attribute of the anchor with id="download"
```

---

### GameInfo

Represents information about a game.

**Properties:**
- `id` (string): Unique game identifier
- `name` (string): Game name
- `initoptions` (string): Initialization options
- `imagePath` (string): Path to game image/icon
- `exePath` (string): Path to game executable

**Example:**
```lua
-- GameInfo objects are typically received from callbacks
client.add_callback("on_gamelaunch", function(gameInfo)
    print("Launching: " .. gameInfo.name)
    print("Path: " .. gameInfo.exePath)
end)
```

---

## Client API

Core client functionality for managing scripts, callbacks, and application state.

### client.add_callback()
```lua
client.add_callback(eventname, func)
```
Registers a callback function for a specific event.

**Parameters:**
- `eventname` (string): Name of the event (see [Event Callbacks](#event-callbacks))
- `func` (function): Function to execute when event fires

**Example:**
```lua
client.add_callback("on_launch", function()
    print("GLD has launched!")
end)
```

---

### client.load_script()
```lua
client.load_script(name)
```
Loads a Lua script by name.

**Parameters:**
- `name` (string): Name of the script file (without extension)

**Example:**
```lua
client.load_script("myscript")
```

---

### client.unload_script()
```lua
client.unload_script(name)
```
Unloads a previously loaded script.

**Parameters:**
- `name` (string): Name of the script to unload

**Example:**
```lua
client.unload_script("myscript")
```

---

### client.create_script()
```lua
client.create_script(name, data)
```
Creates a new script with the given content.

**Parameters:**
- `name` (string): Name for the new script
- `data` (string): Lua code content

**Example:**
```lua
local code = [[
    print("Hello from dynamic script!")
]]
client.create_script("dynamic_script", code)
```

---

### client.log()
```lua
client.log(title, text)
```
Logs a message with a title.

**Parameters:**
- `title` (string): Log entry title
- `text` (string): Log message content

**Example:**
```lua
client.log("Info", "Game download completed")
```

---

### client.quit()
```lua
client.quit()
```
Exits the Project-GLD application.

**Example:**
```lua
client.quit()
```

---

### client.GetVersion()
```lua
client.GetVersion()
```
Gets the Project-GLD version as a string.

**Returns:**
- (string): Version string (e.g., "2.15")

**Example:**
```lua
local version = client.GetVersion()
print("Running version: " .. version)
```

---

### client.GetVersionFloat()
```lua
client.GetVersionFloat()
```
Gets the version as a float number.

**Returns:**
- (number): Version as float

**Example:**
```lua
local version = client.GetVersionFloat()
if version >= 2.15 then
    print("Version supported")
end
```

---

### client.GetVersionDouble()
```lua
client.GetVersionDouble()
```
Gets the version as a double-precision number.

**Returns:**
- (number): Version as double

---

### client.CleanSearchTextureCache()
```lua
client.CleanSearchTextureCache()
```
Clears the texture cache for search results.

**Example:**
```lua
client.CleanSearchTextureCache()
```

---

### client.CleanLibraryTextureCache()
```lua
client.CleanLibraryTextureCache()
```
Clears the texture cache for the game library.

**Example:**
```lua
client.CleanLibraryTextureCache()
```

---

### client.GetScriptsPath()
```lua
client.GetScriptsPath()
```
Gets the path to the scripts directory.

**Returns:**
- (string): Full path to scripts folder

**Example:**
```lua
local scriptsPath = client.GetScriptsPath()
print("Scripts located at: " .. scriptsPath)
```

---

### client.GetDefaultSavePath()
```lua
client.GetDefaultSavePath()
```
Gets the default save games path.

**Returns:**
- (string): Default save path

**Example:**
```lua
local savePath = client.GetDefaultSavePath()
```

---

### client.GetScreenHeight()
```lua
client.GetScreenHeight()
```
Gets the screen height in pixels.

**Returns:**
- (number): Screen height

**Example:**
```lua
local height = client.GetScreenHeight()
print("Screen height: " .. height)
```

---

### client.GetScreenWidth()
```lua
client.GetScreenWidth()
```
Gets the screen width in pixels.

**Returns:**
- (number): Screen width

**Example:**
```lua
local width = client.GetScreenWidth()
print("Screen width: " .. width)
```

---

## Menu API

Create and manage custom UI elements in the Project-GLD interface.

### menu.set_dpi()
```lua
menu.set_dpi(dpi)
```
Sets the DPI scaling for menu elements.

**Parameters:**
- `dpi` (number): DPI scale value

**Example:**
```lua
menu.set_dpi(1.5)
```

---

### menu.set_visible()
```lua
menu.set_visible(visible)
```
Shows or hides the menu.

**Parameters:**
- `visible` (boolean): true to show, false to hide

**Example:**
```lua
menu.set_visible(true)
```

---

### menu.next_line()
```lua
menu.next_line()
```
Moves to the next line in the menu layout.

**Example:**
```lua
menu.add_button("Button1")
menu.next_line()
menu.add_button("Button2")
```

---

### menu.add_check_box()
```lua
menu.add_check_box(name)
```
Adds a checkbox to the menu.

**Parameters:**
- `name` (string): Unique identifier for the checkbox

**Example:**
```lua
menu.add_check_box("enable_feature")
```

---

### menu.add_button()
```lua
menu.add_button(name)
```
Adds a button to the menu.

**Parameters:**
- `name` (string): Button label and identifier

**Note:** Button clicks trigger the `on_button_<name>` callback.

**Example:**
```lua
menu.add_button("Download")

client.add_callback("on_button_Download", function()
    print("Download button clicked!")
end)
```

---

### menu.add_text()
```lua
menu.add_text(text)
```
Adds static text to the menu.

**Parameters:**
- `text` (string): Text to display

**Example:**
```lua
menu.add_text("Game Settings")
```

---

### menu.add_input_text()
```lua
menu.add_input_text(name)
```
Adds a text input field.

**Parameters:**
- `name` (string): Unique identifier for the input

**Example:**
```lua
menu.add_input_text("username")
```

---

### menu.add_input_int()
```lua
menu.add_input_int(name)
```
Adds an integer input field.

**Parameters:**
- `name` (string): Unique identifier for the input

**Example:**
```lua
menu.add_input_int("max_players")
```

---

### menu.add_input_float()
```lua
menu.add_input_float(name)
```
Adds a float input field.

**Parameters:**
- `name` (string): Unique identifier for the input

**Example:**
```lua
menu.add_input_float("volume")
```

---

### menu.add_combo_box()
```lua
menu.add_combo_box(name, labels)
```
Adds a combo box (dropdown) with multiple options.

**Parameters:**
- `name` (string): Unique identifier
- `labels` (table): Array of option strings

**Example:**
```lua
menu.add_combo_box("difficulty", {"Easy", "Normal", "Hard", "Extreme"})
```

---

### menu.add_slider_int()
```lua
menu.add_slider_int(name, min, max)
```
Adds an integer slider.

**Parameters:**
- `name` (string): Unique identifier
- `min` (number): Minimum value
- `max` (number): Maximum value

**Example:**
```lua
menu.add_slider_int("brightness", 0, 100)
```

---

### menu.add_slider_float()
```lua
menu.add_slider_float(name, min, max)
```
Adds a float slider.

**Parameters:**
- `name` (string): Unique identifier
- `min` (number): Minimum value
- `max` (number): Maximum value

**Example:**
```lua
menu.add_slider_float("mouse_sensitivity", 0.1, 5.0)
```

---

### menu.add_color_picker()
```lua
menu.add_color_picker(name)
```
Adds a color picker control.

**Parameters:**
- `name` (string): Unique identifier

**Example:**
```lua
menu.add_color_picker("ui_color")
```

---

### menu.get_bool()
```lua
menu.get_bool(name)
```
Gets the value of a checkbox.

**Parameters:**
- `name` (string): Checkbox identifier

**Returns:**
- (boolean): Current checkbox state

**Example:**
```lua
local enabled = menu.get_bool("enable_feature")
```

---

### menu.get_text()
```lua
menu.get_text(name)
```
Gets the text from an input field.

**Parameters:**
- `name` (string): Input identifier

**Returns:**
- (string): Current text value

**Example:**
```lua
local username = menu.get_text("username")
```

---

### menu.get_int()
```lua
menu.get_int(name)
```
Gets the integer value from an input or slider.

**Parameters:**
- `name` (string): Control identifier

**Returns:**
- (number): Current integer value

**Example:**
```lua
local brightness = menu.get_int("brightness")
```

---

### menu.get_float()
```lua
menu.get_float(name)
```
Gets the float value from an input or slider.

**Parameters:**
- `name` (string): Control identifier

**Returns:**
- (number): Current float value

**Example:**
```lua
local sensitivity = menu.get_float("mouse_sensitivity")
```

---

### menu.get_color()
```lua
menu.get_color(name)
```
Gets the color from a color picker.

**Parameters:**
- `name` (string): Color picker identifier

**Returns:**
- (Color): Color object

**Example:**
```lua
local uiColor = menu.get_color("ui_color")
```

---

### menu.set_bool()
```lua
menu.set_bool(name, value)
```
Sets the value of a checkbox.

**Parameters:**
- `name` (string): Checkbox identifier
- `value` (boolean): New state

**Example:**
```lua
menu.set_bool("enable_feature", true)
```

---

### menu.set_text()
```lua
menu.set_text(name, value)
```
Sets the text of an input field.

**Parameters:**
- `name` (string): Input identifier
- `value` (string): New text value

**Example:**
```lua
menu.set_text("username", "Player1")
```

---

### menu.set_int()
```lua
menu.set_int(name, value)
```
Sets an integer value.

**Parameters:**
- `name` (string): Control identifier
- `value` (number): New integer value

**Example:**
```lua
menu.set_int("brightness", 75)
```

---

### menu.set_float()
```lua
menu.set_float(name, value)
```
Sets a float value.

**Parameters:**
- `name` (string): Control identifier
- `value` (number): New float value

**Example:**
```lua
menu.set_float("mouse_sensitivity", 2.5)
```

---

### menu.set_color()
```lua
menu.set_color(name, value)
```
Sets a color value.

**Parameters:**
- `name` (string): Color picker identifier
- `value` (Color): New color value

**Example:**
```lua
menu.set_color("ui_color", colorValue)
```

---

## Notifications API

Display notification messages to the user.

### Notifications.push()
```lua
Notifications.push(title, text)
```
Shows a standard notification.

**Parameters:**
- `title` (string): Notification title
- `text` (string): Notification message

**Example:**
```lua
Notifications.push("Info", "Download started")
```

---

### Notifications.push_success()
```lua
Notifications.push_success(title, text)
```
Shows a success notification (typically green).

**Parameters:**
- `title` (string): Notification title
- `text` (string): Success message

**Example:**
```lua
Notifications.push_success("Complete", "Game installed successfully")
```

---

### Notifications.push_error()
```lua
Notifications.push_error(title, text)
```
Shows an error notification (typically red).

**Parameters:**
- `title` (string): Notification title
- `text` (string): Error message

**Example:**
```lua
Notifications.push_error("Error", "Failed to download file")
```

---

### Notifications.push_warning()
```lua
Notifications.push_warning(title, text)
```
Shows a warning notification (typically yellow/orange).

**Parameters:**
- `title` (string): Notification title
- `text` (string): Warning message

**Example:**
```lua
Notifications.push_warning("Warning", "Low disk space")
```

---

## Utils API

Utility functions for console, logging, and time operations.

### utils.AttachConsole()
```lua
utils.AttachConsole()
```
Attaches a console window for debugging output.

**Example:**
```lua
utils.AttachConsole()
```

---

### utils.DetachConsole()
```lua
utils.DetachConsole()
```
Detaches the console window.

**Example:**
```lua
utils.DetachConsole()
```

---

### utils.ConsolePrint()
```lua
utils.ConsolePrint(logToFile, format, ...)
```
Prints formatted text to the console.

**Parameters:**
- `logToFile` (boolean): Whether to also log to file
- `format` (string): Format string (printf-style)
- `...` (any): Additional arguments for format string

**Note:** Must call `utils.AttachConsole()` first.

**Example:**
```lua
utils.AttachConsole()
utils.ConsolePrint(true, "Value: %d", 42)
```

---

### utils.GetTimeString()
```lua
utils.GetTimeString()
```
Gets the current time as a formatted string.

**Returns:**
- (string): Time string

**Example:**
```lua
local timeStr = utils.GetTimeString()
print("Current time: " .. timeStr)
```

---

### utils.GetTimestamp()
```lua
utils.GetTimestamp()
```
Gets the current timestamp as a string.

**Returns:**
- (string): Timestamp string

**Example:**
```lua
local timestamp = utils.GetTimestamp()
```

---

### utils.GetTimeUnix()
```lua
utils.GetTimeUnix()
```
Gets the current Unix timestamp.

**Returns:**
- (number): Unix timestamp (seconds since epoch)

**Example:**
```lua
local unixTime = utils.GetTimeUnix()
print("Unix time: " .. unixTime)
```

---

### utils.Log()
```lua
utils.Log(format, ...)
```
Logs a formatted message to `Project-GLD.log` file.

**Parameters:**
- `format` (string): Format string (printf-style)
- `...` (any): Additional arguments

**Note:** Log file is created in the same directory as the GLD executable.

**Example:**
```lua
utils.Log("Game launched at %s", utils.GetTimeString())
```

---

## HTTP API

HTTP request functionality and specialized resolvers for various file hosting services.

### http.get()
```lua
http.get(link, headers)
```
Performs an HTTP GET request.

**Parameters:**
- `link` (string): URL to request
- `headers` (table): Table of HTTP headers (key-value pairs)

**Returns:**
- (string): Response body

**Example:**
```lua
local headers = {
    ["User-Agent"] = "Project-GLD",
    ["Accept"] = "application/json"
}
local response = http.get("https://api.example.com/data", headers)
```

---

### http.post()
```lua
http.post(link, params, headers)
```
Performs an HTTP POST request.

**Parameters:**
- `link` (string): URL to request
- `params` (string): POST data/parameters
- `headers` (table): Table of HTTP headers

**Returns:**
- (string): Response body

**Example:**
```lua
local headers = {["Content-Type"] = "application/x-www-form-urlencoded"}
local params = "user=test&pass=123"
local response = http.post("https://api.example.com/login", params, headers)
```

---

### http.ArchivedotOrgResolver()
```lua
http.ArchivedotOrgResolver(link)
```
Resolves Archive.org (Wayback Machine) URLs to get the actual content.

**Parameters:**
- `link` (string): Archive.org URL

**Returns:**
- (string): Resolved URL or content

**Example:**
```lua
local archiveUrl = "https://web.archive.org/web/20200101000000/http://example.com"
local resolved = http.ArchivedotOrgResolver(archiveUrl)
```

---

### http.mediafireresolver()
```lua
http.mediafireresolver(mediafireurl)
```
Resolves MediaFire download links to get direct download URLs.

**Parameters:**
- `mediafireurl` (string): MediaFire URL

**Returns:**
- (string): Direct download URL

**Example:**
```lua
local mfUrl = "https://www.mediafire.com/file/xxxxx/game.zip"
local directUrl = http.mediafireresolver(mfUrl)
```

---

### http.resolvepixeldrain()
```lua
http.resolvepixeldrain(link)
```
Resolves Pixeldrain links to direct download URLs.

**Parameters:**
- `link` (string): Pixeldrain URL

**Returns:**
- (string): Direct download URL

**Example:**
```lua
local pdUrl = "https://pixeldrain.com/u/xxxxx"
local directUrl = http.resolvepixeldrain(pdUrl)
```

---

### http.CloudFlareSolver()
```lua
http.CloudFlareSolver(url)
```
Solves Cloudflare challenges and retrieves cookies.

**Parameters:**
- `url` (string): URL protected by Cloudflare

**Note:** This function triggers the `on_cfdone` callback when complete. The callback receives:
- Cookie string
- Original URL

**Required User-Agent:** When using the returned cookie, you must use:
```
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15
```

**Example:**
```lua
client.add_callback("on_cfdone", function(cookie, url)
    print("Cloudflare cookie: " .. cookie)
    print("URL: " .. url)
    
    -- Use the cookie in subsequent requests
    local headers = {
        ["Cookie"] = cookie,
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15"
    }
    local content = http.get(url, headers)
end)

http.CloudFlareSolver("https://example.com")
```

---

### http.byetresolver()
```lua
http.byetresolver(url)
```
Resolves Byet/Byethost URLs.

**Parameters:**
- `url` (string): Byet URL

**Returns:**
- (string): Resolved URL or content

**Example:**
```lua
local byetUrl = "https://example.byethost.com/file"
local resolved = http.byetresolver(byetUrl)
```

---

## File API

Comprehensive file system operations including reading, writing, and directory management.

### file.append()
```lua
file.append(path, data)
```
Appends data to a file.

**Parameters:**
- `path` (string): File path
- `data` (string): Data to append

**Example:**
```lua
file.append("C:\\logs\\game.log", "Game started\n")
```

---

### file.write()
```lua
file.write(path, data)
```
Writes data to a file (overwrites if exists).

**Parameters:**
- `path` (string): File path
- `data` (string): Data to write

**Example:**
```lua
file.write("C:\\config.txt", "setting=value")
```

---

### file.read()
```lua
file.read(path)
```
Reads the entire contents of a file.

**Parameters:**
- `path` (string): File path

**Returns:**
- (string): File contents

**Example:**
```lua
local content = file.read("C:\\config.txt")
print(content)
```

---

### file.delete()
```lua
file.delete(path)
```
Deletes a file.

**Parameters:**
- `path` (string): File path

**Example:**
```lua
file.delete("C:\\temp\\oldfile.tmp")
```

---

### file.exists()
```lua
file.exists(path)
```
Checks if a file or directory exists.

**Parameters:**
- `path` (string): Path to check

**Returns:**
- (boolean): true if exists, false otherwise

**Example:**
```lua
if file.exists("C:\\Games\\game.exe") then
    print("Game found!")
end
```

---

### file.exec()
```lua
file.exec(execpath, delay, commandline, isinnosetup, innoproccess)
```
Executes a program (same as global `exec()`).

**Parameters:**
- `execpath` (string): Path to executable
- `delay` (number, optional): Delay in milliseconds (default: 0)
- `commandline` (string, optional): Command line arguments (default: "")
- `isinnosetup` (boolean, optional): Is Inno Setup installer (default: false)
- `innoproccess` (string, optional): Inno Setup process name (default: "")

**Example:**
```lua
file.exec("C:\\installer.exe", 500, "/SILENT")
```

---

### file.listfolders()
```lua
file.listfolders(path)
```
Lists all folders in a directory.

**Parameters:**
- `path` (string): Directory path

**Returns:**
- (table): Array of folder names

**Example:**
```lua
local folders = file.listfolders("C:\\Games")
for _, folder in ipairs(folders) do
    print("Folder: " .. folder)
end
```

---

### file.listexecutables()
```lua
file.listexecutables(path)
```
Lists all executable files (.exe) in a directory (non-recursive).

**Parameters:**
- `path` (string): Directory path

**Returns:**
- (table): Array of executable file names

**Example:**
```lua
local exes = file.listexecutables("C:\\Games\\MyGame")
for _, exe in ipairs(exes) do
    print("Found: " .. exe)
end
```

---

### file.listexecutablesrecursive()
```lua
file.listexecutablesrecursive(path)
```
Lists all executable files in a directory and subdirectories (recursive).

**Parameters:**
- `path` (string): Directory path

**Returns:**
- (table): Array of full paths to executables

**Example:**
```lua
local exes = file.listexecutablesrecursive("C:\\Games")
for _, exe in ipairs(exes) do
    print("Found: " .. exe)
end
```

---

### file.listcompactedfiles()
```lua
file.listcompactedfiles(path)
```
Lists all compressed archive files in a directory (zip, rar, 7z, tar, etc.).

**Parameters:**
- `path` (string): Directory path

**Returns:**
- (table): Array of archive file names

**Example:**
```lua
local archives = file.listcompactedfiles("C:\\Downloads")
for _, archive in ipairs(archives) do
    print("Archive: " .. archive)
end
```

---

### file.getusername()
```lua
file.getusername()
```
Gets the Windows username.

**Returns:**
- (string): Current Windows user name

**Example:**
```lua
local username = file.getusername()
print("User: " .. username)
```

---

### file.create_directory()
```lua
file.create_directory(path)
```
Creates a new directory.

**Parameters:**
- `path` (string): Directory path to create

**Example:**
```lua
file.create_directory("C:\\Games\\NewGame")
```

---

### file.copy_file()
```lua
file.copy_file(src, dst)
```
Copies a file from source to destination.

**Parameters:**
- `src` (string): Source file path
- `dst` (string): Destination file path

**Example:**
```lua
file.copy_file("C:\\source.txt", "C:\\backup\\source.txt")
```

---

### file.move_file()
```lua
file.move_file(src, dst)
```
Moves a file from source to destination.

**Parameters:**
- `src` (string): Source file path
- `dst` (string): Destination file path

**Example:**
```lua
file.move_file("C:\\temp\\file.txt", "C:\\archive\\file.txt")
```

---

### file.get_filename()
```lua
file.get_filename(path)
```
Extracts the filename from a path.

**Parameters:**
- `path` (string): Full file path

**Returns:**
- (string): Filename with extension

**Example:**
```lua
local name = file.get_filename("C:\\Games\\game.exe")
print(name) -- "game.exe"
```

---

### file.get_extension()
```lua
file.get_extension(path)
```
Gets the file extension from a path.

**Parameters:**
- `path` (string): File path

**Returns:**
- (string): File extension (including dot)

**Example:**
```lua
local ext = file.get_extension("C:\\Games\\game.exe")
print(ext) -- ".exe"
```

---

### file.get_parent_path()
```lua
file.get_parent_path(path)
```
Gets the parent directory of a path.

**Parameters:**
- `path` (string): File or directory path

**Returns:**
- (string): Parent directory path

**Example:**
```lua
local parent = file.get_parent_path("C:\\Games\\MyGame\\game.exe")
print(parent) -- "C:\\Games\\MyGame"
```

---

### file.list_directory()
```lua
file.list_directory(path)
```
Lists all files and folders in a directory.

**Parameters:**
- `path` (string): Directory path

**Returns:**
- (table): Table containing directory contents

**Example:**
```lua
local contents = file.list_directory("C:\\Games")
for _, item in ipairs(contents) do
    print("Item: " .. item)
end
```

---

## Game API

Functions related to game information.

### game.getgamename()
```lua
game.getgamename()
```
Gets the currently selected game name from the search results.

**Returns:**
- (string): Game name

**Note:** This function works when viewing a game page.

**Example:**
```lua
client.add_callback("on_gameselected", function()
    local gameName = game.getgamename()
    print("Selected game: " .. gameName)
end)
```

---

## DLL API

DLL injection and Inno Setup hooking functionality.

### dll.inject()
```lua
dll.inject(processexename, dllpath, delay)
```
Injects a DLL into a running 64-bit process.

**Parameters:**
- `processexename` (string): Name of the target process (e.g., "game.exe")
- `dllpath` (string): Full path to the DLL to inject
- `delay` (number): Delay in milliseconds before injection

**Returns:**
- (boolean): true if successful, false otherwise

**Example:**
```lua
local success = dll.inject("GoW.exe", "C:\\mods\\mod.dll", 300)
if success then
    print("DLL injected successfully")
else
    print("Injection failed")
end
```

---

### dll.injectx86()
```lua
dll.injectx86(processexename, dllpath, delay)
```
Injects a DLL into a running 32-bit process.

**Parameters:**
- `processexename` (string): Name of the target process
- `dllpath` (string): Full path to the DLL to inject
- `delay` (number): Delay in milliseconds before injection

**Returns:**
- (boolean): true if successful, false otherwise

**Example:**
```lua
local success = dll.injectx86("game32.exe", "C:\\mods\\mod32.dll", 500)
```

---

### dll.innohook()
```lua
dll.innohook(processname)
```
Hooks into an Inno Setup installer process to monitor extraction.

**Parameters:**
- `processname` (string): Name of the installer process

**Returns:**
- (boolean): true if successful, false otherwise

**Note:** This function triggers the `on_setupcompleted` callback when the installation completes. The callback receives:
- Source path (where files were extracted from)
- Destination path (where files were extracted to)

**Example:**
```lua
client.add_callback("on_setupcompleted", function(sourcePath, destPath)
    print("Installed from: " .. sourcePath)
    print("Installed to: " .. destPath)
    
    -- Add the game to library
    local exePath = destPath .. "\\game.exe"
    GameLibrary.addGame(exePath, "", "My Game", "")
end)

dll.innohook("setup.exe")
```

---

## Browser API

Functions to open URLs in the default browser.

### browser.open()
```lua
browser.open(link)
```
Opens a URL in the default web browser.

**Parameters:**
- `link` (string): URL to open

**Example:**
```lua
browser.open("https://www.example.com")
```

---

## Communication API

Functions for communicating search results and refreshing UI.

### communication.receiveSearchResults()
```lua
communication.receiveSearchResults(resultsTable)
```
Sends search results to be displayed in the search interface.

**Parameters:**
- `resultsTable` (table): Table containing search result data

**Example:**
```lua
local results = {
    {
        name = "Game Title",
        image = "https://example.com/image.jpg",
        url = "https://example.com/game"
    }
}
communication.receiveSearchResults(results)
```

---

### communication.RefreshScriptResults()
```lua
communication.RefreshScriptResults()
```
Refreshes the script results display.

**Example:**
```lua
communication.RefreshScriptResults()
```

---

## Steam API

Integration with Steam for game information and management.

### SteamApi.GetAppID()
```lua
SteamApi.GetAppID(name)
```
Gets the Steam App ID for a game by name.

**Parameters:**
- `name` (string): Game name

**Returns:**
- (string): Steam App ID

**Example:**
```lua
local appId = SteamApi.GetAppID("Counter-Strike 2")
print("App ID: " .. appId)
```

---

### SteamApi.GetSystemRequirements()
```lua
SteamApi.GetSystemRequirements(appid)
```
Gets system requirements for a Steam game.

**Parameters:**
- `appid` (string): Steam App ID

**Returns:**
- (string): System requirements information (JSON format)

**Example:**
```lua
local requirements = SteamApi.GetSystemRequirements("730")
local data = JsonWrapper.parse(requirements)
```

---

### SteamApi.GetGameData()
```lua
SteamApi.GetGameData(appid)
```
Gets detailed game data from Steam.

**Parameters:**
- `appid` (string): Steam App ID

**Returns:**
- (string): Game data (JSON format)

**Example:**
```lua
local gameData = SteamApi.GetGameData("730")
local data = JsonWrapper.parse(gameData)
print("Game: " .. data.name)
```

---

### SteamApi.OpenSteam()
```lua
SteamApi.OpenSteam()
```
Opens the Steam client.

**Example:**
```lua
SteamApi.OpenSteam()
```

---

### SteamApi.IsSteamRunning()
```lua
SteamApi.IsSteamRunning()
```
Checks if Steam is currently running.

**Returns:**
- (boolean): true if Steam is running, false otherwise

**Example:**
```lua
if SteamApi.IsSteamRunning() then
    print("Steam is running")
else
    print("Steam is not running")
end
```

---

## Download API

File download management and utilities.

### Download.DownloadFile()
```lua
Download.DownloadFile(downloadurl)
```
Downloads a file to the default download path with progress tracking.

**Parameters:**
- `downloadurl` (string): URL of the file to download

**Note:** Triggers the `on_downloadcompleted` callback when finished.

**Example:**
```lua
client.add_callback("on_downloadcompleted", function(path, url)
    print("Downloaded to: " .. path)
    print("From: " .. url)
end)

Download.DownloadFile("https://example.com/game.zip")
```

---

### Download.GetFileNameFromUrl()
```lua
Download.GetFileNameFromUrl(url)
```
Extracts the filename from a URL.

**Parameters:**
- `url` (string): URL containing filename

**Returns:**
- (string): Extracted filename

**Example:**
```lua
local filename = Download.GetFileNameFromUrl("https://example.com/files/game.zip")
print(filename) -- "game.zip"
```

---

### Download.DirectDownload()
```lua
Download.DirectDownload(downloadurl, downloadpath)
```
Downloads a file directly to a specified path without progress UI.

**Parameters:**
- `downloadurl` (string): URL of the file
- `downloadpath` (string): Full path where to save the file

**Example:**
```lua
Download.DirectDownload("https://example.com/file.zip", "C:\\Downloads\\file.zip")
```

---

### Download.DownloadImage()
```lua
Download.DownloadImage(imageurl)
```
Downloads an image and returns its local path.

**Parameters:**
- `imageurl` (string): URL of the image

**Returns:**
- (string): Local path to downloaded image

**Example:**
```lua
local imagePath = Download.DownloadImage("https://example.com/cover.jpg")
print("Image saved to: " .. imagePath)
```

---

### Download.ChangeDownloadPath()
```lua
Download.ChangeDownloadPath(path)
```
Changes the default download directory.

**Parameters:**
- `path` (string): New download directory path

**Example:**
```lua
Download.ChangeDownloadPath("D:\\MyDownloads")
```

---

### Download.GetDownloadPath()
```lua
Download.GetDownloadPath()
```
Gets the current default download directory.

**Returns:**
- (string): Download directory path

**Example:**
```lua
local downloadPath = Download.GetDownloadPath()
print("Downloads go to: " .. downloadPath)
```

---

## Game Library API

Manage games in the Project-GLD library.

### GameLibrary.launch()
```lua
GameLibrary.launch(id)
```
Launches a game from the library by its ID.

**Parameters:**
- `id` (number): Game ID

**Returns:**
- (boolean): true if launched successfully, false otherwise

**Example:**
```lua
local gameId = GameLibrary.GetGameIdFromName("My Game")
if GameLibrary.launch(gameId) then
    print("Game launched")
end
```

---

### GameLibrary.close()
```lua
GameLibrary.close()
```
Closes the currently running game.

**Example:**
```lua
GameLibrary.close()
```

---

### GameLibrary.addGame()
```lua
GameLibrary.addGame(exePath, imagePath, gamename, commandline, disableigdbid)
```
Adds a new game to the library.

**Parameters:**
- `exePath` (string): Path to game executable
- `imagePath` (string): Path to game cover image
- `gamename` (string): Display name for the game
- `commandline` (string): Command line arguments to pass when launching
- `disableigdbid` (boolean, optional): Disable IGDB ID lookup (default: false)

**Example:**
```lua
GameLibrary.addGame(
    "C:\\Games\\MyGame\\game.exe",
    "C:\\Games\\MyGame\\cover.jpg",
    "My Awesome Game",
    "-windowed -width 1920"
)
```

---

### GameLibrary.changeGameinfo()
```lua
GameLibrary.changeGameinfo(id, exePath, imagePath, gamename, commandline)
```
Updates information for an existing game.

**Parameters:**
- `id` (number): Game ID to update
- `exePath` (string, optional): New executable path (empty to keep current)
- `imagePath` (string, optional): New image path (empty to keep current)
- `gamename` (string, optional): New name (empty to keep current)
- `commandline` (string, optional): New command line (empty to keep current)

**Example:**
```lua
local gameId = GameLibrary.GetGameIdFromName("My Game")
GameLibrary.changeGameinfo(gameId, "", "", "My Game (Updated)", "")
```

---

### GameLibrary.removeGame()
```lua
GameLibrary.removeGame(id)
```
Removes a game from the library.

**Parameters:**
- `id` (number): Game ID to remove

**Example:**
```lua
local gameId = GameLibrary.GetGameIdFromName("Old Game")
GameLibrary.removeGame(gameId)
```

---

### GameLibrary.GetGameIdFromName()
```lua
GameLibrary.GetGameIdFromName(name)
```
Gets a game's ID by its name.

**Parameters:**
- `name` (string): Game name

**Returns:**
- (number): Game ID, or -1 if not found

**Example:**
```lua
local id = GameLibrary.GetGameIdFromName("My Game")
if id ~= -1 then
    print("Found game with ID: " .. id)
end
```

---

### GameLibrary.GetGameNameFromId()
```lua
GameLibrary.GetGameNameFromId(id)
```
Gets a game's name by its ID.

**Parameters:**
- `id` (number): Game ID

**Returns:**
- (string): Game name

**Example:**
```lua
local name = GameLibrary.GetGameNameFromId(5)
print("Game name: " .. name)
```

---

### GameLibrary.GetGamePath()
```lua
GameLibrary.GetGamePath(id)
```
Gets the executable path for a game.

**Parameters:**
- `id` (number): Game ID

**Returns:**
- (string): Full path to game executable

**Example:**
```lua
local path = GameLibrary.GetGamePath(5)
print("Game location: " .. path)
```

---

### GameLibrary.GetGameList()
```lua
GameLibrary.GetGameList()
```
Gets a list of all games in the library.

**Returns:**
- (table): Array of game info tables

**Example:**
```lua
local games = GameLibrary.GetGameList()
for _, gameInfo in ipairs(games) do
    print("Game: " .. gameInfo.name)
    print("Path: " .. gameInfo.exePath)
end
```

---

## Settings API

Load and save Project-GLD settings.

### settings.save()
```lua
settings.save()
```
Saves current settings to disk.

**Example:**
```lua
settings.save()
```

---

### settings.load()
```lua
settings.load()
```
Loads settings from disk.

**Example:**
```lua
settings.load()
```

---

## Zip API

Archive extraction functionality.

### zip.extract()
```lua
zip.extract(source, destination, deleteaftercomplete, pass)
```
Extracts a compressed archive file.

**Parameters:**
- `source` (string): Path to archive file (zip, rar, 7z, tar, etc.)
- `destination` (string): Destination directory for extracted files
- `deleteaftercomplete` (boolean): Whether to delete archive after extraction
- `pass` (string): Password for encrypted archives (empty string if no password)

**Note:** This function triggers the `on_extractioncompleted` callback when finished. The callback receives:
- Source path (original archive file)
- Destination path (where files were extracted)

**Example:**
```lua
client.add_callback("on_extractioncompleted", function(source, destination)
    print("Extracted: " .. source)
    print("To: " .. destination)
    
    -- Find and add game executable
    local exes = file.listexecutables(destination)
    if #exes > 0 then
        local exePath = destination .. "\\" .. exes[1]
        GameLibrary.addGame(exePath, "", "New Game", "")
    end
end)

zip.extract("C:\\Downloads\\game.zip", "C:\\Games\\NewGame", true, "")
```

---

## GLD Console API

Internal console window for debugging and logging.

### gldconsole.print()
```lua
gldconsole.print(text)
```
Prints text to the GLD console.

**Parameters:**
- `text` (string): Text to display

**Example:**
```lua
gldconsole.print("Debug: Script initialized")
```

---

### gldconsole.show()
```lua
gldconsole.show()
```
Shows the GLD console window.

**Example:**
```lua
gldconsole.show()
```

---

### gldconsole.close()
```lua
gldconsole.close()
```
Closes the GLD console window.

**Example:**
```lua
gldconsole.close()
```

---

## Save API

Cloud save management for backing up and restoring game saves.

### save.Backup()
```lua
save.Backup(name)
```
Backs up save files for a specific game.

**Parameters:**
- `name` (string): Game name

**Example:**
```lua
save.Backup("Dark Souls III")
```

---

### save.Restore()
```lua
save.Restore(name)
```
Restores save files for a specific game from backup.

**Parameters:**
- `name` (string): Game name

**Example:**
```lua
save.Restore("Dark Souls III")
```

---

### save.BackupAll()
```lua
save.BackupAll()
```
Backs up save files for all games.

**Example:**
```lua
save.BackupAll()
```

---

### save.RestoreAll()
```lua
save.RestoreAll()
```
Restores save files for all games from backup.

**Example:**
```lua
save.RestoreAll()
```

---

### save.Download()
```lua
save.Download(name)
```
Downloads save files from cloud storage for a specific game.

**Parameters:**
- `name` (string): Game name

**Example:**
```lua
save.Download("Elden Ring")
```

---

### save.Upload()
```lua
save.Upload(name)
```
Uploads save files to cloud storage for a specific game.

**Parameters:**
- `name` (string): Game name

**Example:**
```lua
save.Upload("Elden Ring")
```

---

### save.UploadAll()
```lua
save.UploadAll()
```
Uploads save files for all games to cloud storage.

**Example:**
```lua
save.UploadAll()
```

---

### save.DownloadAll()
```lua
save.DownloadAll()
```
Downloads save files for all games from cloud storage.

**Example:**
```lua
save.DownloadAll()
```

---

### save.RefreshBackup()
```lua
save.RefreshBackup()
```
Refreshes the backup list display.

**Example:**
```lua
save.RefreshBackup()
```

---

### save.RefreshRestore()
```lua
save.RefreshRestore()
```
Refreshes the restore list display.

**Example:**
```lua
save.RefreshRestore()
```

---

### save.RefreshCloud()
```lua
save.RefreshCloud()
```
Refreshes the cloud saves list display.

**Example:**
```lua
save.RefreshCloud()
```

---

### save.RefreshAll()
```lua
save.RefreshAll()
```
Refreshes all save-related lists.

**Example:**
```lua
save.RefreshAll()
```

---

### save.GetBackupGamesList()
```lua
save.GetBackupGamesList()
```
Gets a list of games with local backups.

**Returns:**
- (table): Array of game names with backups

**Example:**
```lua
local backups = save.GetBackupGamesList()
for _, gameName in ipairs(backups) do
    print("Backup available for: " .. gameName)
end
```

---

### save.GetRestoreGamesList()
```lua
save.GetRestoreGamesList()
```
Gets a list of games that can be restored.

**Returns:**
- (string): JSON string containing restore list

**Example:**
```lua
local restoreList = save.GetRestoreGamesList()
local data = JsonWrapper.parse(restoreList)
```

---

### save.GetCloudGamesList()
```lua
save.GetCloudGamesList()
```
Gets a list of games with cloud saves.

**Returns:**
- (table): Array of game names with cloud saves

**Example:**
```lua
local cloudGames = save.GetCloudGamesList()
for _, gameName in ipairs(cloudGames) do
    print("Cloud save for: " .. gameName)
end
```

---

## Event Callbacks

Project-GLD provides various event callbacks that scripts can hook into using `client.add_callback()`.

### on_launch
Triggered when Project-GLD starts.

**Parameters:** None

**Example:**
```lua
client.add_callback("on_launch", function()
    print("Project-GLD has started")
    -- Initialize your script here
end)
```

---

### on_present
Triggered on every frame of the main application loop.

**Parameters:** None

**Warning:** This callback runs very frequently. Avoid heavy operations here.

**Example:**
```lua
client.add_callback("on_present", function()
    -- Runs every frame
    -- Use sparingly for performance
end)
```

---

### on_gameselected
Triggered when a user selects a game in the search results.

**Parameters:** None

**Example:**
```lua
client.add_callback("on_gameselected", function()
    local gameName = game.getgamename()
    print("Selected: " .. gameName)
end)
```

---

### on_gamelaunch
Triggered when a game is launched from the library.

**Parameters:**
- `gameInfo` (GameInfo): Information about the launched game

**Example:**
```lua
client.add_callback("on_gamelaunch", function(gameInfo)
    print("Launching: " .. gameInfo.name)
    print("Executable: " .. gameInfo.exePath)
    print("ID: " .. gameInfo.id)
    
    -- Inject a mod DLL after 2 seconds
    sleep(2000)
    dll.inject("game.exe", "C:\\mods\\mod.dll", 0)
end)
```

---

### on_gamesearch
Triggered when a user performs a game search.

**Parameters:** None

**Example:**
```lua
client.add_callback("on_gamesearch", function()
    print("User is searching for games")
    -- Fetch search results from your source
end)
```

---

### on_scriptselected
Triggered when a user selects a specific result from the search interface provided by this script.

**Parameters:** Varies based on implementation

**Example:**
```lua
client.add_callback("on_scriptselected", function()
    print("User selected a search result from this script")
end)
```

---

### on_extractioncompleted
Triggered when `zip.extract()` finishes extracting an archive.

**Parameters:**
- `source` (string): Path to the original archive file
- `destination` (string): Path where files were extracted

**Example:**
```lua
client.add_callback("on_extractioncompleted", function(source, destination)
    print("Extraction complete!")
    print("Source: " .. source)
    print("Destination: " .. destination)
    
    -- Automatically find and add game to library
    local exes = file.listexecutablesrecursive(destination)
    if #exes > 0 then
        -- Use the first found executable
        local gameName = file.get_filename(exes[1]):gsub("%.exe$", "")
        GameLibrary.addGame(exes[1], "", gameName, "")
        Notifications.push_success("Game Added", gameName .. " added to library")
    end
end)

-- Trigger extraction
zip.extract("C:\\Downloads\\game.zip", "C:\\Games\\NewGame", true, "")
```

---

### on_downloadclick
Triggered when a user clicks a download button in the game page.

**Parameters:**
- `item` (string): JSON string containing item information
- `url` (string): Download URL
- `scriptname` (string): Name of the script that provided this download

**Example:**
```lua
client.add_callback("on_downloadclick", function(item, url, scriptname)
    print("Download clicked from script: " .. scriptname)
    print("URL: " .. url)
    
    local itemData = JsonWrapper.parse(item)
    print("Item: " .. itemData.name)
    
    -- Handle the download
    Download.DownloadFile(url)
end)
```

---

### on_cfdone
Triggered when `http.CloudFlareSolver()` successfully solves a Cloudflare challenge.

**Parameters:**
- `cookie` (string): Cloudflare cookie value
- `url` (string): Original URL that was solved

**Required User-Agent:** When using the cookie, you must use:
```
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15
```

**Example:**
```lua
client.add_callback("on_cfdone", function(cookie, url)
    print("Cloudflare solved for: " .. url)
    print("Cookie: " .. cookie)
    
    -- Now make authenticated requests
    local headers = {
        ["Cookie"] = cookie,
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15"
    }
    
    local content = http.get(url, headers)
    -- Parse content to find download links
end)

-- Start Cloudflare solving
http.CloudFlareSolver("https://protected-site.com")
```

---

### on_downloadcompleted
Triggered when a file download finishes.

**Parameters:**
- `path` (string): Local path where file was saved
- `url` (string): Original download URL

**Example:**
```lua
client.add_callback("on_downloadcompleted", function(path, url)
    print("Download completed!")
    print("Saved to: " .. path)
    print("From: " .. url)
    
    -- If it's an archive, extract it
    local ext = file.get_extension(path):lower()
    if ext == ".zip" or ext == ".rar" or ext == ".7z" then
        local extractPath = file.get_parent_path(path) .. "\\" .. file.get_filename(path):gsub(ext, "")
        zip.extract(path, extractPath, true, "")
    end
end)
```

---

### on_setupcompleted
Triggered when `dll.innohook()` detects that an Inno Setup installation has completed.

**Parameters:**
- `source` (string): Path to the installer executable
- `destination` (string): Path where the game was installed

**Example:**
```lua
client.add_callback("on_setupcompleted", function(source, destination)
    print("Installation complete!")
    print("Installer: " .. source)
    print("Installed to: " .. destination)
    
    -- Find the game executable
    local exes = file.listexecutablesrecursive(destination)
    for _, exe in ipairs(exes) do
        local filename = file.get_filename(exe):lower()
        -- Skip uninstaller and other common non-game executables
        if not filename:find("unins") and not filename:find("setup") then
            local gameName = file.get_filename(exe):gsub("%.exe$", "")
            GameLibrary.addGame(exe, "", gameName, "")
            Notifications.push_success("Installed", gameName .. " added to library")
            break
        end
    end
end)

-- Hook into installer
dll.innohook("setup.exe")
```

---

### on_quit
Triggered when Project-GLD is closing.

**Parameters:** None

**Example:**
```lua
client.add_callback("on_quit", function()
    print("Project-GLD is closing")
    -- Cleanup, save data, etc.
    settings.save()
end)
```

---

### on_button_<name>
Triggered when a menu button is clicked. Replace `<name>` with the actual button name (without parentheses).

**Parameters:** None

**Note:** You must add the button using `menu.add_button()` before this callback will work.

**Example:**
```lua
-- Add a button
menu.add_button("StartDownload")

-- Add callback for when it's clicked
client.add_callback("on_button_StartDownload", function()
    print("Start Download button was clicked!")
    
    local url = menu.get_text("download_url")
    if url ~= "" then
        Download.DownloadFile(url)
    else
        Notifications.push_error("Error", "Please enter a download URL")
    end
end)
```

---

## Complete Example Scripts

### Example 1: Custom Game Search Script

```lua
-- Initialize on launch
client.add_callback("on_launch", function()
    print("Custom search script loaded")
end)

-- Handle search requests
client.add_callback("on_gamesearch", function()
    local gameName = game.getgamename()
    print("Searching for: " .. gameName)
    
    -- Make HTTP request to your game database
    local searchUrl = "https://api.example.com/search?q=" .. gameName
    local headers = {["User-Agent"] = "Project-GLD"}
    
    local response = http.get(searchUrl, headers)
    local data = JsonWrapper.parse(response)
    
    -- Format results for GLD
    local results = {}
    for _, game in ipairs(data.results) do
        table.insert(results, {
            name = game.title,
            image = game.cover_url,
            url = game.page_url,
            description = game.description
        })
    end
    
    -- Send results to GLD
    communication.receiveSearchResults(results)
end)
```

---

### Example 2: Auto-Extract and Install

```lua
-- Monitor downloads folder for new archives
client.add_callback("on_downloadcompleted", function(path, url)
    local ext = file.get_extension(path):lower()
    
    if ext == ".zip" or ext == ".rar" or ext == ".7z" then
        Notifications.push("Extraction", "Starting extraction...")
        
        local gameName = file.get_filename(path):gsub(ext, "")
        local extractPath = "C:\\Games\\" .. gameName
        
        zip.extract(path, extractPath, true, "")
    end
end)

-- Auto-add to library after extraction
client.add_callback("on_extractioncompleted", function(source, destination)
    Notifications.push_success("Extracted", "Finding game executable...")
    
    local exes = file.listexecutablesrecursive(destination)
    
    for _, exe in ipairs(exes) do
        local filename = file.get_filename(exe):lower()
        
        -- Skip known non-game executables
        if not filename:find("unins") and 
           not filename:find("setup") and
           not filename:find("redist") and
           not filename:find("vcredist") then
            
            local gameName = file.get_filename(exe):gsub("%.exe$", "")
            
            -- Try to find a cover image
            local imagePath = ""
            local possibleImages = {
                destination .. "\\cover.jpg",
                destination .. "\\cover.png",
                destination .. "\\icon.png"
            }
            
            for _, imgPath in ipairs(possibleImages) do
                if file.exists(imgPath) then
                    imagePath = imgPath
                    break
                end
            end
            
            GameLibrary.addGame(exe, imagePath, gameName, "")
            Notifications.push_success("Success", gameName .. " added to library!")
            
            break
        end
    end
end)
```

---
