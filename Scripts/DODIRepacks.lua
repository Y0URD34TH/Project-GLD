-- Project GLD Provider Script: DODIRepacks
local VERSION = "1.0.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/DODIRepacks.lua", VERSION)

local searchprovider = "dodi-repacks.site"
local BASE_URL = "https://dodi-repacks.site"
local version = client.GetVersionDouble()
local cf_cookie = nil
local expectedInstallTimeSeconds = 300
local currentMirrorQueue = {}
local originalDodiUrl = ""
local gamename = ""
local isspawning = false
local activeQueueIndex = 1
local activeBrowserID = nil
local searchBrowserID = nil
local watchdogTargetTime = 0
local isWatchdogActive = false
local isdownloadstarted = false
local HOST_UP4EVER    = "up-4ever.net"
local HOST_SWIFT      = "swiftuploads.com"
local HOST_FILEME     = "file-me.top"
local imagelink = ""
local expectedurl = ""
local defaultdir = "C:/Games"
local pathcheck = ""
local isSeedingEnabled = false
local pendingOrigin = ""
local pendingDir = ""
local isDodiInstalling = false
local lastProcessCheckTime = 0
local DYNAMIC_TRACKERS = ""
local configPath = file.get_parent_path(file.get_parent_path(client.GetScriptsPath())) .. "/Configs/Default.cfg"
local AD_BLACKLIST = {
    "zovo.ink", "d1owuvqs9tkert", "cloudfront.net", "googlesyndication", 
    "googletagmanager", "adblock", "popunder", "aliexpress", "obqj2.com",
    "clarity.ms", "click", "pop", "banner", "turnstile"
}
local session_headers = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15",
    ["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
    ["Accept-Language"] = "en-US,en;q=0.9"
}

-- ============================================================================
-- UTILITIES
-- ============================================================================
local function sanitize(str)
    if not str then return "" end
    return str:lower():gsub("[%s%p]", "")
end

local function fetchDynamicTrackers()
    if DYNAMIC_TRACKERS ~= "" then return DYNAMIC_TRACKERS end
    local trackerUrls = {
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt",
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best_ip.txt"
    }
    for i = 1, #trackerUrls do
        local content = http.get(trackerUrls[i], {})
        if content then
            -- Loop through every non-empty line in the text file
            for tracker in content:gmatch("[^\r\n]+") do
                DYNAMIC_TRACKERS = DYNAMIC_TRACKERS .. "&tr=" .. tracker
            end
        end
    end
    return DYNAMIC_TRACKERS
end

