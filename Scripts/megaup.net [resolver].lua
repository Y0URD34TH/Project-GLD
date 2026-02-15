---@meta MegaUp_Multi_Resolver
local VERSION = "1.1.4"
client.auto_script_update(
    "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/megaup.net%20%5Bresolver%5D.lua",
    VERSION
)

-- Script configuration
local SCRIPT_NAME = "MegaUp Multi-Resolver"
local MEGAUP_PATTERN = "megaup%.net/"
local DOWNLOAD_DOMAIN = "download%.megaup%.net"
local NOTIFICATIONS_TITLE = "MegaUp Resolver"

-- Task Tracking
local active_resolutions = {}
local instance_counter = 0

-- Global Cloudflare State
local cf_solving_in_progress = false
local cf_globally_solved = false

-- ========================================================================================
-- HELPERS
-- ========================================================================================

local function is_megaup_url(url)
    return url and string.match(url:lower(), MEGAUP_PATTERN) ~= nil
end

local function is_download_page(url)
    return url and string.match(url:lower(), DOWNLOAD_DOMAIN) ~= nil
end

local function check_cloudflare(browser_obj, callback)
    if not browser_obj then return callback(false) end

    -- Using the updated async API: GetBrowserSource(callback)
    browser_obj:GetBrowserSource(function(source)
        if not source or source == "" then return callback(false) end

        local indicators = { "Just a moment", "Attention Required", "challenge%-platform", "cf%-browser%-verification",
            "Verify you are human" }
        for _, indicator in ipairs(indicators) do
            if string.match(source, indicator) then return callback(true) end
        end
        callback(false)
    end)
end

-- ========================================================================================
-- JS INJECTION STRINGS
-- ========================================================================================

local JS_INITIAL_PAGE = [[
    (function() {
        console.log('MegaUp: Initial page script active');
        var linkExtracted = false;
        function findBtn() {
            var buttons = document.querySelectorAll('a.btn.btn--primary');
            for (var i = 0; i < buttons.length; i++) {
                var text = (buttons[i].innerText || '').toUpperCase();
                var href = buttons[i].getAttribute('href');
                if ((text.indexOf('DOWNLOAD') !== -1 || text.indexOf('VIEW NOW') !== -1) && href && href !== '#') return buttons[i];
            }
            return null;
        }
        var intv = setInterval(function() {
            var btn = findBtn();
            if (btn && !linkExtracted) {
                console.log('MEGAUP_DOWNLOAD_LINK:' + btn.href);
                linkExtracted = true;
                clearInterval(intv);
            }
        }, 1000);
    })();
]]

local JS_DOWNLOAD_PAGE = [[
    (function() {
        var clicked = false;
        console.log('MegaUp: Download monitor started (waiting for countdown)');

        function getBtn() {
            return document.getElementById('btndownload') ||
                   document.querySelector('a.btn-primary') ||
                   document.querySelector('button.btn-primary');
        }

        var intv = setInterval(function() {
            var btn = getBtn();
            if (!btn) return;

            // Check if button is still in 'Creating Link' / 'disabled' state
            var is_disabled = btn.classList.contains('disabled') || btn.hasAttribute('disabled') || (btn.innerText && btn.innerText.includes('Wait'));

            if (!is_disabled && !clicked) {
                console.log('MegaUp: Timer finished. Preparing click...');

                // Remove target blank to keep download in this instance
                if (btn.tagName === 'A') {
                    btn.removeAttribute('target');
                }

                console.log('MEGAUP_FINAL_BUTTON_CLICKED');
                btn.click();
                clicked = true;
                clearInterval(intv);
            }
        }, 1000);
    })();
]]

-- ========================================================================================
-- CALLBACKS
-- ========================================================================================

client.add_callback("on_beforedownload", function(url)
    -- 1. Initial link click interception
    if is_megaup_url(url) and not is_download_page(url) then
        instance_counter = instance_counter + 1
        local b_name = "MegaUp_" .. instance_counter
        local new_browser = browser.CreateBrowser(b_name, url)

        active_resolutions[new_browser:GetID()] = {
            id = new_browser:GetID(),
            original_url = url,
            browser = new_browser,
            waiting_for_cf = false,
            processing = false
        }
        Notifications.push(NOTIFICATIONS_TITLE, "Started resolver #" .. instance_counter)
        return "cancel", nil, nil
    end

    -- 2. Global Stream Catch (Fallback)
    if is_download_page(url) then
        return url
    end
    return nil, nil, nil
end)

