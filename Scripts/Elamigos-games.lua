--1.12
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end
local headers = {
     ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}
local scriptsfolder = client.GetScriptsPath()
local function webScrapeElAmigosGames(gameName)
    local searchUrl = "https://www.elamigos-games.net/?q=" .. gameName
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
                    ScriptName = "Elamigos-games"
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
local version = "1.12"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Elamigos-games.lua", headers)
local outdated = false
if checkVersion(githubversion, version) then
outdated = false
else
outdated = true
    Notifications.push_warning("Oudated Script", "Please update the script.")
end
local version = client.GetVersionDouble()

if version < 2.14 then
    Notifications.push_error("Lua Script", "Program is outdated. Please update the app to use this script!")
	if outdated then 
	menu.add_button("Update Elamigos-games")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Elamigos-games.lua", scriptsfolder .. "Elamigos-games.lua")
	   client.unload_script("Elamigos-games.lua")
	   client.load_script("Elamigos-games.lua")
    end
	client.add_callback("on_button_Update Elamigos-games", updatebutton)
	end
else
    Notifications.push_success("Lua Script", "Elamigos-games script is loaded and working!")
	if outdated then 
	menu.add_button("Update Elamigos-games")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Elamigos-games.lua", scriptsfolder .. "Elamigos-games.lua")
	   client.unload_script("Elamigos-games.lua")
	   client.load_script("Elamigos-games.lua")
    end
	client.add_callback("on_button_Update elamigos-games", updatebutton)
	end
local function elamigos()
local gamename = game.getgamename()  
local results = webScrapeElAmigosGames(gamename)
communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", elamigos)
end
