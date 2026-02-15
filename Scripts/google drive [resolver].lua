--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
--[[
    Google Drive Link Resolver for Project-GLD
    Author: Jma
    Version: 1.0.0
    Description: Resolves Google Drive download links to direct download URLs
]]

local VERSION = "1.0.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/google%20drive%20%5Bresolver%5D.lua", VERSION)
-- Configuration
local config = {
    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    api_key = "", -- Optional: Add your Google Drive API key here for better reliability
    use_api = false, -- Set to true if you want to use API method
    debug = false
}

-- Patterns for Google Drive URLs
local patterns = {
    file_id = {
        "drive%.google%.com/file/d/([a-zA-Z0-9_%-]+)",
        "drive%.google%.com/open%?id=([a-zA-Z0-9_%-]+)",
        "drive%.google%.com/uc%?.*id=([a-zA-Z0-9_%-]+)",
        "drive%.usercontent%.google%.com/download%?id=([a-zA-Z0-9_%-]+)",
        "docs%.google%.com/document/d/([a-zA-Z0-9_%-]+)"
    }
}

-- Helper function to extract file ID from URL
local function extract_file_id(url)
    for _, pattern in ipairs(patterns.file_id) do
        local file_id = url:match(pattern)
        if file_id then
            if config.debug then
                gldconsole.print("[Google Drive] Found file ID: " .. file_id)
            end
            return file_id
        end
    end
    return nil
end

-- Helper function to extract resource key from URL
local function extract_resource_key(url)
    local resource_key = url:match("resourcekey=([a-zA-Z0-9_%-]+)")
    if resource_key and config.debug then
        gldconsole.print("[Google Drive] Found resource key: " .. resource_key)
    end
    return resource_key
end

-- Helper function to parse JSON
local function parse_json(json_str)
    local success, result = pcall(function()
        return JsonWrapper.parse(json_str)
    end)
    if success then
        return result
    else
        if config.debug then
            gldconsole.print("[Google Drive] JSON parse error: " .. tostring(result))
        end
        return nil
    end
end

-- Helper function to extract filename from headers or content
local function extract_filename(html, headers)
    -- Try to get filename from HTML
    local filename = html:match('"fileName"%s*:%s*"([^"]+)"')
    if filename then
        return filename
    end
    
    -- Try from title tag
    filename = html:match('<title>([^<]+)</title>')
    if filename then
        filename = filename:gsub(" %- Google Drive", "")
        return filename
    end
    
    return nil
end

-- Method 1: Direct download using confirm parameter
local function resolve_direct_download(file_id, resource_key)
    local url = "https://drive.google.com/uc?id=" .. file_id .. "&export=download"
    if resource_key then
        url = url .. "&resourcekey=" .. resource_key
    end
    
    local headers = {
        "User-Agent: " .. config.user_agent,
        "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Language: en-US,en;q=0.5"
    }
    
    if config.debug then
        gldconsole.print("[Google Drive] Attempting direct download: " .. url)
    end
    
    -- First request to get confirm token
    local response = http.get(url, headers)
    
    if not response then
        if config.debug then
            gldconsole.print("[Google Drive] Failed to get initial response")
        end
        return nil, nil, headers
    end
    
    -- Check if we got a direct download or need confirmation
    local confirm_token = response:match('confirm=([^&"]+)')
    local download_url = response:match('"downloadUrl"%s*:%s*"([^"]+)"')
    
    -- Extract filename
    local filename = extract_filename(response, headers)
    
    if download_url then
        download_url = download_url:gsub("\\/", "/")
        if config.debug then
            gldconsole.print("[Google Drive] Found download URL in JSON")
        end
        return download_url, filename, headers
    end
    
    if confirm_token then
        -- Build confirmed download URL
        local confirmed_url = url .. "&confirm=" .. confirm_token
        if config.debug then
            gldconsole.print("[Google Drive] Using confirm token: " .. confirm_token)
        end
        return confirmed_url, filename, headers
    end
    
    -- Try to find download link in HTML
    download_url = response:match('href="(/uc%?[^"]*export=download[^"]*)"')
    if download_url then
        download_url = "https://drive.google.com" .. download_url:gsub("&amp;", "&")
        if config.debug then
            gldconsole.print("[Google Drive] Found download URL in HTML")
        end
        return download_url, filename, headers
    end
    
    -- If no special handling needed, return original URL
    return url, filename, headers
