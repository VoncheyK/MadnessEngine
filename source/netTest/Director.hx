package netTest;

import flixel.FlxSubState;
import GameJolt.GameJoltAPI;
import GameJolt.GameJoltInfo;
import GameJolt.GameJoltLogin;
import GameJolt;
import flixel.FlxG;
import ui.Prompt;

class Director extends MusicBeatState
{
	override function create()
	{
		switch(GameJoltAPI.getStatus()){
			case true:
				FlxG.switchState(new ServerHandler());
				//we exit the switch statement
			case false:
				openPrompt(MultiplayerPromptShit.showGameJoltLogin());
		}
		super.create();
	}

	public static function cancelledRequestShit():Void
	{
		FlxG.switchState(new MainMenuState());
	}

	public function openPrompt(target:FlxSubState, ?openCallback:Void->Void)
		{
			target.closeCallback = function()
			{
				if (openCallback != null)
					openCallback();
			}
	
			openSubState(target);
		}

	public function openPromptW(target:FlxSubState, ?openCallback:Void->Void)
        {
            var whatever:Void->Void;
            if (openCallback != null)
            {
                whatever = function() {
                    openCallback();
                }
            }
    
            openPrompt(target, openCallback);
        }
}