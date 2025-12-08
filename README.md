<div align=center>
  <a href="https://github.com/Y0URD34TH/Project-GLD">
    <img src="https://github.com/Y0URD34TH/Project-GLD/blob/main/Images/sho_now_1.png" alt="Logo" width="640" height="320">
  </a>
  <h1 align="center">Project GLD</h1>
  <p>
    Project GLD is a game library and launcher that offers Lua script compatibility for finding and downloading games.
  </p>
<br/>
<a href=https://github.com/Y0URD34TH/Project-GLD/releases/latest/download/GLDSetup.exe>
<img src="https://i.ibb.co/F7B1NKZ/1b7f18c64777e092025c1a7531e90f08.png" alt="Download" width="200">
</a>
  
[![discord](https://img.shields.io/badge/Discord-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/FyH6Z34vcZ)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue?style=for-the-badge)](https://github.com/Y0URD34TH/Project-GLD/blob/main/LICENSE)

![Downloads](https://img.shields.io/github/downloads/Y0URD34TH/Project-GLD/total) ![Contributors](https://img.shields.io/github/contributors/Y0URD34TH/Project-GLD?color=dark-green) ![Stargazers](https://img.shields.io/github/stars/Y0URD34TH/Project-GLD?style=social) ![Issues](https://img.shields.io/github/issues/Y0URD34TH/Project-GLD) 
</div>

## Table of Content

* [Features](#features)
* [Project Showcase](#project-showcase)
* [Getting Started](#getting-started)
* [Authors](#authors)
* [Sponsors](#sponsors)
* [How to Sponsor](#how-to-sponsor)
* [Acknowledgements](#acknowledgements)

## Features

Project GLD offers a variety of features to explore and utilize for your use case.

### [📁] Game Library
* Achievement support (pop-up notification + sound on completion)
* Playtime tracking and sorting based on playtime, last played, favorites, ID, or alphabetically
* Support for joystick configuration, command-line arguments & shortcuts

### **[🔎] Game Search**
* Discover new games & get results immediately
* Filter games by genre, game mode, theme, game studio, new releases, top rated...
* View game's platforms, rating, game modes, perspectives, age ratings, min and max requirements

### **[ ☁️ ] Cloud Saving**
* Back up your games and save them to cloud thanks to [Rclone](https://rclone.org/) and [ludusavi](https://github.com/mtkennerly/ludusavi)
* Support for Gdrive, Box, dropbox, onedrive, ftp, smb, webdav and custom providers
* Automatic back up, restore, and cloud sync available

### **[🎮] Game Download**
* Download a game from any source via Lua scripts
* Have the game automatically extracted/setup and placed in library with the correct .exe path (works for 1click, 2clicks, FitGirl, Dodi, and Online-fix scripts)
* Built-in download manager and Real-Debrid & TorBox support
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
* Custom background images support
* 10+ translations available & you can easily make your own

### **[💻] Console**
* Interact with GLD via CLI instead of the GUI
* Extract games via the console

### **[👥] Account System**
* Save your library and settings
* Follow your friends and see what they're playing

### **[🍄] Misc fun shit**
* Over 50 in-app achievements you can unlock by discovering cool shit in GLD
* Power options (timer for PC shut down, sleep, restart, etc.)
* Link opener tool

### **[🕹️] Joystick**
* Native joystick support - you can navigate GLD with just your joystick!
* KEY(START | MENU) = launch game
* KEY(BACK | VIEW | SHARE) = open achievements popup
* KEY(R1 | RB) = open game settings popup
* KEY(L1 | LB) = open image change popup
* KEY(R2 | RT) = add game from favorites
* KEY(L2 | LT) = quit from popup (similar to esc key)

## Project Showcase


https://github.com/user-attachments/assets/b078f7a2-f542-4c3f-ad08-50ba4173d5ac


## Getting Started

* To install scripts, simply navigate to the Installers tab in GLD. Alternatively, you can place a script file in "Documents/Project-GLD/Scripts".
* To back up your game library and favorites list go to "Documents/Project-GLD/GameList".
* Settings are saved in the "Documents/Project-GLD/Configs" folder.

### Currently available scripts:

⭐ **Recommended:**
- **[FitGirl](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/%5B1click%5D%20FitGirl.lua)** [🧲]
- [**Steamrip**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/%5B1click%5D%20SteamRip.lua) / [**Alternative**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/%5B1click%5D%20SteamRip%20(Alternative).lua) [📥]
- [**Online-fix**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/%5B1click%5D%20Online-Fix.lua) [🧲]
- [**Rezi**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Rezi.lua) [📥]
- **[Dodi](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/%5B1click%5D%20DODI.lua)** [🧲]

🗂️ **Other:**
- **[GOG-games](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/GOG-games.lua )** [🧲]
- [**G4U**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/G4U.lua) [📥]
- [**Elamigos**](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Elamigos-games.lua) [📥]
- **[Xatab](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Xatab.lua)** [🧲]
- **[Tiny-repacks](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Tiny-repacks.lua)** [🧲]
- **[KaOsKrew](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/KaOsKrew.lua)** [🧲]
- **[Empress](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Empress.lua)** [🧲]
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

## Authors

* [jma](https://github.com/Y0URD34TH) - *Lead Developer / Founder*
* [qiracy](https://github.com/qiracy) - *Tester / Translator / Designer*
* [argonptg](https://github.com/argonptg) - *Translator / Designer / Profile system developer*

## Sponsors

Thanks to those kind people and organizations, GLD got the funds to keep on going and improving.

![tb](https://i.ibb.co/TWTvThN/1144442816781635634.webp)

**[TorBox](https://torbox.app/)** / **[Guide](https://rentry.co/torbox-gld)**


## How to Sponsor

Want to sponsor GLD yourself? 

Feel free to send us donations via our Bitcoin wallet: `bc1q4tuvrhftmgwff90q5czupehksh237upeng364c`. 

If you contact us via [Discord](kPHb6xz4v7) or [make an issue on GitHub](https://github.com/Y0URD34TH/Project-GLD/issues) with proof of payment, we will prioritize a feature of your choice! You will also obtain a special role in our Discord server, as well as our eternal gratitude.

## Acknowledgements

* [ImGui](https://github.com/ocornut/imgui)
* [CURL](https://github.com/curl/curl)
* [libtorrent](https://www.libtorrent.org/)
* [Mile.Aria2](https://github.com/ProjectMile/Mile.Aria2/tree/main)
* [vcpkg](https://vcpkg.io/en/)
* [Lua](https://www.lua.org/)
* [nlohmann/json](https://github.com/nlohmann/json)
* [x360ce](https://github.com/x360ce/x360ce)
* [Gumbo HTML](https://github.com/google/gumbo-parser)
* [CEF](https://github.com/chromiumembedded/cef)
* [ludusavi](https://github.com/mtkennerly/ludusavi)
* [Rclone](https://rclone.org/)
  
