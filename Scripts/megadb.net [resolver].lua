local VERSION = "1.1.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/megadb.net%20%5Bresolver%5D.lua", VERSION)
-- Script configuration
local SCRIPT_NAME = "MegaDB Resolver"
local MEGADB_PATTERN = "megadb%.net/"

-- State tracking for multiple downloads
local active_resolvers = {} -- Table to track multiple active resolvers
local resolver_counter = 0 -- Counter for unique resolver IDs

-- Helper function to check if URL is from MegaDB
local function is_megadb_url(url)
    return string.match(url, MEGADB_PATTERN) ~= nil
end

-- Helper function to get resolver by browser ID
local function get_resolver_by_browser_id(browser_id)
    for _, resolver in pairs(active_resolvers) do
        if resolver.browser_id == browser_id then
            return resolver
        end
    end
    return nil
end

-- Helper function to count table entries
local function table_count(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- Helper function to inject countdown monitor and auto-click script
local function inject_download_script(browser_id)
    local js_code = [[
        (function() {
            // Prevent multiple injections
            if (window.megadbMonitorActive) {
                console.log('MegaDB: Monitor already active, skipping injection');
                return;
            }
            window.megadbMonitorActive = true;
            
            console.log('MegaDB: Starting smart countdown monitor');
            
            var downloadClicked = false;
            var lastNotifiedSecond = -1;
            
            // Check if captcha is solved
            function isCaptchaSolved() {
                var captchaResponse = document.getElementById('g-recaptcha-response');
                if (!captchaResponse) return false;
                return captchaResponse.value.length > 0;
            }
            
            // Get current countdown seconds
            function getCountdownSeconds() {
                var countdown = document.getElementById('countdown');
                if (!countdown) return -1;
                
                var secondsSpan = countdown.querySelector('.seconds');
                if (!secondsSpan) return -1;
                
                var seconds = parseInt(secondsSpan.textContent) || 0;
                return seconds;
            }
            
            // Check if countdown is finished
            function isCountdownFinished() {
                var countdown = document.getElementById('countdown');
                if (!countdown) return true;
                
                var style = window.getComputedStyle(countdown);
                if (style.visibility === 'hidden' || style.display === 'none') {
                    return true;
                }
                
                var seconds = getCountdownSeconds();
                return seconds <= 0;
            }
            
            // Check if button is enabled
            function isButtonEnabled() {
                var btn = document.getElementById('downloadbtn');
                if (!btn) {
                    var buttons = document.querySelectorAll('.downloadbtn, a.btn-success');
                    if (buttons.length > 0) btn = buttons[0];
                }
                if (!btn) return false;
                
                return !btn.disabled && !btn.hasAttribute('disabled') && !btn.classList.contains('disabled');
            }
            
            // Get download button
            function getDownloadButton() {
                var btn = document.getElementById('downloadbtn');
                if (btn) return btn;
                
                var buttons = document.querySelectorAll('.downloadbtn, a.btn-success, button.btn-success');
                if (buttons.length > 0) return buttons[0];
                
                return null;
            }
            
            // Attempt to click download
            function attemptClick() {
                if (downloadClicked) return true;
                
                var captchaSolved = isCaptchaSolved();
                var countdownFinished = isCountdownFinished();
                var buttonEnabled = isButtonEnabled();
                
                console.log('MegaDB: Status check - Captcha: ' + captchaSolved + ', Countdown: ' + countdownFinished + ', Button: ' + buttonEnabled);
                
                if (!captchaSolved) {
                    console.log('MegaDB: Waiting for captcha...');
                    return false;
                }
                
                if (!countdownFinished) {
                    var seconds = getCountdownSeconds();
                    console.log('MegaDB: Countdown active: ' + seconds + ' seconds');
                    return false;
                }
                
                if (!buttonEnabled) {
                    console.log('MegaDB: Button not enabled yet');
                    return false;
                }
                
                // All conditions met!
                var btn = getDownloadButton();
                if (btn) {
                    console.log('MegaDB: All conditions met - clicking download!');
                    btn.click();
                    downloadClicked = true;
                    console.log('MEGADB_DOWNLOAD_CLICKED');
                    return true;
                }
                
                console.log('MegaDB: Download button not found!');
                return false;
            }
            
            // Monitor countdown and notify Lua
            function monitorCountdown() {
                if (downloadClicked) return;
                
                var captchaSolved = isCaptchaSolved();
                var seconds = getCountdownSeconds();
                
                // Only notify of countdown if captcha is solved
                if (captchaSolved && seconds !== lastNotifiedSecond && seconds >= 0) {
                    console.log('MEGADB_COUNTDOWN:' + seconds);
                    lastNotifiedSecond = seconds;
                }
                
                // Try to click if ready
                attemptClick();
            }
            
            // Monitor every 500ms
            var monitorInterval = setInterval(function() {
                monitorCountdown();
                
                if (downloadClicked) {
                    console.log('MegaDB: Download clicked, stopping monitor');
                    clearInterval(monitorInterval);
                }
            }, 500);
            
            // Watch for DOM changes
            var observer = new MutationObserver(function() {
                setTimeout(monitorCountdown, 100);
            });
            
            observer.observe(document.body, {
                childList: true,
                subtree: true,
                attributes: true,
                attributeFilter: ['disabled', 'value', 'class', 'style']
            });
            
            // Initial check after delay
            setTimeout(function() {
                console.log('MegaDB: Initial status check');
                monitorCountdown();
            }, 1000);
            
            console.log('MegaDB: Monitor initialized successfully');
        })();
    ]]
    
    -- Get browser by ID
    local browser_obj = browser.GetBrowserByID(browser_id)
    if browser_obj and browser_obj:HasBrowser() then
        browser_obj:ExecuteJavaScriptOnMainFrame(js_code)
        gldconsole.print("[" .. SCRIPT_NAME .. "] Countdown monitor injected for browser ID: " .. browser_id)
    else
        gldconsole.print("[" .. SCRIPT_NAME .. "] Failed to inject script - browser not ready")
    end
end

-- Helper function to cleanup resolver
local function cleanup_resolver(resolver_id)
    local resolver = active_resolvers[resolver_id]
    if resolver then
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Cleaning up resolver...")
        
        -- Close the browser
        if resolver.browser_id then
            local browser_obj = browser.GetBrowserByID(resolver.browser_id)
            if browser_obj and browser_obj:HasBrowser() then
                browser_obj:CloseBrowser()
                gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Browser closed")
            end
        end
        
        -- Remove from active resolvers
        active_resolvers[resolver_id] = nil
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Resolver removed from active list")
    end
end

-- Callback: Before download starts (resolver)
client.add_callback("on_beforedownload", function(url)
    if is_megadb_url(url) then
        gldconsole.print("[" .. SCRIPT_NAME .. "] ========================================")
        gldconsole.print("[" .. SCRIPT_NAME .. "] MegaDB URL detected!")
        gldconsole.print("[" .. SCRIPT_NAME .. "] URL: " .. url)
        
        -- Create new resolver instance
        resolver_counter = resolver_counter + 1
        local resolver_id = "megadb_" .. resolver_counter
        local browser_name = "megadb_resolver_" .. resolver_counter
        
        gldconsole.print("[" .. SCRIPT_NAME .. "] Creating resolver [" .. resolver_id .. "]...")
        
        -- Create resolver browser
        local resolver_browser = browser.CreateBrowser(browser_name, url)
        if not resolver_browser then
            gldconsole.print("[" .. SCRIPT_NAME .. "] ERROR: Failed to create browser!")
            return "cancel", nil, nil
        end
        
        local browser_id = resolver_browser:GetID()
        gldconsole.print("[" .. SCRIPT_NAME .. "] Browser created with ID: " .. browser_id)
        
        -- Store resolver state
        active_resolvers[resolver_id] = {
            id = resolver_id,
            browser_name = browser_name,
            browser_id = browser_id,
            original_url = url,
            last_countdown = -1,
            captcha_solved = false,
            created_time = os.time(),
            page_loaded = false
        }
        
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver_id .. "] Resolver created successfully")
        gldconsole.print("[" .. SCRIPT_NAME .. "] Active resolvers: " .. table_count(active_resolvers))
        gldconsole.print("[" .. SCRIPT_NAME .. "] ========================================")
        
        Notifications.push("MegaDB Resolver", "Starting resolver #" .. resolver_counter)
        
        -- Cancel the original download
        return "cancel", nil, nil
    end
    
    -- Return nil to allow other downloads
    return nil, nil, nil
end)

