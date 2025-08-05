# Project-GLD Lua API Documentation

## Overview

Project-GLD provides a comprehensive Lua scripting API for game launcher functionality. Scripts can interact with the system through various namespaces and callbacks.

## Important Notes

- For using AI to make scripts please send (copy and paste) to your AI our compact documentation of lua ready for AI: https://github.com/Y0URD34TH/Project-GLD/blob/main/Ai-Lua.txt 

## Global Functions

### Basic Functions
```lua
print(message)          -- Print message to output
sleep(milliseconds)     -- Sleep for specified milliseconds
exec(path, delay, commandline, isinnosetup, innoproccess) -- Execute file
```

## Core Objects

### JsonWrapper
```lua
local result = JsonWrapper.parse(jsonString)  -- Parse JSON string to Lua object
```

### HtmlWrapper
```lua
local result = HtmlWrapper.findAttribute(htmlString, elementTagName, elementTermKey, elementTermValue, desiredResultKey)
-- Find HTML element attribute by tag and criteria
```

### GameInfo Object
```lua
-- Properties available in GameInfo objects:
game.id          -- Game ID
game.name        -- Game name
game.initoptions -- Initialization options
game.imagePath   -- Path to game image
game.exePath     -- Path to game executable
```

## API Namespaces

### Client (`client`)

#### Script Management
```lua
client.load_script(name)           -- Load a script by name
client.unload_script(name)         -- Unload a script by name
client.create_script(name, data)   -- Create new script with data
```

#### Callbacks
```lua
client.add_callback(eventname, function) -- Add event callback
-- Available events: see Callbacks section below
```

#### System Information
```lua
client.log(title, text)            -- Log message
client.quit()                      -- Quit application
client.GetVersion()                -- Get version string
client.GetVersionFloat()           -- Get version as float
client.GetVersionDouble()          -- Get version as double
client.GetScriptsPath()            -- Get scripts directory path
client.GetDefaultSavePath()        -- Get default save path
client.GetScreenHeight()           -- Get screen height
client.GetScreenWidth()            -- Get screen width
```

#### Cache Management
```lua
client.CleanSearchTextureCache()   -- Clean search texture cache
client.CleanLibraryTextureCache()  -- Clean library texture cache
```

### Notifications (`Notifications`)

```lua
Notifications.push(title, text)         -- Push notification
Notifications.push_success(title, text) -- Push success notification
Notifications.push_error(title, text)   -- Push error notification
Notifications.push_warning(title, text) -- Push warning notification
```

### Menu (`menu`)

#### Menu Configuration
```lua
menu.set_dpi(dpi)                  -- Set menu DPI
menu.set_visible(visible)          -- Set menu visibility
menu.next_line()                   -- Add line break
```

#### Menu Controls
```lua
menu.add_check_box(name)           -- Add checkbox
menu.add_button(name)              -- Add button
menu.add_text(text)                -- Add text label
menu.add_input_text(name)          -- Add text input
menu.add_input_int(name)           -- Add integer input
menu.add_input_float(name)         -- Add float input
menu.add_combo_box(name, labels)   -- Add combo box with labels table
menu.add_slider_int(name, min, max)    -- Add integer slider
menu.add_slider_float(name, min, max)  -- Add float slider
menu.add_color_picker(name)        -- Add color picker
```

#### Menu Value Access
```lua
-- Getters
local value = menu.get_bool(name)     -- Get checkbox value
local text = menu.get_text(name)      -- Get text input value
local number = menu.get_int(name)     -- Get integer value
local number = menu.get_float(name)   -- Get float value
local color = menu.get_color(name)    -- Get color value

-- Setters
menu.set_bool(name, value)         -- Set checkbox value
menu.set_text(name, value)         -- Set text input value
menu.set_int(name, value)          -- Set integer value
menu.set_float(name, value)        -- Set float value
menu.set_color(name, color)        -- Set color value
```

### Utilities (`utils`)

#### Console Functions
```lua
utils.AttachConsole()              -- Attach console window
utils.DetachConsole()              -- Detach console window
utils.ConsolePrint(logToFile, format, ...) -- Print to console
```

#### Time Functions
```lua
local timeStr = utils.GetTimeString()    -- Get formatted time string
local timestamp = utils.GetTimestamp()   -- Get timestamp string
local unixTime = utils.GetTimeUnix()     -- Get Unix timestamp
```

#### Logging
```lua
utils.Log(format, ...)             -- Log to Project-GLD.log file
```

