package netTest;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import io.colyseus.Client;
import netTest.schemaShit.BattleState;
import flixel.FlxG;
import GameJolt.GameJoltAPI;
import GameJolt.GameJoltInfo;
import GameJolt.GameJoltLogin;
import GameJolt;
import flixel.util.FlxColor;

class MultiplayerMenu extends MusicBeatState
{
	var client = new Client("ws://localhost:2567");

	override function create()
	{
		FlxG.mouse.visible = true;
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		switch(GameJoltAPI.getStatus()){
			case true:
				trace('the j');
			case false:
				GameJoltInfo.changeState = new MultiplayerMenu();
				GameJoltInfo.fontPath = 'assets/fonts/emptyLetters.ttf';
				GameJoltInfo.font = Paths.font('emptyLetters.ttf');
				FlxG.switchState(new GameJoltLogin());
		}


		var bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, 0.17);
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

	
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}