-- Callback: When browser page loads
client.add_callback("on_browserloaded", function(browser_id)
    local resolver = get_resolver_by_browser_id(browser_id)
    if resolver then
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Browser page loaded event")
        
        local browser_obj = browser.GetBrowserByID(browser_id)
        if browser_obj and browser_obj:HasBrowser() then
            local current_url = browser_obj:BrowserUrl()
            gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Current URL: " .. current_url)
            
            if is_megadb_url(current_url) then
                resolver.page_loaded = true
                gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] MegaDB page confirmed")
                
                -- Wait for page to stabilize
                gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Waiting 2 seconds for page to stabilize...")
                sleep(2000)
                
                -- Inject countdown monitor
                gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Injecting monitor script...")
                inject_download_script(browser_id)
                
                Notifications.push("MegaDB Resolver", "Page loaded - waiting for captcha #" .. string.match(resolver.id, "%d+"))
            else
                gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Not a MegaDB URL, ignoring")
            end
        else
            gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] ERROR: Browser object not available")
        end
    end
end)

-- Callback: When captcha is detected
client.add_callback("on_captchadetected", function(browser_id)
    local resolver = get_resolver_by_browser_id(browser_id)
    if resolver then
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Captcha detected!")
        Notifications.push("MegaDB Resolver", "Captcha detected on download #" .. string.match(resolver.id, "%d+"))
    end
end)