-- ============================================================================
-- PHASE 1: SEARCH LOGIC
-- ============================================================================
local function dodirepackssearch()
    settings.save()
    
    local getgamename = game.getgamename()
    if not getgamename or getgamename == "" then return end
    
    if not cf_cookie then
        Notifications.push_warning("DODI Repacks", "Bypassing Cloudflare protection, please wait...")
        http.CloudFlareSolver(BASE_URL)
        return
    end
    
    local encodedName = getgamename:gsub(" ", "+")
    local searchUrl = BASE_URL .. "/?s=" .. encodedName
    local htmlContent = http.get(searchUrl, session_headers)
    if not htmlContent or htmlContent == "" then
        Notifications.push_error("DODI Repacks", "Failed to retrieve search results. Token may be expired.")
        cf_cookie = nil
        return
    end
    local lowerHTML = htmlContent:lower()
    if lowerHTML:find("protected by cpguard", 1, true) or lowerHTML:find("cf-turnstile", 1, true) then
        Notifications.push_warning("DODI Repacks", "cPGuard firewall detected. Spawning browser to solve...")
        local bName = "DODISearchBypass_" .. tostring(os.time())
        local bObj = browser.CreateBrowser(bName, searchUrl)
        if bObj then
            searchBrowserID = bObj:GetID()
            browser.set_visible(true, bName)
        else
            communication.receiveSearchResults({}) -- Prevents the UI warning hang
        end
        return
    end

    Notifications.push_success("DODI Repacks", "Mr. Ghost's DODI Repacks Script loaded.")
    local doc = html.parse(htmlContent)
    local headings = doc:css("h2.entry-title a")
    
    local results = {}
    local cleanedQuery = sanitize(getgamename)
    
    for i = 1, #headings do
        local heading = headings[i]
        local name = heading:text()
        local link = heading:attr("href")
        
        if name and link then
            if name:match("^%d+%-") then
                
                local isMatch = true
                for word in getgamename:gmatch("%S+") do
                    local cleanedWord = sanitize(word)
                    local cleanedName = sanitize(name)
                    if not cleanedName:find(cleanedWord, 1, true) then
                        isMatch = false
                        break
                    end
                end
                
                if isMatch then
                    local extractedSize = name:match("([%d%.]+%s*[Gg][Bb])")
                    
                    if not extractedSize then
                        local pageHtml = http.get(link, session_headers)
                        
                        if pageHtml and pageHtml ~= "" then
                            local sizeMatch = pageHtml:match("[Rr]epack%s+[Ss]ize.-([%d%.]+%s*[Gg][Bb])")
                            if sizeMatch then extractedSize = sizeMatch end
                        end
                    end
                    
                    local displayName = name
                    if extractedSize then
                        local normalizedSize = extractedSize:upper():gsub("%s+", "")
                        displayName = "[" .. normalizedSize .. "] " .. name
                    end
                    
                    local tooltip = "Platform: PC\nSource: DODI Repacks\nPost URL: " .. link
                    
                    local searchResult = {
                        name = displayName,
                        links = {},
                        tooltip = tooltip,
                        ScriptName = "DODIRepacks",
                    }
                    
                    table.insert(searchResult.links, {
                        name = "Download",
                        link = link,
                        addtodownloadlist = true
                    })
                    
                    table.insert(results, searchResult)
                end
            end
        end
    end
    
    if #results > 0 then
        communication.receiveSearchResults(results)
    else
        Notifications.push_error("DODI Repacks", "No matching games found.")
    end
end

-- ============================================================================
-- PHASE 2: DOWNLOAD ENGINE
-- ============================================================================
local function cleanBrowserContext()
    isWatchdogActive = false
    local activeBrowser = browser.GetBrowserByID(activeBrowserID)
    if activeBrowser then activeBrowser:CloseBrowser() end
    activeBrowserID = nil
end

local function processNextMirror()
    cleanBrowserContext()
    if activeQueueIndex > #currentMirrorQueue then
        Notifications.push_error("DODI Repacks", "All available mirrors failed.")
	isspawning = false
	if originalDodiUrl and originalDodiUrl ~= "" then
            Download.SetHistoryUrl(originalDodiUrl, originalDodiUrl)
        end
        return
    end
    local nextTarget = currentMirrorQueue[activeQueueIndex]
    local bName = "DODI_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
    local bObj = browser.CreateBrowser(bName, nextTarget)
    if bObj then
        activeBrowserID = bObj:GetID()
        browser.set_visible(false, bName)
	browser.DisableCaptchaDetection(bName)
	watchdogTargetTime = utils.GetTimeUnix() + 25
        isWatchdogActive = true
    else
	isspawning = false
        activeQueueIndex = activeQueueIndex + 1
        processNextMirror()
        return
    end
end

