--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
function extractDomainNUC(url)
    local pattern = "^[^:]+://([^/]+)"
    local domain = string.match(url, pattern)

    return domain
end
local function isGofileLink(link)
    return string.find(link, "gofile")
end
local function isqiwilink(link)
    return string.find(link, "qiwi.gg")
end
local function endsWith(str, pattern)
    return string.sub(str, -string.len(pattern)) == pattern
end

local watchlink1 = ""
local watchlink2 = ""
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
local function webScrape1clickNUC(gameName)
gameName = substituteRomanNumerals(gameName)
gameName = gameName:gsub(":", "")
utils.ConsolePrint(true, gameName)
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
                    ScriptName = "1click"
                }

               local linksDL = HtmlWrapper.findAttribute(gameResponseBody, "a", "class", "shortc-button medium green ", "href")
               local linksDL2 = HtmlWrapper.findAttribute(gameResponseBody, "a", "class", "shortc-button medium purple ", "href")
              for _, serverLink in ipairs(linksDL) do
    if isGofileLink(serverLink) then
        local serverName = "Download"
		watchlink1 = "https:" .. serverLink
        table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink, addtodownloadlist = true })
    end
	if isqiwilink(serverLink) then
        local serverName = "2Clicks Download"
		watchlink1 = "https:" .. serverLink
        table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink, addtodownloadlist = false })
    end
end

for _, serverLink2 in ipairs(linksDL2) do
    if isGofileLink(serverLink2) then
        local serverName = "Download"
		watchlink2 = "https:" .. serverLink2
        table.insert(gameResult.links, { name = serverName, link = "https:" .. serverLink2, addtodownloadlist = true })
    end
	if isqiwilink(serverLink2) then
        local serverName = "2Clicks Download"
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
local defaultdir = "C:/Games"
if version < 3.50 then --3.50
    Notifications.push_error("Program is outdated. Please update the app to use this script!")
else
    Notifications.push_success("Lua Script", "1click script is loaded and working!")
    menu.add_input_text("Default game dir")
    menu.set_text("Default game dir", defaultdir)
    settings.load()
local function click1NUC()
settings.save()
local gamenameNUC = game.getgamename()  
local resultsNUC = webScrape1clickNUC(gamenameNUC)
communication.receiveSearchResults(resultsNUC)
end
local imagelink = ""
local gamename = ""
local gamepath = ""
local extractpath = ""
local shouldprogressextraction = false
local function ondownloadclick(gamejson, downloadurl, scriptname)
shouldprogressextraction = false
if scriptname == "1click" then
shouldprogressextraction = true
end
local jsonResults =JsonWrapper.parse(gamejson)["image"]
local jsonName = JsonWrapper.parse(gamejson).name
gamename = jsonName
imagelink = jsonResults.medium_url
end
local pathcheck = ""
local function ondownloadcompleted(path, url)
if shouldprogressextraction then
local gamenametopath = gamename
gamenametopath = gamenametopath:gsub(":", "")
defaultdir = menu.get_text("Default game dir") .. "/" .. gamenametopath .. "/"
--if url == watchlink2 or url == watchlink1 then
path = path:gsub("\\", "/")
pathcheck = defaultdir
zip.extract(path, defaultdir, true)
--end
end
settings.save()
end
local function onextractioncompleted(path)
if pathcheck == path then
local imagePath = Download.DownloadImage(imagelink)
GameLibrary.addGame(path, imagePath, gamename, "")
Notifications.push_success("1Click Script", "Game has been successfully installed!")
Notifications.push_warning("1Click Script", "Please got to the library and modify the game path!")
end
end
client.add_callback("on_scriptselected", click1NUC)
client.add_callback("on_downloadclick", ondownloadclick)
client.add_callback("on_downloadcompleted", ondownloadcompleted)
client.add_callback("on_extractioncompleted", onextractioncompleted)
end