-- Callback: When captcha is solved
client.add_callback("on_captchasolved", function(browser_id)
    local resolver = get_resolver_by_browser_id(browser_id)
    if resolver then
        resolver.captcha_solved = true
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Captcha SOLVED!")
        Notifications.push_success("MegaDB Resolver", "Captcha solved #" .. string.match(resolver.id, "%d+") .. " - monitoring countdown")
        
        -- Re-inject to ensure monitoring is active
        sleep(500)
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Re-injecting monitor script...")
        inject_download_script(browser_id)
    end
end)

-- Callback: Monitor console messages for countdown updates
client.add_callback("on_browserconsolemessage", function(browser_id, message)
    local resolver = get_resolver_by_browser_id(browser_id)
    if not resolver then return end
    
    -- Check for countdown updates
    local countdown_seconds = string.match(message, "MEGADB_COUNTDOWN:(%d+)")
    if countdown_seconds then
        local seconds = tonumber(countdown_seconds)
        
        -- Only notify if it's a new second (avoid spam)
        if seconds ~= resolver.last_countdown then
            local download_num = string.match(resolver.id, "%d+")
            gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Countdown: " .. seconds .. " seconds")
            
            if seconds > 0 and resolver.captcha_solved then
                Notifications.push("MegaDB", "Download #" .. download_num .. " in " .. seconds .. "s")
            elseif seconds <= 0 and resolver.captcha_solved then
                Notifications.push_success("MegaDB", "Clicking download #" .. download_num .. "!")
            end
            
            resolver.last_countdown = seconds
        end
        return
    end
    
    -- Check for download click
    if string.match(message, "MEGADB_DOWNLOAD_CLICKED") then
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Download button CLICKED!")
        return
    end
    
    -- Log MegaDB-related messages
    if string.match(message, "MegaDB:") then
        gldconsole.print("[" .. resolver.id .. "] " .. message)
    end
end)

-- Callback: When browser initiates download
client.add_callback("on_browserbeforedownload", function(browser_id, url, suggested_name, size)
    local resolver = get_resolver_by_browser_id(browser_id)
    if resolver then
        local download_num = string.match(resolver.id, "%d+")
        
        gldconsole.print("[" .. SCRIPT_NAME .. "] ========================================")
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] DOWNLOAD STARTING!")
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] File: " .. suggested_name)
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Size: " .. size .. " bytes")
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Download URL: " .. url)
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Original URL: " .. resolver.original_url)
        
        -- Set history URL for resume capability
        Download.SetHistoryUrl(url, resolver.original_url)
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] History URL set for resume support")
        
        Notifications.push_success("MegaDB Resolver", "Download #" .. download_num .. " started!")
        
        -- Store original URL for return
        local original_url = resolver.original_url
        
        -- Cleanup this resolver
        cleanup_resolver(resolver.id)
        
        gldconsole.print("[" .. SCRIPT_NAME .. "] Active resolvers remaining: " .. table_count(active_resolvers))
        gldconsole.print("[" .. SCRIPT_NAME .. "] ========================================")
        
        -- Return original URL for download history
        return original_url
    end
    
    return nil
end)

-- Initialize
gldconsole.print("========================================")
gldconsole.print("[" .. SCRIPT_NAME .. "] v" .. VERSION .. " LOADED")
gldconsole.print("[" .. SCRIPT_NAME .. "] Multi-download resolver ready")
gldconsole.print("[" .. SCRIPT_NAME .. "] Browsers will run in background")
gldconsole.print("========================================")



