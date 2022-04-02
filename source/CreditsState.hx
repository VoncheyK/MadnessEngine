package;

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
	var credit1:FlxText;

	var credits:Array<Dynamic> = [
		"Vonchy -  Main Programmer",
		"Jorge - Programmer",
		"BeastlyGhost - Programmer",
		"k2knotfound - Programmer",
		"Ziad - Programmer"
	];

override function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGMagenta'));
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.screenCenter();
		add(bg);

		for (index => credit in credits) {
			credit1 = new FlxText(100, 150 + (50 * index), FlxG.width, credit, 32);
			credit1.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			credit1.screenCenter(X);
			add(credit1);
		}

		/*
		credit1 = new FlxText(100, 150, FlxG.width, "Vonchy - Lead Coder", 32);
	    credit1.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	    credit1.screenCenter(X);
	    add(credit1);
        credit1 = new FlxText(100, 200, FlxG.width, "Jorge - Coder", 32);
	    credit1.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	    credit1.screenCenter(X);
	    add(credit1);
        credit1 = new FlxText(100, 250, FlxG.width, "BeastlyGhost - Coder", 32);
	    credit1.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	    credit1.screenCenter(X);
	    add(credit1);
        credit1 = new FlxText(100, 300, FlxG.width, "k2knotfound - Coder", 32);
	    credit1.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	    credit1.screenCenter(X);
	    add(credit1);
        credit1 = new FlxText(100, 350, FlxG.width, "TheRealJake_13 - Coder", 32);
	    credit1.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	    credit1.screenCenter(X);
	    add(credit1);
		*/
        credit1 = new FlxText(100, 75, FlxG.width, "Madness Engine dev", 54);
	    credit1.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	    credit1.screenCenter(X);
	    add(credit1);

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
