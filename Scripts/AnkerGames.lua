local VERSION = "1.0.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/AnkerGames.lua", VERSION)
local function scrapAnkerGames(gameName, name_script)
    Notifications.push_warning("Anker Script", "Downloads takes 10 seconds to add and more 10 to start!")
    local searchUrl = "https://ankergames.net/search/" .. gameName:gsub(" ", "%%20")
    local headers = {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    }
    local resp = http.get(searchUrl, headers)
    if not resp then
        return {}
    end
    local results = {}
    for href, title in resp:gmatch(
        '<a href="(https://ankergames%.net/game/[^"]+)"[^>]+aria%-label="([^"]+)%- View details"') do
        local resp2 = http.get(href, headers)
        
        -- Extract version
        local version = resp2:match('class="[^"]*animate%-glow[^"]*"[^>]*>%s*V%s+([%d%.]+)')
        
        -- Extract size (looking for the pattern with "GB" after the size number)
        local size = nil

          -- Pattern 1: Mobile view (lg:hidden) with GB
        size = resp2:match('class="[^"]*lg:hidden[^"]*"[^>]*>.-<span>([%d%.]+%s*GB)</span>')
        
        -- Pattern 2: If not found in mobile view, try desktop view (hidden lg:flex)
        if not size then
            size = resp2:match('class="[^"]*hidden lg:flex[^"]*"[^>]*>.-<span>([%d%.]+%s*[MG]B)</span>')
        end
        
        -- Pattern 3: More general pattern for any span containing size
        if not size then
            size = resp2:match('<span>([%d%.]+%s*[MG]B)</span>')
        end
        
        -- Extract Release Group
        local release_group = resp2:match('Release Group.-<a[^>]+href="[^"]+"[^>]*>([^<]+)</a>')
        
        -- Build tooltip with extracted information
        local tooltip_parts = {}
        
        if version then
            table.insert(tooltip_parts, "Version: V " .. version)
        end
        
        if size then
            table.insert(tooltip_parts, "Size: " .. size)
        end
        
        if release_group then
            table.insert(tooltip_parts, "Release Group: " .. release_group)
        end
        
        local tooltip = table.concat(tooltip_parts, "\n")
        
        local patchresult = {
            name = "[".. size .."] "..title,
            links = {},
            tooltip = tooltip,
            ScriptName = name_script
        }
        
        table.insert(patchresult.links, {
            name = "Download",
            link = href,
            addtodownloadlist = true
        })
        
        table.insert(results, patchresult)
    end
    return results
end

local version = client.GetVersionDouble()
local defaultdir = "C:/Games"
if version < 6.95 then -- 3.50
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "Anker Script Loaded and Working")
    menu.add_input_text("Anker Game Dir")
    menu.set_text("Anker Game Dir", defaultdir)
    settings.load()
    local function ankersearch()
        settings.save()
        local getgamename = game.getgamename()
        local scriptname = "AnkerGames"

        local results = scrapAnkerGames(getgamename, scriptname)

        communication.receiveSearchResults(results)
    end
    local imagelink = ""
    local gamename = ""
    local gamepath = ""
    local extractpath = ""
    local expectedurl = ""
    local function ondownloadclick(gamejson, downloadurl, scriptname)       
        if scriptname == "AnkerGames" then
            Notifications.push_warning("Anker Script", "YOUR DOWNLOAD WILL START IN 10 SECONDS")
            Notifications.push_warning("Anker Script", "DONT PANICK WAIT THE 10 SECONDS!")
            expectedurl = downloadurl
        end
        local jsonResults = JsonWrapper.parse(gamejson)
        local coverImageUrl = jsonResults["cover"]["url"]

        if coverImageUrl and coverImageUrl:sub(1, 2) == "//" then
            coverImageUrl = "https:" .. coverImageUrl
        end
        if coverImageUrl then
            coverImageUrl = coverImageUrl:gsub("t_thumb", "t_cover_big")
        end

        local jsonName = JsonWrapper.parse(gamejson).name
        gamename = jsonName
        imagelink = coverImageUrl
    end
    local pathcheck = ""
    local function ondownloadcompleted(path, url)
        if expectedurl == url then
            local gamenametopath = gamename
            gamenametopath = gamenametopath:gsub(":", "")
            defaultdir = menu.get_text("Anker Game Dir") .. "/" .. gamenametopath .. "/"
            -- if url == watchlink2 or url == watchlink1 then
            path = path:gsub("\\", "/")
            pathcheck = path
            zip.extract(path, defaultdir, false)
            -- end
        end
        settings.save()
    end
    local function onextractioncompleted(origin, path)
        if pathcheck == origin then
            path = path:gsub("/", "\\")
            local folders = file.listfolders(path)

            local secondFolder = folders[1]
            if secondFolder then
                local fullFolderPath = path .. "\\" .. secondFolder

                local executables = file.listexecutables(fullFolderPath) -- Returns a vector

                -- Get the first executable (assuming executables[1] exists)
                if executables and #executables >= 1 then
                    local firstExecutable = executables[1]

                    local fullExecutablePath = fullFolderPath .. "\\" .. firstExecutable
                    local gameidl = GameLibrary.GetGameIdFromName(gamename)
                    if gameidl == -1 then
                        local imagePath = Download.DownloadImage(imagelink)
                        GameLibrary.addGame(fullExecutablePath, imagePath, gamename, "")
                        Notifications.push_success("Anker Script", "Game Successfully Installed!")
                    else
                        GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                        Notifications.push_success("Anker Script", "Game Successfully Installed!")
                    end
                else
                    local executables2 = file.listexecutablesrecursive(fullFolderPath) -- Returns a vector
                    if executables2 and #executables2 >= 1 then
                        local firstExecutable = executables2[1]
                        local gameidl = GameLibrary.GetGameIdFromName(gamename)
                        if gameidl == -1 then
                            local imagePath = Download.DownloadImage(imagelink)
                            GameLibrary.addGame(firstExecutable, imagePath, gamename, "")
                            Notifications.push_success("Anker Script", "Game Successfully Installed!")
                        else
                            GameLibrary.changeGameinfo(gameidl, firstExecutable)
                            Notifications.push_success("Anker Script", "Game Successfully Installed!")
                        end
                    end
                end
            end
        end
    end
    client.add_callback("on_scriptselected", ankersearch)
    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_extractioncompleted", onextractioncompleted)
end















