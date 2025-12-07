local VERSION = "1.0.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/G4U.lua", VERSION)
local function extractGameName(url)
    -- Attempt to find the game name in the pattern "/%d+%-([%a%d%-]+)%-"
    local start_index, end_index, game_name = url:find("/%d+%-([%a%d%-]+)%-")
    if game_name and game_name ~= "" then
        return game_name
    else
        -- If the URL doesn't match the first pattern, try to extract the game name directly
        start_index, end_index, game_name = url:find("/([%a%d%-]+)/?$") -- Also consider a possible trailing slash
        if game_name and game_name ~= "" then
            return game_name
        else
            return nil
        end
    end
end

function extractDomain(url)
    local pattern = "^[^:]+://([^/]+)"
    local domain = string.match(url, pattern)

    return domain
end
local function filterLinksByGameName(links, gameName)
    local filteredLinks = {}

    for _, link in ipairs(links) do
        -- Check if the link contains the game name string
        if string.find(link, gameName, 1, true) then
            table.insert(filteredLinks, link)
        end
    end

    return filteredLinks
end
local function filterLinks(links)
    local filteredLinks = {}
    for _, link in ipairs(links) do
        -- Check if the link starts with "/en/" followed by a number
        if string.match(link, "^/en/%d") then
            table.insert(filteredLinks, link)
        end
    end
    return filteredLinks
end
-- Function to filter, complete, and remove duplicates from links
local function filterCompleteAndRemoveDuplicates(links)
    local uniqueLinks = {}
    local filteredLinks = {}

    for _, link in ipairs(links) do
        -- Check if the link ends with "/nzb"
        local endsWithNzb = string.match(link, "/nzb$")

        -- Check if the link contains "ddownload," "katfile," or "steam"
        local containsDdownload = string.match(link, "ddownload")
        local containsKatfile = string.match(link, "katfile")
        local containsSteam = string.match(link, "steam")

        -- Complete incomplete links with "https://g4u.to/"
        if not link:match("^https://") then
            link = "https://g4u.to" .. link
        end

        -- Add the link to the filtered list if it meets any of the conditions and is not a duplicate
        if endsWithNzb or containsSteam then
            if not uniqueLinks[link] then
                uniqueLinks[link] = true
                table.insert(filteredLinks, link)
            end
        end
    end

    return filteredLinks
end
local function webScrapeg4u(gameName)
    local searchUrl = "https://g4u.to/en/search/?str=" .. gameName
    searchUrl = searchUrl:gsub(" ", "+")
    local gamenamemod = gameName
    gamenamemod = gamenamemod:gsub(" ", "-")
    gamenamemod = gamenamemod:gsub(":", "")
    gamenamemod = gamenamemod:gsub("'", "")
    gamenamemod = string.lower(gamenamemod)
    local headers = {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    local responseBody = http.get(searchUrl, headers)
    local gameLinks = {}
    
    local gameResultsL = filterLinksByGameName(filterLinks(HtmlWrapper.findAttribute(responseBody, "a", "", "", "href")), gamenamemod)
    local gameResults = {}

    for _, link in ipairs(gameResultsL) do
        table.insert(gameLinks, "https://g4u.to" .. link)
    end

    for i = 1, #gameLinks do
        local gameResponseBody = http.get(gameLinks[i], headers)

        if gameResponseBody then
                local gameResult = {
                    name = extractGameName(gameLinks[i]),
                    links = {},
                    ScriptName = "g4u"
                }

               local linksDL = HtmlWrapper.findAttribute(gameResponseBody, "a", "class", "w3-button w3-block w3-orange w3-text-white w3-hover-green w3-padding-small", "href")
               local linksDL2 = filterCompleteAndRemoveDuplicates(HtmlWrapper.findAttribute(gameResponseBody, "a", "target", "_blank", "href"))
               table.insert(gameResult.links, { name = "View Game Page", link = gameLinks[i], addtodownloadlist = false })
               for _, serverLink in ipairs(linksDL) do
                 -- Insert into gameResult.links
                 local serverName = "freediscussions"
                 table.insert(gameResult.links, { name = serverName, link = "https://g4u.to" .. serverLink, addtodownloadlist = false })
               end
               for _, serverLink2 in ipairs(linksDL2) do
                 -- Insert into gameResult.links
                 local serverName = extractDomain(serverLink2)
                 if string.match(serverName, "g4u") then
                 table.insert(gameResult.links, { name = "nzb", link = serverLink2, addtodownloadlist = true })
                 else
                 table.insert(gameResult.links, { name = serverName, link = serverLink2, addtodownloadlist = false })
                end
               end

                table.insert(gameResults, gameResult)
        else
        end
    end

    return gameResults
end

local version = client.GetVersionDouble()

if version < 6.95 then
     Notifications.push_error("Lua Script", "Program is outdated. Please update the app to use this script!")  
else
   Notifications.push_success("Lua Script", "G4U script is loaded and working!")
	local function g4u()
local gamename = game.getgamename()  
local results = webScrapeg4u(gamename)
communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", g4u)
end


