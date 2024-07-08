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

function remove_duplicates(urls)
   local unique_urls = {}
    for _, url in ipairs(urls) do
        if url ~= "" then
            unique_urls[url] = true
        end
    end
    local result = {}
    for unique_url, _ in pairs(unique_urls) do
        table.insert(result, unique_url)
    end
    return result
end

function extractDownloadLinks(html)
    local links = {}
    
    -- Define the regex pattern to match download links and providers
    local pattern = '<span style="color: #ff0000;">%s*<strong>%s*([^<]+)%s*&#8211;%s*<a%s+href="([^"]+)"[^>]*>Click%s+Here</a>'
    
    -- Iterate through matches in the HTML code
    for provider, link in html:gmatch(pattern) do
        table.insert(links, {link = link, provider = provider})
    end
    
    return links
end

local headers = {
  ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local function webScrapedodi(gameName)
    local searchUrl = "https://dodi-repacks.site/?s=" .. gameName
    searchUrl = searchUrl:gsub(" ", "+")

    local responseBody = http.get(searchUrl, headers)
    local gameLinks = {}
    local gameResultsL = HtmlWrapper.findAttribute(responseBody, "a", "rel", "bookmark", "href")
    local gameResults = {}

    for _, link in ipairs(remove_duplicates(gameResultsL)) do
        table.insert(gameLinks, link)
    end

    for i = 1, #gameLinks do
        local gameResponseBody = http.get(gameLinks[i], headers)

        if gameResponseBody and extractGameName(gameLinks[i]) ~= "" then
                local gameResult = {
                    name = extractGameName(gameLinks[i]),
                    links = {},
                    ScriptName = "dodi-repacks"
                }
               local linksDL = extractDownloadLinks(gameResponseBody)
               table.insert(gameResult.links, { name = "View Game Page", link = gameLinks[i], addtodownloadlist = false })
               for _, serverLink in ipairs(linksDL) do
                 -- Insert into gameResult.links
                 table.insert(gameResult.links, { name = serverLink.provider, link = serverLink.link, addtodownloadlist = false })
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
    Notifications.push_success("Lua Script", "Dodi-repacks script is loaded and working!")
local function dodirepacks()
        local gamename = game.getgamename()  
        local results = webScrapedodi(gamename)
        communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", dodirepacks)
end
