--1.00
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end
local scriptsfolder = client.GetScriptsPath()
local updtheaders = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local version = "1.00"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/gamedrive.lua", updtheaders)

local outdated = false
if checkVersion(githubversion, version) then
outdated = false
else
outdated = true
    Notifications.push_warning("Script Outdated", "The Script Is Outdated Please Update")
end
local function extractGameName(url)
    local pattern = "gamedrive.org/(.-)/"
    local fullName = string.match(url, pattern)
    return fullName
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
local function filterDownloadLinks(links)
    local filteredLinks = {}

    for _, link in ipairs(links) do
        if not string.match(link, "gamedrive%.org") then
            table.insert(filteredLinks, link)
        end
    end

    return filteredLinks
end
local function filterLinks(links)
    local filteredLinks = {}

    -- Function to check if a link should be filtered
    local function shouldFilter(link)
        local filters = {
            "/category",
            "/dmca",
            "/dc",
            "/yt",
            "/2023",
            "/2022",
            "/2021",
            "/2020",
             "/a%-z",
            "/disclaimer",
            "/contact%-us",
            "/privacy%-policy",
            "/business%-with%-us",
"/discord",
"/tg",
"/page",
        }

        -- Check if the link contains any filter
        for _, filter in ipairs(filters) do
            if string.find(link, filter) then
                return true
            end
        end

        -- Check if the link ends with gamedrive.org
        if string.match(link, "gamedrive.org/?$") then
            return true
        end

        return false
    end

    -- Filter and remove links
    for _, link in ipairs(links) do
        if not shouldFilter(link) then
            table.insert(filteredLinks, link)
        end
    end

    return filteredLinks
end
local function webScrapegamedrive(gameName)
    local searchUrl = "https://gamedrive.org/?s=" .. gameName
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

    local gameNames = {}
    local gameLinks = {}
    
    local gameResultsL = filterLinksByGameName(filterLinks(HtmlWrapper.findAttribute(responseBody, "a", "", "", "href")), gamenamemod)
    local gameResults = {}

    for _, link in ipairs(gameResultsL) do
        table.insert(gameLinks,link)
    end

    for i = 1, #gameLinks do
        local gameResponseBody = http.get(gameLinks[i], headers)

        if gameResponseBody then
                local gameResult = {
                    name = extractGameName(gameLinks[i]),
                    links = {},
                    ScriptName = "gamedrive"
                }

               local linksDL = filterDownloadLinks(HtmlWrapper.findAttribute(gameResponseBody, "a", "target", "_blank", "href"))
               for _, serverLink in ipairs(linksDL) do
                 -- Insert into gameResult.links
                 local serverName = extractDomain(serverLink)
                 table.insert(gameResult.links, { name = serverName, link = serverLink, addtodownloadlist = false })
               end

                table.insert(gameResults, gameResult)
        else
        end
    end

    return gameResults
end

local version = client.GetVersionDouble()

if version < 2.14 then
    Notifications.push_error("Lua Script", "Program is Outdated Please Update to use that Script")
   if outdated then 
	menu.add_button("Update gamedrive")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/gamedrive.lua", scriptsfolder .. "gamedrive.lua")
	   client.unload_script("gamedrive.lua")
	   client.load_script("gamedrive.lua")
    end
	client.add_callback("on_button_Update gamedrive", updatebutton)
	end
else
   Notifications.push_success("Lua Script", "gamedrive Script Loaded And Working")
  if outdated then 
	menu.add_button("Update gamedrive")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/gamedrive.lua", scriptsfolder .. "gamedrive.lua")
	   client.unload_script("gamedrive.lua")
	   client.load_script("gamedrive.lua")
    end
	client.add_callback("on_button_Update gamedrive", updatebutton)
	end
local function gamedrive()
local gamename = game.getgamename()  
local results = webScrapegamedrive(gamename)
communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", gamedrive)
end












