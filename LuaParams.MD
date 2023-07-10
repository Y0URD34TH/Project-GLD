# Lua API Documentation

## You can find script examples here: https://github.com/Y0URD34TH/Project-GLD/tree/main/Scripts
## If you're unfamiliar with or new to LUA, it's highly recommended to first check out the general [LUA documentation](https://www.lua.org/docs.html).

## Table Of Content

* [Client](#namespace-client)
* [Jsonwrapper](#namespace-jsonwrapper)
* [Game](#namespace-game)
* [Menu](#namespace-menu)
* [HTTP](#namespace-http)
* [Utils](#namespace-utils)
* [Communication](#namespace-communication)
* [File](#namespace-file)
* [Download](#namespace-Download)
* [Notifications](#namespace-Notifications)

---
## Namespace: JsonWrapper

### Function: parse
```lua
function parse(jsonString: string)
```
Parses a JSON string and converts it into a Lua object.

#### Parameters:
- `jsonString` (string): The JSON string to parse.

#### Returns:
- A Lua object representing the parsed JSON.

#### Usage Example:
```lua
local jsonString = '{"name": "John", "age": 30}'
local luaObject = JsonWrapper.parse(jsonString)
utils.ConsolePrint(true, "Parsed JSON: %s", tostring(luaObject))
```
---

## Namespace: game

### Function: getgamename
```lua
function game.getgamename()
```
Returns the name of the current game.

#### Returns:
- A string representing the name of the game.

#### Usage Example:
```lua
local gameName = game.getgamename()
utils.ConsolePrint(true, "Current Game: %s", gameName)
```

---

## Namespace: menu

### Function: get_visible
```lua
function menu.get_visible()
```
Checks if the menu is visible.

#### Returns:
- `true` if the menu is visible, `false` otherwise.

#### Usage Example:
```lua
local isVisible = menu.get_visible()
utils.ConsolePrint(true, "Menu is visible: %s", tostring(isVisible))
```

### Function: set_visible
```lua
function menu.set_visible(visible: boolean)
```
Sets the visibility of the menu.

#### Parameters:
- `visible` (boolean): `true` to show the menu, `false` to hide it.

#### Usage Example:
```lua
menu.set_visible(true)
```

### Function: next_line
```lua
function menu.next_line()
```
Moves the cursor to the next line in the menu.

#### Usage Example:
```lua
menu.next_line()
```

### Function: add_check_box
```lua
function menu.add_check_box(name: string)
```
Adds a checkbox item to the menu.

#### Parameters:
- `name` (string): The name of the checkbox item.

#### Usage Example:
```lua
menu.add_check_box("Enable Feature")
```

### Function: add_button
```lua
function menu.add_button(name: string)
```
Adds a button item to the menu.

#### Parameters:
- `name` (string): The name of the button item.

#### Usage Example:
```lua
menu.add_button("Click Me")
```

### Function: add_combo_box
```lua
function menu.add_combo_box(name: string, labels: table)
```
Adds a combo box item to the menu.

#### Parameters:
- `name` (string): The name of the combo box item.
- `labels` (table): A table containing the labels for the combo box options.

#### Usage Example:
```lua
local options = { "Option 1", "Option 2", "Option 3" }
menu.add_combo_box("Choose Option", options)
```

### Function: add_slider_int
```lua
function menu.add_slider_int(name: string, min: number, max: number)
```
Adds an integer slider item to the menu.

#### Parameters:
- `name` (string): The name of the slider item.
- `min` (number): The minimum value of the slider.
- `max` (number): The maximum value of the slider.

#### Usage Example:
```lua
menu.add_slider_int("Volume", 0, 100)
```

### Function: add_slider_float
```lua
function menu.add_slider_float(name: string, min: number, max: number)
```
Adds a floating-point slider item to the menu.

#### Parameters:
- `name` (string): The name of the slider item.
- `min` (number): The minimum value of the slider.
- `max` (number): The maximum value of the slider.

#### Usage Example:
```lua
menu.add_slider_float("Intensity", 0.0, 

````

### Function: add_color_picker
```lua
function menu.add_color_picker(name: string)
```
Adds a color picker item to the menu.

#### Parameters:
- `name` (string): The name of the color picker item.

#### Usage Example:
```lua
menu.add_color_picker("Background Color")
```

### Function: get_bool
```lua
function menu.get_bool(name: string)
```
Gets the value of a boolean menu item.

#### Parameters:
- `name` (string): The name of the boolean menu item.

#### Returns:
- `true` if the menu item is checked, `false` otherwise.

#### Usage Example:
```lua
local isEnabled = menu.get_bool("Enable Feature")
utils.ConsolePrint(true, "Is Feature Enabled: %s", tostring(isEnabled))
```

### Function: get_int
```lua
function menu.get_int(name: string)
```
Gets the value of an integer menu item.

#### Parameters:
- `name` (string): The name of the integer menu item.

#### Returns:
- The value of the integer menu item.

#### Usage Example:
```lua
local volume = menu.get_int("Volume")
utils.ConsolePrint(true, "Current Volume: %d", volume)
```

### Function: get_float
```lua
function menu.get_float(name: string)
```
Gets the value of a floating-point menu item.

#### Parameters:
- `name` (string): The name of the floating-point menu item.

#### Returns:
- The value of the floating-point menu item.

#### Usage Example:
```lua
local intensity = menu.get_float("Intensity")
utils.ConsolePrint(true, "Current Intensity: %.2f", intensity)
```

---

## Namespace: http

### Function: get
```lua
function http.get(link: string, headers: table)
```
Sends an HTTP GET request and retrieves the response.

#### Parameters:
- `link` (string): The URL to send the GET request to.
- `headers` (table): A table containing additional headers for the request.

#### Returns:
- The response string received from the GET request.

#### Usage Example:
```lua
local response = http.get("https://example.com/api/data", { ["Authorization"] = "Bearer token123" })
utils.ConsolePrint(true, "Response: %s", response)
```

### Function: post
```lua
function http.post(link: string, params: string, headers: table)
```
Sends an HTTP POST request with the specified parameters and retrieves the response.

#### Parameters:
- `link` (string): The URL to send the POST request to.
- `params` (string): The parameters to include in the POST request body.
- `headers` (table): A table containing additional headers for the request.

#### Returns:
- The response string received from the POST request.

#### Usage Example:
```lua
local params = "name=John&age=30"
local response = http.post("https://example.com/api/data", params, { ["Content-Type"] = "application/x-www-form-urlencoded" })
utils.ConsolePrint(true, "Response: %s", response)
```

### Function: ArchieveOrgResolver
```lua
function http.ArchivedotOrgResolver(link: string)
```
Resolves a link using the Archive.org service.

#### Parameters:
- `link` (string): The link to resolve.

#### Returns:
- The resolved location header.

#### Usage Example:
```lua
local resolvedLink = http.ArchivedotOrgResolver("https://example.com")
utils.ConsolePrint(true, "Resolved Link: %s", resolvedLink)
```

---

## Namespace: file

### Function: append
```lua
function file.append(path: string, data: string)
```
Appends data to a file.

#### Parameters:
- `path` (string): The path of the file.
- `data` (string): The data to append.

#### Usage Example:
```lua
file.append("log.txt", "New log entry")
```

### Function: write
```lua
function file.write(path: string, data: string)
```
Writes data to a file, overwriting any existing content.

#### Parameters:
- `path` (string): The path of the file.
-


### Function: write
```lua
function file.write(path: string, data: string)
```
Writes data to a file, overwriting any existing content.

#### Parameters:
- `path` (string): The path of the file.
- `data` (string): The data to write.

#### Usage Example:
```lua
file.write("config.ini", "Setting=value")
```

### Function: read
```lua
function file.read(path: string)
```
Reads the content of a file.

#### Parameters:
- `path` (string): The path of the file.

#### Returns:
- The content of the file as a string.

#### Usage Example:
```lua
local content = file.read("log.txt")
utils.ConsolePrint(true, "File Content: %s", content)
```

---

## Namespace: client

### Function: add_callback
```lua
function client.add_callback(eventname: string, func: function)
```
Adds a callback function for a specific event.

#### Parameters:
- `eventname` (string): The name of the event.
- `func` (function): The callback function to be invoked.

#### Some CallBacks Event Names:
- `on_present` always run the function in that callback
- `on_buttonpressed` only run the function when one button (added by a lua script) is pressed
- `on_gameselected` execute the function when a game is selected in the search tab

#### Usage Examples:
```lua
client.add_callback("on_present", function()
    utils.ConsolePrint(true, "Present event triggered")
end)
```
```lua
local function example()
  local gamename = game.getgamename()
  utils.ConsolePrint(true, "A game was selected! game name: %s", gamename)
end
client.add_callback("on_gameselected", example)
```

### Function: load_script
```lua
function client.load_script(name: string)
```
Loads a script by name.

#### Parameters:
- `name` (string): The name of the script to load.

#### Usage Example:
```lua
client.load_script("myscript.lua")
```

### Function: unload_script
```lua
function client.unload_script(name: string)
```
Unloads a script by name.

#### Parameters:
- `name` (string): The name of the script to unload.

#### Usage Example:
```lua
client.unload_script("myscript.lua")
```

### Function: log
```lua
function client.log(title: string, text: string)
```
Logs a message with a title.

#### Parameters:
- `title` (string): The title of the log message.
- `text` (string): The content of the log message.

#### Usage Example:
```lua
client.log("Info", "Script loaded successfully")
```

### Function: GetVersion
```lua
function client.GetVersion()
```
Returns the version of the client.

#### Returns:
- A string representing the client version.

#### Usage Example:
```lua
local version = client.GetVersion()
utils.ConsolePrint(true, "Client Version: %s", version)
```

---

## Namespace: communication

### Function: receiveSearchResults
```lua
function receiveSearchResults(resultsTable: table)
```
Receives search results as a Lua table and processes them.

#### Parameters:
- `resultsTable` (table): The Lua table containing the search results.

#### Usage Example:
```lua
-- Define a sample search results table
local resultsTable = {
    {
        name = "Result 1",
        links = {
            { name = "Link 1", link = "https://example.com/link1", addtodownloadlist = true },
            { name = "Link 2", link = "https://example.com/link2", addtodownloadlist = false }
        },
        ScriptName = "Script 1"
    },
    {
        name = "Result 2",
        links = {
            { name = "Link 3", link = "https://example.com/link3", addtodownloadlist = true },
            { name = "Link 4", link = "https://example.com/link4", addtodownloadlist = true }
        },
        ScriptName = "Script 2"
    }
}

-- Call the receiveSearchResults function
communication.receiveSearchResults(resultsTable)
```

---

## Namespace: Download

### Function: DownloadFile
```lua
function Download.DownloadFile(Downloadurl: string)
```
Downloads a file from the specified URL.

#### Parameters:
- `Downloadurl` (string): The URL of the file to Download.

#### Usage Example:
```lua
Download.DownloadFile("https://example.com/file.zip")
```

### Function: GetFileNameFromUrl
```lua
function Download.GetFileNameFromUrl(url: string)
```
Extracts the file name from a URL.

#### Parameters:
- `url` (string): The URL from which to extract the file name.

#### Returns:
- The extracted file name as a string.

#### Usage Example:
```lua
local fileName = Download.GetFileNameFromUrl("https://example.com/files/file.zip")
utils.ConsolePrint(true, "File Name: %s", fileName)
```

---

## Namespace: Notifications

### Function: push
```lua
function Notifications.push(title: string, text: string)
```
Pushes a notification with the specified title and text.

#### Parameters:
- `title` (string): The title of the notification.
- `text` (string): The content of the notification.

#### Usage Example:
```lua
Notifications.push("Notification", "Hello, World!")
```

### Function: push_success
```lua
function Notifications.push_success(title: string, text: string)
```
Pushes a success notification with the specified title and text.

#### Parameters:
- `title` (string): The title of the notification.
- `text` (string): The content of the notification.

#### Usage Example:
```lua
Notifications.push_success("Success", "Operation completed successfully")
```

### Function: push_error
```lua
function Notifications.push_error(title: string, text: string)
```
Pushes an error notification with the specified title and text.

#### Parameters:
- `title` (string): The title of the notification.
- `text` (string): The content of the notification.

#### Usage Example:
```lua
Notifications.push_error("Error", "An error occurred")
```

### Function: push_warning
```lua
function Notifications.push_warning(title: string, text: string)
```
Pushes a warning notification with the specified title and text.

#### Parameters:
- `title` (string): The title of the notification.
- `text` (string): The content of the notification.

#### Usage Example:
```lua
Notifications.push_warning("Warning", "Warning: Low disk space")
```
