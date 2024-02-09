package;

import Section.UnifiedSectionDef;
import sys.FileStat;
import haxe.ds.Either;
import helpers.OneOfTwo;
import Section.SwaggiestSection;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import sys.io.File;
import sys.FileSystem;
import lime.utils.Assets;

using StringTools;

// support for old and new chart shit
typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var validScore:Bool;
	var chartVersion:String;
	var stage:Null<String>;

	var events:Array<EventNote>;
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

	var sections:Array<SwaggiestSection>;
	var chartVersion:String;
	var stage:Null<String>;

	var notes:Array<SwagNote>;

	var events:Array<EventNote>;
}

typedef SwagNote =
{
	var strumTime:Float;
	var noteData:Int;
	var sustainLength:Float;
	var mustHit:Bool;
}

typedef EventNote = {
	var eventData:{step:Int, event:String, param1:String, param2:String};
}

enum UnderlyingTypes{
	Swaggiest;
	Swag;
}

@:structInit class UnifiedSongDef{
	public var song:String;
	public var bpm:Int;
	public var needsVoices:Bool;
	public var stage:Null<String>;
	public var events:Array<EventNote>;
	public var speed:Float;
	public var player1:String;
	public var player2:String;
	public var validScore:Bool;
	public var notes:Array<SwagNote>;
	public var underlyingType:UnderlyingTypes;

	//kms
	public var sections:Array<UnifiedSectionDef>;

	public static function fromSwagSong(swag:SwagSong):UnifiedSongDef {
		final conv:Array<SwagNote> = [];
		for (sec in swag.notes)
			for (note in sec.sectionNotes)
				//just a few checks incase this is loading a note which has strings in the type
				if (note[0] is Float && note[1] is Int && note[2] is Float)
					conv.push({strumTime: note[0], noteData: Std.int(note[1]), sustainLength: note[2], mustHit: sec.mustHitSection});

		return {
			song: swag.song,
			bpm: swag.bpm,
			needsVoices: swag.needsVoices,
			stage: swag.stage,
			speed: swag.speed,
			events: swag.events,
			player1: swag.player1,
			player2: swag.player2,
			validScore: swag.validScore,
			underlyingType: UnderlyingTypes.Swag,
			notes: conv,
			sections: [for(sec in swag.notes)UnifiedSectionDef.fromSwagSection(sec)],
		}
	}

	public static function fromSwaggiestSong(swag:SwaggiestSong):UnifiedSongDef {
		return {
			song: swag.song,
			bpm: swag.bpm,
			needsVoices: swag.needsVoices,
			stage: swag.stage,
			speed: swag.speed,
			events: swag.events,
			player1: swag.player1,
			player2: swag.player2,
			validScore: swag.validScore,
			notes: swag.notes,
			underlyingType: UnderlyingTypes.Swaggiest,
			sections: [for(sec in swag.sections)UnifiedSectionDef.fromSwaggiest(sec)]
		};
	}

	//because if you want to
	overload extern inline public static function fromVariable(originel:OneOfTwo<SwagSong, SwaggiestSong>):UnifiedSongDef {
		return switch(originel){
			case Left(l):
				final conv:Array<SwagNote> = [];
				for (sec in l.notes)
					for (note in sec.sectionNotes)			
						if (note[0] is Float && note[1] is Int && note[2] is Float)
							conv.push({strumTime: note[0], noteData: Std.int(note[1]), sustainLength: note[2], mustHit: sec.mustHitSection});

				{
					song: l.song,
					bpm: l.bpm,
					needsVoices: l.needsVoices,
					stage: l.stage,
					speed: l.speed,
					events: l.events,
					player1: l.player1,
					player2: l.player2,
					validScore: l.validScore,
					underlyingType: UnderlyingTypes.Swag,
					notes: conv,
					sections: [for(sec in l.notes)UnifiedSectionDef.fromSwagSection(sec)]
				};
			case Right(r):
				{
					song: r.song,
					bpm: r.bpm,
					needsVoices: r.needsVoices,
					stage: r.stage,
					speed: r.speed,
					events: r.events,
					player1: r.player1,
					player2: r.player2,
					validScore: r.validScore,
					notes: r.notes,
					underlyingType: UnderlyingTypes.Swaggiest,
					sections: [for(sec in r.sections)UnifiedSectionDef.fromSwaggiest(sec)]
				};
		}
	};

	overload extern inline public static function fromVariable(originel:Dynamic):UnifiedSongDef {
		//casting tiem
		var ret:UnifiedSongDef = null;

		inline function returnUniFromSwaggiest():UnifiedSongDef {
			final swag:SwaggiestSong = cast originel;

			return {
				song: swag.song,
				bpm: swag.bpm,
				needsVoices: swag.needsVoices,
				stage: swag.stage,
				speed: swag.speed,
				events: swag.events,
				player1: swag.player1,
				player2: swag.player2,
				validScore: swag.validScore,
				notes: swag.notes,
				underlyingType: UnderlyingTypes.Swaggiest,
				sections: [for(sec in swag.sections)UnifiedSectionDef.fromSwaggiest(sec)]
			};
		}

		switch(originel.chartVersion){
			case "1.0":
				final swag:SwagSong = cast originel;

				final conv:Array<SwagNote> = [];
				for (sec in swag.notes)
					for (note in sec.sectionNotes)
						if (note[0] is Float && note[1] is Int && note[2] is Float)
							conv.push({strumTime: note[0], noteData: Std.int(note[1]), sustainLength: note[2], mustHit: sec.mustHitSection});

				ret = {
					song: swag.song,
					bpm: swag.bpm,
					needsVoices: swag.needsVoices,
					stage: swag.stage,
					speed: swag.speed,
					events: swag.events,
					player1: swag.player1,
					player2: swag.player2,
					validScore: swag.validScore,
					underlyingType: UnderlyingTypes.Swag,
					notes: conv,
					sections: [for(sec in swag.notes)UnifiedSectionDef.fromSwagSection(sec)]
				}
			case "1.5":
				ret = returnUniFromSwaggiest();				
			default: 
				ret = returnUniFromSwaggiest();
		}

		return ret;
	}
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
	public var stats:FileStat = null;

	public function new(song, sections, notes, bpm)
	{
		this.song = song;
		this.sections = sections;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):UnifiedSongDef
	{
		var rawJson = File.getContent(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase(), null)).trim();
		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):UnifiedSongDef
	{
		var parsedShit:Dynamic = cast Json.parse(rawJson).song;
		var swagShit:UnifiedSongDef = null;

		if (parsedShit.chartVersion == "1.5")
			swagShit = UnifiedSongDef.fromSwaggiestSong(parsedShit);
		else if (parsedShit.chartVersion == "1.0" || parsedShit.chartVersion == null)
			swagShit = UnifiedSongDef.fromSwagSong(parsedShit);

		swagShit.validScore = true;
		return swagShit;
	}

	overload extern inline public static function translate(song:SwagSong):SwaggiestSong
	{
		/*// the only thing that really changes are how notes and sections work
		var swagNotes:Array<SwagNote> = [];
		var swagSections:Array<SwaggiestSection> = [];

		for ()

		for (sec in song.notes)
		{
			/*for (note in sec.sectionNotes)
				swagNotes.push({
					noteData: note[1],
					sustainLength: note[2],
					strumTime: note[0]
				});

			swagSections.push({
				mustHit: sec.mustHitSection,
				lengthInSteps: sec.lengthInSteps,
				typeOfSection: sec.typeOfSection,
				changeBPM: {
					active: sec.changeBPM,
					bpm: sec.bpm
				},
				altAnim: sec.altAnim,
				//perhaps
				//sectionNotes: swagNotes
			});
		}

		if (song.events == null)
			song.events = [];*/

		return {
			song: "tutorial",
			bpm: 90,
			speed: 1.0,
			needsVoices: true,
			validScore: true,
			player1: "bf",
			player2: "gf",

			//notes: swagNotes,
			sections: [],
			chartVersion: "1.5",
			stage: 'stage',
			events: [],
			notes: []
		}
	}
}