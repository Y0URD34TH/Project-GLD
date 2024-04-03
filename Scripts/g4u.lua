--1.02
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end
local scriptsfolder = client.GetScriptsPath()
local updtheaders = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local version = "1.02"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/g4u.lua", updtheaders)

local outdated = false
if checkVersion(githubversion, version) then
outdated = false
else
outdated = true
    Notifications.push_warning("Script Outdated", "The Script Is Outdated Please Update")
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
    searchUrl = searchUrl:gsub(" ", "%%20")
    local gamenamemod = gameName
    gamenamemod = gamenamemod:gsub(" ", "-")
    gamenamemod = gamenamemod:gsub(":", "")
    gamenamemod = gamenamemod:gsub("'", "")
    gamenamemod = string.lower(gamenamemod)
    local headers = {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    local responseBody = http.get(searchUrl, headers)
cout(gamenamemod)
    local gameLinks = {}
    
    local gameResultsL = filterLinksByGameName(filterLinks(HtmlWrapper.findAttribute(responseBody, "a", "", "", "href")), gamenamemod)
    local gameResults = {}

    for _, link in ipairs(gameResultsL) do
cout(link)
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

if version < 2.14 then
     Notifications.push_error("Lua Script", "Program is outdated. Please update the app to use this script!")
   if outdated then 
	menu.add_button("Update g4u")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/g4u.lua", scriptsfolder .. "g4u.lua")
	   client.unload_script("g4u.lua")
	   client.load_script("g4u.lua")
    end
	client.add_callback("on_button_Update g4u", updatebutton)
	end
else
   Notifications.push_success("Lua Script", "g4u script is loaded and working!")
  if outdated then 
	menu.add_button("Update g4u")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/g4u.lua", scriptsfolder .. "g4u.lua")
	   client.unload_script("g4u.lua")
	   client.load_script("g4u.lua")
    end
	client.add_callback("on_button_Update g4u", updatebutton)
	end
	local function g4u()
local gamename = game.getgamename()  
local results = webScrapeg4u(gamename)
communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", g4u)
end
