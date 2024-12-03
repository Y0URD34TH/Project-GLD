<div align=center>
  <a href="https://github.com/Y0URD34TH/Project-GLD">
    <img src="https://github.com/Y0URD34TH/Project-GLD/blob/main/Images/favicon.png?raw=true" alt="Logo" width="640" height="320">
  </a>
  <h1 align="center">Project GLD</h1>
  <p>
    Project GLD is a game library and launcher that offers Lua script compatibility for finding and downloading games.
  </p>
<br/>
<a href=https://github.com/Y0URD34TH/Project-GLD/releases/latest/download/GLDSetup.exe>
<img src="https://github.com/Y0URD34TH/Project-GLD/blob/main/Images/dl.png" alt="Download" width="155">
</a>
  
[![discord](https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/FyH6Z34vcZ)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue?style=for-the-badge)](https://github.com/Y0URD34TH/Project-GLD/blob/main/LICENSE)

![Downloads](https://img.shields.io/github/downloads/Y0URD34TH/Project-GLD/total) ![Contributors](https://img.shields.io/github/contributors/Y0URD34TH/Project-GLD?color=dark-green) ![Stargazers](https://img.shields.io/github/stars/Y0URD34TH/Project-GLD?style=social) ![Issues](https://img.shields.io/github/issues/Y0URD34TH/Project-GLD) 
</div>

## Table of Content

* [Features](#features)
  * [Game Library](#-game-library)
  * [Game Search](#-game-search)
  * [Game Download](#-game-download)
  * [Torrent Client](#-torrent-client)
  * [Lua Scripts](#-lua-scripts)
  * [Browser](#-browser)
  * [Customization](#%EF%B8%8F-customization)
  * [Console](#-console)
  * [Account System](#-account-system)
* [Project Showcase](#project-showcase)
* [Getting Started](#getting-started)
  * [Scripts](#currently-available-scripts)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Known Bugs](#known-bugs)
* [Roadmap](#roadmap)
* [License](#license)
* [Authors](#authors)
* [Acknowledgements](#acknowledgements)

## Features

Project GLD offers a variety of features to explore and utilize for your use case.

### [📁] Game Library
* Playtime tracking and sorting based on playtime, last played, favorites, ID, or alphabetically
* Joystick configuration
* Command line arguments

### **[🔎] Game Search**
* Discover new games
* View game's images/trailers/videos
* View game's platforms, rating, min and max requirements

### **[🎮] Game Download**
* Download a game from any source via Lua scripts
* Built-in download manager and Real-Debrid support
* Start multiple downloads at the same time

### **[🧲] Torrent Client**
* Minimalist built-in torrent client based on Libtorrent
* VPN bind/killswitch available
* Download confirmation on torrents (optional)

### **[🌙] Lua Scripts**
* Built-in Lua code editor with tabs and themes
* Easily create a script for any source you'd like with our **[Lua API](https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md)**
* Customizable Lua settings and permissions

### **[🌐] Browser**
* Built-in lightweight browser with ad, popup, and redirect blockers
* CF and Byet bypass

### **[🖼️] Customization**
* Built-in theme editor and fully customizable UI
* You can change the language of the app or make your own translation for it

### **[💻] Console**
* Interact with GLD via CLI instead of the GUI
* Extract games via the console

### **[👥] Account System**
* Save your library and settings
* Follow your friends and see what they're playing

## Project Showcase


https://github.com/user-attachments/assets/b078f7a2-f542-4c3f-ad08-50ba4173d5ac


## Getting Started

To install scripts, simply place the .lua script file in the "Documents/Project-GLD/Scripts" directory, or use the program's script installer.

To backup your game library and favorites list go to "Documents/Project-GLD/GameList".

Settings are saved in the "Documents/Project-GLD/Configs" folder.

### Currently available scripts:

⭐ **Recommended:**
- **[FitGirl](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/FitGirl.lua) / [2](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/FitGirl_2%20(Torrent).lua)** [🧲] [📥]
- [**1click**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/1click.lua) [📥]
- [**Steamrip**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Steamrip.lua) [📥]
- [**Rezi**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Rezi.lua) [📥]

✅ **Preinstalled:**
- [**Images and Videos**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Images&Videos.lua) [🎬]
- [**Prowlarr**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Prowlarr.lua) [🧲]
- **[Steam](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Steam.lua)** [📥]
- **[Hydra_Sources](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Hydra_Sources.lua)** [🧲]

🗂️ **Other:**
- **[Dodi DDL](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Dodi-repacks%20(DDL).lua) / [Torrent](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Dodi-repacks%20(Torrent).lua)** [🧲] [📥]
- **[GOG-games DDL](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/GOG-games%20(DDL).lua ) / [Torrent](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/GOG-games%20(Torrent).lua)** [🧲] [📥]
- [**G4U**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/G4U.lua) [📥]
- [**Elamigos**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Elamigos-games.lua) [📥]
- [**Online fix**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Online-Fix.lua) [🧲]
- **[Xatab](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Xatab.lua)** [🧲]
- **[Tiny-repacks](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Tiny-repacks.lua)** [🧲]
- **[Steam Amiga](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Steam-Amiga.lua)** [🧲]
- **[KaOsKrew](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/KaOsKrew.lua)** [🧲]
- **[Empress](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Empress.lua)** [🧲]
- [**GameBounty**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/GameBounty.lua) [📥]
- [**Gamedrive**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Gamedrive.lua) [📥]
- [**1337x**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/1337x.lua) **[🧲] [⚠️] ONLY DOWNLOAD FROM TRUSTED UPLOADERS!!!**

For instructions on how to use Lua for making scripts, please refer to [this guide](https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md).

See our Lua Documentation [here](https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md).

### Prerequisites

* [DirectX](https://www.microsoft.com/pt-br/download/details.aspx?id=35)
* [Microsoft Visual C++ Redist (x86 and x64)](https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/)

### Installation

1. Download the program [here](https://github.com/Y0URD34TH/Project-GLD/releases/latest/download/GLDSetup.exe).

2. Install the program.

3. Enjoy!


## Known Bugs

You might experience a slight delay when searching for and downloading games. This is normal, so please refrain from closing the app as it simply needs some more time to fulfill your request, especially when initiating a download script for the searched game.

## Roadmap

Check out the [open issues](https://github.com/Y0URD34TH/Project-GLD/issues) for a list of proposed features and known issues.

## License

Distributed under the Apache-2.0 License. See [LICENSE](https://github.com/Y0URD34TH/Project-GLD/blob/main/LICENSE) for more information.

## Authors

* [jma](https://github.com/Y0URD34TH) - *Lead Developer / Founder*
* [foie](https://github.com/KaylinOwO) - *Tester / Designer / Developer*
* [qiracy](https://github.com/qiracy) - *Tester / Translator / Designer*
* [piqseu](https://github.com/piqseu) - *Designer*
* [Brisolo32](https://github.com/Brisolo32) - *Translator / Designer*
* [Backend](https://github.com/Backend2121) - *Designer / Coding Helper*

## Acknowledgements

* [ImGui](https://github.com/ocornut/imgui)
* [Rezi](https://rezi.one/)
* [CURL](https://github.com/curl/curl)
* [libtorrent](https://www.libtorrent.org/)
* [vcpkg](https://vcpkg.io/en/)
* [Lua](https://www.lua.org/)
* [nlohmann/json](https://github.com/nlohmann/json)
* [x360ce](https://github.com/x360ce/x360ce)
* [Gumbo HTML](https://github.com/google/gumbo-parser)
* [CEF](https://github.com/chromiumembedded/cef)
