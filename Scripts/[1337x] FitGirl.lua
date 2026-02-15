--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local VERSION = "1.2"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/%5B1337x%5D%20FitGirl.lua", VERSION)

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

local searchprovider = "1337x.to"
local version = client.GetVersionDouble()
local cfCookies1337x = ""

local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15"
}

if version < 3.52 then
    Notifications.push_error("Lua Script", "Program is outdated. Please update the app to use this script!")
else
    Notifications.push_success("Lua Script", "[1337x] FitGirl script is loaded and working!")
    
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
        
        -- Parse the HTML document
        local doc = html.parse(htmlContent)
        
        -- Find all table rows
        local rows = doc:css('tr')
        
        for i = 1, #rows do
            local row = rows[i]
            
            -- Check if this row contains a FitGirl upload
            -- Look for td with class "coll-5 vip" containing FitGirl user link
            local uploaderCells = row:children()
            local isFitGirl = false
            
            for j = 1, #uploaderCells do
                local cell = uploaderCells[j]
                local cellClass = cell:attr("class")
                
                if cellClass and cellClass:find("coll%-5") and cellClass:find("vip") then
                    -- Check if this cell contains FitGirl link
                    local cellLinks = cell:children()
                    for k = 1, #cellLinks do
                        local link = cellLinks[k]
                        if link:tag() == "a" then
                            local href = link:attr("href")
                            if href and href:find("/user/FitGirl/") then
                                isFitGirl = true
                                break
                            end
                        end
                    end
                end
                
                if isFitGirl then break end
            end
            
            if isFitGirl then
                -- Extract torrent link from the row
                local torrentLink = nil
                local torrentName = nil
                
                -- Find all links in the row
                local allLinks = row:children()
                for j = 1, #allLinks do
                    local cell = allLinks[j]
                    if cell:tag() == "td" then
                        local cellLinks = cell:children()
                        for k = 1, #cellLinks do
                            local link = cellLinks[k]
                            if link:tag() == "a" then
                                local href = link:attr("href")
                                if href and href:find("^/torrent/") then
                                    torrentLink = "https://" .. searchprovider .. href
                                    -- Extract name from URL
                                    torrentName = href:match("/([^/]+)/$")
                                    break
                                end
                            end
                        end
                    end
                    if torrentLink then break end
                end
                
                if torrentLink and torrentName then
                    -- Extract metadata from the row
                    local size = ""
                    local seeds = ""
                    local leeches = ""
                    local uploadDate = ""
                    
                    -- Get all cells in the row
                    local cells = row:children()
                    for j = 1, #cells do
                        local cell = cells[j]
                        local cellClass = cell:attr("class")
                        
                        if cellClass then
                            -- Extract size and seeds from coll-4
                            if cellClass:find("coll%-4") then
                                local cellText = cell:text()
                                -- Size is the main text, seeds are in a span
                                size = cellText:match("^([^%s]+%s+[^%s]+)")
                                if size then
                                    size = size:gsub("^%s*(.-)%s*$", "%1")
                                end
                                
                                local seedsSpan = cell:children()
                                for k = 1, #seedsSpan do
                                    local span = seedsSpan[k]
                                    if span:tag() == "span" and span:attr("class") == "seeds" then
                                        seeds = span:text():gsub("^%s*(.-)%s*$", "%1")
                                        break
                                    end
                                end
                            end
                            
                            -- Extract leeches from coll-3
                            if cellClass:find("coll%-3") and cellClass:find("leeches") then
                                leeches = cell:text():gsub("^%s*(.-)%s*$", "%1")
                            end
                            
                            -- Extract date from coll-date
                            if cellClass:find("coll%-date") then
                                uploadDate = cell:text():gsub("^%s*(.-)%s*$", "%1")
                            end
                        end
                    end
                    
                    -- Fetch the torrent page to get magnet link
                    local torrentPageHtml = http.get(torrentLink, headers)
                    
                    if torrentPageHtml then
                        local torrentDoc = html.parse(torrentPageHtml)
                        
                        -- Format tooltip
                        local tooltip = ""
                        if size ~= "" and seeds ~= "" and leeches ~= "" and uploadDate ~= "" then
                            tooltip = string.format("Size: %s | Seeds: %s | Leeches: %s | Upload date: %s | Uploader: FitGirl", 
                                size, seeds, leeches, uploadDate)
                        elseif size ~= "" and seeds ~= "" and uploadDate ~= "" then
                            tooltip = string.format("Size: %s | Seeds: %s | Upload date: %s | Uploader: FitGirl", 
                                size, seeds, uploadDate)
                        else
                            tooltip = "Uploader: FitGirl"
                        end
                        
                        local searchResult = {
                            name = "[" .. (size ~= "" and size or "Unknown") .. "] " .. torrentName,
                            links = {},
                            ScriptName = "[1337x] FitGirl",
                            tooltip = tooltip,
                            metadata = {
                                uploader = "FitGirl"
                            }
                        }
                        
                        -- Find magnet link
                        local magnetLinks = torrentDoc:css('a[href^="magnet:"]')
                        if #magnetLinks > 0 then
                            local magnetHref = magnetLinks[1]:attr("href")
                            if magnetHref then
                                searchResult.links[#searchResult.links + 1] = {
                                    name = "Download (Auto-Install)",
                                    link = magnetHref,
                                    addtodownloadlist = true
                                }
                            end
                        end
                        
                        -- If no magnet link found, add the torrent page URL
                        if #searchResult.links == 0 then
                            searchResult.links[#searchResult.links + 1] = {
                                name = "Download",
                                link = torrentLink
                            }
                        end
                        
                        table.insert(results, searchResult)
                    end
                end
            end
        end

        if #results > 0 then
            communication.receiveSearchResults(results)
        else
            Notifications.push("Search results", "No FitGirl repacks found.")
        end
    end

    local expectedurl = ""
    local imagelink = ""
    local gamename = ""
    
    local function ondownloadclick(gamejson, downloadurl, scriptname)
        if scriptname == "[1337x] FitGirl" then
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
                Notifications.push_success("[1337x] FitGirl Script", "Game successfully installed!")
            else
                GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                Notifications.push_success("[1337x] FitGirl Script", "Game successfully installed!")
            end
        else
            local executables2 = file.listexecutablesrecursive(destination)
            if executables2 and #executables2 >= 1 then
                local firstExecutable = executables2[1]
                local gameidl = GameLibrary.GetGameIdFromName(gamename)
                if gameidl == -1 then
                    local imagePath = Download.DownloadImage(imagelink)
                    GameLibrary.addGame(firstExecutable, imagePath, gamename, "")
                    Notifications.push_success("[1337x] FitGirl Script", "Game successfully installed!")
                else
                    GameLibrary.changeGameinfo(gameidl, firstExecutable)
                    Notifications.push_success("[1337x] FitGirl Script", "Game successfully installed!")
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
                Notifications.push_warning("[1337x] FitGirl Script", "No executables found in download folder")
                return
            end

            local setupFound = false
            for _, exe in ipairs(executables) do
                if exe:lower():find("setup") then
                    local setupPath = path .. "/" .. exe
                    exec(setupPath, 5000, "", true, "setup.tmp")
                    Notifications.push_success("[1337x] FitGirl Script", "Setup.exe launched successfully!")
                    client.add_callback("on_setupcompleted", setupcompletedf)
                    setupFound = true
                    break
                end
            end

            if not setupFound then
                Notifications.push_warning("[1337x] FitGirl Script", "No valid setup executable found")
            end
        end
    end

    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_scriptselected", request1337x)
    client.add_callback("on_cfdone", cfcallback)
end