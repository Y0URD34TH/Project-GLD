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
  GetVersion  
  }  

Notifications  
  {  
  push  
  push_success  
  push_error  
  push_warning  
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
  ArchivedotOrgResolver  
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
  print("Test", "im a print test")  
  local gamename = game.getgamename()  
  menu.add_check_box("checkbox example")  
  utils.AtachConsole()  
  utils.ConsolePrint(false, tostring(game.getgamename()))