function ondownloadclick(gamejson, url, scriptname)
    if scriptname ~= "DODIRepacks" then return end
    if isdownloadstarted then 
	isdownloadstarted = false
	return 
    end
    if isspawning then return end
    isspawning = true
    originalDodiUrl = url
    local success, jsonResults = pcall(JsonWrapper.parse, gamejson)
    if not success or not jsonResults then return end
    local coverImageUrl = nil
    if jsonResults["cover"] and jsonResults["cover"]["url"] then
        coverImageUrl = jsonResults["cover"]["url"]
    elseif jsonResults.coverurl then
        coverImageUrl = jsonResults.coverurl
    end
    if coverImageUrl and coverImageUrl:sub(1, 2) == "//" then
        coverImageUrl = "https:" .. coverImageUrl
    end
    if coverImageUrl then
        coverImageUrl = coverImageUrl:gsub("t_thumb", "t_cover_big")
    end
    gamename = jsonResults.name or ""
    imagelink = coverImageUrl or ""
    local targetUrl = url
    local htmlContent = http.get(targetUrl, session_headers)
    if not htmlContent or htmlContent == "" then return end
    local lowerHtml = htmlContent:lower()
    local installTimePos = lowerHtml:find("install time", 1, true)
    if installTimePos then
	local extractedMax = 0
	local multiplier = 0
        local chunk = lowerHtml:sub(installTimePos, installTimePos + 120)
        chunk = chunk:gsub("&#%d+;", "-") 
        chunk = chunk:gsub("&nbsp;", " ") 
        chunk = chunk:gsub("<[^>]+>", " ")
        chunk = chunk:match("(%d+.-mins?)") or 
		chunk:match("(%d+.-hours?)") or 
		chunk:match("(%d+.-hrs?)")
	if chunk:find("hour") or chunk:find("hr") then
            multiplier = 3600
        elseif chunk:find("min") then
            multiplier = 60
        end
	for num in chunk:gmatch("%d+%.?%d*") do
            extractedMax = tonumber(num) * multiplier
            if extractedMax and extractedMax > expectedInstallTimeSeconds then
                expectedInstallTimeSeconds = extractedMax
            end
	    extractedMax = 0
        end
    end
    local doc = html.parse(htmlContent)
    local foundMirrors = {}
    local searchIndex = 1
    while true do
        local startPos = lowerHtml:find("torrent", searchIndex, true)
        if not startPos then break end
        local endPos = lowerHtml:find("</p>", startPos, true)
        if not endPos then endPos = #lowerHtml end
        local chunk = htmlContent:sub(startPos, endPos)
        local anyLinkFoundInChunk = false
        for link in chunk:gmatch('href=["\'](http.-)["\']') do
            anyLinkFoundInChunk = true
            local lowerLink = link:lower()
            if lowerLink:find(HOST_SWIFT, 1, true) or 
               lowerLink:find(HOST_FILEME, 1, true) or 
               lowerLink:find(HOST_UP4EVER, 1, true) then
                table.insert(foundMirrors, link)
            end
        end
        if anyLinkFoundInChunk then
            break
        end
        searchIndex = endPos
    end
    if #foundMirrors == 0 then
        isspawning = false
        Notifications.push_error("DODI Repacks", "No torrent download links extracted from page layout.")
	if originalDodiUrl and originalDodiUrl ~= "" then
            Download.SetHistoryUrl(originalDodiUrl, originalDodiUrl)
        end
        return 
    end
    table.sort(foundMirrors, function(a, b)
        local getWeight = function(url)
            local lowerUrl = url:lower()
            if lowerUrl:find(HOST_FILEME, 1, true) then return 1 end
            if lowerUrl:find(HOST_SWIFT, 1, true) then return 2 end
            if lowerUrl:find(HOST_UP4EVER, 1, true) then return 3 end
            return 5
        end
        return getWeight(a) < getWeight(b)
    end)
    currentMirrorQueue = foundMirrors
    activeQueueIndex = 1
    processNextMirror()
end

function onbeforedownload(url)
    local safe_url = tostring(url)
    if safe_url:find("dodi-repacks.site", 1, true) then
	Notifications.push_warning("DODI Repacks", "Download will start automatically in 15-20 seconds.")
        return "cancel", nil, nil
    end
    return nil, nil, nil
end

function onbrowserbeforeresourceload(browserID, url, method, referrer, resourceType)
    if browserID ~= activeBrowserID then return end
    local lowerUrl = url:lower()
    for i = 1, #AD_BLACKLIST do
        if lowerUrl:find(AD_BLACKLIST[i], 1, true) then return "block" end
    end
end

