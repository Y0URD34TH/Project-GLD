local VERSION = "1.0.1"
client.auto_script_update(
    "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/vikingfile.com%20%5Bresolver%5D.lua",
    VERSION
)

-- Script configuration
local SCRIPT_NAME = "VikingFile Resolver"
local VIKINGFILE_PATTERNS = {"vikingfile%.com", "vik1ngfile%.site", "vikingf1le%.us%.to"}

-- State tracking for multiple downloads
local active_resolvers = {}
local resolver_counter = 0

-- Helper function to check if URL is from VikingFile
local function is_vikingfile_url(url)
    if not url then return false end
    local l = url:lower()
    for _, pattern in ipairs(VIKINGFILE_PATTERNS) do
        if string.match(l, pattern) then
            return true
        end
    end
    return false
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

-- Helper function to inject auto-click script
local function inject_auto_click_script(browser_id)
    local js_code = [[
        (function() {
            if (window.vikingfileMonitorActive) {
                console.log('VikingFile: Monitor already active');
                return;
            }
            window.vikingfileMonitorActive = true;
            
            console.log('VikingFile: Starting download button monitor');
            
            var buttonClicked = false;
            var checkCount = 0;
            
            function tryClickDownload() {
                if (buttonClicked) return true;
                
                checkCount++;
                
                var btn = document.getElementById('download-link');
                if (!btn) {
                    console.log('VikingFile: Button not found (check #' + checkCount + ')');
                    return false;
                }
                
                var hasHref = btn.href && btn.href.startsWith('http');
                var isHidden = btn.classList.contains('hidden');
                var isVisible = window.getComputedStyle(btn).display !== 'none';
                
                console.log('VikingFile: Button status - hasHref: ' + hasHref + ', isHidden: ' + isHidden + ', isVisible: ' + isVisible);
                
                if (hasHref && !isHidden && isVisible) {
                    console.log('VikingFile: Clicking download button!');
                    var clickEvent = new MouseEvent('click', {bubbles: true, cancelable: true, view: window});
                    btn.dispatchEvent(clickEvent);
                    btn.click();
                    buttonClicked = true;
                    console.log('VIKINGFILE_BUTTON_CLICKED');
                    return true;
                }
                
                return false;
            }
            
            // Monitor every 500ms
            var monitorInterval = setInterval(function() {
                tryClickDownload();
                if (buttonClicked) {
                    console.log('VikingFile: Stopping monitor - button clicked');
                    clearInterval(monitorInterval);
                }
            }, 500);
            
            // Watch for DOM changes
            var observer = new MutationObserver(function() {
                setTimeout(tryClickDownload, 100);
            });
            
            observer.observe(document.body, {
                childList: true,
                subtree: true,
                attributes: true,
                attributeFilter: ['class', 'style', 'href']
            });
            
            // Initial checks
            setTimeout(function() {
                console.log('VikingFile: Initial check (1s)');
                tryClickDownload();
            }, 1000);
            
            setTimeout(function() {
                console.log('VikingFile: Secondary check (3s)');
                tryClickDownload();
            }, 3000);
            
            console.log('VikingFile: Monitor initialized');
        })();
    ]]
    
    local browser_obj = browser.GetBrowserByID(browser_id)
    if browser_obj and browser_obj:HasBrowser() then
        browser_obj:ExecuteJavaScriptOnMainFrame(js_code)
        gldconsole.print("[" .. SCRIPT_NAME .. "] Auto-click monitor injected for browser ID: " .. browser_id)
    else
        gldconsole.print("[" .. SCRIPT_NAME .. "] ERROR: Cannot inject - browser not ready")
    end
end

-- Helper function to cleanup resolver
local function cleanup_resolver(resolver_id)
    local resolver = active_resolvers[resolver_id]
    if resolver then
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Cleaning up resolver...")
        
        if resolver.browser_id then
            local browser_obj = browser.GetBrowserByID(resolver.browser_id)
            if browser_obj and browser_obj:HasBrowser() then
                browser_obj:CloseBrowser()
                gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Browser closed")
            end
        end
        
        active_resolvers[resolver_id] = nil
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Resolver removed")
    end
end

