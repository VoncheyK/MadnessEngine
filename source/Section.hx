package;

import Song;

typedef SwagSection =
{
	var sectionNotes:Array<Array<Dynamic>>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;
}

typedef SwaggiestSection = 
{
	var mustHit:Bool;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var changeBPM:{active:Bool,bpm:Int}; //this will most likely change later
	var altAnim:Bool; 
	//maybe sectionizing notes can fix them being so stupid??
	var sectionNotes:Array<Song.SwagNote>;
}

@:structInit class UnifiedSectionDef{
	//go for the better, honestly i dont like the current dynamic system
	public var lengthInSteps:Int;
	public var typeOfSection:Int;
	public var altAnim:Bool;
	public var mustHit:Bool;
	public var changeBPM:Bool;
	public var newBPM:Int;
	public var underlyingType:Song.UnderlyingTypes;
	public var sectionNotes:Null<Array<Array<Float>>> = null;

	public static function fromSwagSection(swag:SwagSection):UnifiedSectionDef {
		final conv:Array<Array<Float>> = [];
		for (note in swag.sectionNotes)
			//just a few checks incase this is loading a note which has strings in the type
			if (note[0] is Float && note[1] is Int && note[2] is Float)
				conv.push([note[0], note[1], note[2]]);

		return {	
			typeOfSection: swag.typeOfSection,
			lengthInSteps: swag.lengthInSteps,
			mustHit: swag.mustHitSection,
			newBPM: swag.bpm,
			changeBPM: swag.changeBPM,
			altAnim: swag.altAnim,
			sectionNotes: conv,
			underlyingType: Song.UnderlyingTypes.Swag
		};
	}

	public static function fromSwaggiest(swag:SwaggiestSection):UnifiedSectionDef 
		return {
			mustHit: swag.mustHit,
			lengthInSteps: swag.lengthInSteps,
			typeOfSection: swag.typeOfSection,
			changeBPM: swag.changeBPM.active,
			newBPM: swag.changeBPM.bpm,
			altAnim: swag.altAnim,
			underlyingType: Song.UnderlyingTypes.Swaggiest
		};
}

class Section
{
	public var sectionNotes:Array<Dynamic> = [];

	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		this.lengthInSteps = lengthInSteps;
	}
}