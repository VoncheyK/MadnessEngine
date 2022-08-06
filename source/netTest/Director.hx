package netTest;

import GameJolt.GameJoltAPI;
import GameJolt.GameJoltInfo;
import GameJolt.GameJoltLogin;
import GameJolt;
import flixel.FlxG;

class Director extends MusicBeatState
{
	override function create()
	{
		switch(GameJoltAPI.getStatus()){
			case true:
				FlxG.switchState(new ServerHandler());
				//we exit the switch statement
			case false:
				GameJoltInfo.changeState = new ServerHandler();
				GameJoltInfo.fontPath = 'assets/fonts/emptyLetters.ttf';
				GameJoltInfo.font = Paths.font('emptyLetters.ttf');
				FlxG.switchState(new GameJoltLogin());
		}
		super.create();
	}
}