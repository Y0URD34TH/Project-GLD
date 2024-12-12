--1.10
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end
local function isGofileLink(link)
    return string.find(link, "gofile")
end
local function isqiwilink(link)
    return string.find(link, "qiwi.gg")
end
local function isbuzzlink(link)
    return string.find(link, "buzzheavier.com")
end
local function ismegadblink(link)
    return string.find(link, "megadb.net")
end
local function endsWith(str, pattern)
    return string.sub(str, -string.len(pattern)) == pattern
end
local scriptsfolder = client.GetScriptsPath()
local updtheaders = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local version = "1.10"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Steamrip%20(Alternative).lua", updtheaders)

local outdated = false
if checkVersion(githubversion, version) then
outdated = false
else
outdated = true
    Notifications.push_warning("Outdated Script", "Please update the script.")
end

function extractDomain(url)
    local pattern = "^[^:]+://([^/]+)"
    local domain = string.match(url, pattern)

    return domain
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
local function webScrapesteamrip(gameName)
gameName = substituteRomanNumerals(gameName)
gameName = gameName:gsub(":", "")
    local searchUrl = "https://steamrip.com/?s=" .. gameName
    searchUrl = searchUrl:gsub(" ", "%%20")

    local headers = {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    local responseBody = http.get(searchUrl, headers)

    local gameNames = {}
    local gameLinks = {}
    
    local gameResultsL = HtmlWrapper.findAttribute(responseBody, "a", "class", "all-over-thumb-link", "href")
    local gameResultsN = HtmlWrapper.findAttribute(responseBody, "h2", "", "", "")
    local gameResults = {}

    for _, link in ipairs(gameResultsL) do
        table.insert(gameLinks, "https://steamrip.com/" .. link)
    end

   for _, name in ipairs(gameResultsN) do
      if name and name ~= "" then
        table.insert(gameNames, name)
      end
    end

    for i = 1, #gameLinks do
        local gameResponseBody = http.get(gameLinks[i], headers)

        if gameResponseBody then
                local gameResult = {
                    name = gameNames[i],
                    links = {},
                    ScriptName = "steamrip-alt"
                }
               table.insert(gameResult.links,{name = "View Page", link = gameLinks[i], addtodownloadlist = false})
               local linksDL = HtmlWrapper.findAttribute(gameResponseBody, "a", "class", "shortc-button medium green ", "href")
               local linksDL2 = HtmlWrapper.findAttribute(gameResponseBody, "a", "class", "shortc-button medium purple ", "href")
              for _, serverLink in ipairs(linksDL) do
                 -- Insert into gameResult.links
                 local serverName = extractDomainNUC("https:" .. serverLink)
  if isGofileLink(serverLink) then
        local serverName = "GoFile"
		watchlink1 = "https:" .. serverLink
        table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink, addtodownloadlist = true })
    end
	if isqiwilink(serverLink) then
        local serverName = "kiwi"
		watchlink1 = "https:" .. serverLink
        table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink, addtodownloadlist = false })
    end
    if isbuzzlink(serverLink) then
        local serverName = "buzzheavier"
		watchlink1 = "https:" .. serverLink
        table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink, addtodownloadlist = false })
    end
    if ismegadblink(serverLink) then
        local serverName = "megadb"
		watchlink1 = "https:" .. serverLink
        table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink, addtodownloadlist = false })
    end
end

for _, serverLink2 in ipairs(linksDL2) do
    if isGofileLink(serverLink2) then
        local serverName = "GoFile"
		watchlink2 = "https:" .. serverLink2
        table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink2, addtodownloadlist = true })
    end
	if isqiwilink(serverLink2) then
        local serverName = "kiwi"
		watchlink2 = "https:" .. serverLink2
        table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink2, addtodownloadlist = false })
    end
    if isbuzzlink(serverLink2) then
        local serverName = "buzzheavier"
		watchlink2 = "https:" .. serverLink2
        table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink2, addtodownloadlist = false })
    end
    if ismegadblink(serverLink2) then
        local serverName = "megadb"
		watchlink2 = "https:" .. serverLink2
        table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink2, addtodownloadlist = false })
    end
end

                table.insert(gameResults, gameResult)
        else
        end
    end

    return gameResults
end

local version = client.GetVersionDouble()

if version < 3.50 then
      Notifications.push_error("Lua Script", "Program is outdated. Please update the app to use this script!")
   if outdated then 
	menu.add_button("Update steamrip")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Steamrip%20(Alternative).lua", scriptsfolder .. "Steamrip (Alternative).lua")
	   client.unload_script("Steamrip (Alternative).lua")
	   client.load_script("Steamrip (Alternative).lua")
    end
	client.add_callback("on_button_Update steamrip", updatebutton)
	end
else
   Notifications.push_success("Lua Script", "Steamrip (alternative) script is loaded and working!")
  if outdated then 
	menu.add_button("Update steamrip")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Steamrip%20(Alternative).lua", scriptsfolder .. "Steamrip (Alternative).lua")
	   client.unload_script("Steamrip (Alternative).lua")
	   client.load_script("Steamrip (Alternative).lua")
    end
	client.add_callback("on_button_Update steamrip", updatebutton)
	end
local function steamrip()
local gamename = game.getgamename()  
local results = webScrapesteamrip(gamename)
communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", steamrip)
end


