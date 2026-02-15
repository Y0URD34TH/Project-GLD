--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
------------------------------------------------------------
-- PixelDrain download resolver for Project-GLD
-- Resolves pixeldrain.com links to direct API download
-- Uses on_beforedownload callback
------------------------------------------------------------
local VERSION = "1.0.0"
client.auto_script_update(
    "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/pixeldrain.com%20%5Bresolver%5D.lua",
    VERSION
)
------------------------------------------------------------
-- Resolve PixelDrain link
------------------------------------------------------------
local function resolve_pixeldrain(url)
    -- Extract file id (last path segment)
    local file_id = url:match("/([^/]+)$")

    if not file_id or file_id == "" then
        gldconsole.print("[pixeldrain] failed to extract file id")
        return nil
    end

    -- Remove query params if present
    file_id = file_id:match("([^?]+)")

    local direct =
        "https://pixeldrain.com/api/file/" ..
        file_id ..
        "?download"

    gldconsole.print("[pixeldrain] resolved: " .. direct)
    return direct
end

------------------------------------------------------------
-- on_beforedownload hook
------------------------------------------------------------
client.add_callback("on_beforedownload", function(original_url)
    if not original_url then
        return nil
    end

    -- Only handle PixelDrain
    if not original_url:find("pixeldrain.com", 1, true) then
        return nil
    end

    gldconsole.print("[resolver] PixelDrain detected")
    gldconsole.print("[resolver] original: " .. original_url)

    local resolved = resolve_pixeldrain(original_url)
    if not resolved then
        gldconsole.print("[resolver] resolution failed")
        return nil
    end

    -- Optional filename
    local filename = Download.GetFileNameFromUrl(resolved)

    -- return_url, filename, headers
    return resolved, filename, nil
end)

------------------------------------------------------------
-- Script loaded confirmation
------------------------------------------------------------
gldconsole.print("[PixelDrain Resolver] loaded successfully")

