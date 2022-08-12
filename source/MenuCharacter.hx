package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class CharInfo
{
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var scale(default, null):Float;
	public var flippedX(default, null):Bool;

	public function new(x:Int = 0, y:Int = 0, scale:Float = 1.0, flippedX:Bool = false)
	{
		this.x = x;
		this.y = y;
		this.scale = scale;
		this.flippedX = flippedX;
	}
}

class MenuCharacter extends FlxSprite
{
	//will softcode later im lazye also credits to kade!!!
	private static var infos:Map<String, CharInfo> = [
		'bf' => new CharInfo(0, -20, 1.0, true),
		'gf' => new CharInfo(50, 80, 1.5, true),
		'dad' => new CharInfo(-15, 130),
		'spooky' => new CharInfo(20, 30),
		'pico' => new CharInfo(0, 0, 1.0, true),
		'mom' => new CharInfo(-30, 140, 0.85),
		'parents-christmas' => new CharInfo(100, 130, 1.8),
		'senpai' => new CharInfo(-40, -45, 1.4)
	]; // sorry, this will be removed later
	// just so the engine ui doesnt look weird until we do it

	private var flippedX:Bool = false;

	private var danceLeft:Bool = false;
	private var character:String = '';

	public function new(x:Int, y:Int, scale:Float, flippedX:Bool)
	{
		super(x, y);
		this.flippedX = flippedX;

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

		setGraphicSize(Std.int(width * scale));
		updateHitbox();
	}

	public function setCharacter(character:String):Void
	{
		var isCharSame:Bool = character == this.character;
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

		if (!isCharSame)
		{
			dance(true);
		}

		var info:CharInfo = infos[character];
		offset.set(info.x, info.y);
		setGraphicSize(Std.int(width * info.scale));
		flipX = info.flippedX != flippedX;
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