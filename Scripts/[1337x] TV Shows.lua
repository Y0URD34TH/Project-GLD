--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
local VERSION = "1.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/%5B1337x%5D%20TV%20Shows.lua", VERSION)

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
    Notifications.push_success("Lua Script", "[1337x] TV Shows script is loaded and working!")
    
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
        
local moviename = movie.getmoviename()
if not moviename then
    return
end

if romantonormalnumbers then
    moviename = substituteRomanNumerals(moviename)
end

-- Pull in the extra search fields (any/empty = not set)
local moviequality = movie.getmoviequality()
local movieyear    = movie.getmovieyear()
local moviecodec   = movie.getmoviecodec()

-- Build the search term, appending only the non-empty extras
local searchterm = moviename

if moviequality and moviequality ~= "" then
    searchterm = searchterm .. " " .. moviequality
end

if movieyear and movieyear ~= "" then
    searchterm = searchterm .. " " .. movieyear
end

if moviecodec and moviecodec ~= "" then
    searchterm = searchterm .. " " .. moviecodec
end

-- Updated search URL format
local urlrequest = "https://" .. searchprovider .. "/category-search/" .. tostring(searchterm):gsub(" ", "+") .. "/TV/1/"
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
                            tooltip = string.format("Size: %s | Seeds: %s | Leeches: %s | Upload date: %s", 
                                size, seeds, leeches, uploadDate)
                        elseif size ~= "" and seeds ~= "" and uploadDate ~= "" then
                            tooltip = string.format("Size: %s | Seeds: %s | Upload date: %s", 
                                size, seeds, uploadDate)
                        end
                        
                        local searchResult = {
                            name = "[" .. (size ~= "" and size or "Unknown") .. "] " .. torrentName,
                            links = {},
                            ScriptName = "[1337x] TV Shows",
                            tooltip = tooltip
                        }
                        
                        -- Find magnet link
                        local magnetLinks = torrentDoc:css('a[href^="magnet:"]')
                        if #magnetLinks > 0 then
                            local magnetHref = magnetLinks[1]:attr("href")
                            if magnetHref then
                                searchResult.links[#searchResult.links + 1] = {
                                    name = "Watch",
                                    link = magnetHref,
                                    addtodownloadlist = false,
                                    isMovie = true
                                }
                                searchResult.links[#searchResult.links + 1] = {
                                    name = "Download",
                                    link = magnetHref,
                                    addtodownloadlist = true,
                                    isMovie = true
                                }

                            end
                        end
                        
                        -- If no magnet link found, add the torrent page URL
                        if #searchResult.links == 0 then
                            searchResult.links[#searchResult.links + 1] = {
                                name = "View Page",
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
            Notifications.push("Search results", "No TV Shows found.")
        end
    end

    client.add_callback("on_scriptselected", request1337x)
    client.add_callback("on_cfdone", cfcallback)
end







