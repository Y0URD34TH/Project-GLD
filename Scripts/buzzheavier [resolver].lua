local SCRIPT_NAME    = "buzzheavier_resolver"
local VERSION = "4.2"
client.auto_script_update(
    "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/buzzheavier%20%5Bresolver%5D.lua",
    VERSION
)
local USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:144.0) Gecko/20100101 Firefox/144.0"

-- Simple logging
local function log(msg)
    gldconsole.print("[BuzzResolver] " .. msg)
end

-- Check if URL belongs to supported domains
local function is_buzzheavier_url(url)
    local lower = url:lower()
    return lower:match("buzzheavier%.com/[%w%-]+") or
           lower:match("bzzhr%.co/[%w%-]+") or
           lower:match("fuckingfast%.co/[%w%-]+") or
           lower:match("fuckingfast%.net/[%w%-]+")
end

-- Check if URL is specifically fuckingfast
local function is_fuckingfast_url(url)
    local lower = url:lower()
    return lower:match("fuckingfast%.co/") or lower:match("fuckingfast%.net/")
end

-- Global table to track which URLs we are currently resolving via browser
local resolving_urls = {}
local ogurl = ""

-- Callback: Intercept download before it starts
local function on_beforedownload(url)
    ogurl = ""
    if not is_buzzheavier_url(url) then
        return nil -- not our host → proceed normally
    end

    log("Intercepted download attempt: " .. url)

    local browser_name = "buzz" .. url
    local main_browser = browser.CreateBrowser(browser_name, url)
    if not main_browser or not main_browser:HasBrowser() then
        log("ERROR: No main browser available")
        notifications.push_error("Resolver Error", "Cannot resolve - no browser instance")
        return nil
    end

    main_browser:ChangeBrowserURL(url)
    -- Mark this URL as being resolved via browser
    resolving_urls[url] = true

    -- Load the page in the main browser
    log("Loading page in GLD browser: " .. url)
    ogurl = url

    -- Cancel the original download attempt
    log("Cancelling original download - waiting for browser trigger")
    return "cancel"
end

