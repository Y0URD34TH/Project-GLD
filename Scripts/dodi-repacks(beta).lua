local function extractGameName(url)
    local start_index, end_index = url:find("/%d+%-([%a%-]+)%-")
    if start_index then
        return url:sub(start_index + 1, end_index - 1)
    else
        -- If the URL doesn't match the pattern, try to extract the game name directly
        local start_index, end_index = url:find("/([%a%-]+)/?$") -- Also consider a possible trailing slash
        if start_index then
            return url:sub(start_index + 1, end_index)
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

local cfcookies = ""

local headers = {
}

local function cfcallback(cookie, url)
if url == "https://dodi-repacks.site/" then
cfcookies = cookie
local cfclearence = "cf_clearance=" .. tostring(cfcookies)
headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15",
    ["Cookie"] = cfclearence
}
communication.RefreshScriptResults()
end
end

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

        if gameResponseBody then
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
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "dodi-repacks Script Loaded and Working")
local function dodirepacks()
  if cfcookies == nil or cfcookies == "" then
        http.CloudFlareSolver("https://dodi-repacks.site/")
   else
        local gamename = game.getgamename()  
        local results = webScrapedodi(gamename)
        communication.receiveSearchResults(results)
end
end
client.add_callback("on_scriptselected", dodirepacks)
client.add_callback("on_cfdone", cfcallback)
end

