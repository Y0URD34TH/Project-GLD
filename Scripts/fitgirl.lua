--1.14
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end
local function sanitizeString(input)
    -- Remove leading and trailing whitespaces
    input = input:match("^%s*(.-)%s*$")
    -- Remove HTML tags
    input = input:gsub("<[^>]+>", "")
    -- Replace HTML entities
    local entities = {
        nbsp = " ",
        quot = "\"",
        amp = "&",
        lt = "<",
        gt = ">",
        apos = "'",
        mdash = "—",
        ndash = "–",
        hellip = "…",
        middot = "·"
    }
    input = input:gsub("&(%w+);", entities)
    return input
end

local function sanitizeMagnet(magnet)
    magnet = magnet:gsub("&#(%d+);", function(entity)
        return string.char(tonumber(entity))
    end)
    magnet = magnet:gsub("&amp;", "&")
    magnet = magnet:gsub("&quot;", '"')
    magnet = magnet:gsub("&lt;", "<")
    magnet = magnet:gsub("&gt;", ">")
    magnet = magnet:gsub("&apos;", "'")
    magnet = magnet:gsub("&#039;", "'")
    magnet = magnet:gsub("&#x27;", "'")
    magnet = magnet:gsub("&mdash;", "—")
    magnet = magnet:gsub("&ndash;", "–")
    magnet = magnet:gsub("&hellip;", "…")
    magnet = magnet:gsub("&middot;", "·")
    magnet = magnet:gsub("&nbsp;", " ")
    return magnet
end

 local headers = {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }


local version = "1.14"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/fitgirl.lua", headers)

if checkVersion(githubversion, version) then
else
    Notifications.push_warning("Script Outdated", "The Script Is Outdated Please Update")
end
 local version = client.GetVersion()
 if version ~= "V1.02" then
  Notifications.push_error("Lua Script", "Program is Outdated Please Update to use that Script")
else
  Notifications.push_success("Lua Script", "fitgirl Script Loaded And Working")

local function scraper()
    local statebool = false
    local gamename = game.getgamename()
    local url = "https://fitgirl-repacks.site/?s=" .. tostring(gamename)
    url = url:gsub(" ", "%%20")
   
    local htmlContent = http.get(url, headers)

    local results = {}

    local hrefPattern = '<h1%s[^>]*class%s*=%s*"[^"]*entry%-title[^"]*"%s*><a%s[^>]*href%s*=%s*"([^"]+)"'
    local hrefList = {}
    for href in string.gmatch(htmlContent, hrefPattern) do
        table.insert(hrefList, href)
    end

    for _, href in ipairs(hrefList) do
        local htmlContent2 = http.get(href, headers)
        local searchResult = {
            name = "unnamed",
            links = {
                { name = "View in Site", link = href }
            },
            ScriptName = "fitgirl"
        }
        local gameName = htmlContent2:match('<h1 class="entry%-title">([^<]+)</h1>')
        if gameName then
            searchResult.name = sanitizeString(gameName)
        end

        local downloadMirrorsSection = htmlContent2:match('<h3>Download Mirrors</h3>.-</ul>')
        if downloadMirrorsSection then
            -- Extract the download links using regex pattern
            local linkPattern = '<a%s[^>]*href%s*=%s*"([^"]+)"%s*target%s*=%s*"_blank"%s*rel%s*=%s*"noopener">(.-)</a>'
            local linkList = {}
            for link, mirrorName in string.gmatch(downloadMirrorsSection, linkPattern) do
                table.insert(linkList, { link = link, name = mirrorName })
            end

            -- Extract the magnet links using regex pattern
            local magnetLinkPattern = '<a%s[^>]*href%s*=%s*"([^"]+)"[^>]*>magnet</a>'
            local magnetList = {}
            for magnet in string.gmatch(downloadMirrorsSection, magnetLinkPattern) do
                table.insert(magnetList, magnet)
            end

             for i, magnet in ipairs(magnetList) do
            magnetList[i] = sanitizeMagnet(magnet)
        end

        -- Add the sanitized magnet links to the link list
        for i, entry in ipairs(linkList) do
            if i == 1 and magnetList[1] then
                local sanitizedMagnet = sanitizeMagnet(magnetList[1])
                local magnetEntry = { link = sanitizedMagnet, name = "1337x (magnet)", addtodownloadlist = true }
                table.insert(searchResult.links, magnetEntry)
            elseif i == 2 and magnetList[2] then
                local sanitizedMagnet = sanitizeMagnet(magnetList[2])
                local magnetEntry = { link = sanitizedMagnet, name = "RuTor (magnet)", addtodownloadlist = true }
                table.insert(searchResult.links, magnetEntry)
            end
            local mirrorEntry = { link = entry.link, name = entry.name, addtodownloadlist = false }
            table.insert(searchResult.links, mirrorEntry)
        end

            table.insert(results, searchResult)
        end
    end

    communication.receiveSearchResults(results)
end
client.add_callback("on_gameselected", scraper)
end