function onbrowserloaded(browserID)
    if browserID == searchBrowserID then
        local activeBrowser = browser.GetBrowserByID(browserID)
        if not activeBrowser then return end
        local url = activeBrowser:BrowserUrl() or ""
        local pageTitle = (activeBrowser:GetPageTitle() or ""):lower()
        if url:match("^https?://dodi%-repacks%.site") and not url:find("recaptcha.cloud", 1, true) then
            Notifications.push_success("DODI Repacks", "Firewall bypassed successfully! Resuming search...")
            activeBrowser:CloseBrowser()
            searchBrowserID = nil
            dodirepackssearch()
        end
        return
    end
    if browserID ~= activeBrowserID then return end
    local activeBrowser = browser.GetBrowserByID(browserID)
    if not activeBrowser then return end
    activeBrowser:GetBrowserSource(function(pageSource)
        if not pageSource or pageSource == "" then return end
        local lowerSource = pageSource:lower()
        local pageTitle = (activeBrowser:GetPageTitle() or ""):lower()
        if lowerSource:find("file not found", 1, true) then
	    watchdogTargetTime = 0
            return
        end
        if pageTitle:find("just a moment", 1, true) or pageTitle:find("cloudflare", 1, true) or lowerSource:find("cf-challenge", 1, true) then
	    Notifications.push_warning("DODI Repacks", "Bypassing Cloudflare protection, please wait...")
            browser.set_visible(true, activeBrowser.name)
	    isWatchdogActive = false
            return
     	end
        local url = activeBrowser:BrowserUrl() or ""
        browser.set_visible(false, activeBrowser.name)

	if url:find(HOST_FILEME, 1, true) then
            activeBrowser:ExecuteJavaScriptOnMainFrame("if(document.forms['F1']) { document.forms['F1'].submit(); } else { $('.file-download-btnn').click(); }")
	
        elseif url:find(HOST_SWIFT, 1, true) then

            local hybridBypassJS = [[
                (function() {
    		    let attempts = 0;
    		    let watcher = setInterval(function() {
			attempts++;

        		let token = document.querySelector('meta[name="csrf-token"]')?.content;
        		if (!token) {
            		    let tokenInput = document.querySelector('input[name="_token"]');
            		    if (tokenInput) token = tokenInput.value;
        		}
        
        		if (!token) {
            		    if (attempts % 5 === 0);
            		    return;
        		}

        		let step1Input = document.querySelector('input[name="p"][value="down_1"]');
        		let step2Form = document.getElementById('down_2Form');
        		let anchors = document.querySelectorAll('a');
        		let foundFinalButton = false;
        		let finalButtonElement = null;

        		for (let i = 0; i < anchors.length; i++) {
            		    let text = anchors[i].innerText.toLowerCase();
            		    if (text.includes('click here to download') || text.includes('download file')) {
                		foundFinalButton = true;
                		finalButtonElement = anchors[i];
                		break;
            		    }
        		}

        		if (step1Input && step1Input.form) {
            		    clearInterval(watcher);
            		    triggerGhostSubmit(token, 'down_1');
        		} 
        		else if (step2Form) {
            		    clearInterval(watcher);
            		    triggerGhostSubmit(token, 'down_2');
        		} 
        		else if (foundFinalButton) {
            		    clearInterval(watcher);
            		    console.log("EXTEND_WATCHDOG_TIMER");
            		    finalButtonElement.click();
        		}
        		else {
            		    if (attempts > 30) {
                		clearInterval(watcher);
                		console.log("WARN: Landed on a page with no recognizable download structures.");
            		    }
        		}
    		    }, 500);

    		    function triggerGhostSubmit(token, stepValue) {
        		let cleanForm = document.createElement('form');
        		cleanForm.method = 'POST';
        		cleanForm.action = window.location.href;
        		cleanForm.innerHTML = `
            		    <input type="hidden" name="_token" value="${token}">
            		    <input type="hidden" name="p" value="${stepValue}">
            		    <input type="hidden" name="method" value="free">
        		`;
        		document.body.appendChild(cleanForm);
        		cleanForm.submit();
    		    }
		})();
            ]]
            activeBrowser:ExecuteJavaScriptOnMainFrame(hybridBypassJS)
        
	elseif url:find(HOST_UP4EVER, 1, true) then

            local up4everBypassJS = [[
                (function() {
                    if (document.getElementById('gld-up4ever-guard')) return;
		    let guard = document.createElement('div');
		    guard.id = 'gld-up4ever-guard';
		    guard.style.display = 'none';
		    document.body.appendChild(guard);

                    let attempts = 0;
                    let captchaShown = false;
                    let watcher = setInterval(function() {
                        attempts++;
                        
                        if (attempts >= 180) {
                            console.log("WARN: Landed on a page with no recognizable download structures.");
                            clearInterval(watcher);
                            return;
                        }

                        let finalBtn = document.getElementById('downLoadLinkButton');
                        if (finalBtn) {
                            clearInterval(watcher);
                            let targetUrl = finalBtn.getAttribute('data-target');
                            if (targetUrl) window.location.href = targetUrl;
                            return;
                        }

                        let captchaBtn = document.getElementById('downloadbtn');
                        if (captchaBtn) {
                            if (attempts % 10 === 0) console.log("EXTEND_WATCHDOG_TIMER");
                            if (!captchaShown) {
                                console.log("UP4EVER_SHOW_CAPTCHA");
                                captchaShown = true;
                            }
                            let recaptchaResponse = document.getElementById('g-recaptcha-response');
                            let isCaptchaSolved = recaptchaResponse && recaptchaResponse.value.trim() !== "";
                            if (isCaptchaSolved) {
                                console.log("UP4EVER_HIDE_BROWSER");
                                clearInterval(watcher);
                                let idInput = document.querySelector('input[name="id"]');
                                let randInput = document.querySelector('input[name="rand"]');
                                let cleanForm = document.createElement('form');
                                cleanForm.method = 'POST';
                                cleanForm.action = window.location.href;
                                cleanForm.innerHTML = `
                                    <input type="hidden" name="op" value="download2">
                                    <input type="hidden" name="id" value="${idInput ? idInput.value : ''}">
                                    <input type="hidden" name="rand" value="${randInput ? randInput.value : ''}">
                                    <input type="hidden" name="method_free" value="Free Download">
                                    <textarea name="g-recaptcha-response" style="display:none;">${recaptchaResponse.value}</textarea>
                                `;
                                document.body.appendChild(cleanForm);
                                cleanForm.submit();
                            }
                            return;
                        }

                        let freeDownloadBtn = document.querySelector('input[name="method_free"]');
                        let opInput = document.querySelector('input[name="op"][value="download1"]');
                        if (freeDownloadBtn && opInput) {
                            clearInterval(watcher);
                            let idInput = document.querySelector('input[name="id"]');
                            let cleanForm = document.createElement('form');
                            cleanForm.method = 'POST';
                            cleanForm.action = window.location.href;
                            cleanForm.innerHTML = `
                                <input type="hidden" name="op" value="download1">
                                <input type="hidden" name="id" value="${idInput ? idInput.value : ''}">
                                <input type="hidden" name="method_free" value="Free Download">
                            `;
                            document.body.appendChild(cleanForm);
                            cleanForm.submit();
                            return;
                        }
                    }, 500);
                })();
            ]]
            activeBrowser:ExecuteJavaScriptOnMainFrame(up4everBypassJS)

        end
    end)
