--1.18
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end

local scriptsfolder = client.GetScriptsPath()
local function organizeLinks(results)
    for _, result in ipairs(results) do
        local magnets = {}
        local viewInSite = {}
        local others = {}

        for _, link in ipairs(result.links) do
            if link.name == "View in Site" then
                table.insert(viewInSite, link)
            elseif link.name:find("magnet") then
                table.insert(magnets, link)
            else
                table.insert(others, link)
            end
        end

        -- Concatenate viewInSite links first, then magnets, then others
        for _, link in ipairs(magnets) do
            table.insert(viewInSite, link)
        end
        for _, link in ipairs(others) do
            table.insert(viewInSite, link)
        end

        result.links = viewInSite
    end
end
local function sanitizeString(input)
    input = input:match("^%s*(.-)%s*$")  -- Remove leading and trailing whitespaces
    input = input:gsub("<[^>]+>", "")  -- Remove HTML tags

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

local version = "1.18"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/FitGirl.lua", headers)
local outdated = false

if checkVersion(githubversion, version) then
    outdated = false
else
    outdated = true
    Notifications.push_warning("Script Outdated", "This script is outdated. Please update it!")
end

local version = client.GetVersionDouble()

if version < 2.14 then
    Notifications.push_error("Lua Script", "Program is outdated. Please update it to use the script!")
    if outdated then 
        menu.add_button("Update fitgirl")
        local function updatebutton()
            Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/fitgirl.lua", scriptsfolder .. "fitgirl.lua")
            client.unload_script("fitgirl.lua")
            client.load_script("fitgirl.lua")
        end
        client.add_callback("on_button_Update fitgirl", updatebutton)
    end
else
    Notifications.push_success("Lua Script", "fitgirl Script Loaded And Working")
    if outdated then 
        menu.add_button("Update fitgirl")
        local function updatebutton()
            Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/fitgirl.lua", scriptsfolder .. "fitgirl.lua")
            client.unload_script("fitgirl.lua")
            client.load_script("fitgirl.lua")
        end
        client.add_callback("on_button_Update fitgirl", updatebutton)
    end

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

            local downloadMirrorsSections = {
                '<h3>Download Mirrors</h3>.-</ul>',
                '<h3>Download Mirrors %(Direct Links%)</h3>.-</ul>',
                '<h3>Download Mirrors %(Torrent%)</h3>.-</ul>'
            }

            for _, downloadMirrorsSection in ipairs(downloadMirrorsSections) do
                for downloadMirrorsSectionContent in htmlContent2:gmatch(downloadMirrorsSection) do
                    local magnetLinkPattern = '<a%s[^>]*href%s*=%s*"([^"]+)"[^>]*>magnet</a>'
                    local magnetList = {}
                    for magnet in string.gmatch(downloadMirrorsSectionContent, magnetLinkPattern) do
                        table.insert(magnetList, magnet)
                    end

                    for i, magnet in ipairs(magnetList) do
                        magnetList[i] = sanitizeMagnet(magnet)
                    end

                    if #magnetList > 0 then
                        local magnetEntry = { link = sanitizeMagnet(magnetList[1]), name = "1337x [magnet]", addtodownloadlist = true }
                        table.insert(searchResult.links, magnetEntry)
                    end

                    if #magnetList > 1 then
                        local magnetEntry = { link = sanitizeMagnet(magnetList[2]), name = "RuTor [magnet]", addtodownloadlist = true }
                        table.insert(searchResult.links, magnetEntry)
                    end

                    local linkPattern = '<a%s[^>]*href%s*=%s*"([^"]+)"%s*target%s*=%s*"_blank"%s*rel%s*=%s*"noopener">(.-)</a>'
                    local linkList = {}
                    for link, mirrorName in string.gmatch(downloadMirrorsSectionContent, linkPattern) do
                        table.insert(linkList, { link = link, name = mirrorName })
                    end

                    for i, entry in ipairs(linkList) do
                        local mirrorEntry = { link = entry.link, name = entry.name, addtodownloadlist = false }
                        table.insert(searchResult.links, mirrorEntry)
                    end
                    table.insert(results, searchResult)
                    break
                end
            end
        end
        organizeLinks(results)
        communication.receiveSearchResults(results)
    end

    client.add_callback("on_scriptselected", scraper)
end
