package netTest;

import flixel.FlxSprite;
import GameJolt;
import flixel.FlxG;
import ui.Prompt;

class Director extends MusicBeatState
{
	var prompt:MultiPrompt;
	var bg:FlxSprite;

	override function create()
		{
			switch(GameJoltAPI.getStatus())
			{
				case true:
					LoadingState.loadAndSwitchState(new ServerHandler()); //normal stuff
				case false:
					bg = new FlxSprite(-80).loadGraphic(Paths.image('multiplayerBG'));
					bg.scrollFactor.x = 0;
					bg.scrollFactor.y = 0.18;
					bg.setGraphicSize(Std.int(bg.width * 0.7));
					bg.updateHitbox();
					bg.screenCenter();
					bg.antialiasing = true;
					add(bg);
					//open prompt
					prompt = new MultiPrompt("\n You need to sign in\n to GameJolt for\n Multiplayer", Custom("ok", "no"));
					prompt.back.alpha = 0.6;
					prompt.onYes = function()
						{
							GameJoltInfo.changeState = new MainMenuState();
							remove(bg);
							FlxG.switchState(new GameJoltLogin());
							prompt.setButtons(None);
							prompt.exists = false;
							prompt.close();		
						}
					prompt.onNo = function()
						{
							remove(bg);
							FlxG.switchState(new MainMenuState());
							prompt.setButtons(None);
							prompt.exists = false;
							prompt.close();
						}
						openSubState(prompt);
			}
		}
}