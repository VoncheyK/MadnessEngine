package;

import Section;
import helpers.OneOfTwo;
import Song;
import haxe.ds.Either;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Int;
}

class Conductor
{
	public static var bpm:Int = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public function new(){}

	public static function mapBPMChanges(song:UnifiedSongDef)
	{
		bpmChangeMap = [];

		var curBPM:Int = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;

		trace('Loading song of type: ${song.underlyingType}');

		for (section in song.sections){
			if (section.changeBPM && section.newBPM != curBPM){
				curBPM = section.newBPM;
				bpmChangeMap.push({stepTime: totalSteps,songTime: totalPos,bpm: curBPM});
			}

			final deltaSteps:Int = section.lengthInSteps;
			totalSteps+=deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}

		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Int)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}