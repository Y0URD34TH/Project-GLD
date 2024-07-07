--1.01
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end
local function isGofileLink(link)
    return string.find(link, "gofile")
end
local scriptsfolder = client.GetScriptsPath()
local updtheaders = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local version = "1.01"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/steamrip.lua", updtheaders)

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
local function webScrapesteamrip(gameName)
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
                    ScriptName = "steamrip"
                }

               local linksDL = HtmlWrapper.findAttribute(gameResponseBody, "a", "class", "shortc-button medium green ", "href")
               local linksDL2 = HtmlWrapper.findAttribute(gameResponseBody, "a", "class", "shortc-button medium purple ", "href")
              for _, serverLink in ipairs(linksDL) do
                 -- Insert into gameResult.links
                 local serverName = extractDomainNUC("https:" .. serverLink)
    if isGofileLink(serverLink) then
                 table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink, addtodownloadlist = true })
else
                 table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink, addtodownloadlist = false })
end
               end
               for _, serverLink2 in ipairs(linksDL2) do
                 -- Insert into gameResult.links
                 local serverName = extractDomainNUC("https:" .. serverLink2)
    if isGofileLink(serverLink2) then
                 table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink2, addtodownloadlist = true })
else
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
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/steamrip.lua", scriptsfolder .. "steamrip.lua")
	   client.unload_script("steamrip.lua")
	   client.load_script("steamrip.lua")
    end
	client.add_callback("on_button_Update steamrip", updatebutton)
	end
else
   Notifications.push_success("Lua Script", "steamrip script is loaded and working!")
  if outdated then 
	menu.add_button("Update steamrip")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/steamrip.lua", scriptsfolder .. "steamrip.lua")
	   client.unload_script("steamrip.lua")
	   client.load_script("steamrip.lua")
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