-- Callback: Page finished loading in browser
local function on_browserloaded(browser_id)
    local br = browser.GetBrowserByID(browser_id)
    if not br or not br:HasBrowser() then
        log("on_browserloaded: invalid browser")
        return
    end

    local current_url = br:BrowserUrl()
    if not is_buzzheavier_url(current_url) then
        return -- not a buzzheavier page
    end

    if not resolving_urls[current_url] then
        log("Page loaded but not in resolving list: " .. current_url)
        return
    end

    resolving_urls[current_url] = nil  -- cleanup
    log("Page fully loaded - processing: " .. current_url)

    -- Different logic based on the host
    if is_fuckingfast_url(current_url) then
        -- FuckingFast specific logic
        local ff_js = [[
            (function() {
                console.log("[GLD Resolver] FuckingFast - Attempting to trigger download...");
                
                // Wait a moment for the page to fully initialize
                setTimeout(function() {
                    // Look for the download button with hx-post attribute
                    const downloadButton = document.querySelector('a[hx-post*="/go"]');
                    
                    if (downloadButton) {
                        console.log("[GLD Resolver] Found FuckingFast download button");
                        
                        // First click: opens ads (required by site)
                        console.log("[GLD Resolver] First click - opening ads...");
                        downloadButton.click();
                        
                        // Second click: starts download (after short delay for ad)
                        setTimeout(function() {
                            console.log("[GLD Resolver] Second click - starting download...");
                            downloadButton.click();
                        }, 1500); // 1.5 second delay for ad to open
                        
                    } else {
                        console.log("[GLD Resolver] Download button not found, trying alternative methods...");
                        
                        // Alternative: Direct HTMX POST request
                        const hxPostMatch = document.body.innerHTML.match(/hx-post="([^"]*\/go)"/);
                        if (hxPostMatch) {
                            const goUrl = hxPostMatch[1];
                            console.log("[GLD Resolver] Found go URL: " + goUrl);
                            
                            // Simulate HTMX request
                            fetch(goUrl, {
                                method: 'POST',
                                headers: {
                                    'HX-Request': 'true',
                                    'HX-Current-URL': window.location.href,
                                    'Content-Type': 'application/x-www-form-urlencoded',
                                    'Referer': window.location.href
                                }
                            })
                            .then(response => {
                                console.log("[GLD Resolver] Response status: " + response.status);
                                if (response.ok) {
                                    // Check for redirect
                                    const hxRedirect = response.headers.get('HX-Redirect');
                                    if (hxRedirect) {
                                        console.log("[GLD Resolver] Redirecting to: " + hxRedirect);
                                        window.location.href = hxRedirect;
                                    }
                                }
                            })
                            .catch(err => {
                                console.error("[GLD Resolver] Fetch error: " + err);
                            });
                        }
                    }
                }, 2000); // Wait 2 seconds for page to load
            })();
        ]]
        
        br:ExecuteJavaScriptOnMainFrame(ff_js)
        
    else
        -- Original Buzzheavier logic
        local trigger_js = [[
            (function() {
                console.log("[GLD Resolver] Attempting to start download...");

                const selectors = [
                    'a[hx-get*="/download"]',
                    'a.link-button',
                    'a.gay-button',
                    'button[hx-get*="/download"]',
                    '[hx-get*="/download"]',
                    '#download',
                    '[role="button"][hx-get]',
                    'a[href*="/download"]'
                ];

                let button = null;
                for (let sel of selectors) {
                    button = document.querySelector(sel);
                    if (button) {
                        console.log("[GLD Resolver] Found element with selector: " + sel);
                        break;
                    }
                }

                if (button) {
                    console.log("[GLD Resolver] Clicking download button...");
                    button.click();
                    return;
                }

                // Fallback: manual HTMX-like request
                console.log("[GLD Resolver] No button found - using fetch fallback");
                const downloadPath = '/download';
                fetch(window.location.origin + downloadPath, {
                    method: 'GET',
                    credentials: 'include',
                    headers: {
                        'HX-Request': 'true',
                        'HX-Current-URL': window.location.href,
                        'HX-Target': 'body',
                        'Referer': window.location.href,
                        'Accept': '*/*',
                        'User-Agent': ']] .. USER_AGENT .. [['
                    }
                })
                .then(response => {
                    const hxRedirect = response.headers.get('hx-redirect');
                    if (hxRedirect) {
                        console.log("[GLD Resolver] HX-Redirect found: " + hxRedirect);
                        let finalUrl = hxRedirect;
                        if (finalUrl.startsWith('/')) {
                            finalUrl = window.location.origin + finalUrl;
                        }
                        window.location.href = finalUrl;
                    } else {
                        console.error("[GLD Resolver] No hx-redirect header");
                    }
                })
                .catch(err => {
                    console.error("[GLD Resolver] Fetch error: " + err);
                });
            })();
        ]]
        
        br:ExecuteJavaScriptOnMainFrame(trigger_js)
    end
end

local function add_download_to_history(browser_id, bdurl, bdname, bdsize)
    local br = browser.GetBrowserByID(browser_id)
    if not br or not br:HasBrowser() then
        log("on_browserbeforedownload: invalid browser")
        return
    end
    local bname = "LuaBrowser_buzz" .. ogurl
    if ogurl and br.name == bname then
        Download.SetHistoryUrl(bdurl, ogurl)
        br:CloseBrowser()
        return ogurl
    end
    return nil
end

-- Register all callbacks
client.add_callback("on_beforedownload", on_beforedownload)
client.add_callback("on_browserloaded", on_browserloaded)
client.add_callback("on_browserbeforedownload", add_download_to_history)

log("Script loaded - version " .. VERSION)
