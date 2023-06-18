	lua.new_usertype<JsonWrapper>("JsonWrapper",
		"parse", &JsonWrapper::parse
		);
	lua[("collectgarbage")] = sol::nil;
	lua[("dofilsse")] = sol::nil;
	lua[("load")] = sol::nil;
	lua[("loadfile")] = sol::nil;
	lua[("pcall")] = sol::nil;
	lua[("print")] = customPrint;
	lua[("xpcall")] = sol::nil;
	lua[("getmetatable")] = sol::nil;
	lua[("setmetatable")] = sol::nil;
	lua[("__nil_callback")] = [](){};

	auto client = lua.create_table();
	client[("add_callback")] = ns_client::add_callback;
	client[("load_script")] = ns_client::load_script;
	client[("unload_script")] = ns_client::unload_script;
	client[("log")] = ns_client::log;


	auto menu = lua.create_table();
	menu[("next_line")] = ns_menu::next_line;
	menu[("add_check_box")] = ns_menu::add_check_box;
	menu[("add_button")] = ns_menu::add_button;
	menu[("add_combo_box")] = ns_menu::add_combo_box;
	menu[("add_slider_int")] = ns_menu::add_slider_int;
	menu[("add_slider_float")] = ns_menu::add_slider_float;
	menu[("add_color_picker")] = ns_menu::add_color_picker;
	menu[("get_bool")] = ns_menu::get_bool;
	menu[("get_int")] = ns_menu::get_int;
	menu[("get_float")] = ns_menu::get_float;

	auto utils = lua.create_table();//new
	utils[("AtachConsole")] = Utils::AttachConsole;//new
	utils[("DetachConsole")] = Utils::DetachConsole;//new
	utils[("ConsolePrint")] = Utils::ConsolePrint;//new

	auto memory = lua.create_table();//new

	auto http = lua.create_table();//new
	http[("get")] = ns_http::get;//new
	http[("post")] = ns_http::post;//new

	auto file = lua.create_table();//new
	file[("append")] = ns_file::append; //new
	file[("write")] = ns_file::write;//new
	file[("read")] = ns_file::read;//new

	auto game = lua.create_table();
	game["getgamename"] = ns_game::getgamename;

	auto communication = lua.create_table();
	communication["receiveSearchResults"] = ns_communication::receiveSearchResults;

	auto download = lua.create_table();
	download["DownloadFile"] = ns_download::DownloadFile;
	download["GetFileNameFromUrl"] = ns_download::GetFileNameFromUrl;


	lua[("client")] = client;
	lua[("menu")] = menu;
	lua[("utils")] = utils;//new
	lua[("memory")] = memory;//new
	lua[("http")] = http;//new
	lua[("file")] = file;//new
	lua[("game")] = game;//new
	lua[("communication")] = communication;//new
	lua[("Download")] = download; //its now new xD