end

function onbrowserbeforedownload(browserID, downloadUrl, filename, size)
    if browserID ~= activeBrowserID then return end
    local lower_url = tostring(downloadUrl):lower()
    if lower_url:find("%.torrent") then
	if originalDodiUrl and originalDodiUrl ~= "" then
       	    Download.SetHistoryUrl(downloadUrl, originalDodiUrl)
        end
        local torrent_content = http.get(tostring(downloadUrl), {})
        if torrent_content and torrent_content ~= "" then
            local magnet = Download.TorrentContentToMagnet(torrent_content)
            if magnet and magnet ~= "" then
		local bestTrackers = fetchDynamicTrackers()
                magnet = magnet .. bestTrackers
		expectedurl = magnet
                Download.DownloadFile(magnet)
		isdownloadstarted = true
            end
        end
    end
    cleanBrowserContext()
    isspawning = false
    return originalDodiUrl
end

-- ============================================================================
-- PHASE 3: INSTALLATION LOGIC
-- ============================================================================
local function ondownloadcompleted(path, url)
    local installAfter = menu.get_bool("Install After Download DODI Repacks")
    if not installAfter then return end
    if expectedurl == url then
	Notifications.push_success("DODI Repacks", "Game Successfully Downloaded! Initiating Installation. Please wait...")
	path = path:gsub("\\", "/")
	local gamenametopath = gamename:gsub(":", "")
        defaultdir = menu.get_text("DODI Repacks Dir") .. "/" .. gamenametopath
	local exes = file.listexecutables(path)
        local setupExeName = ""
        local setupExePath = ""
	if exes and #exes > 0 then
            for i = 1, #exes do
                local currentExe = exes[i]
                local lowerExe = currentExe:lower()
                if lowerExe:find("setup") and not lowerExe:find("unins") then
                    setupExeName = currentExe
                    setupExePath = path .. "/" .. setupExeName
                    break
                end
            end
        end
	if setupExeName ~= "" and setupExePath ~= "" then
            local commandLine = '/DIR="' .. defaultdir .. '" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART'
            local ghostSetupPath = path .. "/" .. "Setup_GLD_Unlocked.exe"
	    pathcheck = ghostSetupPath:gsub("\\", "/")
	    file.copy_file(setupExePath, ghostSetupPath)
            sleep(500)
            file.exec(ghostSetupPath, 2000, commandLine, flase, "")
            pendingOrigin = ghostSetupPath
            pendingDir = defaultdir
            isDodiInstalling = true
            lastProcessCheckTime = utils.GetTimeUnix() + expectedInstallTimeSeconds
            Notifications.push("DODI Repacks", "Installer launched! Press 'UP' arrow. Script will automatically complete when you close the installer.")
        end
    end
