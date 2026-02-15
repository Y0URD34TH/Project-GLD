local VERSION = "1.1"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/%5Bmain%5D%20Resolver%20Manager%20%5Bresolver%5D.lua", VERSION)

-- Define all resolver scripts that should exist
local resolvers = {
    {
        name = "vikingfile.com [resolver].lua",
        url = "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/vikingfile.com%20%5Bresolver%5D.lua"
    },
    {
        name = "pixeldrain.com [resolver].lua",
        url = "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/pixeldrain.com%20%5Bresolver%5D.lua"
    },
    {
        name = "megaup.net [resolver].lua",
        url = "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/megaup.net%20%5Bresolver%5D.lua"
    },
    {
        name = "megadb.net [resolver].lua",
        url = "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/megadb.net%20%5Bresolver%5D.lua"
    },
    {
        name = "mediafire.com [resolver].lua",
        url = "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/mediafire.com%20%5Bresolver%5D.lua"
    },
    {
        name = "google drive [resolver].lua",
        url = "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/google%20drive%20%5Bresolver%5D.lua"
    },
    {
        name = "GoFile [resolver].lua",
        url = "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/GoFile%20%5Bresolver%5D.lua"
    },
    {
        name = "buzzheavier [resolver].lua",
        url = "https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/buzzheavier%20%5Bresolver%5D.lua"
    }
}

