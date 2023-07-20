--1.11
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end
local headers = {
     ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local function webScrapeElAmigosGames(gameName)
    local searchUrl = "https://www.elamigos-games.com/?q=" .. gameName
    searchUrl = searchUrl:gsub(" ", "%%20")

    local responseBody = http.get(searchUrl, headers)

    local gameNames = {}
    local gameLinks = {}

    for link, name in responseBody:gmatch('<h6 class="card%-title">.-<a href="(.-)">(.-)</a>') do
        table.insert(gameNames, name)
        table.insert(gameLinks, link)
    end

    -- Table to store the results
    local gameResults = {}

    for i = 1, #gameNames do
        local gameResponseBody = http.get(gameLinks[i], headers)

        if gameResponseBody then
            local downloadServersSection = gameResponseBody:match('<h3 class="my%-4">Download servers<hr></h3>.-</div>%s-</div>')
            if downloadServersSection then
                local gameResult = {
                    name = gameNames[i],
                    links = {},
                    ScriptName = "elamigos-games"
                }

                for serverLink, serverName in downloadServersSection:gmatch('<a href="(.-)".->(.-)</a>') do
                    if not (serverName:find("<img") or serverName:find("comments powered by Disqus.")) then
                        table.insert(gameResult.links, { name = serverName, link = serverLink, addtodownloadlist = false })
                    end
                end

                table.insert(gameResults, gameResult)
            else
            end
        else
        end
    end

    return gameResults
end
local version = "1.11"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/elamigos-games.lua", headers)

if checkVersion(githubversion, version) then
else
    Notifications.push_warning("Script Outdated", "The Script Is Outdated Please Update")
end
local version = client.GetVersion()
if version ~= "V1.12" then
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "elamigos-games Script Loaded and Working")
local function elamigos()
local gamename = game.getgamename()  
local results = webScrapeElAmigosGames(gamename)
communication.receiveSearchResults(results)
end
client.add_callback("on_gameselected", elamigos)
end


