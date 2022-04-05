package;

import hscript.Checker;
import hscript.Interp;
import hscript.Parser;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	public var menuItems:FlxTypedGroup<FlxSprite>;

	var versionShit:FlxText;
	var optionShit:Array<String> = ['story_mode', 'freeplay', 'credits', 'options'];

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var interp:Interp;
	var camFollow:FlxObject;
	var interp:Interp;
	var tween:FlxTween;

	public function callInterp(func_name:String, args:Array<Dynamic>){
        if (!interp.variables.exists(func_name)) return;

        var method = interp.variables.get(func_name);
        Reflect.callMethod(interp,method,args);
	}

	public function callInterp(func_name:String, args:Array<Dynamic>){
        if (!interp.variables.exists(func_name)) return;
        
        var method = interp.variables.get(func_name);
        Reflect.callMethod(interp,method,args);
	}

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		interp = new Interp();

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.antialiasing = true;
		bg.alpha = 0;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.scrollFactor.set();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;

		for (i in 0...optionShit.length)
		{
			var offsetY:Float = -90;
			var offsetX:Float = -10;
			var menuItem:FlxSprite = new FlxSprite(0 + offsetX, (i * 160) + offsetY);
			menuItem.scale.x = scale;
			menuItem.scale.y = scale;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 12);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.alpha = 0;
			//menuItem.scrollType = "D-Shape";
			menuItems.add(menuItem);
			menuItem.antialiasing = true;
			menuItem.updateHitbox();
			tween = FlxTween.tween(menuItem, {alpha: 1}, 0.6, {ease: FlxEase.expoInOut});
		}

		/*menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});*/

		FlxG.camera.follow(camFollow, null, 0.06);

		versionShit = new FlxText(5, FlxG.height - 18, 0, "Madness Engine v" + Main.engineVer, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.alpha = 0;
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();

		// bg tweens
		FlxTween.tween(bg, {alpha: 1}, 1.4, {ease: FlxEase.expoInOut});

		// other tweens
		FlxTween.tween(versionShit, {alpha: 1}, 1, {ease: FlxEase.expoInOut});
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.NOTE_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.NOTE_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				// bg tweens
				FlxTween.tween(bg, {alpha: 0}, 1.4, {ease: FlxEase.expoInOut});

				// other tweens
				FlxTween.tween(versionShit, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
				menuItems.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.6, {
						ease: FlxEase.expoInOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				});

				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.7);
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				// bg tweens
				FlxTween.tween(bg, {alpha: 0}, 1.4, {ease: FlxEase.expoInOut});

				// other tweens
				FlxTween.tween(versionShit, {alpha: 0}, 1, {ease: FlxEase.expoInOut});
				menuItems.forEach(function(spr:FlxSprite)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.6, {
						ease: FlxEase.expoInOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				});
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				FlxFlicker.flicker(magenta, 1.1, 0.15, false);

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.6, {
							ease: FlxEase.expoInOut,
							onComplete: function(twn:FlxTween)
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'story_mode':
									MusicBeatState.switchState(new StoryMenuState());
								case 'freeplay':
									MusicBeatState.switchState(new FreeplayState());
								case 'credits':
									MusicBeatState.switchState(new CreditsState());
								case 'options':
									MusicBeatState.switchState(new OptionsMenu());
							}
						});
					}
				});
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			// spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		/*var bullShit:Int = 0;
		for (item in menuItems.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
		}*/

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				// camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				switch (optionShit[curSelected])
				{
					case 'story_mode':
						spr.offset.x = 0.15 * (spr.frameWidth / 2 + -320);
						spr.offset.y = 0.15 * spr.frameHeight;
					case 'freeplay':
						spr.offset.x = 0.15 * (spr.frameWidth / 2 + -290);
						spr.offset.y = 0.15 * spr.frameHeight;
					case 'options':
						spr.offset.x = 0.15 * (spr.frameWidth / 2 + -280);
						spr.offset.y = 0.15 * spr.frameHeight;
					case 'credits':
						spr.offset.x = 0.15 * (spr.frameWidth / 2 + -260);
						spr.offset.y = 0.15 * spr.frameHeight;
					default:
						spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
						spr.offset.y = 0.15 * spr.frameHeight;
				}
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}
