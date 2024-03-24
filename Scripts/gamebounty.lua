--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
function checkLinkType(link)
    if string.match(link, "^https://qiwi%.gg/") then
        return "kiwi.gg"
    elseif string.match(link, "^https://mirrors%.") then
        return "mirrors"
    else
        return "unknown"
    end
end
local function extractGameName(url)
    local pattern = "gamebounty.world/(.-)/"
    local fullName = string.match(url, pattern)
    return fullName
end
local function webScrapegamebounty(gameName)
    local searchUrl = "https://gamebounty.world/?s=" .. gameName
    searchUrl = searchUrl:gsub(" ", "+")
    local headers = {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    local responseBody = http.get(searchUrl, headers)

    local gameLinks = {}
    
    local gameResultsL = HtmlWrapper.findAttribute(responseBody, "a", "target", "_self", "href")
    local gameResults = {}

    for _, link in ipairs(gameResultsL) do
        table.insert(gameLinks, link)
    end

    for i = 1, #gameLinks do
        local gameResponseBody = http.get(gameLinks[i], headers)

        if gameResponseBody then
                local gameResult = {
                    name = extractGameName(gameLinks[i]),
                    links = {},
                    ScriptName = "gamebounty"
                }

               local linksDL = HtmlWrapper.findAttribute(gameResponseBody, "a", "class", "wp-block-button__link has-text-align-center wp-element-button", "href")
               table.insert(gameResult.links, { name = "View Game Page", link = gameLinks[i], addtodownloadlist = false })
               for _, serverLink in ipairs(linksDL) do
                 -- Insert into gameResult.links
                 local serverName = checkLinkType(serverLink)
                 table.insert(gameResult.links, { name = serverName, link = serverLink, addtodownloadlist = false })
               end
			   table.insert(gameResult.links, { name = "Password: gamebounty", link = "gamebounty", addtodownloadlist = false })
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
    Notifications.push_success("Lua Script", "gamebounty script is loaded and working!")
local function gamebounty()
Notifications.push_warning("gamebounty", "The default password for the games is: gamebounty")
local gamename = game.getgamename()  
local results = webScrapegamebounty(gamename)
communication.receiveSearchResults(results)
end
local function passnotification(gamejson, downloadurl, scriptname)
if scriptname == "gamebounty" then
Notifications.push_warning("gamebounty", "The default password for the games is: gamebounty")
end
end
client.add_callback("on_scriptselected", gamebounty)
client.add_callback("on_downloadclick", passnotification)
end
