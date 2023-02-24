package;

import lime.utils.Assets;
import haxe.ds.Map;
#if sys
import sys.io.File;
#end

using StringTools;
using Lambda;

class CoolUtil
{	
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function difficultyString():String
	{
		return difficultyArray[PlayState.storyDifficulty];
	}

	public static function grantAchivement(name):String // wtf does this do??
	{
		return difficultyArray[PlayState.storyDifficulty];
	}
	
	//credits to yanni for the getkeyfromval code (i edited it to add types n shit)
	public static function getKeyFromValue<KEY, VALUE>(map:Map<KEY, VALUE>, value:VALUE):KEY{
			try {
				for (map_key => map_value in map)
					{
						if(map_value == value) return map_key;
					}
			}
			catch (e) {
				trace('error: $e');
			}

			return null; //lets just do this for now
		}

	
	inline public static function bound(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(max, value));
	}

	public static function useless(path:String):String {
		var daText = Assets.getText(path);

		return daText;
	}
	
	public static function lerpShit(elapsed:Float, mult:Float):Float {
		return Math.max(0, Math.min(1, elapsed * mult));
	}

	public static function GetTypeOf(thing:Dynamic):Dynamic
	{
		return Type.typeof(thing);
	}

	public static function coolTextFile(path:String):Null<Array<String>>
	{
		if (sys.FileSystem.exists(path)){
			var daList:Array<String> = File.getContent(path).trim().split('\n');
			if (daList != null){
				for (i in 0...daList.length)
				{
					daList[i] = daList[i].trim();
				}
	
				return daList;
			}
			else
				return null;
		}
		else
			return null;
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
}
