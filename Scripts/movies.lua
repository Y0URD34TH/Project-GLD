--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
-- Modified version to search all 1337x results and use video files for library addition
local VERSION = "1.3"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/%5B1337x%5D%20All%20Results.lua", VERSION)

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
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36"
}

if version < 3.52 then
    Notifications.push_error("Lua Script", "Program is outdated. Please update the app to use this script!")
else
    Notifications.push_success("Lua Script", "[1337x] All Results script is loaded and working!")
    
    menu.add_check_box("Roman Numbers Conversion 1337x")
    local romantonormalnumbers = true
    menu.set_bool("Roman Numbers Conversion 1337x", true)

    local function cfcallback(cookie, url)
        if url == "https://".. searchprovider then
            cfCookies1337x = cookie
            local cfclearence = "cf_clearance=" .. tostring(cfCookies1337x)
            headers = {
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36",
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

        -- Updated search URL format using the new pattern
        local urlrequest = "https://" .. searchprovider .. "/search/" .. tostring(gamename):gsub(" ", "+") .. "/1/"
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
            
            -- Extract torrent link from the row
            local torrentLink = nil
            local torrentName = nil
            local uploader = "Unknown"
            
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
                                if torrentName then
                                    torrentName = torrentName:gsub("-", " ")
                                end
                                break
                            end
                            -- Check for uploader info
                            if href and href:find("/user/") then
                                uploader = href:match("/user/([^/]+)")
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
                        tooltip = string.format("Size: %s | Seeds: %s | Leeches: %s | Upload date: %s | Uploader: %s", 
                            size, seeds, leeches, uploadDate, uploader)
                    elseif size ~= "" and seeds ~= "" and uploadDate ~= "" then
                        tooltip = string.format("Size: %s | Seeds: %s | Upload date: %s | Uploader: %s", 
                            size, seeds, uploadDate, uploader)
                    else
                        tooltip = string.format("Uploader: %s", uploader)
                    end
                    
                    local searchResult = {
                        name = "[" .. (size ~= "" and size or "Unknown") .. "] " .. torrentName,
                        links = {},
                        ScriptName = "[1337x] All Results",
                        tooltip = tooltip,
                        metadata = {
                            uploader = uploader
                        }
                    }
                    
                    -- Find magnet link
                    local magnetLinks = torrentDoc:css('a[href^="magnet:"]')
                    if #magnetLinks > 0 then
                        local magnetHref = magnetLinks[1]:attr("href")
                        if magnetHref then
                            searchResult.links[#searchResult.links + 1] = {
                                name = "Download (Add to Library)",
                                link = magnetHref,
                                addtodownloadlist = true
                            }
                        end
                    end
                    
                    -- If no magnet link found, add the torrent page URL
                    if #searchResult.links == 0 then
                        searchResult.links[#searchResult.links + 1] = {
                            name = "Open Torrent Page",
                            link = torrentLink
                        }
                    end
                    
                    table.insert(results, searchResult)
                end
            end
        end

        if #results > 0 then
            communication.receiveSearchResults(results)
        else
            Notifications.push("Search results", "No results found.")
        end
    end

    local expectedurl = ""
    local imagelink = ""
    local gamename = ""
    
    local function ondownloadclick(gamejson, downloadurl, scriptname)
        if scriptname == "[1337x] All Results" then
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

    -- Function to find video files (mkv, mp4, avi, etc.)
    local function findVideoFiles(directory)
        local videoExtensions = {".mkv", ".mp4", ".avi", ".mov", ".wmv", ".flv", ".webm", ".m4v", ".mpg", ".mpeg"}
        local videoFiles = {}
        
        local function scanDirectory(dir)
            local files = file.listfiles(dir)
            for _, file in ipairs(files) do
                local fullPath = dir .. "\\" .. file
                if file.isfolder then
                    scanDirectory(fullPath)
                else
                    for _, ext in ipairs(videoExtensions) do
                        if file.name:lower():find(ext, 1, true) then
                            table.insert(videoFiles, fullPath)
                            break
                        end
                    end
                end
            end
        end
        
        scanDirectory(directory)
        return videoFiles
    end

    local function setupcompletedf(from, destination)
        -- Look for video files instead of executables
        local videoFiles = findVideoFiles(destination)
        
        if videoFiles and #videoFiles >= 1 then
            local firstVideoFile = videoFiles[1]
            local gameidl = GameLibrary.GetGameIdFromName(gamename)
            if gameidl == -1 then
                local imagePath = Download.DownloadImage(imagelink)
                GameLibrary.addGame(firstVideoFile, imagePath, gamename, "")
                Notifications.push_success("[1337x] All Results Script", "Video file successfully added to library!")
            else
                GameLibrary.changeGameinfo(gameidl, firstVideoFile)
                Notifications.push_success("[1337x] All Results Script", "Video file successfully updated in library!")
            end
        else
            Notifications.push("[1337x] All Results Script", "No video files (.mkv, .mp4, etc.) found in downloaded content")
        end
    end

    local function ondownloadcompleted(path, url)
        if expectedurl == url then
            local gamenametopath = gamename:gsub(":", "")
            path = path:gsub("\\", "/")
            
            Notifications.push_success("[1337x] All Results Script", "Download completed! Looking for video files...")
            
            -- Check for video files in the download folder
            local videoFiles = findVideoFiles(path)
            
            if #videoFiles > 0 then
                -- Setup is removed, directly add to library
                client.add_callback("on_setupcompleted", setupcompletedf)
                setupcompletedf(nil, path)
            else
                Notifications.push_warning("[1337x] All Results Script", "No video files found in download folder. Files may need to be extracted first.")
            end
        end
    end

    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_scriptselected", request1337x)
    client.add_callback("on_cfdone", cfcallback)
end