-- Function to check and download missing resolvers
local function check_and_download_resolvers()
    gldconsole.print("[Resolver Checker] Starting resolver check...")
    
    local scripts_path = client.GetScriptsPath()
    local missing_count = 0
    local downloaded_count = 0
    local failed_downloads = {}
    local newly_downloaded = {}
    
    -- Check each resolver
    for _, resolver in ipairs(resolvers) do
        local full_path = scripts_path .. "\\" .. resolver.name
        
        -- Check if file exists
        if not file.exists(full_path) then
            missing_count = missing_count + 1
            gldconsole.print("[Resolver Checker] Missing: " .. resolver.name)
            
            -- Try to download the file using DirectDownload
            gldconsole.print("[Resolver Checker] Downloading from GitHub...")
            
            local success = pcall(function()
                Download.DirectDownload(resolver.url, full_path)
            end)
            
            if success then
                sleep(1000) -- Wait for download to complete
                
                -- Verify the file was written
                if file.exists(full_path) then
                    downloaded_count = downloaded_count + 1
                    table.insert(newly_downloaded, resolver.name)
                    gldconsole.print("[Resolver Checker] ✓ Successfully downloaded: " .. resolver.name)
                else
                    table.insert(failed_downloads, resolver.name)
                    gldconsole.print("[Resolver Checker] ✗ Failed to verify: " .. resolver.name)
                end
            else
                table.insert(failed_downloads, resolver.name)
                gldconsole.print("[Resolver Checker] ✗ Failed to download: " .. resolver.name)
            end
            
        else
            gldconsole.print("[Resolver Checker] ✓ Exists: " .. resolver.name)
        end
    end
    
    -- Load newly downloaded scripts
    if #newly_downloaded > 0 then
        gldconsole.print("[Resolver Checker] Loading newly downloaded scripts...")
        for _, script_name in ipairs(newly_downloaded) do
            pcall(function()
                client.load_script(script_name)
                gldconsole.print("[Resolver Checker] Loaded: " .. script_name)
            end)
        end
    end
    
    -- Show summary
    gldconsole.print("[Resolver Checker] Check complete!")
    gldconsole.print("[Resolver Checker] Total resolvers: " .. #resolvers)
    gldconsole.print("[Resolver Checker] Missing: " .. missing_count)
    gldconsole.print("[Resolver Checker] Downloaded: " .. downloaded_count)
    
    -- Show notifications
    if missing_count > 0 then
        if downloaded_count == missing_count then
            Notifications.push_success("Resolvers Updated", 
                "Downloaded " .. downloaded_count .. " missing resolver script(s)")
        elseif downloaded_count > 0 then
            Notifications.push_warning("Resolvers Partially Updated", 
                "Downloaded " .. downloaded_count .. " of " .. missing_count .. " missing resolvers")
        else
            Notifications.push_error("Resolver Download Failed", 
                "Could not download any missing resolvers")
        end
        
        -- Log failed downloads
        if #failed_downloads > 0 then
            gldconsole.print("[Resolver Checker] Failed downloads:")
            for _, name in ipairs(failed_downloads) do
                gldconsole.print("  - " .. name)
            end
        end
    else
        Notifications.push_success("Resolvers Check", "All resolver scripts are present")
    end
end

-- Function to force update all resolvers (delete and re-download)
local function update_all_resolvers()
    gldconsole.print("[Resolver Updater] Force updating all resolvers...")
    
    local scripts_path = client.GetScriptsPath()
    local updated_count = 0
    local failed_updates = {}
    local scripts_to_reload = {}
    
    for _, resolver in ipairs(resolvers) do
        local full_path = scripts_path .. "\\" .. resolver.name
        local was_existing = file.exists(full_path)
        
        -- Unload script if it existed (will be reloaded after update)
        if was_existing then
            pcall(function()
                client.unload_script(resolver.name)
                gldconsole.print("[Resolver Updater] Unloaded: " .. resolver.name)
            end)
        end
        
        -- Delete existing file if it exists
        if file.exists(full_path) then
            file.delete(full_path)
            gldconsole.print("[Resolver Updater] Removed old version: " .. resolver.name)
        end
        
        -- Download fresh copy using DirectDownload
        gldconsole.print("[Resolver Updater] Downloading: " .. resolver.name)
        
        local success = pcall(function()
            Download.DirectDownload(resolver.url, full_path)
        end)
        
        if success then
            sleep(1000) -- Wait for download to complete
            
            if file.exists(full_path) then
                updated_count = updated_count + 1
                if was_existing then
                    table.insert(scripts_to_reload, resolver.name)
                else
                    table.insert(scripts_to_reload, resolver.name)
                end
                gldconsole.print("[Resolver Updater] ✓ Updated: " .. resolver.name)
            else
                table.insert(failed_updates, resolver.name)
                gldconsole.print("[Resolver Updater] ✗ Failed to write: " .. resolver.name)
            end
        else
            table.insert(failed_updates, resolver.name)
            gldconsole.print("[Resolver Updater] ✗ Failed to download: " .. resolver.name)
        end
        
    end
    
    -- Reload all successfully updated scripts
    if #scripts_to_reload > 0 then
        gldconsole.print("[Resolver Updater] Loading updated scripts...")
        for _, script_name in ipairs(scripts_to_reload) do
            pcall(function()
                client.load_script(script_name)
                gldconsole.print("[Resolver Updater] Loaded: " .. script_name)
            end)
        end
    end
    
    -- Show summary
    gldconsole.print("[Resolver Updater] Update complete!")
    gldconsole.print("[Resolver Updater] Updated: " .. updated_count .. " of " .. #resolvers)
    
    if updated_count == #resolvers then
        Notifications.push_success("Resolvers Updated", "All " .. updated_count .. " resolvers updated successfully")
    else
        Notifications.push_warning("Resolvers Update", 
            "Updated " .. updated_count .. " of " .. #resolvers .. " resolvers")
    end
    
    if #failed_updates > 0 then
        gldconsole.print("[Resolver Updater] Failed updates:")
        for _, name in ipairs(failed_updates) do
            gldconsole.print("  - " .. name)
        end
    end
end

-- Add menu options
menu.add_text("=== Resolver Scripts Manager ===")
menu.add_button("Check Missing Resolvers")
menu.add_button("Update All Resolvers")
menu.next_line()

-- Button callbacks
client.add_callback("on_button_Check Missing Resolvers", function()
    check_and_download_resolvers()
end)

client.add_callback("on_button_Update All Resolvers", function()
    update_all_resolvers()
end)

gldconsole.print("[Resolver Checker] Script loaded! Version: " .. VERSION)
gldconsole.print("[Resolver Checker] Use the menu buttons to check or update resolvers")

check_and_download_resolvers()

