package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import haxe.CallStack;
import lime.app.Application;
import haxe.io.Path;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import openfl.events.UncaughtErrorEvent;
import GameJolt;
#if desktop
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
import Sys;
#end

using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game on fullscreen or not
	public static var fpsVar:openfl.display.CustomFPS;
	public static var engineVer:String = "0.0.1";
	public static var gjToastManager:GJToastManager;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash); //thanks gedehari

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		gjToastManager = new GJToastManager();
	
		// fuck you, persistent caching stays ON during sex
		FlxGraphic.defaultPersist = true;
		// the reason for this is we're going to be handling our own cache smartly
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		#if !mobile
		fpsVar = new openfl.display.CustomFPS(10, 3, 0xFFFFFF);
		addChild(gjToastManager);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if debug flixel.addons.studio.FlxStudio.create(); #end

	}

	function onCrash(e:UncaughtErrorEvent):Void
		{
			var errMsg:String = "";
			var path:String;
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var dateNow:String = Date.now().toString();
			var args:Array<String> = [];
			
			var errMsgBeforeLines:String;
			
			var quotes:Array<String> = [
						"This time it was not our fault!",
						"Skill issue",
						"Hah, get better at coding.",
						"Blueballed.",
						"You should go and take a break bud.",
						"Let me explain!",
						"Go and report the bug NOW.",
						"Von caused this I swear!",
						"Hey shitass, wanna see me crash the game?",
						"The game ran so fast that it crashed.",
						"You made null object reference beatable!"
			];
	
			dateNow = StringTools.replace(dateNow, " ", "_");
			dateNow = StringTools.replace(dateNow, ":", "'");
	
			path = "./crash/" + "MadnessEngine_" + dateNow + ".txt";
	
			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case FilePos(s, file, line, column):
						errMsg += file + " (line " + line + ")\n";
					default:
						trace(stackItem);
				}
			}
			
			errMsgBeforeLines = e.error;
			errMsg += e.error;
			args.insert(0, errMsgBeforeLines);
			
			if (!FileSystem.exists("./crash/"))
				FileSystem.createDirectory("./crash/");
	
			File.saveContent(path, errMsg + "\n");
	
			trace(errMsg);
			trace("Crash dump saved in " + Path.normalize(path));
			args.insert(1, Path.normalize(path));
			args.insert(2, quotes[Std.random(quotes.length)]);
			args.insert(3, Sys.getCwd());
			
			var crashDialoguePath:String = "MadnessCrashHandler";
	
			#if windows
			crashDialoguePath += ".exe";
			#end
	
			if (FileSystem.exists("./" + crashDialoguePath))
			{
				trace("Found crash dialog: " + crashDialoguePath);
	
				#if linux
				crashDialoguePath = "./" + crashDialoguePath;
				#end
				new Process(crashDialoguePath, args);
			}
			else
			{
				// I had to do this or the stupid CI won't build :distress:
				trace("No crash dialog found! Making a simple alert instead...");
				Application.current.window.alert(errMsg, "Error!");
			}

			Sys.exit(1);
		}
}
