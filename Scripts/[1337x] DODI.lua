--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local VERSION = "1.1"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/%5B1337x%5D%20DODI.lua", VERSION)

local function endsWith(str, pattern)
    return string.sub(str, -string.len(pattern)) == pattern
end

local function substituteRomanNumerals(gameName)
    local romans = {
        [" I"] = " 1",
        [" II"] = " 2",
        [" III"] = " 3",
        [" IV"] = " 4",
        [" V"] = " 5",
        [" VI"] = " 6",
        [" VII"] = " 7",
        [" VIII"] = " 8",
        [" IX"] = " 9",
        [" X"] = " 10"
    }

    for numeral, substitution in pairs(romans) do
        if endsWith(gameName, numeral) then
            gameName = string.sub(gameName, 1, -string.len(numeral) - 1) .. substitution
        end
    end

    return gameName
end

local regex = "<a href%s*=%s*\"(/torrent/[^\"]+)\""
local magnetRegex = "href%s*=%s*\"(magnet:[^\"]+)\""
local searchprovider = "1337x.to"
local version = client.GetVersionDouble()
local cfCookies1337x = ""

local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15"
}

if version < 3.52 then
    Notifications.push_error("Lua Script", "Program is outdated. Please update the app to use this script!")
else
    Notifications.push_success("Lua Script", "[1337x] DODI script is loaded and working!")
    
    menu.add_check_box("Roman Numbers Conversion 1337x")
    local romantonormalnumbers = true
    menu.set_bool("Roman Numbers Conversion 1337x", true)

    local function cfcallback(cookie, url)
        if url == "https://".. searchprovider then
            cfCookies1337x = cookie
            local cfclearence = "cf_clearance=" .. tostring(cfCookies1337x)
            headers = {
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15",
                ["Cookie"] = cfclearence
            }
            communication.RefreshScriptResults()
        end
    end

    -- Only DODI uploader allowed
    local allowedUploaders = {
        ["/user/DODI/"] = "DODI"
    }

    local function request1337x()
        if cfCookies1337x == nil or cfCookies1337x == "" then
            http.CloudFlareSolver("https://".. searchprovider)
            return
        end
        
        local gamename = game.getgamename()
        if not gamename then
            return
        end

        if romantonormalnumbers then
            gamename = substituteRomanNumerals(gamename)
        end

        -- Updated search URL format
        local urlrequest = "https://" .. searchprovider .. "/category-search/" .. tostring(gamename):gsub(" ", "+") .. "/Games/1/"
        local htmlContent = http.get(urlrequest, headers)

        if not htmlContent then
            return
        end

        local results = {}
        
        -- Parse each torrent result
        local currentPos = 1
        while true do
            -- Find the next torrent row
            local rowStart = htmlContent:find('<tr>', currentPos)
            if not rowStart then break end
            
            local rowEnd = htmlContent:find('</tr>', rowStart)
            if not rowEnd then break end
            
            local rowContent = htmlContent:sub(rowStart, rowEnd)
            currentPos = rowEnd
            
            -- Check if this row has the specific uploader cell
            local uploaderFound = false
            local uploaderName = ""
            local tdStart = rowContent:find('<td class="coll%-5 vip">')
            if tdStart then
                local tdEnd = rowContent:find('</td>', tdStart)
                if tdEnd then
                    local tdContent = rowContent:sub(tdStart, tdEnd)
                    
                    -- Only check for DODI uploader
                    if tdContent:find("/user/DODI/") then
                        uploaderFound = true
                        uploaderName = "DODI"
                    end
                end
            end
            
            if uploaderFound then
                -- Extract torrent link
                local torrentLink = rowContent:match(regex)
                if torrentLink then
                    local url = "https://" .. searchprovider .. torrentLink
                    
                    local torrentName = url:match("/([^/]+)/$")
                    if torrentName then
                        local htmlContent2 = http.get(url, headers)
                        
                        if htmlContent2 then
                            -- Extract torrent info for tooltip
                            local sizeSeedsInfo = ""
                            local uploadDate = ""
                            
                            -- Extract size and seeds from the main page row
                            local sizeSeedsPattern = '<td class="coll%-4 size mob%-vip">([^<]+)<span class="seeds">([^<]+)</span></td>'
                            local size, seeds = rowContent:match(sizeSeedsPattern)
                            
                            -- Extract leeches from the main page row
                            local leechesPattern = '<td class="coll%-3 leeches">([^<]+)</td>'
                            local leeches = rowContent:match(leechesPattern)
                            
                            -- Extract date from main page row
                            local datePattern = '<td class="coll%-date">([^<]+)</td>'
                            local dateMatch = rowContent:match(datePattern)
                            
                            if size and seeds and leeches and dateMatch then
                                -- Clean up the data
                                size = size:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
                                seeds = seeds:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
                                leeches = leeches:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
                                uploadDate = dateMatch:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
                                
                                -- Format the tooltip string
                                sizeSeedsInfo = string.format("Size: %s | Seeds: %s | Leeches: %s | Upload date: %s", 
                                    size, seeds, leeches, uploadDate)
                            elseif size and seeds and dateMatch then
                                -- Fallback if leeches not found
                                size = size:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
                                seeds = seeds:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
                                uploadDate = dateMatch:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
                                
                                sizeSeedsInfo = string.format("Size: %s | Seeds: %s | Upload date: %s", 
                                    size, seeds, uploadDate)
                            end
                            
                            -- Add uploader info to tooltip
                            sizeSeedsInfo = sizeSeedsInfo .. " | Uploader: " .. uploaderName
                            
                            local searchResult = {
                                name = "[" .. size .. "] " .. torrentName,
                                links = {},
                                ScriptName = "[1337x] DODI",  -- Changed script name
                                tooltip = sizeSeedsInfo,
                                metadata = {
                                    uploader = uploaderName
                                }
                            }
                            
                            for magnetMatch in htmlContent2:gmatch(magnetRegex) do
                                -- For DODI repacks, set up automatic execution
                                searchResult.links[#searchResult.links + 1] = {
                                    name = "Download (Auto-Install)",
                                    link = magnetMatch,
                                    addtodownloadlist = true                                                                      
                                }
                                break
                            end
                            
                            if next(searchResult.links) == nil then
                                searchResult.links[#searchResult.links + 1] = {
                                    name = "Download",
                                    link = url
                                }
                            end
                            
                            results[#results + 1] = searchResult
                        end
                    end
                end
            end
        end

        if next(results) ~= nil then
            communication.receiveSearchResults(results)
        else
            Notifications.push("Search results", "No DODI repacks found.")
        end
    end

    local expectedurl = ""
    local imagelink = ""
    local gamename = ""
    local function ondownloadclick(gamejson, downloadurl, scriptname)
        if scriptname == "[1337x] DODI" then  -- Updated script name check
            expectedurl = downloadurl
        end
        local jsonResults = JsonWrapper.parse(gamejson)
        local coverImageUrl = jsonResults["cover"]["url"]

        if coverImageUrl and coverImageUrl:sub(1, 2) == "//" then
            coverImageUrl = "https:" .. coverImageUrl
        end
        if coverImageUrl then
            coverImageUrl = coverImageUrl:gsub("t_thumb", "t_cover_big")
        end

        local jsonName = JsonWrapper.parse(gamejson).name
        gamename = jsonName
        imagelink = coverImageUrl
    end

    local function setupcompletedf(from, destination)
        local executables = file.listexecutables(destination)

        if executables and #executables >= 1 then
            local firstExecutable = executables[1]
            local fullExecutablePath = destination .. "\\" .. firstExecutable
            local gameidl = GameLibrary.GetGameIdFromName(gamename)
            if gameidl == -1 then
                local imagePath = Download.DownloadImage(imagelink)
                GameLibrary.addGame(fullExecutablePath, imagePath, gamename, "")
                Notifications.push_success("[1337x] DODI Script", "Game successfully installed!")
            else
                GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                Notifications.push_success("[1337x] DODI Script", "Game successfully installed!")
            end
        else
            local executables2 = file.listexecutablesrecursive(destination)
            if executables2 and #executables2 >= 1 then
                local firstExecutable = executables2[1]
                local gameidl = GameLibrary.GetGameIdFromName(gamename)
                if gameidl == -1 then
                    local imagePath = Download.DownloadImage(imagelink)
                    GameLibrary.addGame(firstExecutable, imagePath, gamename, "")
                    Notifications.push_success("[1337x] DODI Script", "Game successfully installed!")
                else
                    GameLibrary.changeGameinfo(gameidl, firstExecutable)
                    Notifications.push_success("[1337x] DODI Script", "Game successfully installed!")
                end
            end
        end
    end

    local function ondownloadcompleted(path, url)
        if expectedurl == url then
            local gamenametopath = gamename:gsub(":", "")
            path = path:gsub("\\", "/")

            local executables = file.listexecutables(path)
            if #executables == 0 then
                Notifications.push_warning("[1337x] DODI Script", "No executables found in download folder")
                return
            end

            local setupFound = false
            for _, exe in ipairs(executables) do
                if exe:lower():find("setup") then
                    local setupPath = path .. "/" .. exe
                    exec(setupPath, 5000, "", true, "Setup.tmp")
                    Notifications.push_success("[1337x] DODI Script", "Setup.exe launched successfully!")
                    client.add_callback("on_setupcompleted", setupcompletedf)
                    setupFound = true
                    break
                end
            end

            if not setupFound then
                Notifications.push_warning("[1337x] DODI Script", "No valid setup executable found")
            end
        end
    end

    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_scriptselected", request1337x)
    client.add_callback("on_cfdone", cfcallback)
end