end

local function onsetupcompleted(origin, path)
    local installAfter = menu.get_bool("Install After Download DODI Repacks")
    if not installAfter then return end
    local cleanOrigin = origin:gsub("\\", "/")
    if pathcheck == cleanOrigin then
        gldconsole.print("COMPLETE ENTER: Installation verified.")
        local installDir = path:gsub("\\", "/")
        local targetExe = ""
        local exes = file.listexecutablesrecursive(installDir)
        local validExes = {}
        local blacklist = {"unins", "redist", "crash", "dxweb", "vc_redist", "dotnet", "setup", "helper", "uninstall"}
        if exes and #exes > 0 then
            for i = 1, #exes do
                local currentExe = exes[i]
                local lowerExe = currentExe:lower()
                local isValid = true
                for j = 1, #blacklist do
                    if lowerExe:find(blacklist[j]) then
                        isValid = false
                        break
                    end
                end
                if isValid then
                    table.insert(validExes, currentExe)
                end
            end
        end
        if #validExes > 0 then
            targetExe = validExes[1]
            local gameNameLower = gamename:lower():gsub("[%s%p]", "")
            for i = 1, #validExes do
                local exe = validExes[i]
                local lowerExe = exe:lower()
                if lowerExe:find(gameNameLower) or lowerExe:find("shipping") or lowerExe:find("win64") then
                    targetExe = exe
                    break
                end
            end
        end
        if targetExe ~= "" then
            targetExe = targetExe:gsub("/", "\\")
            local gameidl = GameLibrary.GetGameIdFromName(gamename)
            local imagePath = ""
            if imagelink and imagelink ~= "" then
                imagePath = Download.DownloadImage(imagelink)
            end
            if gameidl == -1 then
                GameLibrary.addGame(targetExe, imagePath, gamename, "")
            else
                GameLibrary.changeGameinfo(gameidl, targetExe)
            end
            Notifications.push_success("DODI Repacks", "Game Successfully Installed and Added to Library!")
        else
            Notifications.push_error("DODI Repacks", "Installed, but could not automatically locate the game executable.")
        end
        if not isSeedingEnabled then
            local deleteAfter = menu.get_bool("Delete After Installation DODI Repacks")
            if deleteAfter then
                local downloadFolder = file.get_parent_path(cleanOrigin)
                file.delete(downloadFolder)
            end
        end
        file.delete(cleanOrigin)
        settings.save()
    end
