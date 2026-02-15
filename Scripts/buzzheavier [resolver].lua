local SCRIPT_NAME    = "buzzheavier_resolver"
local VERSION = "4.1"
client.auto_script_update(
    "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/buzzheavier%20%5Bresolver%5D.lua",
    VERSION
)
local USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:144.0) Gecko/20100101 Firefox/144.0"

-- Simple logging
local function log(msg)
    gldconsole.print("[BuzzResolver] " .. msg)
    -- client.log("Buzzheavier", msg) -- optional
end

-- Check if URL belongs to supported domains
local function is_buzzheavier_url(url)
    local lower = url:lower()
    return lower:match("buzzheavier%.com/[%w%-]+") or
           lower:match("bzzhr%.co/[%w%-]+") or
           lower:match("fuckingfast%.co/[%w%-]+") or
           lower:match("fuckingfast%.net/[%w%-]+")
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

    log("Intercepted Buzzheavier download attempt: " .. url)

    local main_browser = browser.CreateBrowser("buzz"..url, url)
    if not main_browser or not main_browser:HasBrowser() then
        log("ERROR: No main browser available")
        notifications.push_error("Resolver Error", "Cannot resolve - no browser instance")
        return nil -- fallback: try original (probably fails)
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
    log("Page fully loaded - triggering download: " .. current_url)

    -- JavaScript to auto-trigger the download
    local trigger_js = [[
        (function() {
            console.log("[GLD Resolver] Attempting to start download...");

            // Try to find and click the download button
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
                    window.location.href = finalUrl;  // trigger download
                } else {
                    console.error("[GLD Resolver] No hx-redirect header");
                }
            })
            .catch(err => {
                console.error("[GLD Resolver] Fetch error: " + err);
            });
        })();
    ]]

    -- Execute the script
    br:ExecuteJavaScriptOnMainFrame(trigger_js)
    -- Optional: open dev tools to see console logs (good for debugging)
    -- br:ShowDevTools()
end


local function add_download_to_history(browser_id, bdurl, bdname, bdsize)
    local br = browser.GetBrowserByID(browser_id)
    if not br or not br:HasBrowser() then
        log("on_browserbeforedownload: invalid browser")
        return
    end
local bname = "LuaBrowser_buzz".. ogurl
if ogurl and br.name  ==  bname then
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











