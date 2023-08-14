--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md
menu.add_text("Mediafire Resolver:")
menu.add_input_text("mediafire link")
menu.add_text("archive Resolver:")
menu.add_input_text("archive link")
menu.add_button("Resolve links")

local function resolver()
local mediafirelink = menu.get_text("mediafire link")
local archiveorglink = menu.get_text("archive link")
if mediafirelink ~= "" then
local resolvedmediafirelink = http.mediafireresolver(mediafirelink)
menu.set_text("mediafire link", resolvedmediafirelink)
Notifications.push_success("link Resolver", "Mediafire Link Sucessfully Resolved")
else
Notifications.push_warning("Mediafire Resolver", "You First need to provide a link!!!")
end
if archiveorglink ~= "" then
local resolvedarchivelink = http.ArchivedotOrgResolver(archiveorglink)
menu.set_text("archive link", resolvedarchivelink)
Notifications.push_success("link Resolver", "Archive.org Link Sucessfully Resolved")
else
Notifications.push_warning("Archive.org Resolver", "You First need to provide a link!!!")
end
end

client.add_callback("on_button_Resolve links", resolver)





