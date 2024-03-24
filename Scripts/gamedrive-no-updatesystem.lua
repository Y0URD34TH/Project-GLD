--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md

local function extractGameName(url)
    local pattern = "gamedrive.org/(.-)/"
    local fullName = string.match(url, pattern)
    return fullName
end

function extractDomainNUC(url)
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
local function webScrapegamedriveNUC(gameName)
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
                 local serverName = extractDomainNUC(serverLink)
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
    Notifications.push_error("Lua Script", "Program is outdated. Please update the app to use this script!")
else
    Notifications.push_success("Lua Script", "gamedrive script is loaded and working!")
local function gamedriveNUC()
local gamenameNUC = game.getgamename()  
local resultsNUC = webScrapegamedriveNUC(gamenameNUC)
communication.receiveSearchResults(resultsNUC)
end
client.add_callback("on_scriptselected", gamedriveNUC)
end