### HTTP (`http`)

#### Basic Requests
```lua
local response = http.get(url, headers_table)           -- HTTP GET request
local response = http.post(url, params, headers_table)  -- HTTP POST request
```

#### URL Resolvers
```lua
local url = http.ArchivedotOrgResolver(archiveUrl)      -- Resolve Archive.org URL
local url = http.mediafireresolver(mediafireUrl)        -- Resolve MediaFire URL
local url = http.resolvepixeldrain(pixeldrainUrl)       -- Resolve Pixeldrain URL
local url = http.byetresolver(byetUrl)                  -- Resolve Byet URL
```

#### CloudFlare Solver
```lua
http.CloudFlareSolver(url)         -- Solve CloudFlare challenge
-- Triggers 'on_cfdone' callback when complete
```

### File System (`file`)

#### File Operations
```lua
file.write(path, data)             -- Write data to file
file.append(path, data)            -- Append data to file
local content = file.read(path)    -- Read file content
file.delete(path)                  -- Delete file
local exists = file.exists(path)   -- Check if file exists
```

#### Process Execution
```lua
file.exec(execpath, delay, commandline, isinnosetup, innoproccess)
-- Execute file with optional parameters
```

#### Directory Listing
```lua
local folders = file.listfolders(path)                    -- List folders
local exes = file.listexecutables(path)                   -- List executables
local exes = file.listexecutablesrecursive(path)          -- List executables recursively
local archives = file.listcompactedfiles(path)            -- List compressed files
```

### Game (`game`)

```lua
local name = game.getgamename()    -- Get current game name from search
```

### DLL Injection (`dll`)

```lua
local success = dll.inject(processname, dllpath, delay)      -- Inject DLL (x64)
local success = dll.injectx86(processname, dllpath, delay)   -- Inject DLL (x86)
local success = dll.innohook(processname)                   -- Hook Inno Setup process
-- innohook triggers 'on_setupcompleted' callback
```

### Browser (`browser`)

```lua
browser.open(url)                  -- Open URL in default browser
```

### Communication (`communication`)

```lua
communication.receiveSearchResults(resultsTable)  -- Receive search results
communication.RefreshScriptResults()              -- Refresh script results
```

### Steam API (`SteamApi`)

```lua
local appid = SteamApi.GetAppID(gamename)                    -- Get Steam App ID
local sysreq = SteamApi.GetSystemRequirements(appid)        -- Get system requirements
local gamedata = SteamApi.GetGameData(appid)                -- Get game data
SteamApi.OpenSteam()                                         -- Open Steam client
local running = SteamApi.IsSteamRunning()                    -- Check if Steam is running
```

### Downloads (`Download`)

```lua
Download.DownloadFile(url)                           -- Download file
Download.DirectDownload(url, path)                   -- Direct download to path
local filename = Download.GetFileNameFromUrl(url)    -- Extract filename from URL
local imagepath = Download.DownloadImage(imageurl)   -- Download image
Download.ChangeDownloadPath(path)                    -- Change download directory
local path = Download.GetDownloadPath()              -- Get current download path
```

### Game Library (`GameLibrary`)

#### Game Management
```lua
GameLibrary.addGame(exePath, imagePath, gamename, commandline)     -- Add game
GameLibrary.changeGameinfo(id, exePath, imagePath, gamename, commandline) -- Modify game
GameLibrary.removeGame(id)                                        -- Remove game
```

#### Game Operations
```lua
local success = GameLibrary.launch(id)             -- Launch game by ID
GameLibrary.close()                                -- Close current game
```

#### Game Information
```lua
local id = GameLibrary.GetGameIdFromName(name)     -- Get ID from name
local name = GameLibrary.GetGameNameFromId(id)     -- Get name from ID
local path = GameLibrary.GetGamePath(id)           -- Get game executable path
local games = GameLibrary.GetGameList()            -- Get all games list
```

### Settings (`settings`)

```lua
settings.save()                    -- Save current settings
settings.load()                    -- Load settings
```

### Archive Extraction (`zip`)

```lua
zip.extract(source, destination, deleteaftercomplete, password)
-- Extract archive, triggers 'on_extractioncompleted' callback
```

### GLD Console (`gldconsole`)

```lua
gldconsole.print(message)          -- Print to GLD console
gldconsole.show()                  -- Show console window
gldconsole.close()                 -- Close console window
```

### Save Management (`save`)

