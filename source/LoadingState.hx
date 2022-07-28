package;

import flixel.math.FlxMath;
import flixel.ui.FlxBar;
import lime.app.Promise;
import lime.app.Future;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import haxe.io.Path;
import flixel.FlxG;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;

	var target:FlxState;
	var targetShit:Float;
	var stopMusic = false;
	var callbacks:MultiCallback;
	var loadingFromMods:Bool;
	var additionLib:String;

	var funkay:FlxSprite;
	var loadBar:FlxBar;

	function new(target:FlxState, stopMusic:Bool, loadingFromMods:Bool, ?additionLib:String)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
		this.loadingFromMods = loadingFromMods;
		if (additionLib != null)
			this.additionLib = additionLib;
	}

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, -3473587);
		add(bg);

		funkay = new FlxSprite().loadGraphic(Paths.image('funkay'));
		funkay.setGraphicSize(0, FlxG.height);
		funkay.updateHitbox();
		funkay.antialiasing = true;
		add(funkay);
		funkay.scrollFactor.set();
		funkay.screenCenter();

		loadBar = new FlxBar(0, FlxG.height - 20);
		loadBar.makeGraphic(FlxG.width, 10, -59694);
		loadBar.screenCenter(X);
		add(loadBar);

		initSongsManifest().onComplete(function(lib)
		{
			callbacks = new MultiCallback(onLoad);
			var introComplete = callbacks.add("introComplete");
			checkLoadSong(getSongPath());
			if (PlayState.SONG.needsVoices)
				checkLoadSong(getVocalPath());
			checkLibrary("shared");
			if (PlayState.storyWeek > 0)
				checkLibrary("week" + PlayState.storyWeek);
			else
				checkLibrary("tutorial");

			if(loadingFromMods)
				checkLibrary("mods", true, additionLib);

			var fadeTime = 0.5;
			FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
			new FlxTimer().start(fadeTime + MIN_TIME, function(_) introComplete());
		});
	}

	function checkLoadSong(path:String)
	{
		if (!Assets.cache.hasSound(path))
		{
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function(_)
			{
				callback();
			});
		}
	}

	function checkLibrary(library:String, ?exception:Bool, ?exceptionalLib:String)
	{
		trace(Assets.hasLibrary(library));
		if (Assets.getLibrary(library) == null && exception == null || exception == false)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
				throw "Missing library: " + library;

			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function(_)
			{
				callback();
			});
		}
		else if(Assets.getLibrary(library) == null && library == "mods" && exception != null && exception == true){
			@:privateAccess
			if(!LimeAssets.libraryPaths.exists(library +"/"+exceptionalLib))
				throw "Missing lib: " + library + "/" + exceptionalLib;

			var callback = callbacks.add("library: " + library + "/" + exceptionalLib);
			Assets.loadLibrary(library + "/" + exceptionalLib).onComplete(function(_){
				callback();
			});
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		elapsed = elapsed = 0.88 * FlxG.width;
		funkay.setGraphicSize(Std.int(elapsed + 0.9 * (funkay.width - elapsed)));
		funkay.updateHitbox();

		if (controls.ACCEPT)
		{
			funkay.setGraphicSize(Std.int(funkay.width + 60));
			funkay.updateHitbox();
		}

		if (callbacks != null)
		{
			targetShit = FlxMath.remapToRange(callbacks.numRemaining / callbacks.length, 1, 0, 0, 1);

			elapsed = loadBar.scale.x;
			loadBar.scale.x = elapsed + 0.5 * this.targetShit - elapsed;
		}
	}

	function onLoad()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.switchState(target);
	}

	static function getSongPath()
	{
		return Paths.inst(PlayState.SONG.song);
	}

	static function getVocalPath()
	{
		return Paths.voices(PlayState.SONG.song);
	}

	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false, loadingFromMods:Bool, ?additionalLib:String)
	{
		if(additionalLib == null)
			FlxG.switchState(getNextState(target, stopMusic, loadingFromMods));
		else
			FlxG.switchState(getNextState(target, stopMusic, loadingFromMods, additionalLib));
	}

	static function getNextState(target:FlxState, stopMusic = false, loadingFromMods:Bool, ?additionalLib:String):FlxState
	{
		Paths.setCurrentLevel("week" + PlayState.storyWeek);
		#if NO_PRELOAD_ALL
		var loaded = isSoundLoaded(getSongPath())
			&& (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()))
			&& isLibraryLoaded("shared");

		if (!loaded && additionalLib != null)
			return new LoadingState(target, stopMusic, loadingFromMods, additionalLib);
		else if (!loaded && additionalLib == null)
			return new LoadingState(target, stopMusic, loadingFromMods);
		#end
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();

		return target;
	}

	#if NO_PRELOAD_ALL
	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}

	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	#end

	override function destroy()
	{
		super.destroy();

		callbacks = null;
	}

	static function initSongsManifest()
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);

		if (library != null)
		{
			return Future.withValue(library);
		}

		var path = id;
		var rootPath = null;

		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		if (libraryPaths.exists(id))
		{
			path = libraryPaths[id];
			rootPath = Path.directory(path);
		}
		else
		{
			if (StringTools.endsWith(path, ".bundle"))
			{
				rootPath = path;
				path += "/library.json";
			}
			else
			{
				rootPath = Path.directory(path);
			}
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
		}

		AssetManifest.loadFromFile(path, rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error("Cannot parse asset manifest for library \"" + id + "\"");
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);

			if (library == null)
			{
				promise.error("Cannot open library \"" + id + "\"");
			}
			else
			{
				@:privateAccess
				LimeAssets.libraries.set(id, library);
				library.onChange.add(LimeAssets.onChange.dispatch);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
				promise.error("There is no asset library with an ID of \"" + id + "\"");
		});

		return promise.future;
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String = null;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;

	var unfired = new Map<String, Void->Void>();
	var fired = new Array<String>();

	public function new(callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}

	public function add(id = "untitled")
	{
		id = '$length:$id';
		length++;
		numRemaining++;
		var func:Void->Void = null;
		func = function()
		{
			if (unfired.exists(id))
			{
				unfired.remove(id);
				fired.push(id);
				numRemaining--;

				if (logId != null)
					log('fired $id, $numRemaining remaining');

				if (numRemaining == 0)
				{
					if (logId != null)
						log('all callbacks fired');
					callback();
				}
			}
			else
				log('already fired $id');
		}
		unfired[id] = func;
		return func;
	}

	inline function log(msg):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}

	public function getFired()
		return fired.copy();

	public function getUnfired()
		return [for (id in unfired.keys()) id];
}
