package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import Options;
import ClientSettings;

class OptionsSubState extends MusicBeatSubstate
{
	var textMenuItems:Array<String> =  //the option name
	[
		'Downscroll',
		'Middlescroll',
		'Ghost Tapping',
		'Show Accuracy'
	];
	var optionNames:Array<String> = //the variable name for the option on ClientSettings
	[
		'downScroll',
		'middleScroll',
		'ghostTapping',
		'displayAccuracy'
	];

	private var currentDescription:String = "";
	public static var descriptionText:FlxText;

	var selector:FlxSprite;
	var curSelected:Int = 0;
	var grpOptionsTexts:FlxTypedGroup<Alphabet>;

	override function create()
	{
		super.create();

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		menuBG.color = 0x063970;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpOptionsTexts = new FlxTypedGroup<Alphabet>();
		add(grpOptionsTexts);

		selector = new FlxSprite().makeGraphic(5, 5, FlxColor.RED);
		add(selector);

		for (i in 0...textMenuItems.length)
		{
			var optionText:Alphabet = new Alphabet(0, 20 + (i * 90), textMenuItems[i], true, false);
			optionText.ID = i;
			optionText.targetY = i;
			optionText.screenCenter(X);
			grpOptionsTexts.add(optionText);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.UP_P)
			changeSelection(-1);

		if (controls.DOWN_P)
			changeSelection(1);

		if (controls.BACK){
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}

		if (controls.ACCEPT){
			FlxG.save.data.optionNames[curSelected] = !FlxG.save.data.optionNames[curSelected];
			trace(optionNames[curSelected] + " : " + FlxG.save.data.optionNames[curSelected]);
		}
		FlxG.save.flush();
	}

	function changeSelection(change:Int)
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = textMenuItems.length - 1;
		if (curSelected >= textMenuItems.length)
			curSelected = 0;
		
		FlxG.sound.play(Paths.sound("scrollMenu"));

		grpOptionsTexts.forEach(function(txt:Alphabet)
		{
			txt.color = FlxColor.WHITE;

			if (txt.ID == curSelected)
			{
				txt.color = FlxColor.YELLOW;
			}		
		});
	}
}
