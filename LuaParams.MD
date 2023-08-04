# Lua API Documentation

## You can find script examples here: https://github.com/Y0URD34TH/Project-GLD/tree/main/Scripts
## If you're unfamiliar with or new to LUA, it's highly recommended to first check out the general [LUA documentation](https://www.lua.org/docs.html).

## Table Of Content

* [Client](#namespace-client)
* [Jsonwrapper](#namespace-jsonwrapper)
* [Game](#namespace-game)
* [Game Library](#namespace-gamelibrary)
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

#### Function: add_text

```lua
function add_text(text: string)
```

Adds a text element to the lua menu.

#### Parameters:
- `text` (string): The text to be displayed.

#### Usage Example:
```lua
-- Add a text element to the menu
menu.add_text("Hello, World!")
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

#### Function: get_color

```lua
function get_color(name: string) -> Color
```

Retrieves the color value of a menu item.

#### Parameters:
- `name` (string): The name of the menu item.

#### Returns:
- `Color`: The color value of the specified menu item.

#### Usage Example:
```lua
-- Get the color value of a menu item named "MenuTextColor"
local textColor = menu.get_color("MenuTextColor")
```

---

#### Function: set_bool

```lua
function set_bool(name: string, value: boolean)
```

Sets the boolean value of a menu item.

#### Parameters:
- `name` (string): The name of the menu item.
- `value` (boolean): The new boolean value for the menu item.

#### Usage Example:
```lua
-- Set the boolean value of a menu item named "ToggleFeature" to true
menu.set_bool("ToggleFeature", true)
```

---

#### Function: set_int

```lua
function set_int(name: string, value: integer)
```

Sets the integer value of a menu item.

#### Parameters:
- `name` (string): The name of the menu item.
- `value` (integer): The new integer value for the menu item.

#### Usage Example:
```lua
-- Set the integer value of a menu item named "SliderValue" to 50
menu.set_int("SliderValue", 50)
```

---

#### Function: set_float

```lua
function set_float(name: string, value: float)
```

Sets the float value of a menu item.

#### Parameters:
- `name` (string): The name of the menu item.
- `value` (float): The new float value for the menu item.

#### Usage Example:
```lua
-- Set the float value of a menu item named "Sensitivity" to 2.5
menu.set_float("Sensitivity", 2.5)
```

---

#### Function: set_color

```lua
function set_color(name: string, value: Color)
```

Sets the color value of a menu item.

#### Parameters:
- `name` (string): The name of the menu item.
- `value` (Color): The new color value for the menu item.

#### Usage Example:
```lua
-- Set the color value of a menu item named "MenuBackgroundColor" to red
local backgroundColor = Color(1.0, 0.0, 0.0, 1.0) -- Red color
menu.set_color("MenuBackgroundColor", backgroundColor)
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


### Namespace: utils

The `utils` namespace provides utility functions for console management, logging, and timestamp retrieval.

#### Function: AttachConsole

```lua
function AttachConsole()
```

Attaches a new console to the current process, allowing for console output.

#### Usage Example:
```lua
-- Attach a console to the current process
utils.AttachConsole()
```

---

#### Function: DetachConsole

```lua
function DetachConsole()
```

Detaches the console from the current process.

#### Usage Example:
```lua
-- Detach the console from the current process
utils.DetachConsole()
```

---

#### Function: ConsolePrint

```lua
function ConsolePrint(logToFile: boolean, fmt: string, ...)
```

Prints a formatted message to the attached console.

#### Parameters:
- `logToFile` (boolean): Whether to log the message to a file.
- `fmt` (string): The format string for the message.
- `...` (any): Additional parameters for the format string.

#### Usage Example:
```lua
-- Print a message to the console and log it to a file
utils.ConsolePrint(true, "This is a log message")
```

---

#### Function: Log

```lua
function Log(fmt: string, ...)
```

Logs a formatted message to a file.

#### Parameters:
- `fmt` (string): The format string for the message.
- `...` (any): Additional parameters for the format string.

#### Usage Example:
```lua
-- Log a message to a file
utils.Log("This is a log message")
```

---

#### Function: GetTimestamp

```lua
function GetTimestamp() -> string
```

Retrieves the current timestamp in a formatted string.

#### Returns:
- `string`: The current timestamp in the format `"[Day Month DayOfMonth Hour:Minute:Second Year]"`.

#### Usage Example:
```lua
-- Get the current timestamp
local timestamp = utils.GetTimestamp()
```

---

#### Function: GetTimeString

```lua
function GetTimeString() -> string
```

Retrieves the current time in a formatted string.

#### Returns:
- `string`: The current time in the format `"HH:MM:SS"`.

#### Usage Example:
```lua
-- Get the current time as a string
local timeString = utils.GetTimeString()
```

#### Function: GetTimeUnix

```lua
function GetTimeUnix() -> number
```

Gets the current Unix timestamp in seconds.

#### Returns:
- `number`: The current Unix timestamp in seconds.

#### Usage Example:
```lua
-- Get the current Unix timestamp
local timestamp = utils.GetTimeUnix()
utils.ConsolePrint(false, "Current Unix timestamp:", timestamp)
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
- `on_button_(button name)` only run the function when one button (added by a lua script) is pressed, put the button name without ()! and make sure that you added the button before!!!
- `on_scriptselected` execute the function when a selecte is selected in the search (game) tab
- `on_gameselected` execute the function when a game is selected in the search tab
- `on_gamesearch` execute the function when you search for a game
#### Usage Examples:
```lua
	menu.add_button("Update Script")--set the button name
    local function updatebutton()
      --do your function
      print("Script Exaple", "Worked!!!")
    end
	client.add_callback("on_button_Update Script", updatebutton)--use the button name after the _
```
```lua
client.add_callback("on_present", function()
    utils.ConsolePrint(true, "Present event triggered")
end)
```
```lua
local function example()
  local gamename = game.getgamename()
  utils.ConsolePrint(true, "A script was selected! game name: %s", gamename)
end
client.add_callback("on_scriptselected", example)
```
```lua
local function example2()
  local gamename = game.getgamename()
  utils.ConsolePrint(true, "A game was selected! game name: %s", gamename)
end
client.add_callback("on_gameselected", example)
```
```lua
local function example3()
  utils.ConsolePrint(true, "A search was done!)
end
client.add_callback("on_gamesearch", example)
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

#### Function: GetDefaultSavePath

```lua
function GetDefaultSavePath() -> string
```

Retrieves the default save path for the client.

#### Returns:
- `string`: The default save path for the client.

#### Usage Example:
```lua
-- Get the default save path for the client
local defaultSavePath = client.GetDefaultSavePath()
```

---

#### Function: GetScriptsPath

```lua
function GetScriptsPath() -> string
```

Retrieves the path to the scripts folder for the client.

#### Returns:
- `string`: The path to the scripts folder for the client.

#### Usage Example:
```lua
-- Get the path to the scripts folder for the client
local scriptsPath = client.GetScriptsPath()
```

---

#### Function: CleanSearchTextureCache

```lua
function CleanSearchTextureCache()
```

Clears the search texture cache in the client.

#### Usage Example:
```lua
-- Clean the search texture cache
client.CleanSearchTextureCache()
```

---

#### Function: CleanLibraryTextureCache

```lua
function CleanLibraryTextureCache()
```

Clears the library texture cache in the client.

#### Usage Example:
```lua
-- Clean the library texture cache
client.CleanLibraryTextureCache()
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

### Namespace: Download

The `Download` namespace provides functions to handle downloading files and managing the download path.

#### Function: DownloadFile

```lua
function DownloadFile(downloadurl: string)
```

Queues a file download from the specified URL using the internal download manager.

#### Parameters:
- `downloadurl` (string): The URL of the file to download.

#### Usage Example:
```lua
-- Queue a file download from the given URL
Download.DownloadFile("https://example.com/files/myfile.zip")
```

---

#### Function: DirectDownload

```lua
function DirectDownload(downloadurl: string, downloadpath: string)
```

Downloads a file directly from the given URL to the specified local path.

#### Parameters:
- `downloadurl` (string): The URL of the file to download.
- `downloadpath` (string): The local path where the downloaded file will be saved.

#### Usage Example:
```lua
-- Download a file directly to a specific path
Download.DirectDownload("https://example.com/files/image.jpg", "C:/Downloads/image.jpg")
```

---

#### Function: DownloadImage

```lua
function DownloadImage(imageurl: string) -> string
```

Downloads an image from the given URL and saves it in the Images folder.

#### Parameters:
- `imageurl` (string): The URL of the image to download.

#### Returns:
- `string`: The local path to the downloaded image.

#### Usage Example:
```lua
-- Download an image and get its local path
local imagePath = Download.DownloadImage("https://example.com/images/image.jpg")
```

---

#### Function: ChangeDownloadPath

```lua
function ChangeDownloadPath(path: string)
```

Changes the default download path to the specified path.

#### Parameters:
- `path` (string): The new download path.

#### Usage Example:
```lua
-- Change the default download path
Download.ChangeDownloadPath("C:/MyDownloads")
```

---

#### Function: GetDownloadPath

```lua
function GetDownloadPath() -> string
```

Retrieves the current default download path.

#### Returns:
- `string`: The current download path.

#### Usage Example:
```lua
-- Get the current default download path
local downloadPath = Download.GetDownloadPath()
```

---

#### Function: GetFileNameFromUrl

```lua
function GetFileNameFromUrl(url: string)
```

Extracts the filename from the given URL.

#### Parameters:
- `url` (string): The URL from which to extract the filename.

#### Usage Example:
```lua
-- Extract the filename from a URL
local fileName = Download.GetFileNameFromUrl("https://example.com/files/myfile.zip")
```

---

### Namespace: GameLibrary

The `GameLibrary` namespace provides functions to manage a game library, which allows adding and removing games along with retrieving game information.

#### Function: addGame

```lua
function addGame(exePath: string, imagePath: string, gamename: string, commandline: string)
```

Adds a new game to the game library.

#### Parameters:
- `exePath` (string): The path to the game's executable file.
- `imagePath` (string): The path to the game's image or icon.
- `gamename` (string): The name of the game.
- `commandline` (string): The command-line options to launch the game.

#### Usage Example:
```lua
-- Add a new game to the library
GameLibrary.addGame("C:/Games/MyGame.exe", "C:/Games/MyGameIcon.png", "MyGame", "-fullscreen -novid")
```

---

#### Function: removeGame

```lua
function removeGame(id: number)
```

Removes a game from the game library by its unique identifier (id).

#### Parameters:
- `id` (number): The unique identifier of the game to remove.

#### Usage Example:
```lua
-- Remove a game from the library by its id
GameLibrary.removeGame(2)
```

---

#### Function: GetGameIdFromName

```lua
function GetGameIdFromName(name: string) -> number
```

Retrieves the unique identifier (id) of a game by its name.

#### Parameters:
- `name` (string): The name of the game.

#### Returns:
- `number`: The unique identifier (id) of the game.

#### Usage Example:
```lua
-- Get the id of a game by its name
local gameId = GameLibrary.GetGameIdFromName("MyGame")
```

---

#### Function: GetGameNameFromId

```lua
function GetGameNameFromId(id: number) -> string
```

Retrieves the name of a game by its unique identifier (id).

#### Parameters:
- `id` (number): The unique identifier of the game.

#### Returns:
- `string`: The name of the game.

#### Usage Example:
```lua
-- Get the name of a game by its id
local gameName = GameLibrary.GetGameNameFromId(3)
```

---

#### Function: GetGamePath

```lua
function GetGamePath(id: number) -> string
```

Retrieves the executable path of a game by its unique identifier (id).

#### Parameters:
- `id` (number): The unique identifier of the game.

#### Returns:
- `string`: The path to the game's executable file.

#### Usage Example:
```lua
-- Get the executable path of a game by its id
local gamePath = GameLibrary.GetGamePath(1)
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
