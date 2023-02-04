package;

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
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