package;

import flixel.group.FlxGroup.FlxTypedGroup;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.util.FlxColor;

using StringTools;

class CreditsState extends MusicBeatState
{
	//alphabet is shitty so ill stick to flxtext
	var credits:FlxTypedGroup<FlxText>; //Alphabet
	//will maybe soft code later
	var text:Array<String> = [
		"",
		"Vonchy - Lead Coder",
		"Jorge - Coder",
		"BeastlyGhost - Coder",
		"k2knotfound - Coder",
		"TheRealJake_13 - Coder",	
	];

	override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGMagenta'));
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.screenCenter();
		add(bg);
		
		var title = new FlxText(0, 100, FlxG.width, "Madness Engine Developers", 42);
		title.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		title.screenCenter(X);
		add(title);
		credits = new FlxTypedGroup<FlxText>();
		add(credits);
		for (i in 0...text.length)
		{
			var text = new FlxText(100, 100 + (i * 50), FlxG.width, text[i], 32);
			text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.screenCenter(X);
			credits.add(text);
		}

        var leText:String = "Press ANYTHING To return to main menu.";
		var size:Int = 16;
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);
    }

    override function update(elapsed:Float)
        {
            if (FlxG.keys.justPressed.ANY)
            {
                FlxG.switchState(new MainMenuState());
            }
    
            super.update(elapsed);
        }
    }