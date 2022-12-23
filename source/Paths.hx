package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline public static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function mods(modLib:String)
	{
		return 'assets/mods/$modLib';
	}
	
	inline static public function modtxt(modLib:String, key:String)
	{
		return 'mods:${Paths.mods(modLib)}/data/$key.txt';
	}

	inline static public function getFromMods(modLib:String, dir:String, file:String){
		return Paths.mods(modLib)+'/$dir/'+file; //dumbass me (ziad/zoardedz) made a typo here and it was making it look like modname,/DIR/filename nad the dir wouldnt change it would just be dir bec i forgor $ sign
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}
	
	inline public static function getWeek(key:String, ?library:String){
		return getPath('$key.json', TEXT, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}
	//mod is the library, key is the json name and song is the song dir or the lib
	inline static public function modJSON(mod:String, key:String)
	{
		return 'mods:assets/mods/${mod}/data/${key}.json';
	}

	inline static public function json(key:String, ?library:String, ?mod:String)
	{
		if (mod == null)
			return getPath('data/$key.json', TEXT, library) 
		else
			return modJSON(mod, key);
	}

	inline static public function script(key:String, ?library:String)
	{
		return getPath('scripts/$key.hscript', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String, ?mod:String)
	{
		if(mod == null)
			return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
		else
			return 'mods:assets/mods/${mod}/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String, ?mod:String)
	{
		if (mod == null)
			return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
		else
			return 'mods:assets/mods/${mod}/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function getAtlas(folder:String)
	{
		return 'assets/shared/${folder}';
	}

	/**
	 * Loading the image, credits to Kade Engine for this!
	 * @param key 
	 * @param library 
	 * @return FlxGraphic
	 */
	static public function loadImage(key:String, ?library:String):FlxGraphic
	{
		var path = image(key, library);
		if (OpenFlAssets.exists(path, IMAGE)) {
			var bitmap = OpenFlAssets.getBitmapData(path);
			return FlxGraphic.fromBitmapData(bitmap);
		} else {
			trace('no image found in $path');
			return null;
		}
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}

	inline public static function getScript(fileName:String)
	{
		return 'assets/scripts/${fileName}';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function modSparrowAtlas(key:String, modName:String)
	{
		return FlxAtlasFrames.fromSparrow('mods:assets/mods/$modName/images/$key.png', 'mods:assets/mods/$modName/images/$key.xml');
	}

	inline static public function getSparrowAtlasW7(key:String, ?library:String)
	{
			return FlxAtlasFrames.fromSparrow(image(key, library), getPath('images/$key.xml', TEXT, library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
	
	inline static public function getZip(key:String, library:String){
		return 'assets/$library/$key.zip';
	}
}