client.add_callback("on_browserloaded", function(browserID)
    local state = active_resolutions[browserID]
    if not state or state.processing then return end

    state.processing = true
    local b_obj = state.browser
    local current_url = b_obj:BrowserUrl()

    check_cloudflare(b_obj, function(is_cf)
        state.processing = false

        if is_cf then
            -- Only trigger solver if we haven't globally solved it yet
            if not cf_globally_solved and not cf_solving_in_progress then
                gldconsole.print("[" ..
                    SCRIPT_NAME .. "] [" .. browserID .. "] Cloudflare challenge. Solving globally...")
                Notifications.push_warning(NOTIFICATIONS_TITLE, "Cloudflare challenge detected — solving globally")
                cf_solving_in_progress = true
                state.waiting_for_cf = true
                http.CloudFlareSolver(current_url)
            else
                gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. browserID .. "] Waiting for global CF bypass...")
                Notifications.push(NOTIFICATIONS_TITLE, "Waiting for global Cloudflare bypass...")
                state.waiting_for_cf = true
            end
        else
            state.waiting_for_cf = false
            if is_download_page(current_url) then
                gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. browserID .. "] Waiting for timer/countdown...")
                Notifications.push(NOTIFICATIONS_TITLE, "Download page detected — waiting for countdown")
                b_obj:ExecuteJavaScriptOnMainFrame(JS_DOWNLOAD_PAGE)
            elseif is_megaup_url(current_url) then
                Notifications.push(NOTIFICATIONS_TITLE, "Initial MegaUp page detected — extracting link")
                b_obj:ExecuteJavaScriptOnMainFrame(JS_INITIAL_PAGE)
            end
        end
    end)
end)

client.add_callback("on_cfdone", function(cookie, url)
    if url and string.match(url, "download%.megaup%.net") then
        gldconsole.print("[" .. SCRIPT_NAME .. "] Global Bypass Success! Re-notifying active tasks.")
        Notifications.push_success(NOTIFICATIONS_TITLE, "Global Cloudflare bypass successful")
        cf_solving_in_progress = false
        cf_globally_solved = true

        for id, state in pairs(active_resolutions) do
            if state.waiting_for_cf then
                state.waiting_for_cf = false
                local target = state.browser:BrowserUrl()
                state.browser:ChangeBrowserURL(target)
                Notifications.push(NOTIFICATIONS_TITLE, "Resuming resolver #" .. tostring(state.id))
            end
        end
    end
end)

client.add_callback("on_browserconsolemessage", function(browserID, message)
    local state = active_resolutions[browserID]
    if not state then return end

    if string.match(message, "MEGAUP_DOWNLOAD_LINK:(.+)") then
        local next_link = string.match(message, "MEGAUP_DOWNLOAD_LINK:(.+)")
        state.browser:ChangeBrowserURL(next_link)
        Notifications.push(NOTIFICATIONS_TITLE, "Found download link — navigating to download page")
    elseif string.match(message, "MEGAUP_FINAL_BUTTON_CLICKED") then
        gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. browserID .. "] Button clicked! Catching download stream...")
        Notifications.push(NOTIFICATIONS_TITLE, "Final download button clicked — catching stream")
    end
end)

client.add_callback("on_browserbeforedownload", function(browserID, url, filename, size)
    local state = active_resolutions[browserID]
    if not state then return end
    gldconsole.print("[" .. SCRIPT_NAME .. "] [" .. browserID .. "] SUCCESS: " .. filename)
    Download.SetHistoryUrl(url, state.original_url)

    state.browser:CloseBrowser()
    active_resolutions[browserID] = nil
    return url
end)

gldconsole.print("[" .. SCRIPT_NAME .. "] v" .. VERSION .. " loaded. Countdown handling active.")
