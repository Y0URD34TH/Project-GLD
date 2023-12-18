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
local githubversion = http.get("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/prowlarr.lua", headers2)

local outdated = false
if checkVersion(githubversion, version) then
outdated = false
else
outdated = true
    Notifications.push_warning("Script Outdated", "The Script Is Outdated Please Update")
end

local version = client.GetVersion()
if version ~= "V2.12" then
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
	if outdated then 
	menu.add_button("Update prowlarr")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/prowlarr.lua", scriptsfolder .. "prowlarr.lua")
	   client.unload_script("prowlarr.lua")
	   client.load_script("prowlarr.lua")
    end
	client.add_callback("on_button_Update prowlarr", updatebutton)
	end
else
    Notifications.push_success("Lua Script", "prowlarr Script Loaded")
    Notifications.push_warning("Prowlarr Script", "Be sure to put your API Key in the lua script!!!")
    if outdated then 
	menu.add_button("Update prowlarr")
    local function updatebutton()
       Download.DirectDownload("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/main/Scripts/prowlarr.lua", scriptsfolder .. "prowlarr.lua")
	   client.unload_script("prowlarr.lua")
	   client.load_script("prowlarr.lua")
    end
	client.add_callback("on_button_Update prowlarr", updatebutton)
	end
	menu.add_input_text("prowlarr key")
    menu.set_text("prowlarr key", apikey)
    settings.load()
    local function prowlarrUC()
        apikey = menu.get_text("prowlarr key")
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
                Notifications.push_error("Prowlarr Script", "no API key provided in script")
        end
        settings.save()
    end
    client.add_callback("on_scriptselected", prowlarrUC)
end































