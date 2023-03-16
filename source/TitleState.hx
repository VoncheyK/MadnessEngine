package;

import helpers.Waveform.TestState;
import options.OptionsData;
import sys.io.File;
import helpers.Vector3;
import helpers.Modsupport;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import GameJolt.GameJoltAPI;
import GameJolt;
import options.OptionsMenu;

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxTypedGroup<Alphabet>;
	var credTextShit:Alphabet;
	var textGroup:FlxTypedGroup<Alphabet>;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	//md5 hash verify test
	//var bfMd5:String = "38495a06b646af00267deeeacb3458cc";

	//get the bytes and convert them to hex.
	//var bfSrc:String = File.getBytes("assets/shared/images/BOYFRIEND.png").toHex();
	//variable to be filled with the bytearray.
	//var md5t:ByteArray;

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		//FlxG.switchState(new TestState("chaos", "fleetway"));

		//fuck polymod!!11
		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['testMod']});
		#end

		var mods:Array<String> = CoolUtil.coolTextFile("mods.txt");
		Modsupport.init("mods", mods);

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();
		// normally APIStuff things would be in here but it's only for NG shit but we're using gamejolt, aka it's useless
		FlxG.save.bind('madness', 'voncheyk');
		GameJoltAPI.connect();
		GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);

		Highscore.load();
		OptionsData.init();
		OptionsMenu.loadSettings();

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			/*if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;*/
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end

		#if desktop
		DiscordClient.initialize();
		
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		#end
		//tedious process
		/*md5t = Hex.toArray(bfSrc);
		var md5Verifier:MD5 = new MD5();
		var sex = md5Verifier.hash(md5t);
		if (Hex.fromArray(sex) == bfMd5)
			trace("Files match.");
		else
			trace("File integrity invalid.");*/
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(102);
		persistentUpdate = true;


		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(blackScreen);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuBGMagenta"));
		// bg.antialiasing = true;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		//gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		//gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		//gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		//gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		//gfDance.antialiasing = true;
		// add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;
		add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});


		credGroup = new FlxTypedGroup<Alphabet>();
		add(credGroup);
		textGroup = new FlxTypedGroup<Alphabet>();

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		//ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
//ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		//add(ngSpr);
		//collectedSprites.push(ngSpr);
		//ngSpr.visible = false;
		//ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		//ngSpr.updateHitbox();
		//ngSpr.screenCenter(X);
		//ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);

		//ManifestFunctions.simpleManifestReload();
		#if !HOTFIXES_DISABLED
			try{
				var baseURL = "https://raw.githubusercontent.com/Zoardedz/MadnessHotfixes/main/";
				var data = new haxe.Http(baseURL + Main.version + "/testHotfix.hscript");
				data.onData = (data:String) -> {
					sys.io.File.saveContent("testHotfix", data);
					Main.addHotfix(101, "testHotfix", function(){
						Sys.exit(1);
					});
				};
				data.onError = (err:String) -> {
					throw new haxe.Exception(err);
				}
				data.request(false);
			}catch(e:haxe.Exception){trace(e);}
		#end
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F) {
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		//ClientSettings.loadSettings();

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			FlxTween.tween(FlxG.camera, {y: 1000}, 1.2, {ease: FlxEase.expoIn, startDelay: 0.1});

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Check if version is outdated (soon)
				FlxG.switchState(new MainMenuState());
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (PlayState.SONG != null && PlayState.SONG.chartVersion == "1.5")
			(PlayState.SONG.sections[Math.floor(curStep / 16)] != null && PlayState.SONG.sections[Math.floor(curStep / 16)].changeBPM.active) ? Conductor.changeBPM(PlayState.SONG.sections[Math.floor(curStep / 16)].changeBPM.bpm) : null;
		else if (PlayState.SONG != null && PlayState.SONG.chartVersion == "1.0")
			(PlayState.SONG.notes[Math.floor(curStep / 16)] != null && PlayState.SONG.notes[Math.floor(curStep / 16)].changeBPM) ? Conductor.changeBPM(PlayState.SONG.notes[Math.floor(curStep / 16)].bpm) : null;

		logoBl.animation.play('bump');
		//danceLeft = !danceLeft;

		//if (danceLeft)
		//	gfDance.animation.play('danceRight');
		//else
		//	gfDance.animation.play('danceLeft');

		//FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 1:
				createCoolText(['Madness Engine By']);
			// credTextShit.visible = true;
			case 3:
				addMoreText('Vonchyy');
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				createCoolText(['Not in association', 'with']);
			case 7:
				addMoreText('newgrounds');
				//ngSpr.visible = true;
			// credTextShit.text += '\nNewgrounds';
			case 8:
				deleteCoolText();
				//ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			case 9:
				createCoolText([curWacky[0]]);
			// credTextShit.visible = true;
			case 11:
				addMoreText(curWacky[1]);
			// credTextShit.text += '\nlmao';
			case 12:
				deleteCoolText();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('Friday');
			// credTextShit.visible = true;
			case 14:
				addMoreText('Night');
			// credTextShit.text += '\nNight';
			case 15:
				addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();
		}
		if (options.OptionsMenu.options.cameraZoom)
		{	
			FlxTween.tween(FlxG.camera, {zoom: 1.085}, Conductor.crochet / 1250, {ease: FlxEase.cubeOut, onComplete: function(f:FlxTween){
				FlxTween.tween(FlxG.camera, {zoom: 1.0}, Conductor.crochet / 1250, {ease: FlxEase.cubeOut});
			}});
		}
	}

	override function destroy()
	{
		super.destroy();
		remove(credGroup);
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			//collectedSprites.remove(ngSpr);
			//remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
