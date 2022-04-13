package;

import flixel.FlxG;
import haxe.PosInfos;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

using StringTools;

class CoolUtil
{	
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"]; //fix shit :(
	public static var defaultDifficulty:String = 'NORMAL';

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if(num == null) num = PlayState.storyDifficulty;

		var fileSuffix:String = difficultyArray[num];
		if(fileSuffix != defaultDifficulty)
		{
			fileSuffix = '-' + fileSuffix;
		}
		else
		{
			fileSuffix = '';
		}
		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	inline public static function coolTrace(text:Dynamic, infos:PosInfos) { // so it can be used in callbacks????
		trace(text, infos);
	}

	inline public static function bound(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function grantAchivement(name):String // wtf does this do??
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function useless(path:String):String {
		var daText = Assets.getText(path);

		return daText;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	// uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void { // psych engine
		if (!Assets.cache.hasSound(Paths.sound(sound, library))) {
			FlxG.sound.cache(Paths.sound(sound, library));
		}
	}

	public static function browserLoad(site:String) { // psych engine
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
	
	//this is an utility that formats the song name,
	//for example, if the song is winter-horrorland
	//this utility makes the song name Winter Horrorland
	//useful for adding watermarks etc.
	public static function coolSongFormatter(song:String):String
        {
            var swag:String = song.replace('-', ' ').toLowerCase();
            var splitSong:Array<String> = swag.split(' ');
    
            for (i in 0...splitSong.length)
            {
                var firstLetter = splitSong[i].substring(0, splitSong[i].length - (splitSong[i].length - 1));
                var coolSong:String = splitSong[i].replace(firstLetter, firstLetter.toUpperCase());

                for (a in 0...splitSong.length)
                {
                    var stringSong:String = Std.string(splitSong[a+1]);
                    var stringFirstLetter:String = stringSong.substring(0, stringSong.length - (stringSong.length - 1));
                    coolSong += ' ${stringSong.toLowerCase().replace(stringFirstLetter.toLowerCase(), stringFirstLetter.toUpperCase())}';
                }
                
                return coolSong.replace(' Null', '');
            }
    
            return swag;
        }
}
