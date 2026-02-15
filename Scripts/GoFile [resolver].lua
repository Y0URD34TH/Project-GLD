local VERSION = "1.0.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/GoFile%20%5Bresolver%5D.lua", VERSION)
local pendingGofileResolvers = {} -- Table to track browser instances by browser ID

local gldversion = client.GetVersionDouble()
if gldversion < 6.95 then
    Notifications.push_error("Lua Script", "Program is Outdated. Please Update to use this Script")
else
    Notifications.push_success("Lua Script", "Gofile Resolver Loaded and Working")
    
    -- Download resolver for Gofile
    local function on_beforedownload(url)
        -- Check if this is a Gofile URL
        if url:match("^https?://gofile%.io/d/") or url:match("^https?://[^/]*gofile%.io/") then
            Notifications.push_warning("Gofile Resolver", "Resolving Gofile download link...")
            
            -- Generate unique browser name for this download
            local browserName = "GofileResolver_" .. tostring(os.time()) .. "_" .. tostring(math.random(1000, 9999))
            
            -- Create hidden browser for this download
            local resolverBrowser = browser.CreateBrowser(browserName, url)
            browser.set_visible(false, browserName)

            -- Store resolver info using browser ID
            pendingGofileResolvers[resolverBrowser:GetID()] = {
                originalUrl = url,
                resolved = false,
                browserName = browserName
            }
            
            -- Cancel the original download - we'll resolve it first
            return "cancel", nil, nil
        end
        
        -- Not a Gofile URL, let it proceed normally
        return nil, nil, nil
    end
    
    -- Handle browser load completion for Gofile resolvers
    local function on_browserloaded(browserID)
        -- Get browser to check if it's one of our resolvers
        local resolverBrowser = browser.GetBrowserByID(browserID)
        if not resolverBrowser then
            return
        end
                
        -- Check if this is one of our pending Gofile resolvers
        if pendingGofileResolvers[browserID] and not pendingGofileResolvers[browserID].resolved then
            local resolverInfo = pendingGofileResolvers[browserID]
            
            -- Mark as resolved to prevent multiple executions
            resolverInfo.resolved = true
            
            -- Execute the automation script to click download button
            local fullAutomation = [=[
                // Click download button on Gofile
                let attempts = 0;
                const tryDownload = setInterval(() => {
                    // Find the download button with class 'item_download'
                    const downloadBtn = document.querySelector('button.item_download');
                    
                    if (downloadBtn && !downloadBtn.disabled) {
                        console.log('Clicking Gofile download button');
                        downloadBtn.click();
                        clearInterval(tryDownload);
                    } else if (attempts++ > 50) { // 50 attempts (about 10 seconds)
                        clearInterval(tryDownload);
                        console.error('Download button not found');
                    }
                }, 200);
            ]=]
            
            resolverBrowser:ExecuteJavaScriptOnMainFrame(fullAutomation)
            resolverBrowser:ExecuteJavaScriptOnFocusedFrame(fullAutomation)
            Notifications.push_success("Gofile Resolver", "Automation script executed!")
        end
    end
    
    -- Handle browser downloads (when the real download link is triggered)
    local function on_browserbeforedownload(browserID, downloadUrl, suggestedName, size)
        local resolverBrowser = browser.GetBrowserByID(browserID)
        if not resolverBrowser then
            return nil
        end
                
        -- Check if this download came from one of our Gofile resolvers
        if pendingGofileResolvers[browserID] then
            local resolverInfo = pendingGofileResolvers[browserID]
            
            -- Add the resolved download with the original URL for tracking
            Download.SetHistoryUrl(downloadUrl, resolverInfo.originalUrl)
            
            Notifications.push_success("Gofile Resolver", "Download link resolved successfully!")
            
            -- Close the resolver browser
            resolverBrowser:CloseBrowser()
            
            -- Clean up resolver tracking
            pendingGofileResolvers[browserID] = nil
            
            -- Return original URL for history tracking
            return resolverInfo.originalUrl
        end
        
        return nil
    end
    
    -- Register all callbacks
    client.add_callback("on_beforedownload", on_beforedownload)
    client.add_callback("on_browserloaded", on_browserloaded)
    client.add_callback("on_browserbeforedownload", on_browserbeforedownload)
end