#### Backup Operations
```lua
save.Backup(name)                  -- Backup specific game save
save.BackupAll()                   -- Backup all game saves
save.RefreshBackup()               -- Refresh backup list
local games = save.GetBackupGamesList()  -- Get backup games list
```

#### Restore Operations
```lua
save.Restore(name)                 -- Restore specific game save
save.RestoreAll()                  -- Restore all game saves
save.RefreshRestore()              -- Refresh restore list
local games = save.GetRestoreGamesList()  -- Get restore games list
```

#### Cloud Operations
```lua
save.Download(name)                -- Download save from cloud
save.Upload(name)                  -- Upload save to cloud
save.DownloadAll()                 -- Download all saves from cloud
save.UploadAll()                   -- Upload all saves to cloud
save.RefreshCloud()                -- Refresh cloud saves list
local games = save.GetCloudGamesList()   -- Get cloud games list
```

#### Refresh All
```lua
save.RefreshAll()                  -- Refresh all save lists
```

## Event Callbacks

Use `client.add_callback(eventname, function)` to register for these events:

### Application Lifecycle
```lua
client.add_callback("on_launch", function()
    -- Called when GLD starts
end)

client.add_callback("on_present", function()
    -- Called every frame (main loop)
end)

client.add_callback("on_quit", function()
    -- Called when GLD is exiting
end)
```

### Game Events
```lua
client.add_callback("on_gamesearch", function()
    -- Called when a game search is performed
end)

client.add_callback("on_gameselected", function()
    -- Called when a game is selected in search results
end)

client.add_callback("on_gamelaunch", function(gameInfo)
    -- Called when a game is launched
    -- gameInfo: GameInfo object with game details
  print(gameInfo.id .." ".. gameInfo.name)
  --more values: 
  --gameInfo.initoptions | retrieve command line string
  --gameInfo.imagePath | retrieve game image path
  --gameInfo.exePath | retrieve game path
end)

client.add_callback("on_scriptselected", function()
    -- Called when a script is selected in search tab
end)
```

### Download Events
```lua
client.add_callback("on_downloadclick", function(item, url, scriptname)
    -- Called when download button is clicked
    -- item: JSON string of download item
    -- url: download URL string
    -- scriptname: script name string
end)

client.add_callback("on_downloadcompleted", function(path, url)
    -- Called when download is completed
    -- path: local file path string
    -- url: download URL string
end)
```

### CloudFlare Events
```lua
client.add_callback("on_cfdone", function(cookie, url)
    -- Called when CloudFlare solver completes
    -- cookie: CloudFlare cookie string
    -- url: resolved URL string
    -- Use with User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15
end)
```

### Extraction Events
```lua
client.add_callback("on_extractioncompleted", function(path)
    -- Called when zip extraction completes
    -- path: extraction destination path string
end)
```

### Setup Events
```lua
client.add_callback("on_setupcompleted", function(from, to)
    -- Called when DLL injection setup completes
    -- from: source file path string
    -- to: destination path string
end)
```

### Button Events
```lua
client.add_callback("on_button_" .. buttonname, function()
    -- Called when a menu button is pressed
    -- Replace 'buttonname' with actual button name
    -- Button must be added with menu.add_button() first
end)
```

## Example Usage

### Basic Script Structure
```lua
-- Initialize script
client.add_callback("on_launch", function()
    print("Script loaded!")
    
    -- Setup menu
    menu.add_text("My Script Settings")
    menu.add_check_box("Enable Feature")
    menu.add_button("Test Button")
    
    -- Register button callback
    client.add_callback("on_button_Test Button", function()
        Notifications.push_success("Success", "Button clicked!")
    end)
end)

-- Handle game search
client.add_callback("on_gamesearch", function()
    local gamename = game.getgamename()
    print("Searching for: " .. gamename)
    
    -- Your search logic here
end)
```

### HTTP Request Example
```lua
local headers = {
    ["User-Agent"] = "Project-GLD/2.15",
    ["Accept"] = "application/json"
}

local response = http.get("https://api.example.com/games", headers)
local gameData = JsonWrapper.parse(response)
```

### File Operations Example
```lua
-- Write configuration
local config = {
    enabled = true,
    downloadPath = "C:\\Games"
}

file.write("config.json", JsonWrapper.stringify(config))

-- Read and parse
if file.exists("config.json") then
    local content = file.read("config.json")
    local config = JsonWrapper.parse(content)
end
```
