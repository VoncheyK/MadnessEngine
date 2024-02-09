package;

import openfl.media.Sound;
import openfl.display.BitmapData;
import sys.io.File;
import helpers.Modsupport;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.AssetCache;

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

	//psych engine code
	static public function modFolders(key:String) {
		for(mod in Modsupport.modz){
			final fileToCheck:String = mods('$mod/$key');
			if(FileSystem.exists(fileToCheck))
				return fileToCheck;
		}
		return 'mods/$key';
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
		return 'assets/$file';

	inline static public function mods(modLib:String)
		return 'mods/$modLib';
	
	inline static public function modtxt(key:String)
		return modFolders('data/$key.txt');

	inline static public function modImage(key:String)
		return modFolders('images/$key.png');

	inline public static function modSound(key:String) 
		return modFolders('sounds/$key.$SOUND_EXT');

	inline public static function modStageLoader(mod:String, stage:String):String{
		var stagePath = 'mods/$mod/stages/';
		if (FileSystem.exists(stagePath))
		{
			stagePath = 'mods/$mod/stages/${stage}Init.hscript';
			if (FileSystem.exists(stagePath))
				return stagePath;
			else if (FileSystem.exists('mods/$mod/stages/${stage}Details.json'))
				return 'mods/$mod/stages/${stage}Details.json';
			else return null;
		}
		else return null;
	}

	inline static public function getFromMods(modLib:String, dir:String, file:String)
		return Paths.mods(modLib)+'/$dir/'+file; //dumbass me (ziad/zoardedz) made a typo here and it was making it look like modname,/DIR/filename nad the dir wouldnt change it would just be dir bec i forgor $ sign

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
		return getPath(file, type, library);
	
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

	inline static public function modsXml(key:String) {
		return modFolders('images/$key.xml');
	}

	//mod is the library, key is the json name and song is the song dir or the lib
	inline static public function modJSON(key:String)
	{
		return modFolders('data/' + key + '.json');
	}

	inline static public function json(key:String, ?library:String)
	{
		if (FileSystem.exists(modJSON(key))) return modJSON(key);
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function script(key:String, ?library:String)
	{
		return getPath('scripts/$key', TEXT, library);
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

	inline static public function voicePath(song:String, ?mod:String){
		var path:String = 'mods/$mod/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
		if (!FileSystem.exists(path))
			path = 'assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
		return path;
	}

	inline static public function instPath(song:String, ?mod:String){
		var path:String = 'mods/$mod/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
		if (!FileSystem.exists(path))
			path = 'assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
		
		return path;
	}

	inline static public function voices(song:String, ?mod:String)
		return Sound.fromFile('./' + voicePath(song, mod));

	inline static public function inst(song:String, ?mod:String)
		return Sound.fromFile('./' + instPath(song, mod));

	inline static public function image(key:String, ?library:String)
	{
		if (FileSystem.exists(modImage(key))) return modImage(key);
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function getAtlas(folder:String)
	{
		return 'assets/shared/${folder}';
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function formatToSongPath(path:String) {
		return path.toLowerCase().replace(' ', '-');
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		var imageLoaded:FlxGraphic = FlxGraphic.fromBitmapData(openfl.display.BitmapData.fromFile(modImage(key)));
		var xmlExists:Bool = false;
		if(FileSystem.exists(modsXml(key)))
			xmlExists = true;
		
		if (xmlExists)
			return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)), (xmlExists ? File.getContent(modsXml(key)) : file('images/$key.xml', library)));
		
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getSparrowAtlasW7(key:String, ?library:String)
		return FlxAtlasFrames.fromSparrow(image(key, library), getPath('images/$key.xml', TEXT, library));

	inline static public function getPackerAtlas(key:String, ?library:String)
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	
	inline static public function getZip(key:String, library:String)
		return 'assets/$library/$key.zip';
}
