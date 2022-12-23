package;

import Section;
import flixel.util.typeLimit.OneOfTwo;
import Song;

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

	public function new()
	{
	}

	//god forgive me for using dynamics
	public static function mapBPMChanges(song:Dynamic)
	{
		bpmChangeMap = [];

		//hopefully not null
		var curBPM:Int = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		var isNewVerSong:Null<Bool> = null;

		//i have no other option other than using chartVersion, i cant really use isOfType on the song
		if (song.chartVersion == "1.5")
			isNewVerSong = true;
		
		if (song.chartVersion == "1.0")
			isNewVerSong = false;

		trace(isNewVerSong);

		if (isNewVerSong){
			var sex:SwaggiestSong = cast(song);
			for (sec in sex.sections)
			{
				if(sec.changeBPM.active && sec.changeBPM.bpm != curBPM)
				{
					curBPM = sec.changeBPM.bpm;
					var event:BPMChangeEvent = {
						stepTime: totalSteps,
						songTime: totalPos,
						bpm: curBPM
					};
					bpmChangeMap.push(event);
				}

				var deltaSteps:Int = sec.lengthInSteps;
				totalSteps += deltaSteps;
				totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
			}
		}
		else if (!isNewVerSong){
			final sex:SwagSong = cast(song);
			for (i in 0...sex.notes.length)
				{
					if(sex.notes[i].changeBPM && sex.notes[i].bpm != curBPM)
					{
						curBPM = sex.notes[i].bpm;
						var event:BPMChangeEvent = {
							stepTime: totalSteps,
							songTime: totalPos,
							bpm: curBPM
						};
						bpmChangeMap.push(event);
					}
		
					var deltaSteps:Int = sex.notes[i].lengthInSteps;
					totalSteps += deltaSteps;
					totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
				}
		}
		//old functionality ^

		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function changeBPM(newBpm:Int)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}