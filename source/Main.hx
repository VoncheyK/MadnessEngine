package;

import ui.CustomFPS;
import flixel.graphics.FlxGraphic;
import openfl.display.StageScaleMode;
import ui.FlxSoundTrayCustom;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.Bitmap;
import openfl.Assets;
import ui.CustomFPS;

class FlxGameCustom extends FlxGame {
	var gameWidth:Int = Lib.application.window.width; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = Lib.application.window.height; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 144; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public function new() {
		var stageWidth:Float = Lib.application.window.width;
		var stageHeight:Float = Lib.application.window.height;

		if (zoom == -1) {
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		super(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen);
		_customSoundTray = FlxSoundTrayCustom;
	}
}

class Main extends Sprite {
	public static var engineVer:String = "0.0.1";
	public static var instance:Main;

	public static var bitmapFPS:Bitmap;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

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
		// fuck you, persistent caching stays ON during sex
		FlxGraphic.defaultPersist = true;
		// the reason for this is we're going to be handling our own cache smartly
		addChild(new FlxGameCustom());

		#if !mobile
		fpsCounter = new CustomFPS(10, 3, 0xFFFFFF);
		addChild(fpsCounter);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end
	}

	public static var fpsCounter:CustomFPS;
}
