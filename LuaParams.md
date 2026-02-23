# Project-GLD Lua API — Complete Documentation

---

## Table of Contents

1. [Global Functions](#1-global-functions)
2. [client](#2-client)
3. [menu](#3-menu)
4. [notifications](#4-notifications)
5. [http](#5-http)
6. [file](#6-file)
7. [browser](#7-browser)
8. [GLDBrowser Usertype](#8-gldbrowser-usertype)
9. [download](#9-download)
10. [input](#10-input)
11. [VK — Virtual Keys](#11-vk--virtual-keys)
12. [GP — Gamepad Keys](#12-gp--gamepad-keys)
13. [html & xml Parsers](#13-html--xml-parsers)
14. [utils](#14-utils)
15. [gldconsole](#15-gldconsole)
16. [game](#16-game)
17. [GameLibrary](#17-gamelibrary)
18. [communication](#18-communication)
19. [SteamApi](#19-steamapi)
20. [dll](#20-dll)
21. [zip](#21-zip)
22. [save](#22-save)
23. [settings](#23-settings)
24. [base64](#24-base64)
25. [GameInfo Usertype](#25-gameinfo-usertype)
26. [JsonWrapper Usertype](#26-jsonwrapper-usertype)
27. [HtmlWrapper Usertype (Legacy)](#27-htmlwrapper-usertype-legacy)
28. [Lua Callbacks Reference](#28-lua-callbacks-reference)
29. [Full Examples](#29-full-examples)

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

## 1. Global Functions

These functions are available globally without any table prefix.

### `print(...)`
```lua
print(...)
```
Prints values to the debug console. Only useful during development when a console is attached.

---

### `exec(execpath [, delay [, commandline [, isinnosetup [, innoproc]]]])`
```lua
exec(execpath, delay, commandline, isinnosetup, innoproc)
```
Executes a file (e.g., an `.exe`).

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `execpath` | string | required | Full path to the executable |
| `delay` | int | `0` | Milliseconds to wait before launching |
| `commandline` | string | `""` | Command-line arguments |
| `isinnosetup` | bool | `false` | Set to `true` for InnoSetup installers |
| `innoproc` | string | `""` | Process name for InnoSetup hook |

---

### `system(command [, delay])`
```lua
system(command, delay)
```
Runs a system command (CMD).

---

### `system_output(command [, delay])`
```lua
local output = system_output("whoami")
```
Runs a system command and returns the stdout as a string.

---

### `sleep(ms)`
```lua
sleep(500) -- wait 500ms
```
Pauses execution for `ms` milliseconds.

---

### `beep([frequency [, duration]])`
```lua
beep(1000, 300)
```
Plays a beep sound.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `frequency` | int | `1000` | Frequency in Hz |
| `duration` | int | `500` | Duration in ms |

---

### `xor_encrypt(plain)`
```lua
local encrypted = xor_encrypt("hello")
```
Encrypts a plain string using XOR and returns a hex string.

---

### `xor_decrypt(hex)`
```lua
local plain = xor_decrypt("2f3a...")
```
Decrypts an XOR-encrypted hex string back to plain text.

---

## 2. client

General GLD client functions.

### `client.add_callback(eventname, func)`
```lua
client.add_callback("on_gamesearch", function()
    -- called every time the user searches a game
end)
```
Registers a Lua function to be called when the named event fires. See [Lua Callbacks Reference](#28-lua-callbacks-reference) for all available event names.

---

### `client.load_script(name)`
```lua
client.load_script("myscript")
```
Loads a script by name.

---

### `client.unload_script(name)`
```lua
client.unload_script("myscript")
```
Unloads a script by name.

---

### `client.create_script(name, data)`
```lua
client.create_script("myscript", lua_code_string)
```
Creates a new script with the given name and Lua source code string.

---

### `client.auto_script_update(scripturl, scriptversion)`
```lua
local VERSION = "1.0.0"
client.auto_script_update("https://example.com/myscript.lua", VERSION)
```
Automatically updates the script from a URL if the version differs. `scriptversion` must match a `local VERSION = ""` variable defined in the script.

---

### `client.log(title, text)`
```lua
client.log("Debug", "Something happened")
```
Logs a message shown in the GLD UI.

---

### `client.quit()`
```lua
client.quit()
```
Exits Project-GLD.

---

### `client.GetVersion()`
```lua
local v = client.GetVersion() -- e.g. "2.15"
```
Returns the GLD version as a string.

---

### `client.GetVersionFloat()`
```lua
local v = client.GetVersionFloat() -- e.g. 2.15
```
Returns the GLD version as a float.

---

### `client.GetVersionDouble()`
```lua
local v = client.GetVersionDouble()
```
Returns the GLD version as a double.

---

### `client.CleanSearchTextureCache()`
Clears the texture cache used by the search/game-search tab.

---

### `client.CleanLibraryTextureCache()`
Clears the texture cache used by the game library tab.

---

### `client.GetScriptsPath()`
```lua
local path = client.GetScriptsPath()
```
Returns the full path to the scripts directory.

---

### `client.GetDefaultSavePath()`
```lua
local path = client.GetDefaultSavePath()
```
Returns the default save/download path.

---

### `client.GetScreenHeight()`
```lua
local h = client.GetScreenHeight()
```
Returns the screen height in pixels.

---

### `client.GetScreenWidth()`
```lua
local w = client.GetScreenWidth()
```
Returns the screen width in pixels.

---

## 3. menu

Used to build custom UI elements and read/write their values.

> **Note:** Buttons use the `on_button_(button_name)` client callback. You must call `client.add_callback("on_button_mybutton", fn)` **after** adding the button with `menu.add_button`.

### Adding Elements

#### `menu.add_check_box(name)`
```lua
menu.add_check_box("Enable Feature")
```
Adds a checkbox. Read with `menu.get_bool(name)`.

---

#### `menu.add_button(name)`
```lua
menu.add_button("Do Action")
client.add_callback("on_button_Do Action", function()
    -- fired when clicked
end)
```
Adds a clickable button.

---

#### `menu.add_text(text)`
```lua
menu.add_text("Hello World")
```
Adds a static text label.

---

#### `menu.add_input_text(name)`
```lua
menu.add_input_text("Username")
```
Adds a text input field. Read with `menu.get_text(name)`.

---

#### `menu.add_input_int(name, min, max)`
```lua
menu.add_input_int("Count", 0, 100)
```
Adds an integer input. Read with `menu.get_int(name)`.

---

#### `menu.add_input_float(name, min, max)`
```lua
menu.add_input_float("Speed", 0.0, 10.0)
```
Adds a float input. Read with `menu.get_float(name)`.

---

#### `menu.add_combo_box(name, labels)`
```lua
menu.add_combo_box("Region", {"US", "EU", "ASIA"})
```
Adds a dropdown combo box. Read index with `menu.get_int(name)`.

---

#### `menu.add_slider_int(name)`
```lua
menu.add_slider_int("Volume")
```
Adds an integer slider. Read with `menu.get_int(name)`.

---

#### `menu.add_slider_float(name)`
```lua
menu.add_slider_float("Opacity")
```
Adds a float slider. Read with `menu.get_float(name)`.

---

#### `menu.add_color_picker(name)`
```lua
menu.add_color_picker("Text Color")
```
Adds a color picker. Read with `menu.get_color(name)`.

---

#### `menu.add_keybind(name, default_key)`
```lua
menu.add_keybind("Toggle Key", VK.F5)
```
Adds a keybind selector. Read with `menu.get_keybind(name)`.

---

#### `menu.next_line()`
Forces the next element to appear on the same line as the previous (inline layout).

---

### Getting Values

| Function | Returns | Notes |
|----------|---------|-------|
| `menu.get_bool(name)` | `bool` | For checkboxes |
| `menu.get_text(name)` | `string` | For input text |
| `menu.get_int(name)` | `int` | For int inputs, sliders, combos |
| `menu.get_float(name)` | `float` | For float inputs/sliders |
| `menu.get_color(name)` | `Color` | For color pickers |
| `menu.get_keybind(name)` | `int` | VK code of the bound key |

---

### Setting Values

| Function | Notes |
|----------|-------|
| `menu.set_bool(name, value)` | Set checkbox state |
| `menu.set_text(name, value)` | Set text field |
| `menu.set_int(name, value)` | Set integer field |
| `menu.set_float(name, value)` | Set float field |
| `menu.set_color(name, value)` | Set color |
| `menu.set_keybind(name, value)` | Set keybind (VK code) |

---

### Menu Visibility & DPI

#### `menu.set_visible(visible)`
```lua
menu.set_visible(false) -- hides the GLD menu
```

#### `menu.set_dpi(dpi)`
```lua
menu.set_dpi(1.5)
```
Sets the DPI scale of the menu.

#### `menu.is_main_window_active()`
```lua
if menu.is_main_window_active() then ... end
```
Returns `true` if the GLD main window is focused.

---

## 4. notifications

Push toast notifications to the GLD UI.

### `notifications.push(title, text)`
```lua
notifications.push("Info", "Download started")
```

### `notifications.push_success(title, text)`
```lua
notifications.push_success("Done", "Download complete!")
```

### `notifications.push_error(title, text)`
```lua
notifications.push_error("Error", "Something went wrong")
```

### `notifications.push_warning(title, text)`
```lua
notifications.push_warning("Warning", "Low disk space")
```

---

## 5. http

HTTP request functions.

> All functions accept an optional `headers` table (`{ ["Key"] = "Value" }`). The body parameters accept plain strings (JSON, form data, etc.).

### `http.get(url [, headers])`
```lua
local res = http.get("https://example.com/api", {["Authorization"] = "Bearer token"})
```
Performs an HTTP GET and returns the response body as a string.

---

### `http.post(url, body [, headers])`
```lua
local res = http.post("https://example.com/api", '{"key":"value"}', {["Content-Type"] = "application/json"})
```

---

### `http.put(url, body [, headers])`
### `http.patch(url, body [, headers])`
### `http.delete(url [, headers])`
### `http.head(url [, headers])`
### `http.options(url [, headers])`

All follow the same pattern as `get`/`post` above.

---

### `http.request(method, url, body [, headers])`
```lua
local res = http.request("POST", "https://example.com", body, headers)
```
Generic request method for any HTTP verb.

---

### `http.CloudFlareSolver(url)`
```lua
http.CloudFlareSolver("https://cf-protected-site.com")
client.add_callback("on_cfdone", function(cookie, resolved_url)
    -- use cookie + specific User-Agent below
end)
```
Opens a Cloudflare challenge solver. When done, fires the `on_cfdone` callback with `(cookie, url)`.

**Required User-Agent after solving:**
```
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15
```

---

### `http.byetresolver(url)`
```lua
local resolved = http.byetresolver("https://byethost.example.com/file")
```
Resolves Byet/iFastNet hosted download links.

---

## 6. file

File system operations.

### `file.write(path, data)`
```lua
file.write("C:/myfile.txt", "Hello World")
```
Writes (overwrites) data to a file.

---

### `file.append(path, data)`
```lua
file.append("C:/log.txt", "new line\n")
```
Appends data to a file.

---

### `file.read(path)`
```lua
local contents = file.read("C:/myfile.txt")
```
Returns the full contents of a file as a string.

---

### `file.delete(path)`
```lua
file.delete("C:/myfile.txt")
```
Deletes a file.

---

### `file.exists(path)`
```lua
if file.exists("C:/myfile.txt") then ... end
```
Returns `true` if the file exists.

---

### `file.exec(execpath [, delay [, commandline [, isinnosetup [, innoproc]]]])`
Same as the global `exec()` but scoped under `file`.

---

### `file.listfolders(path)`
```lua
local folders = file.listfolders("C:/Games")
for _, f in ipairs(folders) do print(f) end
```
Returns a list of subdirectory names in the given path.

---

### `file.listexecutables(path)`
Returns a list of `.exe` files in the given path.

---

### `file.listexecutablesrecursive(path)`
Returns a list of `.exe` files in the given path and all subdirectories.

---

### `file.listcompactedfiles(path)`
Returns a list of archive files (`.zip`, `.rar`, `.7z`, `.tar`, etc.) in the path.

---

### `file.getusername()`
```lua
local user = file.getusername()
```
Returns the current Windows username.

---

### `file.create_directory(path)`
```lua
file.create_directory("C:/MyFolder/SubFolder")
```
Creates a directory (and any needed parents).

---

### `file.copy_file(src, dst)`
```lua
file.copy_file("C:/src.txt", "C:/dst.txt")
```

---

### `file.move_file(src, dst)`
```lua
file.move_file("C:/old.txt", "C:/new.txt")
```

---

### `file.get_filename(path)`
```lua
local name = file.get_filename("C:/Games/game.exe") -- "game.exe"
```

---

### `file.get_extension(path)`
```lua
local ext = file.get_extension("C:/file.zip") -- ".zip"
```

---

### `file.get_parent_path(path)`
```lua
local parent = file.get_parent_path("C:/Games/game.exe") -- "C:/Games"
```

---

### `file.list_directory(path)`
```lua
local entries = file.list_directory("C:/Games")
```
Returns a table of all entries (files and folders) in the directory.

---

## 7. browser

Manage embedded Chromium (CEF) browser windows inside GLD.

> Browser names are **unique**. Only one browser per name can exist at a time. Keep this in mind when building download resolvers, as the download manager may launch multiple downloads simultaneously.

### `browser.CreateBrowser(name, url)`
```lua
local b = browser.CreateBrowser("myBrowser", "https://example.com")
```
Creates a new browser with the given name and navigates to `url`. Returns a `GLDBrowser` object.

---

### `browser.GetBrowserByName(name)`
```lua
local b = browser.GetBrowserByName("myBrowser")
```
Returns an existing `GLDBrowser` by name, or `nil`.

---

### `browser.GetBrowserByID(id)`
```lua
local b = browser.GetBrowserByID(1)
```
Returns a `GLDBrowser` by its integer ID.

---

### `browser.set_visible(visible, name)`
```lua
browser.set_visible(true, "myBrowser")
```
Shows or hides a browser window to the user.

---

### `browser.IsBrowserVisible(name)`
```lua
if browser.IsBrowserVisible("myBrowser") then ... end
```
Returns `true` if the browser is visible.

---

### `browser.EnableCaptchaDetection(name)`
```lua
browser.EnableCaptchaDetection("myBrowser")
```
Enables captcha detection for this browser (default is on).

---

### `browser.DisableCaptchaDetection(name)`
```lua
browser.DisableCaptchaDetection("myBrowser")
```
Disables captcha detection. Useful if you're getting stuck on Cloudflare "Just a moment" pages.

---

### `browser.IsCaptchaDetectionOn(name)`
```lua
if browser.IsCaptchaDetectionOn("myBrowser") then ... end
```

---

## 8. GLDBrowser Usertype

An instance returned by `browser.CreateBrowser()` or `browser.GetBrowserByName()`.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `burl` | string | Current URL of the browser |
| `name` | string | Browser name |
| `is_rendering` | bool | Whether the browser is actively rendering |

---

### State Queries

| Method | Returns | Description |
|--------|---------|-------------|
| `HasBrowser()` | bool | Browser instance exists |
| `CanGoBack()` | bool | History allows back navigation |
| `CanGoForward()` | bool | History allows forward navigation |
| `IsLoading()` | bool | Page is currently loading |
| `GetID()` | int | Browser integer ID |
| `HasBrowserAndFocusedFrame()` | bool | Browser + focused frame exist |
| `HasBrowserAndMainFrame()` | bool | Browser + main frame exist |
| `HasBrowserAndHost()` | bool | Browser + host exist |

---

### Navigation

| Method | Description |
|--------|-------------|
| `ChangeBrowserURL(url)` | Navigate to a new URL |
| `ReloadBrowserPage()` | Reload current page |
| `ReloadIgnoreCache()` | Hard reload (bypass cache) |
| `GoBackBrowser()` | Go back in history |
| `GoForwardBrowser()` | Go forward in history |
| `CancelLoading()` | Stop loading the current page |
| `CloseBrowser()` | Close and destroy the browser |
| `BrowserUrl()` | Returns the current URL string |

---

### Content

| Method | Description |
|--------|-------------|
| `GetPageTitle()` | Returns the page title string |
| `GetBrowserSource(callback)` | Calls `callback(source)` with the page HTML source |
| `ExecuteJavaScriptOnMainFrame(code)` | Runs JS in the main frame |
| `ExecuteJavaScriptOnFocusedFrame(code)` | Runs JS in the focused frame |

---

### Clipboard

| Method | Description |
|--------|-------------|
| `Copy()` | Copy selection |
| `Cut()` | Cut selection |
| `Paste()` | Paste |
| `PasteAsPlainText()` | Paste without formatting |
| `Undo()` | Undo |
| `Redo()` | Redo |
| `SelectAll()` | Select all |

---

### View

| Method | Description |
|--------|-------------|
| `ZoomIn()` | Zoom in |
| `ZoomOut()` | Zoom out |
| `ZoomReset()` | Reset zoom |
| `MuteAudio(mute)` | Mute/unmute audio |
| `Print()` | Print the page |
| `Resize()` | Resize the browser view |
| `ViewSource()` | Open page source |
| `SavePageAs()` | Save page dialog |

---

### Search

| Method | Description |
|--------|-------------|
| `Find(text, forward, matchCase, findNext)` | Find text on page |
| `StopFinding(clearSelection)` | Stop find and optionally clear selection |

---

### Downloads

| Method | Description |
|--------|-------------|
| `AddDownload(url)` | Add a URL to the GLD download manager |
| `DownloadImage(imageUrl)` | Download an image via browser |

---

### DevTools

| Method | Description |
|--------|-------------|
| `ShowDevTools()` | Open DevTools panel |
| `CloseDevTools()` | Close DevTools |
| `InspectElementAt(x, y)` | Inspect element at pixel coordinates |

---

### Popups & LocalStorage

| Method | Description |
|--------|-------------|
| `OpenBrowserPopup(url, title)` | Open a popup browser window |
| `ClearLocalStorage()` | Clear all localStorage for this browser |
| `SetCustomLocalStorageValueForURL(url, key, value)` | Set a localStorage key for a specific URL |
| `RemoveCustomLocalStorageValueForURL(url, key)` | Remove a localStorage key for a specific URL |

---

## 9. download

Manage file downloads.

### `Download.DownloadFile(url)`
```lua
Download.DownloadFile("https://example.com/file.zip")
```
Adds a URL to the GLD download queue.

---

### `Download.GetFileNameFromUrl(url)`
```lua
local name = Download.GetFileNameFromUrl("https://example.com/file.zip") -- "file.zip"
```

---

### `Download.DirectDownload(url, path)`
```lua
Download.DirectDownload("https://example.com/file.zip", "C:/Downloads/file.zip")
```
Downloads directly to a specified path.

---

### `Download.DownloadImage(imageurl)`
```lua
local localpath = Download.DownloadImage("https://example.com/img.jpg")
```
Downloads an image and returns the local file path.

---

### `Download.ChangeDownloadPath(path)`
```lua
Download.ChangeDownloadPath("D:/Downloads")
```

---

### `Download.GetDownloadPath()`
```lua
local path = Download.GetDownloadPath()
```

---

### `Download.ChangeMaxActiveDownloads(max)`
```lua
Download.ChangeMaxActiveDownloads(3)
```

---

### `Download.GetMaxActiveDownloads()`
```lua
local max = Download.GetMaxActiveDownloads()
```

---

### `Download.SetMaxConnections(n)`
### `Download.GetMaxConnections()`

Controls the number of simultaneous connections per download.

---

### `Download.TorrentContentToMagnet(torrentcontent)`
```lua
local magnet = Download.TorrentContentToMagnet(torrent_file_contents_string)
```
Converts torrent file content (as a string) to a magnet link.

---

### `Download.TorrentToMagnet(filepath)`
```lua
local magnet = Download.TorrentToMagnet("C:/file.torrent")
```
Converts a `.torrent` file path to a magnet link.

---

### `Download.SetHistoryUrl(url, ogurl)`
```lua
Download.SetHistoryUrl(resolved_url, original_url)
```
Associates a resolved download URL with the original URL so that GLD can resume interrupted downloads correctly.

> **Important:** If a download is cancelled and restarted via the browser, you must call `SetHistoryUrl` again so GLD can resume it after an app restart. `ogurl` is the unresolved original URL.

---

## 10. input

Keyboard, mouse, and virtual gamepad input simulation and detection.

### Keyboard Detection

#### `input.is_key_down(vk_code)`
```lua
if input.is_key_down(VK.F5) then ... end
```
Returns `true` while the key is held down.

#### `input.is_key_pressed(vk_code)`
```lua
if input.is_key_pressed(VK.SPACE) then ... end
```
Returns `true` on the frame the key is first pressed.

#### `input.get_key_state(vk_code)`
Returns the raw `GetKeyState` short value.

#### `input.is_key_toggled(vk_code)`
Returns `true` if the key is in a toggled-on state (e.g., Caps Lock).

---

### Keyboard Simulation

#### `input.key_press(vk_code [, delay [, delay2]])`
```lua
input.key_press(VK.RETURN)
input.key_press(VK.KEY_A, 100, 50) -- wait 100ms before, hold 50ms before release
```
Simulates a full key press (down + up).

| Parameter | Default | Description |
|-----------|---------|-------------|
| `delay` | `0` | Milliseconds before pressing |
| `delay2` | `50` | Milliseconds between down and up |

#### `input.key_down(vk_code [, delay])`
Sends a keydown event.

#### `input.key_up(vk_code [, delay])`
Sends a keyup event.

---

### Mouse

#### `input.get_mouse_pos()`
```lua
local pos = input.get_mouse_pos()
print(pos.x, pos.y)
```
Returns a table with `x` and `y` fields.

#### `input.set_mouse_pos(x, y)`
```lua
input.set_mouse_pos(960, 540)
```
Moves the mouse cursor to the given screen coordinates.

#### `input.mouse_click([button [, delay [, delay2]]])`
```lua
input.mouse_click(0) -- left click
input.mouse_click(1) -- right click
input.mouse_click(2) -- middle click
```
Simulates a mouse button click.

#### `input.mouse_down([button [, delay]])`
#### `input.mouse_up([button [, delay]])`

Sends mouse button down/up events separately.

#### `input.mouse_wheel(delta [, delay])`
```lua
input.mouse_wheel(120)  -- scroll up
input.mouse_wheel(-120) -- scroll down
```

---

### Virtual Gamepad

> Requires **ViGEm Bus Driver**: https://vigembusdriver.com/download/

#### `input.InitializeVirtualGamePad()`
```lua
input.InitializeVirtualGamePad()
```
Initializes a virtual Xbox controller. Call once when the script loads.

#### `input.SendVirtualGamePadKeyPress(gp_code [, holdtime])`
```lua
sleep(100)
input.SendVirtualGamePadKeyPress(GP.A)
sleep(100)
input.SendVirtualGamePadKeyPress(GP.B, 200) -- hold for 200ms
```
Simulates pressing an Xbox controller button. `gp_code` is from the `GP` table.

> **Important:** You must call `sleep()` before each virtual gamepad call.

#### `input.SendVirtualGamePadTriggerPress(righttrigger, value [, holdtime])`
```lua
sleep(100)
input.SendVirtualGamePadTriggerPress(false, 255) -- left trigger, full press
input.SendVirtualGamePadTriggerPress(true, 128)  -- right trigger, half press
```
`value` is `0`–`255`.

#### `input.SendVirtualGamePadThumbMove(rightstick, xvalue, yvalue [, holdtime])`
```lua
sleep(100)
input.SendVirtualGamePadThumbMove(false, 32767, 0) -- left stick, full right
```
Moves an analog stick. Values are typically `-32768` to `32767`.

#### `input.CleanupVirtualGamePad()`
Releases the virtual gamepad. Usually not needed.

---

## 11. VK — Virtual Keys

The `VK` table contains Windows Virtual Key constants. Use these with `input.*` functions.

### Mouse Buttons
| Key | Description |
|-----|-------------|
| `VK.LBUTTON` | Left mouse button |
| `VK.RBUTTON` | Right mouse button |
| `VK.MBUTTON` | Middle mouse button |
| `VK.XBUTTON1` | X1 mouse button |
| `VK.XBUTTON2` | X2 mouse button |
| `VK.CANCEL` | Control-break |

### Common Keys
| Key | Description |
|-----|-------------|
| `VK.BACK` | Backspace |
| `VK.TAB` | Tab |
| `VK.RETURN` | Enter |
| `VK.SHIFT` | Shift |
| `VK.CONTROL` | Ctrl |
| `VK.MENU` | Alt |
| `VK.ESCAPE` | Escape |
| `VK.SPACE` | Spacebar |
| `VK.CAPITAL` | Caps Lock |
| `VK.PAUSE` | Pause |

### Navigation
| Key | Description |
|-----|-------------|
| `VK.LEFT` | Left Arrow |
| `VK.RIGHT` | Right Arrow |
| `VK.UP` | Up Arrow |
| `VK.DOWN` | Down Arrow |
| `VK.HOME` | Home |
| `VK.END` | End |
| `VK.PRIOR` | Page Up |
| `VK.NEXT` | Page Down |
| `VK.INSERT` | Insert |
| `VK.DELETE` | Delete |

### Number Keys
`VK.KEY_0` through `VK.KEY_9`

### Letter Keys
`VK.KEY_A` through `VK.KEY_Z`

### Function Keys
`VK.F1` through `VK.F24`

### Numpad
`VK.NUMPAD0` through `VK.NUMPAD9`, `VK.MULTIPLY`, `VK.ADD`, `VK.SUBTRACT`, `VK.DECIMAL`, `VK.DIVIDE`, `VK.SEPARATOR`

### Modifier Variants
| Key | Description |
|-----|-------------|
| `VK.LSHIFT` | Left Shift |
| `VK.RSHIFT` | Right Shift |
| `VK.LCONTROL` | Left Ctrl |
| `VK.RCONTROL` | Right Ctrl |
| `VK.LMENU` | Left Alt |
| `VK.RMENU` | Right Alt |
| `VK.LWIN` | Left Windows key |
| `VK.RWIN` | Right Windows key |

### Media & Volume
| Key | Description |
|-----|-------------|
| `VK.VOLUME_MUTE` | Mute |
| `VK.VOLUME_DOWN` | Volume Down |
| `VK.VOLUME_UP` | Volume Up |
| `VK.MEDIA_NEXT_TRACK` | Next Track |
| `VK.MEDIA_PREV_TRACK` | Previous Track |
| `VK.MEDIA_STOP` | Stop |
| `VK.MEDIA_PLAY_PAUSE` | Play/Pause |

### Browser Keys
`VK.BROWSER_BACK`, `VK.BROWSER_FORWARD`, `VK.BROWSER_REFRESH`, `VK.BROWSER_STOP`, `VK.BROWSER_SEARCH`, `VK.BROWSER_FAVORITES`, `VK.BROWSER_HOME`

### OEM / Punctuation Keys
| Key | Character |
|-----|-----------|
| `VK.OEM_1` | `;:` |
| `VK.OEM_PLUS` | `=+` |
| `VK.OEM_COMMA` | `,<` |
| `VK.OEM_MINUS` | `-_` |
| `VK.OEM_PERIOD` | `.>` |
| `VK.OEM_2` | `/?` |
| `VK.OEM_3` | `` `~ `` |
| `VK.OEM_4` | `[{` |
| `VK.OEM_5` | `\|` |
| `VK.OEM_6` | `]}` |
| `VK.OEM_7` | `'"` |
| `VK.OEM_102` | `<>` or `\|` (102-key keyboard) |

### Lock Keys
`VK.NUMLOCK`, `VK.SCROLL`

### Other
`VK.APPS`, `VK.SLEEP`, `VK.SNAPSHOT` (Print Screen), `VK.HELP`, `VK.SELECT`, `VK.PRINT`, `VK.EXECUTE`

---

## 12. GP — Gamepad Keys

Xbox controller button constants for use with `input.SendVirtualGamePadKeyPress()`.

| Key | Description |
|-----|-------------|
| `GP.A` | A button |
| `GP.B` | B button |
| `GP.X` | X button |
| `GP.Y` | Y button |
| `GP.DPAD_UP` | D-Pad Up |
| `GP.DPAD_DOWN` | D-Pad Down |
| `GP.DPAD_LEFT` | D-Pad Left |
| `GP.DPAD_RIGHT` | D-Pad Right |
| `GP.START` | Start button |
| `GP.BACK` | Back button |
| `GP.GUIDE` | Guide/Home button |
| `GP.LEFT_THUMB` | Left thumbstick click |
| `GP.RIGHT_THUMB` | Right thumbstick click |
| `GP.LEFT_SHOULDER` | Left bumper (LB) |
| `GP.RIGHT_SHOULDER` | Right bumper (RB) |

---

## 13. html & xml Parsers

### HTML Parser

#### `html.parse(html_string)`
```lua
local doc = html.parse("<html><body><h1>Hello</h1></body></html>")
local root = doc:root()
local body = doc:body()
local nodes = doc:css("h1")
for i = 1, #nodes do
    print(nodes[i]:text())
end
```
Parses an HTML string and returns an `HtmlDocument`.

---

### HtmlDocument Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `doc:css(selector)` | table of `HtmlNode` | Query with CSS selector |
| `doc:root()` | `HtmlNode` | Root `<html>` node |
| `doc:body()` | `HtmlNode` | `<body>` node |

---

### HtmlNode Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `node:tag()` | string | Tag name (e.g., `"h1"`) |
| `node:text()` | string | Inner text content |
| `node:attr(name)` | string or nil | Attribute value |
| `node:parent()` | `HtmlNode` | Parent node |
| `node:children()` | table of `HtmlNode` | Child nodes |

---

### XML Parser

#### `xml.parse(xml_string)`
```lua
local doc = xml.parse("<root><item id='1'>Value</item></root>")
local root = doc:root()
local items = doc:xpath("//item")
```
Parses XML and returns an `XmlDocument`.

---

### XmlDocument Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `doc:xpath(expr)` | table of `XmlNode` | Query with XPath |
| `doc:root()` | `XmlNode` | Root element |

---

### XmlNode Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `node:name()` | string | Element tag name |
| `node:text()` | string | Text content |
| `node:attr(name)` | string or nil | Attribute value |

---

### Legacy HTML Parser (HtmlWrapper — Deprecated)

```lua
local result = HtmlWrapper.findAttribute(htmlString, tagName, termKey, termValue, desiredKey)
```
Kept for backwards compatibility. Use `html.parse()` instead.

---

## 14. utils

Utility and debugging functions.

### `utils.AttachConsole()`
Attaches a Windows console window for debug output.

### `utils.DetachConsole()`
Detaches the console window.

### `utils.ConsolePrint(logToFile, fmt, ...)`
```lua
utils.ConsolePrint(true, "Value: %d", 42)
```
Prints to the attached console. Set `logToFile` to `true` to also write to log file. Must call `AttachConsole()` first.

### `utils.GetTimeString()`
Returns the current time as a human-readable string.

### `utils.GetTimestamp()`
Returns a timestamp string.

### `utils.GetTimeUnix()`
Returns the current Unix timestamp as an integer.

### `utils.Log(fmt, ...)`
```lua
utils.Log("Something happened: %s", "info")
```
Writes to `Project-GLD.log` in the same folder as the GLD executable. Prefer `gldconsole.print()` for interactive logging.

---

## 15. gldconsole

In-app debug console. Preferred logging method.

### `gldconsole.print(text)`
```lua
gldconsole.print("Script started")
```
Prints a message to the GLD built-in console.

### `gldconsole.show()`
Opens/shows the GLD console window.

### `gldconsole.close()`
Closes/hides the GLD console window.

---

## 16. game

Access information about the currently viewed game in the search/game page.

### `game.getgamename()`
```lua
local name = game.getgamename()
```
Returns the name of the game currently selected/displayed in the search tab.

---

## 17. GameLibrary

Manage the GLD game library.

### `GameLibrary.launch(id)`
```lua
GameLibrary.launch(3)
```
Launches the game with the given library ID. Returns `true` on success.

---

### `GameLibrary.close(id)`
Closes/stops the running game.

---

### `GameLibrary.addGame(exePath, imagePath, gamename, commandline [, disableigdbid])`
```lua
GameLibrary.addGame("C:/Games/mygame.exe", "C:/img.jpg", "My Game", "", false)
```
Adds a game to the library.

| Parameter | Type | Description |
|-----------|------|-------------|
| `exePath` | string | Path to the executable |
| `imagePath` | string | Path to the cover image |
| `gamename` | string | Display name |
| `commandline` | string | Launch arguments |
| `disableigdbid` | bool | Disable IGDB ID lookup |

---

### `GameLibrary.changeGameinfo(id [, exePath [, imagePath [, gamename [, commandline]]]])`
```lua
GameLibrary.changeGameinfo(3, "", "", "New Name", "")
```
Updates info for a library game. Pass empty strings to leave fields unchanged.

---

### `GameLibrary.removeGame(id)`
```lua
GameLibrary.removeGame(3)
```

---

### `GameLibrary.GetGameIdFromName(name)`
```lua
local id = GameLibrary.GetGameIdFromName("My Game")
```

---

### `GameLibrary.GetGameNameFromId(id)`
```lua
local name = GameLibrary.GetGameNameFromId(3)
```

---

### `GameLibrary.GetGamePath(id)`
```lua
local path = GameLibrary.GetGamePath(3)
```
Returns the executable path for the game.

---

### `GameLibrary.GetGameList()`
```lua
local list = GameLibrary.GetGameList()
for _, g in ipairs(list) do
    print(g.name, g.id)
end
```
Returns a table of all library games. Each entry has the same fields as `GameInfo`.

---

## 18. communication

Used by search/download scripts to pass results back to GLD's UI.

### `communication.receiveSearchResults(resultsTable)`
```lua
communication.receiveSearchResults({
    {
        title = "Game Title",
        magneturl = "magnet:?xt=...",
        filesize = "10 GB",
        uploadDate = "2024-01-01",
        uriOnline = "https://...",
        image = "https://img.jpg"
    }
})
```
Sends a list of search result items to display in the GLD search results panel.

---

### `communication.RefreshScriptResults()`
Forces the search results UI to refresh/redraw.

---

## 19. SteamApi

Interact with Steam data.

### `SteamApi.GetAppID(name)`
```lua
local appid = SteamApi.GetAppID("Half-Life 2")
```
Searches for a game and returns its Steam App ID string.

---

### `SteamApi.GetSystemRequirements(appid)`
```lua
local reqs = SteamApi.GetSystemRequirements("220")
```
Returns the system requirements as a string for the given App ID.

---

### `SteamApi.GetGameData(appid)`
```lua
local data = SteamApi.GetGameData("220")
```
Returns full game metadata (JSON string) for the given App ID.

---

### `SteamApi.OpenSteam()`
Launches the Steam application.

---

### `SteamApi.IsSteamRunning()`
```lua
if SteamApi.IsSteamRunning() then ... end
```
Returns `true` if Steam is currently running.

---

## 20. dll

DLL injection utilities.

### `dll.inject(processexename, dllpath, delay)`
```lua
dll.inject("GameProcess.exe", "C:/myhook.dll", 300)
```
Injects a 64-bit DLL into the given process. Returns `true` on success.

| Parameter | Description |
|-----------|-------------|
| `processexename` | e.g., `"GoW.exe"` |
| `dllpath` | Full path to the DLL |
| `delay` | Milliseconds to wait before injecting |

---

### `dll.injectx86(processexename, dllpath, delay)`
Same as `inject` but for 32-bit (x86) processes/DLLs.

---

### `dll.innohook(processname)`
```lua
dll.innohook("setup.exe")
client.add_callback("on_setupcompleted", function(from, to)
    print("Extracted from:", from, "to:", to)
end)
```
Hooks an InnoSetup installer process. Fires the `on_setupcompleted` callback when done.

---

## 21. zip

Archive extraction.

### `zip.extract(source, destination, deleteaftercomplete, pass)`
```lua
zip.extract("C:/archive.zip", "C:/extracted", false, "")
zip.extract("C:/archive.rar", "C:/extracted", true, "mypassword")

client.add_callback("on_extractioncompleted", function(origin, dest)
    print("Extracted:", origin, "->", dest)
end)
```
Extracts an archive. Supports zip, rar, 7z, tar, and more.

| Parameter | Type | Description |
|-----------|------|-------------|
| `source` | string | Path to the archive |
| `destination` | string | Extraction destination folder |
| `deleteaftercomplete` | bool | Delete archive after extraction |
| `pass` | string | Password (empty string if none) |

> Fires the `on_extractioncompleted` callback with `(origin_file, destination_path)` when done.

---

## 22. save

Save game backup and cloud sync.

### Local Backup

| Function | Description |
|----------|-------------|
| `save.Backup(name)` | Backup saves for a game by name |
| `save.Restore(name)` | Restore saves for a game by name |
| `save.BackupAll()` | Backup all tracked games |
| `save.RestoreAll()` | Restore all tracked games |

### Cloud Sync

| Function | Description |
|----------|-------------|
| `save.Upload(name)` | Upload saves to cloud |
| `save.Download(name)` | Download saves from cloud |
| `save.UploadAll()` | Upload all to cloud |
| `save.DownloadAll()` | Download all from cloud |

### Refresh

| Function | Description |
|----------|-------------|
| `save.RefreshBackup()` | Refresh backup list |
| `save.RefreshRestore()` | Refresh restore list |
| `save.RefreshCloud()` | Refresh cloud list |
| `save.RefreshAll()` | Refresh all lists |

### Queries

| Function | Returns | Description |
|----------|---------|-------------|
| `save.GetBackupGamesList()` | table | List of games with backups |
| `save.GetRestoreGamesList()` | string | List of restorable games |
| `save.GetCloudGamesList()` | table of strings | List of cloud-synced games |

---

## 23. settings

Persist GLD settings.

### `settings.save()`
Saves the current GLD settings to disk.

### `settings.load()`
Loads GLD settings from disk.

---

## 24. base64

Base64 encoding and decoding.

### `base64.encode(data)`
```lua
local encoded = base64.encode("Hello World")
```

### `base64.decode(data)`
```lua
local decoded = base64.decode("SGVsbG8gV29ybGQ=")
```

### `base64.encode_shifted(data)`
Encodes using a shifted variant (for obfuscation).

### `base64.decode_shifted(data)`
Decodes a shifted base64 string.

---

## 25. GameInfo Usertype

Represents a game entry. Passed to `on_gamelaunch` callback.

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Game ID |
| `name` | string | Game name |
| `initoptions` | string | Launch options/init config |
| `imagePath` | string | Path or URL to cover image |
| `exePath` | string | Path to executable |

**Example:**
```lua
client.add_callback("on_gamelaunch", function(gameinfo)
    print("Launching:", gameinfo.name)
    print("Exe:", gameinfo.exePath)
end)
```

---

## 26. JsonWrapper Usertype

### `JsonWrapper.parse(jsonString)`
```lua
local data = JsonWrapper.parse('{"key": "value"}')
print(data.key) -- "value"
```
Parses a JSON string and returns a Lua table (sol::object).

---

## 27. HtmlWrapper Usertype (Legacy)

> **Deprecated.** Use `html.parse()` instead.

### `HtmlWrapper.findAttribute(html, tagName, termKey, termValue, desiredKey)`
```lua
local result = HtmlWrapper.findAttribute(html, "a", "class", "download-link", "href")
```
Finds an attribute in an HTML element. Uses the Gumbo HTML parser (old).

---

## 28. Lua Callbacks Reference

Register callbacks with:
```lua
client.add_callback("event_name", function(...)
    -- handler
end)
```

| Event | Arguments | Description |
|-------|-----------|-------------|
| `on_launch` | — | GLD is launched. May fire before the script fully loads — not recommended for most use cases |
| `on_present` | — | Main loop tick. Fires every frame |
| `on_quit` | — | GLD is exiting. Use sparingly |
| `on_gamesearch` | — | User searched for a game |
| `on_gameselected` | — | User selected a game in search |
| `on_scriptselected` | — | A script is selected in the search/game tab |
| `on_gamelaunch` | `GameInfo` | A game was launched. Receives the `GameInfo` object |
| `on_downloadclick` | `item_json, url, scriptname` | User clicked "Download" on a game page. All args are strings |
| `on_downloadcompleted` | `path, url` | A download finished. Args are strings |
| `on_beforedownload` | `url` | Called before a download starts. Return `(resolved_url, name, headers)` to modify the download, or `nil` to keep original |
| `on_extractioncompleted` | `origin, destination` | A `zip.extract()` completed. Both args are strings |
| `on_setupcompleted` | `from, to` | `dll.innohook()` completed. Both are strings |
| `on_cfdone` | `cookie, url` | Cloudflare solver completed. Both are strings |
| `on_browserloaded` | `browserID` | A browser finished loading a page (equivalent to `OnLoadEnd`) |
| `on_browserconsolemessage` | `browserID, message` | A browser emitted a console message |
| `on_browserbeforeresourceload` | `browserID, url, method, referrer, resourceType` | Browser is about to load a resource |
| `on_browserbeforedownload` | `browserID, url, suggestedName, size` | Browser is about to download a file. Return `(originalUrl)` to set the base URL for resolvers |
| `on_captchadetected` | `browserID` | Captcha was detected in a browser |
| `on_captchasolved` | `browserID` | Captcha was solved in a browser |
| `on_button_(name)` | — | A menu button named `name` was clicked |

---

### `on_beforedownload` — Download Resolver Pattern

```lua
client.add_callback("on_beforedownload", function(url)
    -- Resolve the URL however you need
    local resolved = resolve_my_url(url)
    local headers = {"Referer: https://example.com"}
    
    -- Return: resolved_url, display_name, headers_table
    -- Return nil to keep original
    return resolved, "filename.zip", headers
    
    -- Cancel a download:
    -- return "cancel"
end)
```

---

## 29. Full Examples

### Example 1: Basic Search Script

```lua
local VERSION = "1.0.0"
client.auto_script_update("https://example.com/myscript.lua", VERSION)

client.add_callback("on_gamesearch", function()
    local gamename = game.getgamename()
    gldconsole.print("Searching for: " .. gamename)

    local response = http.get("https://myapi.com/search?q=" .. gamename, {})
    local data = JsonWrapper.parse(response)

    local results = {}
    for _, item in ipairs(data.results) do
        table.insert(results, {
            title = item.title,
            magneturl = item.magnet,
            filesize = item.size,
            uploadDate = item.date,
            uriOnline = item.page,
            image = item.image
        })
    end

    communication.receiveSearchResults(results)
end)
```

---

### Example 2: Download Resolver with Browser

```lua
client.add_callback("on_beforedownload", function(url)
    if not url:find("myhost.com") then return nil end

    local b = browser.CreateBrowser("resolver_" .. os.time(), url)
    browser.set_visible(false, b.name)

    -- Wait for the page to load
    sleep(3000)

    local resolved = nil
    b:GetBrowserSource(function(src)
        local doc = html.parse(src)
        local links = doc:css("a.download-btn")
        if links[1] then
            resolved = links[1]:attr("href")
        end
    end)

    sleep(500)
    b:CloseBrowser()

    if resolved then
        return resolved, nil, {"Referer: " .. url}
    end
    return nil
end)
```

---

### Example 3: Custom Menu + Keybind

```lua
menu.add_check_box("Auto-Download")
menu.add_keybind("Toggle Key", VK.F8)
menu.add_button("Run Now")

client.add_callback("on_button_Run Now", function()
    if menu.get_bool("Auto-Download") then
        notifications.push("Script", "Auto-download is enabled!")
    end
end)

client.add_callback("on_present", function()
    local key = menu.get_keybind("Toggle Key")
    if input.is_key_pressed(key) then
        local current = menu.get_bool("Auto-Download")
        menu.set_bool("Auto-Download", not current)
        notifications.push_success("Toggled", "Auto-Download: " .. tostring(not current))
    end
end)
```

---

### Example 4: Virtual Gamepad Macro

```lua
input.InitializeVirtualGamePad()

local function press_sequence()
    sleep(200)
    input.SendVirtualGamePadKeyPress(GP.A, 100)
    sleep(300)
    input.SendVirtualGamePadKeyPress(GP.B, 100)
    sleep(300)
    input.SendVirtualGamePadThumbMove(false, 32767, 0, 500) -- push left stick right
    sleep(600)
end

client.add_callback("on_present", function()
    if input.is_key_pressed(VK.F9) then
        press_sequence()
    end
end)
```

---

### Example 5: File Download + Extraction

```lua
client.add_callback("on_downloadcompleted", function(path, url)
    if path:find("%.zip$") then
        gldconsole.print("Download done, extracting: " .. path)
        zip.extract(path, "C:/Games/MyGame", true, "")
    end
end)

client.add_callback("on_extractioncompleted", function(origin, dest)
    gldconsole.print("Extraction complete: " .. dest)
    GameLibrary.addGame(dest .. "/game.exe", "", "My Game", "", false)
    notifications.push_success("Done", "Game installed!")
end)
```

---

### Example 6: Cloudflare Bypass

```lua
local cf_cookie = nil
local cf_url = nil

client.add_callback("on_cfdone", function(cookie, url)
    cf_cookie = cookie
    cf_url = url
    gldconsole.print("CF solved for: " .. url)
end)

local function get_with_cf(url)
    if cf_cookie == nil then
        http.CloudFlareSolver(url)
        -- Wait for on_cfdone then retry
        return nil
    end
    return http.get(url, {
        ["Cookie"] = cf_cookie,
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15"
    })
end
```

---

*End of Project-GLD Lua API Documentation*