<div align=center>
  <a href="https://github.com/Y0URD34TH/Project-GLD">
    <img src="https://github.com/piqseu/Project-GLD/blob/main/Images/favicon.png?raw=true" alt="Logo" width="640" height="320">
  </a>
  <h1 align="center">Project GLD</h1>
  <p>
    Project GLD is a game library and launcher that offers Lua script compatibility for searching and downloading games.
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

* [About the Project](#about-the-project)
* [Project Showcase](#project-showcase)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Known Bugs](#known-bugs)
* [Roadmap](#roadmap)
* [License](#license)
* [Authors](#authors)
* [Acknowledgements](#acknowledgements)

## About The Project


Project GLD allows you to easily search for, download, and manage games. One of its core features is the native support for community-made scripts written in Lua, allowing you to easily create and implement your own scripts to increase the functionality of the app.
It's also worth noting that while the scripts are based on Lua, the program itself is developed in C++, making it very light and fast.

You may create and use any scripts at your own risk. We do not take the responsibility for potential consequences or the content obtained through the utilization of community-generated scripts!

The project is currently in beta and supports torrents, magnet links, and regular downloads.
It's completely free.

Any contribution to the code or design of the app is very welcome! If you wish to help out, you may do so by creating a fork of this repository and submitting a Pull Request with the changes you've made. However, we'd recommend first joining our [Discord server](https://discord.gg/FyH6Z34vcZ) to discuss the features you wish to work on and implement with the other developers.

## Project Showcase



https://github.com/Y0URD34TH/Project-GLD/assets/58450502/799cfa79-4988-470e-8477-5889c4e12a4a




## Getting Started

To install scripts, simply place the .lua script file in the "Documents/Project-GLD/Scripts" directory, or use the program's script installer.
To backup your game library list and favorites list go to "Documents/Project-GLD/GameList"
Settings are Saved in th "Documents/Project-GLD/Configs" Folder

Here are a few examples of functional scripts:

* [1337x.lua](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/1337x.lua)
* [Rezi.lua](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/Rezi.lua)
* [fitgirl.lua](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/fitgirl.lua)
* [elamigos-games.lua](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/elamigos-games.lua)
* [onlinefix.lua](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/onlinefix.lua)
* [prowlarr.lua](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/prowlarr.lua)
* [steamrip.lua](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/steamrip.lua)
* [gamedrive.lua](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/gamedrive.lua)
* [g4u.lua](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/g4u.lua)
* [img&vids.lua](https://github.com/Y0URD34TH/Project-GLD/blob/main/Scripts/img&vids.lua)

For instructions on how to use Lua for making scripts, please refer to [this guide](https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md).

See our Lua Documentation [Here](https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md).

### Prerequisites

* [DirectX](https://www.microsoft.com/pt-br/download/details.aspx?id=35)
* [Microsoft Visual C++ Redist (x86 and x64)](https://www.techpowerup.com/download/visual-c-redistributable-runtime-package-all-in-one/)

### Installation

1. Download the program at [Download Here](https://github.com/Y0URD34TH/Project-GLD/releases/latest/download/GLDSetup.exe).

2. Install the program.

3. Enjoy!


## Known Bugs

You might experience a slight delay when searching for and downloading games. This is normal, so please refrain from closing the app as it simply needs some more time to fulfill your request, especially when initiating a download script for the searched game.

## Roadmap

Check out the [open issues](https://github.com/Y0URD34TH/Project-GLD/issues) for a list of proposed features and known issues.

also we want to be like the [Stremio](https://www.stremio.com/) for games.

## License

Distributed under the Apache-2.0 License. See [LICENSE](https://github.com/Y0URD34TH/Project-GLD/blob/main/LICENSE) for more information.

## Authors

* [jma](https://github.com/Y0URD34TH) - *Lead Developer / Founder*
* [foie](https://github.com/KaylinOwO) - *Tester / Designer / Developer*
* [qiracy](https://github.com/qiracy) - *Tester / Translator / Designer*
* [Pixel](https://github.com/piqseu) - *Designer*
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
