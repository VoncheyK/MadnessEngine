package;

import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import ClientSettings;

class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var textMenuItems:Array<String> =  //the option name
	[
		'',
		'',
		'',
		'WIP',
		'',
		''
	];
	var optionNames:Array<String> = //the variable name for the option on ClientSettings
	[
		'downScroll',
		'middleScroll',
		'ghostTapping',
		'displayAccuracy',
		'showTimeBar',
		'showTimeTxt'
	];

	var options:Array<Dynamic> = //the variable name for the option on ClientSettings
	[
		["Ghost tapping", 'ghostTapping', 'Pressing an arrow wont cause a miss', Bool],
		["Downscroll", 'downScroll', 'Toggles downscroll', Bool]
	];

	var grpOptionsTexts:FlxTypedGroup<Alphabet>;
	var controlsStrings:Array<String> = [];

	private var currentDescription:String = "";	public static var descriptionText:FlxText;
	private var grpControls:FlxTypedGroup<Alphabet>;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		controlsStrings = CoolUtil.coolTextFile(Paths.txt('controls'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		grpOptionsTexts = new FlxTypedGroup<Alphabet>();
		add(grpOptionsTexts);

		currentDescription = "descriptions should be here!";

		descriptionText = new FlxText(FlxG.width - 460, 10, 450, "", 12);
		descriptionText.setFormat("VCR OSD Mono", 24, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descriptionText.borderSize = 2;
		descriptionText.scrollFactor.set();
		descriptionText.text = currentDescription;
		add(descriptionText);

		/* 
			grpControls = new FlxTypedGroup<Alphabet>();
			add(grpControls);

			for (i in 0...controlsStrings.length)
			{
				if (controlsStrings[i].indexOf('set') != -1)
				{
					var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i].substring(3) + ': ' + controlsStrings[i + 1], true, false);
					controlLabel.isMenuItem = true;
					controlLabel.targetY = i;
					grpControls.add(controlLabel);
				}
				// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			}
		 */

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 20 + (i * 90), options[i][1], true, false);
			optionText.ID = i;
			optionText.targetY = i;
			optionText.screenCenter(X);
			grpOptionsTexts.add(optionText);
		}

		super.create();

		//openSubState(new OptionsSubState());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed); 
		/*if (controls.ACCEPT) {
			changeBinding();
		}*/

		if (isSettingControl)
			waitingInput();
		else
		{
			if (controls.BACK)
				FlxG.switchState(new MainMenuState());
			/*if (controls.UP_P)
				changeSelection(-1);
			if (controls.DOWN_P)
				changeSelection(1);*/
		}
		FlxG.save.flush();
	}

	function waitingInput():Void
	{
		if (FlxG.keys.getIsDown().length > 0) {
			PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxG.keys.getIsDown()[0].ID, null);
		}
		// PlayerSettings.player1.controls.replaceBinding(Control)
	}

	var isSettingControl:Bool = false;

	function changeBinding():Void
	{
		if (!isSettingControl)
		{
			isSettingControl = true;
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}

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
