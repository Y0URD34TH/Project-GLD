------------------------------------------------------------
-- MediaFire download resolver for Project-GLD
-- Uses on_beforedownload callback
-- Resolves MediaFire page → direct file URL
------------------------------------------------------------

local VERSION = "1.0.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/mediafire%20%5Bresolver%5D.lua", VERSION)

local USER_AGENT =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " ..
    "AppleWebKit/537.36 (KHTML, like Gecko) " ..
    "Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15"

------------------------------------------------------------
-- MediaFire resolver
------------------------------------------------------------
local function resolve_mediafire(url)
    gldconsole.print("[mediafire] fetching page")

    local html_page = http.get(url, {
        ["User-Agent"] = USER_AGENT
    })

    if not html_page or html_page == "" then
        gldconsole.print("[mediafire] empty response")
        return nil
    end

    local doc = html.parse(html_page)

    -- Main MediaFire download button
    local nodes = doc:css("a.input.popsok")
    if not nodes or #nodes == 0 then
        gldconsole.print("[mediafire] download button not found")
        return nil
    end

    local btn = nodes[1]

    -- Preferred: scrambled URL
    local scrambled = btn:attr("data-scrambled-url")
    if scrambled then
        local decoded = base64.decode(scrambled)
        if decoded and decoded ~= "" then
            gldconsole.print("[mediafire] resolved (scrambled)")
            return decoded
        end
    end

    -- Fallback: href
    local href = btn:attr("href")
    if href and href ~= "" then
        gldconsole.print("[mediafire] resolved (href)")
        return href
    end

    gldconsole.print("[mediafire] failed to resolve")
    return nil
end

------------------------------------------------------------
-- on_beforedownload hook
------------------------------------------------------------
client.add_callback("on_beforedownload", function(original_url)
    if not original_url then
        return nil
    end

    -- Only handle MediaFire
    if not original_url:find("mediafire.com", 1, true) then
        return nil
    end

    gldconsole.print("[resolver] MediaFire detected")
    gldconsole.print("[resolver] original: " .. original_url)

    local resolved = resolve_mediafire(original_url)
    if not resolved then
        gldconsole.print("[resolver] resolution failed")
        return nil
    end

    gldconsole.print("[resolver] direct: " .. resolved)

    -- Optional: filename
    local filename = Download.GetFileNameFromUrl(resolved)

    -- IMPORTANT:
    -- return_url, filename, headers
    return resolved, filename, nil
end)

------------------------------------------------------------
-- Script loaded confirmation
------------------------------------------------------------
gldconsole.print("[MediaFire Resolver] loaded successfully")


