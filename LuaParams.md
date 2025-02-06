# Lua API Documentation

## You can find script examples here: https://github.com/Y0URD34TH/Project-GLD/tree/main/Scripts
## If you're unfamiliar with or new to LUA, it's highly recommended to first check out the general [LUA documentation](https://www.lua.org/docs.html).

## Table Of Content

* [Client](#namespace-client)
* [Jsonwrapper](#namespace-jsonwrapper)
* [Htmlwrapper](#namespace-htmlwrapper)
* [Game](#namespace-game)
* [Game Library](#namespace-gamelibrary)
* [Menu](#namespace-menu)
* [HTTP](#namespace-http)
* [Utils](#namespace-utils)
* [Communication](#namespace-communication)
* [File](#namespace-file)
* [settings](#namespace-settings)
* [Download](#namespace-Download)
* [Notifications](#namespace-Notifications)
* [SteamApi](#namespace-SteamApi)
* [zip](#namespace-zip)
* [gldconsole](#namespace-gldconsole)
* [dll](#namespace-dll)

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

### Namespace: HtmlWrapper

The `HtmlWrapper` class provides static methods for parsing HTML strings and extracting specific attributes.

#### Method: findAttribute

```cpp
static sol::table findAttribute(
    const std::string& htmlString,
    const std::string& elementTagName,
    const std::string& elementTermKey,
    const std::string& elementTermValue,
    const std::string& desiredResultKey
);
```

**Description:**
Parses an HTML string and finds a specified attribute within a specified HTML element. It returns the result as a Lua table.

**Parameters:**
- `const std::string& htmlString`: The HTML string to be parsed.
- `const std::string& elementTagName`: The tag name of the HTML element to search for.
- `const std::string& elementTermKey`: The key of the attribute used to identify the HTML element.
- `const std::string& elementTermValue`: The value of the attribute used to identify the HTML element.
- `const std::string& desiredResultKey`: The key of the attribute whose value is to be retrieved.

**Returns:**
- `sol::table`: A Lua table containing the result attribute.

**Usage Example:**
```lua
-- Assuming a Lua state 's'
local htmlString = "<html><body><div id='content'>Hello, Lua!</div></body></html>"
local resulttable = HtmlWrapper.findAttribute(htmlString, "div", "id", "content", "innerText")
for _, result in ipairs(resulttable) do
   print("Result:, " .. result)
end
```

#### Important Notes:
- The method filters out comments and metadata from the HTML string before parsing.
- The parsed HTML is processed using the Gumbo HTML parser.
- The result is returned as a Lua table.

This method allows Lua scripts to parse HTML strings and extract specific attributes from specified HTML elements. The example demonstrates how to call this method from Lua and access the result.

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

### Namespace: menu

The `menu` namespace provides functions to manage and manipulate menu items and their values.

#### Function: set_visible

```lua
function set_visible(visible: boolean)
```

Sets the visibility of the active window.

- `visible` (boolean): Set to `true` to show the window, `false` to minimize it.

#### Usage Example:
```lua
-- Show the window
menu.set_visible(true)

-- Minimize the window
menu.set_visible(false)
```

---

## **Function: set_dpi**

### **Synopsis**
Sets the DPI scaling factor for the UI.

### **Declaration**
```lua
menu.set_dpi(dpi: number)
```

### **Parameters**
- **`dpi` (number)**: The new DPI scaling factor.

### **Returns**
- **`nil`**: This function does not return a value.

### **Description**
- This function updates the DPI scaling factor for the user interface.
- It sets `g_Options.dpi_scale` to the specified `dpi` value.
- It also enables `g_Options.rescaleall`, which triggers a rescaling of the entire UI.

### **Example Usage**
```lua
menu.set_dpi(1.5) -- Set DPI scaling to 150%
```

---

#### Function: next_line

```lua
function next_line()
```

Adds a new line to the menu.

#### Usage Example:
```lua
-- Add a new line to the menu
menu.next_line()
```

#### Function: add_check_box

```lua
function add_check_box(name: string)
```

Adds a check box item to the menu.

- `name` (string): The name of the check box item.

#### Usage Example:
```lua
-- Add a check box item to the menu
menu.add_check_box("Enable Feature")
```

#### Function: add_input_text

```lua
function add_input_text(name: string)
```

Adds an input text item to the menu.

- `name` (string): The name of the input text item.

#### Usage Example:
```lua
-- Add an input text item to the menu
menu.add_input_text("Player Name")
```

#### Function: add_button

```lua
function add_button(name: string)
```

Adds a button item to the menu.

- `name` (string): The name of the button item.

#### Usage Example:
```lua
-- Add a button item to the menu
menu.add_button("Apply Settings")
```

#### Function: add_text

```lua
function add_text(text: string)
```

Adds a text item to the menu.

- `text` (string): The text to display in the menu.

#### Usage Example:
```lua
-- Add a text item to the menu
menu.add_text("Welcome to the Menu!")
```

#### Function: add_combo_box

```lua
function add_combo_box(name: string, labels: table)
```

Adds a combo box item to the menu.

- `name` (string): The name of the combo box item.
- `labels` (table): A table containing labels for the combo box options.

#### Usage Example:
```lua
-- Add a combo box item to the menu
menu.add_combo_box("Select Weapon", {"Knife", "Pistol", "Rifle"})
```

#### Function: add_slider_int

```lua
function add_slider_int(name: string, min: int, max: int)
```

Adds a slider (integer) item to the menu.

- `name` (string): The name of the slider item.
- `min` (int): The minimum value of the slider.
- `max` (int): The maximum value of the slider.

#### Usage Example:
```lua
-- Add a slider (integer) item to the menu
menu.add_slider_int("Volume", 0, 100)
```

#### Function: add_slider_float

```lua
function add_slider_float(name: string, min: float, max: float)
```

Adds a slider (float) item to the menu.

- `name` (string): The name of the slider item.
- `min` (float): The minimum value of the slider.
- `max` (float): The maximum value of the slider.

#### Usage Example:
```lua
-- Add a slider (float) item to the menu
menu.add_slider_float("Opacity", 0.0, 1.0)
```

#### Function: add_input_int

```lua
function add_input_int(name: string)
```

Adds an input (integer) item to the menu.

- `name` (string): The name of the input item.

#### Usage Example:
```lua
-- Add an input (integer) item to the menu
menu.add_input_int("Player Health")
```

#### Function: add_input_float

```lua
function add_input_float(name: string)
```

Adds an input (float) item to the menu.

- `name` (string): The name of the input item.

#### Usage Example:
```lua
-- Add an input (float) item to the menu
menu.add_input_float("Player Speed")
```

#### Function: add_color_picker

```lua
function add_color_picker(name: string)
```

Adds a color picker item to the menu.

- `name` (string): The name of the color picker item.

#### Usage Example:
```lua
-- Add a color picker item to the menu
menu.add_color_picker("Highlight Color")
```

#### Function: get_bool

```lua
function get_bool(name: string) -> boolean
```

Returns the value of a boolean menu item.

- `name` (string): The name of the boolean menu item.

#### Usage Example:
```lua
-- Get the value of a boolean menu item
local isEnabled = menu.get_bool("Enable Feature")
```

#### Function: get_text

```lua
function get_text(name: string) -> string
```

Returns the value of a text menu item.

- `name` (string): The name of the text menu item.

#### Usage Example:
```lua
-- Get the value of a text menu item
local playerName = menu.get_text("Player Name")
```

#### Function: get_int

```lua
function get_int(name: string) -> int
```

Returns the value of an integer menu item.

- `name` (string): The name of the integer menu item.

#### Usage Example:
```lua
-- Get the value of an integer menu item
local volume = menu.get_int("Volume")
```

#### Function: get_float

```lua
function get_float(name: string) -> float
```

Returns the value of a float menu item

.

- `name` (string): The name of the float menu item.

#### Usage Example:
```lua
-- Get the value of a float menu item
local opacity = menu.get_float("Opacity")
```

#### Function: get_color

```lua
function get_color(name: string) -> Color
```

Returns the value of a color menu item.

- `name` (string): The name of the color menu item.

#### Usage Example:
```lua
-- Get the value of a color menu item
local highlightColor = menu.get_color("Highlight Color")
```

#### Function: set_bool

```lua
function set_bool(name: string, value: boolean)
```

Sets the value of a boolean menu item.

- `name` (string): The name of the boolean menu item.
- `value` (boolean): The new value for the boolean item.

#### Usage Example:
```lua
-- Set the value of a boolean menu item
menu.set_bool("Enable Feature", true)
```

#### Function: set_text

```lua
function set_text(name: string, value: string)
```

Sets the value of a text menu item.

- `name` (string): The name of the text menu item.
- `value` (string): The new value for the text item.

#### Usage Example:
```lua
-- Set the value of a text menu item
menu.set_text("Player Name", "John Doe")
```

#### Function: set_int

```lua
function set_int(name: string, value: int)
```

Sets the value of an integer menu item.

- `name` (string): The name of the integer menu item.
- `value` (int): The new value for the integer item.

#### Usage Example:
```lua
-- Set the value of an integer menu item
menu.set_int("Volume", 50)
```

#### Function: set_float

```lua
function set_float(name: string, value: float)
```

Sets the value of a float menu item.

- `name` (string): The name of the float menu item.
- `value` (float): The new value for the float item.

#### Usage Example:
```lua
-- Set the value of a float menu item
menu.set_float("Opacity", 0.8)
```

#### Function: set_color

```lua
function set_color(name: string, value: Color)
```

Sets the value of a color menu item.

- `name` (string): The name of the color menu item.
- `value` (Color): The new value for the color item.

#### Usage Example:
```lua
-- Set the value of a color menu item
menu.set_color("Highlight Color", Color(1, 0.8, 0))
```

Note: The `menu` namespace provides functions to manage and manipulate menu items, their types, and their values. These functions allow you to add various types of menu items, retrieve their values, and update them as needed. The namespace aims to simplify the process of creating and interacting with menus in Lua scripts, providing an efficient way to customize user interface elements.

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

### Function: mediafireresolver
```lua
function http.mediafireresolver(link: string)
```
Resolves a link using the mediafire.com service.

#### Parameters:
- `link` (string): The link to resolve.

#### Returns:
- The resolved location header.

#### Usage Example:
```lua
local resolvedLink = http.mediafireresolver("https://mediafire.com/link")
utils.ConsolePrint(true, "Resolved Link: %s", resolvedLink)
```

### Function: resolvepixeldrain

```cpp
std::string resolvepixeldrain(
    const std::string& link
);
```

**Description:**
Resolves a Pixeldrain link to its direct download link.

**Parameters:**
- `const std::string& link`: The Pixeldrain link to resolve.

**Returns:**
- `std::string`: The resolved direct download link for Pixeldrain, or the original link if it's not a Pixeldrain link.

**Usage Example:**
```lua
local originalLink = "https://pixeldrain.com/u/somefile123"
local resolvedLink = http.resolvepixeldrain(originalLink)
print("Resolved Link: " .. resolvedLink)
```

#### Important Notes:
- This method checks if the provided link is from Pixeldrain and constructs a direct download link if true.
- If the link is not from Pixeldrain, it returns the original link.
- The resolved link can be used for direct downloading from Pixeldrain.


### Function: byetresolver

```cpp
std::string byetresolver(
    const std::string& url
);
```

**Description:**
Resolves a link that is hosted in byet returning the cookie that can be used in requests.

**Parameters:**
- `const std::string& url`: The url that you want to get the cookies.

**Returns:**
- `std::string`: The cookies to specified url.

**Usage Example:**
```lua
-- Assuming a Lua state 's'
local url = "https://mybyetlink.com"
local cookie = http.byetresolver(url)
print("cookie: " .. cookie)
--then can be used in http requests
```



#### Function: CloudFlareSolver

```lua
function CloudFlareSolver(url: string)
```

**Description:**
Initiates solving Cloudflare protection for a given URL.
when done returns the callback on "on_cfdone" callback

**Parameters:**
- `url` (string): The URL protected by Cloudflare.

**Usage Example:**
```lua
http.CloudFlareSolver("https://1337x.to/")
utils.AtachConsole()
local function cf(cookie, url)
utils.ConsolePrint(false, url .. " " ..cookie)
--if u gonna do some request with the cookie then important note is taht u must sue that following user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15
end
client.add_callback("on_cfdone", cf)
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

### **Function: delete**

#### **Synopsis**
Deletes a specified file or directory.

#### **Declaration**
```lua
file.delete(path)
```

### **Parameters**
- **path** (`string`): The file or directory path to be deleted.

### **Returns**
- **None**

### **Description**
- This function deletes a file or a directory at the specified path.
- Before deleting, it checks if file operations are allowed.
- If the path points to a directory, it deletes the directory and all its contents.
- If the path points to a file, it deletes the file.
- The function ensures that the user cannot accidentally delete the `downloadpath`.

### **Example Usage**
```lua
file.delete("C:\\Users\\User\\Documents\\temp.txt") -- Deletes a file
file.delete("C:\\Users\\User\\Documents\\temp_folder") -- Deletes a folder and its contents
```


### **Function: exists**

#### **Synopsis**
Checks if a file or directory exists at the given path.

#### **Declaration**
```lua
file.exists(path) -> boolean
```

#### **Parameters**
- **path** (`string`): The file or directory path to check.

#### **Returns**
- **`true`** if the file or directory exists.
- **`false`** if it does not exist or if file operations are not allowed (`g_Options.allow_file` is disabled).

#### **Description**
- This function verifies the existence of a file or directory at the specified path.
- If file operations are disabled (`g_Options.allow_file == false`), it logs an error, unloads the script, and returns `false`.
- If the path exists, it returns `true`; otherwise, it returns `false`.

#### **Example Usage**
```lua
if file.exists("C:\\Users\\User\\Documents\\test.txt") then
    print("File exists!")
else
    print("File does not exist.")
end
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
- `on_gamelaunch` execute the function when a game is launched and retrieve game info
- `on_extractioncompleted` execute the function when the extraction progress is completed and retrieve the path to where it got extracted
- `on_downloadclick` execute the function when you click on some download option in the script (on the game page), retrieve game json and download url
- `on_downloadcompleted` execute the function when the download is completed and retrieve the download path and download url
- `on_cfdone` execute the function when the cloudflare solver resolved the link and returns the cloudflare cookie and url of the request (you need to sue the following user agent alongside with the cookie to work: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15)
  
#### Usage Examples:
```lua
	menu.add_button("Update Script")--set the button name
    local function updatebutton()
      --do your function
      print("Worked!!!")
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
client.add_callback("on_gameselected", example2)
```
```lua
local function example3()
  utils.ConsolePrint(true, "A search was done!)
end
client.add_callback("on_gamesearch", example3)
```
```lua
local function example4(info)
  print(info.id .." ".. info.name)
  --more values: 
  --info.initoptions | retrieve command line string
  --info.imagePath | retrieve game image path
  --info.exePath | retrieve game path
end
client.add_callback("on_gamelaunch", example4)
```
```lua
local function example5(path)
  --path is a string
  print("Extraction Path".." ".. path)
end
client.add_callback("on_extractioncompleted", example5)
```
```lua
local function example6(dumpedjson, downloadurl)
  --downloadurl is a string
  --dumpedjson is a dumped json string
  utils.ConsolePrint(true, downloadurl)
  local gamejson = JsonWrapper.parse(dumpedjson)["results"] --example of game json disponible in https://github.com/Y0URD34TH/Project-GLD/blob/main/External/Recommends.txt
  print("Game name" .." ".. gamejson.name)
end
client.add_callback("on_downloadclick", example6)
```
```lua
local function example7(path, url)
  --path is a string
  --url is a string
  print("Download path" .." ".. path)
  print("Download url" .." ".. url)
end
client.add_callback("on_downloadcompleted", example7)
```
```lua
http.CloudFlareSolver("https://1337x.to/")
utils.AtachConsole()
local function cf(cookie, url)
utils.ConsolePrint(false, url .. " " ..cookie)
--if u gonna do some request with the cookie then important note is taht u must sue that following user agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15
end
client.add_callback("on_cfdone", cf)
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

### Function: create_script
```lua
function client.create_script(name: string, data: string)
```
Creates an script in scripts folder.

#### Parameters:
- `name` (string): The name of the script to be created (without .lua in it).
- `data` (string): The data of script (content) to be writen.
- 
#### Usage Example:
```lua
local scriptdata = "local fucntion..."
client.create_script("myscript", scriptdata)
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

#### Function: GetVersionFloat

```cpp
float GetVersionFloat(sol::this_state s);
```

**Description:**
Retrieves the version number as a floating-point value.

**Parameters:**
- `sol::this_state s`: The Lua state.

**Returns:**
- `float`: The version number as a floating-point value.

**Usage Example:**
```lua
-- Assuming a Lua state 's'
local version = client.GetVersionFloat(s)
print("Version (Float): " .. version)
```

#### Function: GetVersionDouble

```cpp
double GetVersionDouble(sol::this_state s);
```

**Description:**
Retrieves the version number as a double-precision floating-point value.

**Parameters:**
- `sol::this_state s`: The Lua state.

**Returns:**
- `double`: The version number as a double-precision floating-point value.

**Usage Example:**
```lua
-- Assuming a Lua state 's'
local version = client.GetVersionDouble(s)
print("Version (Double): " .. version)
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

## **Function: GetScreenHeight**

### **Synopsis**
Retrieves the height of the screen in pixels.

### **Declaration**
```lua
client.GetScreenHeight() -> integer
```

### **Returns**
- **`integer`**: The height of the screen in pixels.

### **Description**
- This function returns the vertical resolution of the primary display.
- It uses the `GetSystemMetrics(SM_CYSCREEN)` function from the Windows API to determine the screen height.

### **Example Usage**
```lua
local height = client.GetScreenHeight()
print("Screen Height: " .. height)
```

---

## **Function: GetScreenWidth**

### **Synopsis**
Retrieves the width of the screen in pixels.

### **Declaration**
```lua
client.GetScreenWidth() -> integer
```

### **Returns**
- **`integer`**: The width of the screen in pixels.

### **Description**
- This function returns the horizontal resolution of the primary display.
- It uses the `GetSystemMetrics(SM_CXSCREEN)` function from the Windows API to determine the screen width.

### **Example Usage**
```lua
local width = client.GetScreenWidth()
print("Screen Width: " .. width)
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

#### Function: quit

```lua
function quit()
```

close the app/quit from app.

#### Usage Example:
```lua
client.quit()
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

### Namespace: settings

The `settings` namespace provides functions to manage and manipulate configuration settings.

#### Function: save

```lua
function save()
```

Saves the current configuration settings to a file.

#### Usage Example:
```lua
-- Save the current configuration settings
settings.save()
```

#### Function: load

```lua
function load()
```

Loads configuration settings from a file.

#### Usage Example:
```lua
-- Load configuration settings from a file
settings.load()
```

Note: The `settings` namespace provides functions to save and load configuration settings. These settings are typically used to customize and persist various aspects of the script or application. The functions allow you to manage configuration files, ensuring that settings can be easily saved and retrieved across different sessions.

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
        tooltip = "test tooltip",
        ScriptName = "Script 1"
    },
    {
        name = "Result 2",
        links = {
            { name = "Link 3", link = "https://example.com/link3", addtodownloadlist = true },
            { name = "Link 4", link = "https://example.com/link4", addtodownloadlist = true }
        },
        tooltip = "test tooltip",
        ScriptName = "Script 2"
    }
}

-- Call the receiveSearchResults function
communication.receiveSearchResults(resultsTable)
```

### Function: RefreshScriptResults

```lua
function RefreshScriptResults()
```

**Description:**
Refreshes the script results by updating the selected script, triggering a new request, and resetting the loading status.

**Usage Example:**
```lua
communication.RefreshScriptResults()
```

This Lua documentation provides usage instructions for the `RefreshScriptResults` function, allowing users to refresh script results in their Lua scripts.
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


## **Function: GetGameList**

### **Synopsis**
Retrieves a list of games stored in the game library.

### **Declaration**
```lua
gameList = GameLibrary.GetGameList()
```

### **Parameters**
- **None**

### **Returns**
- **`table[]`**: A list of tables, each representing a game in the library.  
  Each game table contains the following fields:
  - **`id` (number)**: The unique identifier of the game.
  - **`name` (string)**: The name of the game.
  - **`exePath` (string)**: The path to the game's executable.
  - **`imagePath` (string)**: The path to the game's image (same as `exePath`).
  - **`initoptions` (string)**: Initialization options for the game (same as `exePath`).

### **Description**
- This function retrieves all stored games from the `GameLibrary` and returns them as a list of Lua tables.
- Each game is represented as a table with details such as its ID, name, executable path, and initialization options.
- The function allows Lua scripts to access and manipulate the stored game data.

### **Example Usage**
```lua
local games = GameLibrary.GetGameList()
for _, mgame in ipairs(games) do
    print("Game ID:", mgame.id)
    print("Name:", mgame.name)
    print("Executable:", mgame.exePath)
end
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

### Namespace: SteamApi

The `SteamApi` namespace provides functions for interacting with the Steam API.

#### Function: GetSystemRequirements

```lua
function GetSystemRequirements(appid: string) -> string
```

**Description:**
Retrieves the system requirements string for a specified Steam application.

**Parameters:**
- `appid` (string): The Steam Application ID of the game.

**Returns:**
- (string): The system requirements string of the specified game.

**Usage Example:**
```lua
local appid = "570" -- Dota 2
local systemRequirements = SteamApi.GetSystemRequirements(appid)
print("System Requirements: " .. systemRequirements)
```

---

#### Function: GetGameData

```lua
function GetGameData(appid: string) -> string
```

**Description:**
Retrieves game data as a JSON string for a specified Steam application.

**Parameters:**
- `appid` (string): The Steam Application ID of the game.

**Returns:**
- (string): The game data as a JSON string.

**Usage Example:**
```lua
local appid = "570" -- Dota 2
local gameData = SteamApi.GetGameData(appid)
print("Game Data: " .. gameData)
```

---

#### Function: GetAppID

```lua
function GetAppID(name: string) -> string
```

**Description:**
Retrieves the Steam Application ID of a game by its name.

**Parameters:**
- `name` (string): The name of the game.

**Returns:**
- (string): The Steam Application ID of the game.

**Usage Example:**
```lua
local gameName = "Dota 2"
local appid = SteamApi.GetAppID(gameName)
print("AppID for " .. gameName .. ": " .. appid)
```

### Namespace: zip

The `zip` namespace provides functions for extracting files from compressed archives.

#### Function: extract

```lua
function extract(source: string, destination: string, deleteaftercomplete: boolean, password: string) --passowrd is optional.
```

**Description:**
Asynchronously extracts files from a compressed archive.

**Parameters:**
- `source` (string): The path to the compressed archive.
- `destination` (string): The directory where the files will be extracted.
- `deleteaftercomplete` (boolean): Whether to delete the compressed archive after extraction is complete.
- `password` (string): This is optional, use if the file u want to extract is protected by an password.

**Usage Example:**
```lua
local source = "archive.zip" --works with .rar, .7z etc
local destination = "extracted_files"
local deleteAfterComplete = true
zip.extract(source, destination, deleteAfterComplete)
```

```lua
local source = "archive.zip" --works with .rar, .7z etc
local destination = "extracted_files"
local deleteAfterComplete = true
local pass = "1234"
zip.extract(source, destination, deleteAfterComplete, pass)
```

### Namespace: dll

The `dll` namespace provides functions for injecting dlls.


## **Function: inject**

### **Synopsis**
Injects a DLL into a specified process.

### **Declaration**
```lua
success = dll.inject(process_name, dll_path, delay)
```

### **Parameters**
- **process_name** (`string`): The name of the process to inject the DLL into (e.g., `"GoW.exe"`).
- **dll_path** (`string`): The full file path of the DLL to inject.
- **delay** (`integer`): The delay in milliseconds before the injection occurs (e.g., `300` for 300 milliseconds).

### **Returns**
- **boolean**: `true` if the injection was successful, `false` otherwise.

### **Description**
- This function injects a DLL into a running process.
- It first verifies that file access is allowed (`Lua Read/Write`).
- If a delay is specified, the function waits before attempting injection.
- The process ID is determined using `DLL::GetPID()`, and the DLL file existence is checked.
- If the injection succeeds, a success message is logged; otherwise, an error message is displayed.

### **Example Usage**
```lua
local success = dll.inject("GoW.exe", "C:\\path\\to\\inject.dll", 300)

if success then
    print("Injection successful!")
else
    print("Injection failed!")
end
```


### Namespace: gldconsole

#### Function: print
```lua
function gldconsole.print(text: string)
```
Logs/print a message in gld console.

#### Parameters:
- `text` (string): The content of the log message.

#### Usage Example:
```lua
gldconsole.print("Script loaded successfully")
```

#### Function: show

```lua
function show()
```

open/show gld console window.

#### Usage Example:
```lua
-- open/show gld console window
gldconsole.show()
```

#### Function: close

```lua
function close()
```

close gld console window.

#### Usage Example:
```lua
-- close gld console window
gldconsole.close()
```
