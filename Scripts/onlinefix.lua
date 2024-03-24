--1.11
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end
local scriptsfolder = client.GetScriptsPath()
local headers = {
   ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}
local function urlencode(str)
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

local function getSearchUrl(gameName)
    local encodedGameName = urlencode(gameName)
    return "https://online-fix.me/index.php?do=search&subaction=search&story=" .. encodedGameName
end

local function webScrapeOnlineFixGames(searchUrl)

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
                ScriptName = "onlinefix"
            }

            table.insert(gameResults, gameResult)
        else
        end
    end

    return gameResults
end

local version = "1.11"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/onlinefix.lua", headers)

local outdated = false
if checkVersion(githubversion, version) then
outdated = false
else
outdated = true
    Notifications.push_warning("Outdated Script", "Please update the script.")
end

local version = client.GetVersionDouble()

if version < 2.14 then
    Notifications.push_error("Lua Script", "Program is outdated. Please update the app to use this script!")
	if outdated then 
	menu.add_button("Update onlinefix")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/onlinefix.lua", scriptsfolder .. "onlinefix.lua")
	   client.unload_script("onlinefix.lua")
	   client.load_script("onlinefix.lua")
    end
	client.add_callback("on_button_Update onlinefix", updatebutton)
	end
else
    Notifications.push_success("Lua Script", "onlinefix script is loaded and working!")
if outdated then 
	menu.add_button("Update onlinefix")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/onlinefix.lua", scriptsfolder .. "onlinefix.lua")
	   client.unload_script("onlinefix.lua")
	   client.load_script("onlinefix.lua")
    end
	client.add_callback("on_button_Update onlinefix", updatebutton)
	end
local function main()
    local gameName = game.getgamename()

    local searchUrl = getSearchUrl(gameName)

    local results = webScrapeOnlineFixGames(searchUrl)
    communication.receiveSearchResults(results)
end

-- Execute the main function
client.add_callback("on_scriptselected", main)

end
