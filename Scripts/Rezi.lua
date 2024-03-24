--1.17
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end
local scriptsfolder = client.GetScriptsPath()
local updtheaders = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local version = "1.17"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Rezi.lua", updtheaders)

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
	menu.add_button("Update Rezi")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Rezi.lua", scriptsfolder .. "Rezi.lua")
	   client.unload_script("Rezi.lua")
	   client.load_script("Rezi.lua")
    end
	client.add_callback("on_button_Update Rezi", updatebutton)
	end
else
   Notifications.push_success("Lua Script", "Rezi Script script is loaded and working!")
  if outdated then 
	menu.add_button("Update Rezi")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Rezi.lua", scriptsfolder .. "Rezi.lua")
	   client.unload_script("Rezi.lua")
	   client.load_script("Rezi.lua")
    end
	client.add_callback("on_button_Update Rezi", updatebutton)
	end
local statebool = false

local function request()
    local link = "https://search.rezi.one/indexes/rezi/search"
    local getgamename = game.getgamename()
    local gamename = "\"" .. getgamename .. "\""
    local params = [[{
        "q": ]] .. tostring(gamename) .. [[,
        "limit": 20
    }]]

    local headers = {
        ["Authorization"] = "Bearer e2a1974678b37386fef69bb3638a1fb36263b78a8be244c04795ada0fa250d3d",
        ["Content-Type"] = "application/json",
        ["accept"] = "application/json"
    }

    local response = http.post(link, params, headers)
    local gameResults = JsonWrapper.parse(response)["hits"]

    local results = {}

    for _, result in ipairs(gameResults) do
        local searchResult = {
            name = "(" .. result.icon .. ") ".. result.title,

            links = {
                { name = "Download", link = result.link, addtodownloadlist = false }
            },
            ScriptName = "Rezi"
        }

        if result.link:find("archive.org") then
            local resolvedLink = http.ArchivedotOrgResolver(result.link)
            if resolvedLink then
                searchResult.name = "(" .. result.icon .. ") ".. result.title .. " [archieve]"
                searchResult.links = {
                        { name = "Download", link = resolvedLink, addtodownloadlist = true }
                }
            end
        end
        if result.link:find("myabandonware.com") then
           searchResult.name = "(" .. result.icon .. ") ".. result.title .. " [myabandonware]"
        end
        if result.link:find("steamrip.com") then
           searchResult.name = "(" .. result.icon .. ") ".. result.title .. " [steamrip]"
        end
        if result.link:find("gamesdrive.net") then
           searchResult.name = "(" .. result.icon .. ") ".. result.title .. " [gamesdrive]"
        end
        if result.link:find("madloader.com") then
           searchResult.name = "(" .. result.icon .. ") ".. result.title .. " [madloader]"
        end
        if result.link:find("psndl.net") then
           searchResult.name = "(" .. result.icon .. ") ".. result.title .. " [psndl]"
        end
        if result.link:find("nopaystation.com") then
           searchResult.name = "(" .. result.icon .. ") ".. result.title .. " [nopaystation]"
        end

        table.insert(results, searchResult)
    end

    communication.receiveSearchResults(results)
end
client.add_callback("on_scriptselected", request)--on a game is selected in menu callback
end
