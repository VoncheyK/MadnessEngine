package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import Options;
import ClientSettings;

class OptionsSubState extends MusicBeatSubstate
{
	var textMenuItems:Array<String> = ['Downscroll', 'Ghost Tapping'];
	var optionNames:Array<String> = ['downScroll', 'ghostTapping'];

	var selector:FlxSprite;
	var curSelected:Int = 0;

	var grpOptionsTexts:FlxTypedGroup<Alphabet>;

	public function new()
	{
		super();

		grpOptionsTexts = new FlxTypedGroup<Alphabet>();
		add(grpOptionsTexts);

		selector = new FlxSprite().makeGraphic(5, 5, FlxColor.RED);
		add(selector);

		for (i in 0...textMenuItems.length)
		{
			var optionText:Alphabet = new Alphabet(10, 20 + (i * 90), textMenuItems[i], true, false);
			optionText.ID = i;
			optionText.targetY = i;
			grpOptionsTexts.add(optionText);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);



		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (controls.UP_P)
			curSelected -= 1;

		if (controls.DOWN_P)
			curSelected += 1;

		if (curSelected < 0)
			curSelected = textMenuItems.length - 1;

		if (curSelected >= textMenuItems.length)
			curSelected = 0;

		grpOptionsTexts.forEach(function(txt:Alphabet)
			{
	
				txt.color = FlxColor.WHITE;
	
				if (txt.ID == curSelected)
					txt.color = FlxColor.YELLOW;	
			});

		if (controls.ACCEPT)
		{
			FlxG.save.data.optionNames[curSelected] = !FlxG.save.data.optionNames[curSelected];
			FlxG.save.flush();
			trace(optionNames[curSelected] + " : " + FlxG.save.data.optionNames[curSelected]);
		}
	}
}