end

-- Method 2: Using Google Drive Web API (if API key is available)
local function resolve_via_api(file_id, resource_key)
    if not config.use_api or not config.api_key or config.api_key == "" then
        return nil, nil, nil
    end
    
    local api_url = "https://www.googleapis.com/drive/v3/files/" .. file_id .. 
                    "?supportsAllDrives=true&fields=name,size,mimeType&key=" .. config.api_key .. 
                    "&alt=media"
    
    local headers = {
        "User-Agent: " .. config.user_agent
    }
    
    if resource_key then
        table.insert(headers, "X-Goog-Drive-Resource-Keys: " .. file_id .. "/" .. resource_key)
    end
    
    if config.debug then
        gldconsole.print("[Google Drive] Using API method")
    end
    
    return api_url, nil, headers
end

-- Method 3: Handle virus-infected or quota exceeded files
local function handle_special_cases(file_id, resource_key)
    local url = "https://drive.google.com/uc?id=" .. file_id .. "&export=download&confirm=t"
    if resource_key then
        url = url .. "&resourcekey=" .. resource_key
    end
    
    local headers = {
        "User-Agent: " .. config.user_agent,
        "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
    }
    
    return url, nil, headers
end

-- Main resolver function
local function resolve_google_drive(url)
    if config.debug then
        gldconsole.print("[Google Drive] Attempting to resolve: " .. url)
    end
    
    -- Check if this is a Google Drive URL
    if not (url:match("drive%.google%.com") or 
            url:match("drive%.usercontent%.google%.com") or 
            url:match("docs%.google%.com")) then
        return nil, nil, nil
    end
    
    -- Extract file ID
    local file_id = extract_file_id(url)
    if not file_id then
        if config.debug then
            gldconsole.print("[Google Drive] Could not extract file ID from URL")
        end
        return nil, nil, nil
    end
    
    -- Extract resource key if present
    local resource_key = extract_resource_key(url)
    
    -- Try API method first if enabled
    if config.use_api and config.api_key ~= "" then
        local resolved_url, filename, headers = resolve_via_api(file_id, resource_key)
        if resolved_url then
            Notifications.push_success("Google Drive", "Resolved using API method")
            return resolved_url, filename, headers
        end
    end
    
    -- Try direct download method
    local resolved_url, filename, headers = resolve_direct_download(file_id, resource_key)
    if resolved_url then
        if config.debug then
            gldconsole.print("[Google Drive] Successfully resolved URL")
            if filename then
                gldconsole.print("[Google Drive] Filename: " .. filename)
            end
        end
        Notifications.push_success("Google Drive", "Link resolved successfully")
        return resolved_url, filename, headers
    end
    
    -- Fallback to special cases handling
    if config.debug then
        gldconsole.print("[Google Drive] Using fallback method")
    end
    return handle_special_cases(file_id, resource_key)
end

-- Callback for when download is about to start
local function on_before_download(url)
    -- Only process Google Drive URLs
    if not (url:match("drive%.google%.com") or 
            url:match("drive%.usercontent%.google%.com") or 
            url:match("docs%.google%.com")) then
        return nil, nil, nil
    end
    
    local resolved_url, filename, headers = resolve_google_drive(url)
    
    -- Return the resolved values (return nil to keep original)
    return resolved_url, filename, headers
end

-- Initialize plugin
local function init()
    gldconsole.print("[Google Drive Resolver] Plugin loaded v" .. VERSION)
    
    -- Add callback for before download
    client.add_callback("on_beforedownload", on_before_download)
    
    -- Add menu options
    menu.add_text("Google Drive Resolver v" .. VERSION)
    menu.add_check_box("gd_debug_mode")
    menu.set_bool("gd_debug_mode", config.debug)
    menu.add_input_text("gd_api_key")
    menu.set_text("gd_api_key", config.api_key)
    menu.add_check_box("gd_use_api")
    menu.set_bool("gd_use_api", config.use_api)
    
    Notifications.push_success("Google Drive Resolver", "Plugin initialized successfully")
end

-- Update config from menu
local function update_config()
    config.debug = menu.get_bool("gd_debug_mode")
    config.api_key = menu.get_text("gd_api_key")
    config.use_api = menu.get_bool("gd_use_api")
end

-- Main loop to update config
client.add_callback("on_present", function()
    update_config()
end)

-- Initialize the plugin
init()

