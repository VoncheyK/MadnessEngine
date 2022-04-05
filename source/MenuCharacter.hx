package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class MenuCharacter extends FlxSprite
{
	public var character:String;
	private var danceLeft:Bool = false;

	//will softcode later im lazye also credits to kade!!!
	private var data:Map<String, Array<Dynamic>> = [
		'bf' => [0, -20, 1.0],
		'gf' => [50, 80, 1.5],
		'dad' => [-15, 130],
		'spooky' => [20, 30],
		'pico' => [0, 0, 1.0],
		'mom' => [-30, 140, 0.85],
		'parents-christmas' => [100, 130, 1.8],
		'senpai' => [-40, -45, 1.4]
	];

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		this.character = character;

		antialiasing = true;

		frames = Paths.getSparrowAtlas('campaign_menu_UI_characters');

		animation.addByPrefix('bf', "BF idle dance white", 24, false);
		animation.addByPrefix('bfConfirm', 'BF HEY!!', 24, false);
		animation.addByIndices('gf-left', 'GF Dancing Beat WHITE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		animation.addByIndices('gf-right', 'GF Dancing Beat WHITE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		animation.addByPrefix('dad', "Dad idle dance BLACK LINE", 24, false);
		animation.addByIndices('spooky-left', 'spooky dance idle BLACK LINES', [0, 2, 6], "", 12, false);
		animation.addByIndices('spooky-right', 'spooky dance idle BLACK LINES', [8, 10, 12, 14], "", 12, false);
		animation.addByPrefix('pico', "Pico Idle Dance", 24, false);
		animation.addByPrefix('mom', "Mom Idle BLACK LINES", 24, false);
		animation.addByPrefix('parents-christmas', "Parent Christmas Idle", 24, false);
		animation.addByPrefix('senpai', "SENPAI idle Black Lines", 24, false);
		// Parent Christmas Idle

		animation.play(character);
		updateHitbox();
	}

	public function setCharacter(character:String):Void
	{
		var sameCharacter:Bool = character == this.character;
		this.character = character;
		if (character == '')
		{
			visible = false;
			return;
		}
		else
		{
			visible = true;
		}

		if (!sameCharacter)
		{
			dance(true);
		}

		var data = this.data[character];
		offset.set(data[0], data[1]);
		setGraphicSize(Std.int(width * data[2]));
	}

	public function dance(LastFrame:Bool = false):Void
	{
		if (character == 'gf' || character == 'spooky')
		{
			danceLeft = !danceLeft;

			if (danceLeft)
				animation.play(character + "-left", true);
			else
				animation.play(character + "-right", true);
		}
		else if (character == '')
		{
			return;
		} 
		else
		{
			if (animation.name == "bfConfirm")
				return;
			animation.play(character, true);
		}
		if (LastFrame)
		{
			animation.finish();
		}
	}
}
