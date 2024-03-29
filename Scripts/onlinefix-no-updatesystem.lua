local function urlencodeNUC(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])",
            function(c)
                return string.format("%%%02X", string.byte(c))
            end
        )
        str = string.gsub(str, " ", "+")
    end
    return str
end

local function getSearchUrlNUC(gameName)
    local encodedGameName = urlencodeNUC(gameName)
    return "https://online-fix.me/index.php?do=search&subaction=search&story=" .. encodedGameName
end

local function webScrapeOnlineFixGamesNUC(searchUrl)
    local headers = {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
    }

    local responseBody = http.get(searchUrl, headers)

    local gameLinks = {}

    for link in responseBody:gmatch('<a class="big%-link" href="(.-)"></a>') do
        table.insert(gameLinks, link)
    end

    local gameResults = {}

    for _, plink in ipairs(gameLinks) do
        local gameResponseBody = http.get(plink, headers)

        if gameResponseBody then

         local gameName = gameResponseBody:match('<h1%s+id="news%-title"%s+itemprop="headline">(.-)</h1>')

            local gameResult = {
                name = gameName,
                links = {
                    { name = "View Page", link = plink, addtodownloadlist = false }
                },
                ScriptName = "onlinefixNUC"
            }

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
    Notifications.push_success("Lua Script", "onlinefix script is loaded and working!")

local function mainNUC()
    local gameNameNUC = game.getgamename()

    local searchUrlNUC = getSearchUrlNUC(gameNameNUC)

    local resultsNUC = webScrapeOnlineFixGamesNUC(searchUrlNUC)
    communication.receiveSearchResults(resultsNUC)
end

client.add_callback("on_scriptselected", mainNUC)
end