-- Callback: Before download starts (resolver)
client.add_callback("on_beforedownload", function(url)
    if is_vikingfile_url(url) then
        gldconsole.print("[" .. SCRIPT_NAME .. "] ========================================")
        gldconsole.print("[" .. SCRIPT_NAME .. "] VikingFile URL detected!")
        gldconsole.print("[" .. SCRIPT_NAME .. "] URL: " .. url)
        
        -- Create new resolver instance
        resolver_counter = resolver_counter + 1
        local resolver_id = "vikingfile_" .. resolver_counter
        local browser_name = "vikingfile_resolver_" .. resolver_counter
        
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
            captcha_solved = false,
            created_time = os.time()
        }
        
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver_id .. "] Resolver created successfully")
        gldconsole.print("[" .. SCRIPT_NAME .. "] Active resolvers: " .. table_count(active_resolvers))
        gldconsole.print("[" .. SCRIPT_NAME .. "] ========================================")
        
        Notifications.push("VikingFile Resolver", "Starting resolver #" .. resolver_counter)
        
        -- Cancel the original download
        return "cancel", nil, nil
    end
    
    return nil, nil, nil
end)

-- Callback: When browser page loads
client.add_callback("on_browserloaded", function(browser_id)
    local resolver = get_resolver_by_browser_id(browser_id)
    if not resolver then return end
    
    local browser_obj = browser.GetBrowserByID(browser_id)
    if not browser_obj or not browser_obj:HasBrowser() then
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] ERROR: Browser not available")
        return
    end
    
    local current_url = browser_obj:BrowserUrl()
    gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Page loaded: " .. current_url)
    
    -- Check if we're on a VikingFile page with /f/ in URL
    if is_vikingfile_url(current_url) and string.match(current_url:lower(), "/f/") then
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] VikingFile download page detected")
        
        -- If captcha already solved, inject immediately
        if resolver.captcha_solved then
            gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Captcha already solved, injecting script...")
            sleep(1000)
            inject_auto_click_script(browser_id)
        else
            gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Waiting for captcha to be solved...")
            Notifications.push("VikingFile", "Waiting for captcha #" .. string.match(resolver.id, "%d+"))
        end
    end
end)

-- Callback: When captcha is solved
client.add_callback("on_captchasolved", function(browser_id)
    local resolver = get_resolver_by_browser_id(browser_id)
    if not resolver then return end
    
    local browser_obj = browser.GetBrowserByID(browser_id)
    if not browser_obj or not browser_obj:HasBrowser() then return end
    
    local current_url = browser_obj:BrowserUrl()
    
    -- Check if this is a VikingFile page
    if not is_vikingfile_url(current_url) then return end
    
    gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Captcha SOLVED!")
    resolver.captcha_solved = true
    
    -- Check if we're on the download page
    if string.match(current_url:lower(), "/f/") then
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] On download page, injecting auto-click script...")
        Notifications.push_success("VikingFile", "Captcha solved #" .. string.match(resolver.id, "%d+"))
        
        sleep(1000)
        inject_auto_click_script(browser_id)
    else
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Not on download page yet")
    end
end)

-- Callback: Monitor console messages
client.add_callback("on_browserconsolemessage", function(browser_id, message)
    local resolver = get_resolver_by_browser_id(browser_id)
    if not resolver then return end
    
    -- Check for button clicked
    if string.match(message, "VIKINGFILE_BUTTON_CLICKED") then
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Download button CLICKED!")
        Notifications.push_success("VikingFile", "Download starting #" .. string.match(resolver.id, "%d+"))
        return
    end
    
    -- Log VikingFile messages
    if string.match(message, "VikingFile:") then
        gldconsole.print("[" .. resolver.id .. "] " .. message)
    end
end)

-- Callback: When browser initiates download (download added to manager)
client.add_callback("on_browserbeforedownload", function(browser_id, url, suggested_name, size)
    local resolver = get_resolver_by_browser_id(browser_id)
    if resolver then
        local download_num = string.match(resolver.id, "%d+")
        
        gldconsole.print("[" .. SCRIPT_NAME .. "] ========================================")
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] DOWNLOAD ADDED TO MANAGER!")
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] File: " .. suggested_name)
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Size: " .. size .. " bytes")
        
        -- Set history URL for resume capability
        Download.SetHistoryUrl(url, resolver.original_url)
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] History URL set")
        
        Notifications.push_success("VikingFile Resolver", "Download #" .. download_num .. " added!")
        
        local original_url = resolver.original_url
        
        -- Cleanup this resolver immediately (download is now in download manager)
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. resolver.id .. "] Download added to manager, cleaning up resolver now...")
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
gldconsole.print("[" .. SCRIPT_NAME .. "] Supports: vikingfile.com, vik1ngfile.site, vikingf1le.us.to")
gldconsole.print("[" .. SCRIPT_NAME .. "] Browsers run in background")
gldconsole.print("[" .. SCRIPT_NAME .. "] Resolvers cleanup immediately when download is added")
gldconsole.print("========================================")

