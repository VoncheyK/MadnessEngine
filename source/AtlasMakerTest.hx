package;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.text.FlxText;
import helpers.SpriteAtlas;
import flixel.FlxSprite;

class AtlasMakerTest extends MusicBeatState
{
	public var background:FlxSprite;
	public var playerBackground:SpriteAtlas;
	public var coordinatesText:FlxText;
	public var controlsText:FlxText;
	public var trackingPoint:FlxSprite;

	var spriteAtlases:FlxTypedGroup<SpriteAtlas> = new FlxTypedGroup<SpriteAtlas>();

	var savedCamX:Float;
	var savedCamY:Float;

	override function create()
	{
		background = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFFA7ACB5);
		add(background);

		playerBackground = new SpriteAtlas(-535, -492, "assets/images/atlas", true, spriteAtlases);
		playerBackground.setGraphicSize(Std.int(playerBackground.width * 0.4));
		//no MORE *transforms into hellclown silver*
		playerBackground.addAnimBySymbol("erm", "GF_SHAKING_BF_she_is_like_real_hot_tho_because_she_is_lullaby_girlfriend", 13, true, 120, 33);
		playerBackground.addAnimBySymbol("lol", "Lullaby_GF_Idle_2", 13, true, 120, 33);
		playerBackground.playAnim("erm");
		add(playerBackground);

		trackingPoint = new FlxSprite(0, 0).makeGraphic(10, 10, FlxColor.RED);
		add(trackingPoint);
	
		coordinatesText = new FlxText(50, 50, 0, "Coordinates: ", 16);
		coordinatesText.alignment = CENTER;
		add(coordinatesText);
	
		controlsText = new FlxText(700, 50, 0, "TRACKING POINT TESTING", 16);
		controlsText.alignment = CENTER;
		add(controlsText);

		savedCamX = 0; // Only runs once!!
		savedCamY = 0;
	}

	override function update(elapsed:Float)
		{
			for (atlas in spriteAtlases.members)
			{
				atlas.update(elapsed);
			}
			if (FlxG.keys.pressed.S)
			{
				playerBackground.playAnim("lol");
			}
			if (FlxG.keys.pressed.R)
			{
				playerBackground.playAnim("erm");
			}
			trackingPoint.x = playerBackground.x;
			trackingPoint.y = playerBackground.y;
			controlsText.text = 'Hold CTRL to adjust 5x faster\n\nHold arrow keys to move\n\nPress K to flip x\nPress L to flip y';
			coordinatesText.text = 'Coordinates\nX: ${playerBackground.x}\nY: ${playerBackground.y}\n\nMeasure\nWidth: ${playerBackground.width}\nHeight: ${playerBackground.height}\n\nFlipped\nflipX: ${playerBackground.flipX}\nflipY: ${playerBackground.flipY}';
			if (FlxG.keys.pressed.UP)
			{
				if (FlxG.keys.pressed.CONTROL)
				{
					playerBackground.y = playerBackground.y - 5;
				}
				else
				{
					playerBackground.y = playerBackground.y - 1;
				}
			}
	
			if (FlxG.keys.pressed.DOWN)
			{
				if (FlxG.keys.pressed.CONTROL)
				{
					playerBackground.y = playerBackground.y + 5;
				}
				else
				{
					playerBackground.y = playerBackground.y + 1;
				}
			}
	
			if (FlxG.keys.pressed.LEFT)
			{
				if (FlxG.keys.pressed.CONTROL)
				{
					playerBackground.x = playerBackground.x - 5;
				}
				else
				{
					playerBackground.x = playerBackground.x - 1;
				}
			}
	
			if (FlxG.keys.pressed.RIGHT)
			{
				if (FlxG.keys.pressed.CONTROL)
				{
					playerBackground.x = playerBackground.x + 5;
				}
				else
				{
					playerBackground.x = playerBackground.x + 1;
				}
			}
	
			if (FlxG.keys.justPressed.K)
			{
				playerBackground.flipX = !playerBackground.flipX;
			}
	
			if (FlxG.keys.justPressed.L)
			{
				playerBackground.flipY = !playerBackground.flipY;
			}
		}
}