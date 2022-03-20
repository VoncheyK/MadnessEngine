# Epic fnf engine ;)

How to use?

# 1st Step. 
Download Haxe latest version https://haxe.org/download/

# 2nd Step. 
Setup Haxe https://haxeflixel.com/documentation/install-haxeflixel/

# 3rd Step.
You need to install this lol

all of them must use *haxelib install* first!!!

`flixel,
flixel-addons,
flixel-ui,
hscript,
newgrounds`

# 4th Step.

Then download Git https://git-scm.com/downloads works for all OS just follow the instruction.

# 5th step.

Run haxelib git polymod https://github.com/larsiusprime/polymod.git to install Polymod.

Run haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc to install Discord RPC.

# 6th Step. 

haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons

Once you have all those installed, it's pretty easy to compile the game. You just need to run lime test html5 -debug in the root of the project to build and run the HTML5 version. (command prompt navigation guide can be found here: https://ninjamuffin99.newgrounds.com/news/post/1090480) To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run lime test linux -debug and then run the executable file in export/release/linux/bin. For Windows, you need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:

`MSVC v142 - VS 2019 C++ x64/x86 build tools`
`Windows SDK (10.0.17763.0)`
Once that is done you can open up a command line in the project's directory and run lime test windows -debug. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\windows\bin As for Mac, 'lime test mac -debug' should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.
