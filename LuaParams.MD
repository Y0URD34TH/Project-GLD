json
{
parse
}

lua
{
collectgarbage
dofilsse
load
loadfile
pcall
print
xpcall
getmetatable
setmetatable
__nil_callback
}

client 
{
add_callback
load_script
unload_script
log
}

menu 
{
next_line
add_check_box
add_button
add_combo_box
add_slider_int
add_slider_float
add_color_picker
get_bool
get_int
get_float
}

utils
{
AtachConsole
DetachConsole
ConsolePrint
}

file
{
append
write
read
}

game
{
getgamename
}

communication
{
receiveSearchResults
}

Download
{
DownloadFile
GetFileNameFromUrl
}

lua tables:
client
menu
utils
http
file
game
communication
Download


usage example:
local gamename = game.getgamename()
menu.add_check_box("checkbox example")
utils.AtachConsole()
utils.ConsolePrint(false, tostring(game.getgamename()))

