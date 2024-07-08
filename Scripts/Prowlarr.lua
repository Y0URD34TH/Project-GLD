--1.20
local apikey = "" --YOUR API KEY GOES HERE
local function checkVersion(str, comparison)
    local serverversion = str:sub(3, 6)
    return serverversion == comparison
end
local scriptsfolder = client.GetScriptsPath()
local headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) ApplWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 Edg/114.0.1788.0",
    ["Accept"] = "application/json, text/javascript, */*; q=0.01",
    ["Referer"] = "http://localhost:9696/search",
    ["X-Api-Key"] = apikey,
    ["X-Prowlarr-Client"] = "true",
    ["X-Requested-With"] = "XMLHttpRequest",
    ["Connection"] = "keep-alive",
    ["Sec-Fetch-Mode"] = "cors",
    ["Sec-Fetch-Dest"] = "empty",
    ["Sec-Fetch-Site"] = "same-origin"
}

local headers2 = {
   ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
}

local function isMagnetLinkUC(link)
    return link and string.find(link, "magnet:")
end

local version = "1.20"
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Prowlarr.lua", headers2)

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
	menu.add_button("Update Prowlarr")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Prowlarr.lua", scriptsfolder .. "Prowlarr.lua")
	   client.unload_script("Prowlarr.lua")
	   client.load_script("Prowlarr.lua")
    end
	client.add_callback("on_button_Update Prowlarr", updatebutton)
	end
else
    Notifications.push_success("Lua Script", "Prowlarr is loaded!")
    Notifications.push_warning("Prowlarr Script", "Don't forget to put your API Key in the script!")
    if outdated then 
	menu.add_button("Update Prowlarr")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/Prowlarr.lua", scriptsfolder .. "Prowlarr.lua")
	   client.unload_script("Prowlarr.lua")
	   client.load_script("Prowlarr.lua")
    end
	client.add_callback("on_button_Update Prowlarr", updatebutton)
	end
	menu.add_input_text("Prowlarr key")
    menu.set_text("Prowlarr key", apikey)
    settings.load()
    local function ProwlarrUC()
        apikey = menu.get_text("Prowlarr key")
        local query_fixed = game.getgamename()
        if apikey and apikey ~= nil and apikey ~= "" then
            local url = "http://localhost:9696/api/v1/search?query=" .. query_fixed .. "&type=search&limit=20&offset=0&categories=1000&categories=4050"
            url = url:gsub(" ", "%%20")

            local request = http.get(url, headers)
            if request and request ~= nil and request ~= "" then
                local ret_val = {}
                local request_dec = JsonWrapper.parse(request)

                for _, v in pairs(request_dec) do
                    local entry = {
                        name = v.title .. " " .. v.indexer,
                        links = {}
                    }
                    if isMagnetLinkUC(v.guid) then
                        table.insert(entry.links, { name = "Download", link = v.guid, addtodownloadlist = true })
                        table.insert(entry.links, { name = "Info", link = v.infoUrl, addtodownloadlist = false })
                    else
                        if v.downloadUrl ~= nil and v.downloadUrl ~= "" then
                            table.insert(entry.links, { name = "Download", link = v.downloadUrl, addtodownloadlist = false })
                            table.insert(entry.links, { name = "Info", link = v.infoUrl, addtodownloadlist = false })
                        else
                            table.insert(entry.links, { name = "Download", link = v.guid, addtodownloadlist = false })
                            table.insert(entry.links, { name = "Info", link = v.infoUrl, addtodownloadlist = false })
                        end
                    end

                    table.insert(ret_val, entry)
                end

                communication.receiveSearchResults(ret_val)
            end
        else
                Notifications.push_error("Prowlarr Script", "No API key is provided in the script.")
        end
        settings.save()
    end
    client.add_callback("on_scriptselected", ProwlarrUC)
end