end

-- ============================================================================
-- SUPPORT FUNCTIONS
-- ============================================================================
local function oncfdone(cookie, url)
    if url:find("dodi-repacks.site", 1, true) then
	cf_cookie = cookie
	session_headers["Cookie"] = "cf_clearance=" .. tostring(cf_cookie)
	dodirepackssearch()
    end
end

local function onbrowserconsolemessage(browserID, message)
    gldconsole.print("[JS BROWSER LOG] " .. tostring(message))
    if browserID == activeBrowserID and type(message) == "string" then
	if message == "UP4EVER_SHOW_CAPTCHA" then
            local activeBrowser = browser.GetBrowserByID(browserID)
            if activeBrowser then browser.set_visible(true, activeBrowser.name) end
        elseif message == "UP4EVER_HIDE_BROWSER" then
            local activeBrowser = browser.GetBrowserByID(browserID)
            if activeBrowser then browser.set_visible(false, activeBrowser.name) end
	elseif message == "EXTEND_WATCHDOG_TIMER" then
	    watchdogTargetTime = utils.GetTimeUnix() + 25
	elseif message:find("WARN: Landed on a page with no recognizable download structures.", 1, true) then
	    activeQueueIndex = activeQueueIndex + 1
	    processNextMirror()
	end
    end
end

local function onpresent()
    if isWatchdogActive and utils.GetTimeUnix() >= watchdogTargetTime then
	isWatchdogActive = false
	activeQueueIndex = activeQueueIndex + 1
	processNextMirror()
    end
    if isDodiInstalling and pendingOrigin ~= "" then
	local currentTime = utils.GetTimeUnix()
	if currentTime >= lastProcessCheckTime + 30 then
	    lastProcessCheckTime = currentTime
	    local checkCmd = 'tasklist /FI "IMAGENAME eq Setup_GLD_Unlocked.exe"'
	    local output = system_output(checkCmd)
	    if output and not output:find("Setup_GLD_Unlocked.exe") then
		isDodiInstalling = false
		onsetupcompleted(pendingOrigin, pendingDir)
		pendingOrigin = ""
		pendingDir = ""
	    end
	end
    end
end

-- ============================================================================
-- INITIALIZATION & EVENT REGISTRATION
-- ============================================================================
if version < 7.00 then
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "DODI Repacks Provider Active")
    menu.add_text("=== DODI Repacks ===")
    menu.add_input_text("DODI Repacks Dir")
    menu.set_text("DODI Repacks Dir", defaultdir)
    menu.add_check_box("Install After Download DODI Repacks")
    if file.exists(configPath) then
        local configData = file.read(configPath)
    	if configData and configData:find('"seedafterdownload":%s*true') then
            isSeedingEnabled = true
    	end
    end
    if not isSeedingEnabled then
    	menu.add_check_box("Delete After Installation DODI Repacks")
    end
    menu.add_text("================")
    settings.load()
    
    client.add_callback("on_scriptselected", dodirepackssearch)
    client.add_callback("on_downloadclick", ondownloadclick)
    client.add_callback("on_beforedownload", onbeforedownload)
    client.add_callback("on_browserbeforeresourceload", onbrowserbeforeresourceload)
    client.add_callback("on_browserloaded", onbrowserloaded)
    client.add_callback("on_browserbeforedownload", onbrowserbeforedownload)
    client.add_callback("on_downloadcompleted", ondownloadcompleted)
    client.add_callback("on_setupcompleted", onsetupcompleted)
    client.add_callback("on_cfdone", oncfdone)
    client.add_callback("on_browserconsolemessage", onbrowserconsolemessage)
    client.add_callback("on_present", onpresent)
end