local VERSION = "1.0.1"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/FitGirl.lua", VERSION)
local function sanitizeMagnet(magnet)
    if not magnet then return "" end

    -- First, decode all HTML entities
    local decoded = magnet
    -- Replace HTML entities
    local html_entities = {
        ["&amp;"] = "&",
        ["&#038;"] = "&",
        ["&#38;"] = "&",
        ["&lt;"] = "<",
        ["&gt;"] = ">",
        ["&quot;"] = '"',
        ["&apos;"] = "'",
        ["&nbsp;"] = " ",
    }

    for entity, replacement in pairs(html_entities) do
        decoded = decoded:gsub(entity, replacement)
    end

    -- Also handle numeric entities like &#038;
    decoded = decoded:gsub("&#(%d+);", function(num)
        return string.char(tonumber(num))
    end)

    -- Also handle hex entities like &#x26;
    decoded = decoded:gsub("&#x(%x+);", function(hex)
        return string.char(tonumber(hex, 16))
    end)

    -- Now fix the dn parameter encoding
    -- Find and fix the dn parameter
    decoded = decoded:gsub("([&?]dn=)([^&]*)", function(prefix, encoded_name)
        -- URL decode the name
        local name = encoded_name
            :gsub("%%(%x%x)", function(hex)
                return string.char(tonumber(hex, 16))
            end)
            :gsub("+", " ")

        -- Remove any leftover HTML entities in the name
        for entity, replacement in pairs(html_entities) do
            name = name:gsub(entity, replacement)
        end

        -- URL encode it properly for magnet link
        local encoded = name
            :gsub("([^A-Za-z0-9%-%.%_%~])", function(c)
                return string.format("%%%02X", string.byte(c))
            end)

        return prefix .. encoded
    end)

    return decoded
end

local function ensureMagnetHasName(magnet, gameTitle)
    if not magnet:find("dn=") then
        -- Add dn parameter
        local encoded_name = gameTitle
            :gsub("([^%w%-%.%_%~])", function(c)
                return string.format("%%%02X", string.byte(c))
            end)
        
        if magnet:find("?") then
            return magnet .. "&dn=" .. encoded_name
        else
            return magnet .. "?dn=" .. encoded_name
        end
    end
    return magnet
end

local function sanitizeString(input)
    if not input or type(input) ~= "string" then return "" end

    -- Trim whitespace
    input = input:match("^%s*(.-)%s*$")

    -- Remove HTML tags
    input = input:gsub("<[^>]->", "")

    -- Decode common HTML entities
    local entities = {
        ["&nbsp;"] = " ",
        ["&quot;"] = '"',
        ["&amp;"]  = "&",
        ["&lt;"]   = "<",
        ["&gt;"]   = ">",
        ["&apos;"] = "'",
        ["&#8211;"] = "-",
        ["&#8212;"] = "--",
        ["&#038;"] = "&",
        ["&#039;"] = "'",
        ["&#160;"] = " ",
    }

    for entity, replacement in pairs(entities) do
        input = input:gsub(entity, replacement)
    end

    -- Numeric entities: decimal
    input = input:gsub("&#(%d+);", function(num)
        local n = tonumber(num)
        -- Only map basic ASCII safely (1–255)
        if n and n >= 32 and n <= 126 then
            return string.char(n)
        end
        return "" -- skip unsupported
    end)

    -- Numeric entities: hex
    input = input:gsub("&#x(%x+);", function(hex)
        local n = tonumber(hex, 16)
        if n and n >= 32 and n <= 126 then
            return string.char(n)
        end
        return ""
    end)

    -- Trim again
    input = input:match("^%s*(.-)%s*$") or ""

    -- Collapse multiple spaces
    input = input:gsub("%s+", " ")

    return input
end

local version = client.GetVersionDouble()

if version < 2.14 then
    Notifications.push_error("Lua Script", "Program is outdated. Please update it to use the script!")
