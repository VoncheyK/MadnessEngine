package;

import flixel.FlxG;
import haxe.PosInfos;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{	
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"]; //fix shit :(

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

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
}
