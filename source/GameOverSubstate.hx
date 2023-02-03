package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Character;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public function new(x:Float, y:Float, play:PlayState)
	{
		//code transported to playstate
		var daStage = PlayState.curStage;
		switch (daStage)
		{
			case 'school':
				stageSuffix = '-pixel';
			case 'schoolEvil':
				stageSuffix = '-pixel';
			default:
		}

		super();

		Conductor.songPosition = 0;

		if (play.playstateCache.hasBitmapData("death"))
		{
			trace("found cache");
			//using stage suffix for either loading pixel death anims or literally just load the normal bf-dead
			bf = new Character(x, y, "die" + stageSuffix);
			add(bf);
		}
		else {trace("epic fail wtf"); FlxG.resetState();}

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

			if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			{
				bf.playAnim('deathLoop');
			}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			remove(camFollow);
			remove(bf);

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					remove(camFollow);
					remove(bf);
					PlayState.health = 1;
					PlayState.instance.customHUDClass.resetShit();
					LoadingState.loadAndSwitchState(new PlayState(), false);
				});
			});
		}
	}
}