else
    Notifications.push_success("Lua Script", "FitGirl Script Loaded")

    local function scraper()
        local gamename = game.getgamename()
        local searchUrl = "https://fitgirl-repacks.site/?s=" .. gamename:gsub(" ", "+")

        local htmlContent = http.get(searchUrl, {})
        local results = {}

        -- Extract game page URLs using HtmlWrapper
        local gameLinks = HtmlWrapper.findAttribute(
            htmlContent,
            "a",
            "rel",
            "bookmark",
            "href"
        )

        local count = 0
        for _, linkData in ipairs(gameLinks) do
            count = count + 1
            if count > 3 then break end -- Limit to 3 for speed
            local gamePageUrl = linkData
            if not gamePageUrl then goto continue end

            local gameHtml = http.get(gamePageUrl, {})

            -- Extract game title using HtmlWrapper
            local gameTitle = gameHtml:match('entry%-title">([^<]+)<')

            if not gameTitle then goto continue end

            gameTitle = sanitizeString(gameTitle)

            -- Extract repack size
            local repackSize = gameHtml:match("Repack Size:%s*<strong>([^<]+)</strong>")
            if not repackSize then
                repackSize = gameHtml:match("Original Size:%s*<strong>([^<]+)</strong>")
            end
            repackSize = repackSize and sanitizeString(repackSize) or "Unknown"

            -- Extract version from title
            local gameVersion = gameTitle:match("[vV]([%d%.]+)") or "Unknown"

            -- Extract upload date
            local uploadDate = gameHtml:match('datetime="([^"]+)"')
            if uploadDate then
                uploadDate = uploadDate:match("(%d+/%d+/%d+)") or uploadDate
            else
                uploadDate = "Unknown"
            end

            local searchResult = {
                name = "[" .. repackSize .. "] " .. gameTitle,
                links = {},
                tooltip = "Size: " .. repackSize .. " | Version: " .. gameVersion .. " | Date: " .. uploadDate,
                ScriptName = "fitgirl"
            }

            -- Extract magnet links with simple pattern
            local magnetCount = 0
            for magnet in gameHtml:gmatch('href="(magnet:%?[^"]+)"') do
                magnetCount = magnetCount + 1
                local linkName = magnetCount == 1 and "Download" or "Download " .. magnetCount
                table.insert(searchResult.links, {
                    link = ensureMagnetHasName(sanitizeMagnet(magnet), gameTitle),
                    name = linkName,
                    addtodownloadlist = true
                })
            end

            if magnetCount > 0 then
                table.insert(results, searchResult)
            end
            communication.receiveSearchResults(results)
            ::continue::
        end


    end
    
    local expectedurl = ""
    local imagelink = ""
    local gamename = ""
    local function ondownloadclick(gamejson, downloadurl, scriptname)
        if scriptname == "fitgirl" then
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

    local function setupcompletedf(from, destination)
        local executables = file.listexecutables(destination)         -- Returns a vector

        -- Get the first executable (assuming executables[1] exists)
        if executables and #executables >= 1 then
            local firstExecutable = executables[1]

            local fullExecutablePath = destination .. "\\" .. firstExecutable
            local gameidl = GameLibrary.GetGameIdFromName(gamename)
            if gameidl == -1 then
                local imagePath = Download.DownloadImage(imagelink)
                GameLibrary.addGame(fullExecutablePath, imagePath, gamename, "")
                Notifications.push_success("FitGirl Script", "Game Successfully Installed!")
            else
                GameLibrary.changeGameinfo(gameidl, fullExecutablePath)
                Notifications.push_success("FitGirl Script", "Game Successfully Installed!")
            end
        else
            local executables2 = file.listexecutablesrecursive(destination)         -- Returns a vector
            if executables2 and #executables2 >= 1 then
                local firstExecutable = executables2[1]
                local gameidl = GameLibrary.GetGameIdFromName(gamename)
                if gameidl == -1 then
                    local imagePath = Download.DownloadImage(imagelink)
                    GameLibrary.addGame(firstExecutable, imagePath, gamename, "")
                    Notifications.push_success("FitGirl Script", "Game Successfully Installed!")
                else
                    GameLibrary.changeGameinfo(gameidl, firstExecutable)
                    Notifications.push_success("FitGirl Script", "Game Successfully Installed!")
                end
            end
        end
    end

    local function ondownloadcompleted(path, url)
        if expectedurl == url then
            -- Prepare game name for path
            local gamenametopath = gamename:gsub(":", "")
            path = path:gsub("\\", "/")

            -- Search for setup executables
            local executables = file.listexecutables(path)
            if #executables == 0 then
                Notifications.push_warning("FitGirl Script", "No executables found in download folder")
                return
            end

            -- Look for setup executable
            local setupFound = false
            for _, exe in ipairs(executables) do
                if exe:lower():find("setup") then
                    local setupPath = path .. "/" .. exe
                    exec(setupPath, 5000, "", true, "setup.tmp")
                    Notifications.push_success("FitGirl Script", "Setup.exe launched successfully!")
                    client.add_callback("on_setupcompleted", setupcompletedf)
                    setupFound = true
                    break
                end
            end

            if not setupFound then
                Notifications.push_warning("FitGirl Script", "No valid setup executable found")
            end
        end
    end

    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_scriptselected", scraper)
end













