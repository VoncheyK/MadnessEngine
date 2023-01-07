package;

import flixel.util.typeLimit.OneOfTwo;
import Section.SwaggiestSection;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

using StringTools;

// support for old and new chart shit
typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>; //var sectionNotes:Array<Dynamic>;var lengthInSteps:Int;var typeOfSection:Int;var mustHitSection:Bool;var bpm:Int;var changeBPM:Bool;var altAnim:Bool;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
	var chartVersion:String;
	var stage:Null<String>;
}

typedef SwaggiestSong =
{
	var song:String;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;
	var player1:String;
	var player2:String;
	var validScore:Bool;

	var notes:Array<SwagNote>;
	var sections:Array<SwaggiestSection>;
	var chartVersion:String;
	var stage:Null<String>;
}

typedef SwagNote =
{
	var noteData:Int;
	var sustainLength:Float;
	var strumTime:Float;
	// var mustHit:Bool;
}

class Song
{
	public var song:String;
	public var notes:Null<Array<SwagNote>>;
	public var sections:Null<Array<SwaggiestSection>>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';

	public var stage:Null<String> = null;

	public function new(song, sections, notes, bpm)
	{
		this.song = song;
		this.sections = sections;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):OneOfTwo<SwagSong, SwaggiestSong>
	{
		var rawJson = Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase(), null)).trim();
		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):OneOfTwo<SwagSong, SwaggiestSong>
	{
		var parsedShit:Dynamic = cast Json.parse(rawJson).song;
		var swagShit:OneOfTwo<SwagSong, SwaggiestSong>;

		if (parsedShit.chartVersion == null || parsedShit.chartVersion != "1.5")
		{
			var data:SwagSong = cast parsedShit;
			if (parsedShit.chartVersion == '1.0'){
				trace("parsedShit on old type");
				swagShit = data;
			}
			else
				swagShit = translate(data);
		}
		else
			swagShit = cast parsedShit;

		Reflect.setField(swagShit, "validScore", true);
		return swagShit;
	}

	overload extern inline public static function translate(song:SwagSong):SwaggiestSong
	{
		// the only thing that really changes are how notes and sections work
		var swagNotes:Array<SwagNote> = [];
		var swagSections:Array<SwaggiestSection> = [];
		for (sec in song.notes)
		{
			swagSections.push({
				mustHit: sec.mustHitSection,
				lengthInSteps: sec.lengthInSteps,
				typeOfSection: sec.typeOfSection,
				changeBPM: {
					active: sec.changeBPM,
					bpm: sec.bpm
				},
				altAnim: sec.altAnim
			});

			for (note in sec.sectionNotes)
				swagNotes.push({
					noteData: note[1],
					sustainLength: note[2],
					strumTime: note[0]
				});
		}

		return {
			song: song.song,
			bpm: song.bpm,
			speed: song.speed,
			needsVoices: song.needsVoices,
			validScore: song.validScore,
			player1: song.player1,
			player2: song.player2,

			notes: swagNotes,
			sections: swagSections,
			chartVersion: "1.5",
			stage: 'stage'
		}
	}

	overload extern inline public static function translate(song:SwaggiestSong):SwagSong
	{
		var sections:Array<SwagSection> = [];
		var ver:String = song.chartVersion;
		for (i => section in song.sections)
		{
			var sectionNotes:Array<Array<Dynamic>> = [];
			for (note in song.notes)
				if (note.strumTime >= (Conductor.stepCrochet * section.lengthInSteps) * i
					&& note.strumTime <= (Conductor.stepCrochet * section.lengthInSteps) * (i + 1))
					sectionNotes.push([note.strumTime, note.noteData, note.sustainLength]);

			sections.push({
				sectionNotes: sectionNotes,
				lengthInSteps: section.lengthInSteps,
				typeOfSection: section.typeOfSection,
				mustHitSection: section.mustHit,
				bpm: section.changeBPM.bpm,
				changeBPM: section.changeBPM.active,
				altAnim: section.altAnim
			});
		}

		return {
			song: song.song,
			notes: sections,
			bpm: song.bpm,
			needsVoices: song.needsVoices,
			speed: song.speed,
			player1: song.player1,
			player2: song.player2,
			validScore: song.validScore,
			stage: 'stage',
			chartVersion: ver
		}
	}
}