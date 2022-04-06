# Epic fnf engine ;)

# How to Compile the Game, and what is needed to do so

> ### Dependencies

- Git
- Haxe (The latest one (dont use 4.1.5 wtf, the latest versions dont have problem with git libs no more), you can use the latest version but it may not work properly)
- Visual Studio Community (Windows Only)

> ### OPTIONAL Dependencies

- Visual Studio Code (for modifying the code itself)

> ### Recommended VS Code Extensions

- Lime
- Bracket Pair Colorizer 2
- HXCPP Debugger
- Tabnine

> ### Optional Visual Studio Code Extensions

- Haxe blocks
- Haxe Checkstyle
- Haxe JSX
- Haxe Extension Pack
- HaxeUI
- indent-rainbow
- Lua Extension by keyring

# Compiling Dependencies

### Git & Haxe

Windows and macOS: 

- https://git-scm.com/downloads
- https://haxe.org/download

macOS with homebrew:
```
brew install git
brew install haxe
```

Ubuntu based Linux distros:
```
sudo add-apt-repository ppa:haxe/releases -y
sudo apt update
sudo apt install git haxe -y
mkdir ~/haxelib && haxelib setup ~/haxelib
```

Debian based Linux distros:
```
sudo apt-get install git haxe -y
mkdir ~/haxelib && haxelib setup ~/haxelib
```

Arch based Linux distros:
```
sudo pacman -S git haxe
mkdir ~/haxelib && haxelib setup ~/haxelib
```

Redhat based Linux distros:
```
sudo dnf install git haxe -y
mkdir ~/haxelib && haxelib setup ~/haxelib
```

openSuse based Linux distros: 
```
sudo zypper install git haxe
mkdir ~/haxelib && haxelib setup ~/haxelib
```

### Post installation on all platforms, run
```
haxelib setup
```

### Visual Studio Community

https://my.visualstudio.com/Downloads?q=visual%20studio%202017&wt.mc_id=o~msft~vscom~older-downloads

> ### Visual Studo Community Setup

Once you download and install VS Community, on the "Individual Components" tab, select:

```
MSVC v142 - VS 2019 C++ x64/x86 build tools
Windows SDK (10.0.17763.0)
```


Desktop Development with C++
Near the "Install" button, there's a Drop-Down menu, click on it, Select "Download first, then Install"
Now wait until it finishes, it is recommended to reboot your PC once it finishes, but it's not needed at all

# Terminal Setup & Compiling Game

Windows: Press "Windows + R" and type in "cmd", if you don't like cmd, or you just use something different, open that program instead
cmd is usually faster, that's why I'm recommending it!

Linux: press "CTRL + ALT + T" and a Terminal window should open -- although, if you are on linux, you probably know that already

### Type in these commands:

```bash
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit.git
haxelib git hxvm-luajit https://github.com/nebulazorua/hxvm-luajit
haxelib git faxe https://github.com/uhrobots/faxe
haxelib git polymod https://github.com/MasterEric/polymod.git
haxelib git extension-webm https://github.com/KadeDev/extension-webm
haxelib install lime 7.9.0
haxelib install openfl
haxelib install flixel
haxelib install flixel-tools
haxelib install flixel-ui
haxelib install hscript
haxelib install flixel-addons
haxelib install actuate
haxelib run lime setup
haxelib run lime setup flixel
haxelib run flixel-tools setup
```

**_Read Carefully:_** When it prompts for you to do anything (like: setup the lime command, setup flixel tools, etc)

Compiling test version:

```
lime test PLATFORM # linux, windows, mac
```

### for Debug Builds

Append `-debug` at the end of `lime test PLATFORM`

### Visual Studio Code Installation

Windows and Mac: https://code.visualstudio.com/Download

Linux: https://code.visualstudio.com/docs/setup/linux
* Alternatively, you can use your distro's package manager to install Visual Studio Code
