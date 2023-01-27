package;

import haxe.Exception;
import lime.app.Application;
import flixel.util.typeLimit.OneOfTwo;
import options.OptionsMenu;
import openfl.Lib;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
#if js
import js.html.Clients;
#end

#if desktop
import Discord.DiscordClient;
#end

import Section;
import Song;
import openfl.ui.Keyboard;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import FunkyHscript;
import helpers.Vector3;
import VCRDistortionShader;
import flxanimate.FlxAnimate;

using StringTools;

class PlayState extends MusicBeatState
{
	/*
		use this to access this state on other states
		like this
		PlayState.instance.*variable*
	*/
	public static var instance:PlayState;

	public static var curStage:String = '';
	public static var SONG:Dynamic;

	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	private var vocals:FlxSound;

	public var dadCameraPos:FlxPoint;
	public var bfCameraPos:FlxPoint;

	public static var dad:Character;
	public static var boyfriend:Boyfriend;
    public static var gf:Character;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var cpuStrums:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	// Rating => max MS to get it
	public static var hitTimings:Map<String, Int> = [
		"sick" => 43, //stepmania timings ?? i might make this customizable lol
		"good" => 76,
		"bad" => 125,
		"shit" => 163
	];

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	public static var health:Float = 1;
	private var combo:Int = 0;
	private var highestCombo:Int = 0;
	private var misses:Int = 0;
	private var usedBot:Bool = false;
	
	//accuracy stuff
	public var totalNotesHit:Int = 0;
	public var preAcc:Float = 0;
	public var accuracy:Float = 100;

	public static var goodPos = 42;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	//stage variables and shit
	private var halloweenBG:FlxSprite;
	public var halloweenLevel:Bool = false;
	public var isHalloween:Bool = false;

	private var phillyCityLights:FlxTypedGroup<FlxSprite>;
	private var phillyTrain:FlxSprite;
 
	private var limo:FlxSprite;
	private var fastCar:FlxSprite;
	private var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;

	private var upperBoppers:FlxSprite;
	private var bottomBoppers:FlxSprite;
	private var santa:FlxSprite;
 	
	private var bgGirls:BackgroundGirls;

	//grps
	public var bfGroup:FlxTypedGroup<Boyfriend>;
	public var dadGroup:FlxTypedGroup<Character>;
	public var bfLayerGroup:FlxTypedGroup<FlxSprite>;
	public var dadLayerGroup:FlxTypedGroup<FlxSprite>;
	
	private var camHUD:FlxCamera;
	public var camCustom:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;

	var songLength:Float = 0;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	var dadStrumTimes:Array<Int> = [];
	var bfStrumTimes:Array<Int> = [];

	public var customHUDClass:CamHUD;

	#if desktop
	// Discord RPC variables
	public var storyDifficultyText:String = "";
	public var iconRPC:String = "";
	public var detailsText:String = "";
	public var detailsPausedText:String = "";
	#end

	// Ratings
	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;

	// Botplay Text and Blink (Sine)
	public var botplaySine:Float = 0;

	public var playstateCache:openfl.utils.IAssetCache = new openfl.utils.AssetCache();

	public var fromMod:String = null;

	public function new(?mod:String)
	{
		super();
		this.fromMod = mod;
	}

	override public function create()
	{
		Main.dumpCache();
		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		misses = 0;
		combo = 0;
		highestCombo = 0;

		OptionsMenu.loadSettings();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camCustom = new FlxCamera();
		camCustom.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.setDefaultDrawTarget(camHUD, false);
		FlxG.cameras.add(camCustom);
		FlxG.cameras.setDefaultDrawTarget(camCustom, false);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

        persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		trace('SONG BPM SET TO: ${SONG.bpm}');

		switch (SONG.song.toLowerCase())
		{
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
			default:
				//soft coded dialogue
				var s:Null<Array<String>>;
				if (fromMod != null)
					s = CoolUtil.coolTextFile(Paths.modtxt('${SONG.song.toLowerCase()}/${SONG.song.toLowerCase()}Dialogue'));
				else
					s = CoolUtil.coolTextFile(Paths.txt('${SONG.song.toLowerCase()}/${SONG.song.toLowerCase()}Dialogue'));

				if (s != null)
					dialogue = s;
				else trace("dialogue fail troll");
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		switch (SONG.song.toLowerCase())
		{
            case 'spookeez' | 'monster' | 'south':
            	curStage = 'spooky';
	        	halloweenLevel = true;

		    	var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	        	halloweenBG = new FlxSprite(-200, -100);
		    	halloweenBG.frames = hallowTex;
	        	halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	        	halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	        	halloweenBG.animation.play('idle');
	        	halloweenBG.antialiasing = true;
	        	add(halloweenBG);

		    	isHalloween = true;
		    case 'pico' | 'blammed' | 'philly':
		        curStage = 'philly';

		        var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		        bg.scrollFactor.set(0.1, 0.1);
		        add(bg);

	                var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		        city.scrollFactor.set(0.3, 0.3);
		        city.setGraphicSize(Std.int(city.width * 0.85));
		        city.updateHitbox();
		        add(city);

		        phillyCityLights = new FlxTypedGroup<FlxSprite>();
		        add(phillyCityLights);

		        for (i in 0...5)
		        {
		           	var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		           	light.scrollFactor.set(0.3, 0.3);
		           	light.visible = false;
		           	light.setGraphicSize(Std.int(light.width * 0.85));
		           	light.updateHitbox();
		           	light.antialiasing = true;
		           	phillyCityLights.add(light);
		        }

		        var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		        add(streetBehind);

	            phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		        add(phillyTrain);

		        trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		        FlxG.sound.list.add(trainSound);

		        // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		        var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	            add(street);
		        
		    case 'milf' | 'satin-panties' | 'high':	          
		        curStage = 'limo';
		        defaultCamZoom = 0.90;

		        var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		        skyBG.scrollFactor.set(0.1, 0.1);
		        add(skyBG);

		        var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		        bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		        bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		        bgLimo.animation.play('drive');
		        bgLimo.scrollFactor.set(0.4, 0.4);
		        add(bgLimo);

		        grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		        add(grpLimoDancers);

		        for (i in 0...5)
		        {
		            var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		            dancer.scrollFactor.set(0.4, 0.4);
		            grpLimoDancers.add(dancer);
		        }

		        var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		        overlayShit.alpha = 0.5;
		        // add(overlayShit);

		        // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		        // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		        // overlayShit.shader = shaderBullshit;

		        var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		        limo = new FlxSprite(-120, 550);
		        limo.frames = limoTex;
		        limo.animation.addByPrefix('drive', "Limo stage", 24);
		        limo.animation.play('drive');
		        limo.antialiasing = true;

		        fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		        // add(limo);
		        
		    case 'cocoa' | 'eggnog':		          
	            curStage = 'mall';

		       	defaultCamZoom = 0.80;

		       	var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		       	bg.antialiasing = true;
		       	bg.scrollFactor.set(0.2, 0.2);
		       	bg.active = false;
		       	bg.setGraphicSize(Std.int(bg.width * 0.8));
		       	bg.updateHitbox();
		       	add(bg);

		       	upperBoppers = new FlxSprite(-240, -90);
		       	upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		       	upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		       	upperBoppers.antialiasing = true;
		       	upperBoppers.scrollFactor.set(0.33, 0.33);
		       	upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		       	upperBoppers.updateHitbox();
		       	add(upperBoppers);

		       	var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		       	bgEscalator.antialiasing = true;
		       	bgEscalator.scrollFactor.set(0.3, 0.3);
		       	bgEscalator.active = false;
		       	bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		       	bgEscalator.updateHitbox();
		       	add(bgEscalator);

		       	var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		       	tree.antialiasing = true;
		       	tree.scrollFactor.set(0.40, 0.40);
		       	add(tree);

		       	bottomBoppers = new FlxSprite(-300, 140);
		       	bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		       	bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		       	bottomBoppers.antialiasing = true;
	           	bottomBoppers.scrollFactor.set(0.9, 0.9);
	           	bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		       	bottomBoppers.updateHitbox();
		       	add(bottomBoppers);

		       	var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		       	fgSnow.active = false;
		       	fgSnow.antialiasing = true;
		       	add(fgSnow);

		       	santa = new FlxSprite(-840, 150);
		       	santa.frames = Paths.getSparrowAtlas('christmas/santa');
		       	santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		       	santa.antialiasing = true;
		       	add(santa);
				
		    case 'winter-horrorland':
		        curStage = 'mallEvil';
		        var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		        bg.antialiasing = true;
		        bg.scrollFactor.set(0.2, 0.2);
		        bg.active = false;
		        bg.setGraphicSize(Std.int(bg.width * 0.8));
		        bg.updateHitbox();
		        add(bg);

		        var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		        evilTree.antialiasing = true;
		        evilTree.scrollFactor.set(0.2, 0.2);
		        add(evilTree);

		        var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	            evilSnow.antialiasing = true;
		        add(evilSnow);
		    case 'senpai' | 'roses':
		        curStage = 'school';

		        // defaultCamZoom = 0.9;

		        var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		        bgSky.scrollFactor.set(0.1, 0.1);
		        add(bgSky);

		        var repositionShit = -200;

		        var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		        bgSchool.scrollFactor.set(0.6, 0.90);
		        add(bgSchool);

		        var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		        bgStreet.scrollFactor.set(0.95, 0.95);
		        add(bgStreet);

		        var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		        fgTrees.scrollFactor.set(0.9, 0.9);
		        add(fgTrees);

		        var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		        var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		        bgTrees.frames = treetex;
		        bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		        bgTrees.animation.play('treeLoop');
		        bgTrees.scrollFactor.set(0.85, 0.85);
		        add(bgTrees);

		        var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		        treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		        treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		        treeLeaves.animation.play('leaves');
		        treeLeaves.scrollFactor.set(0.85, 0.85);
		        add(treeLeaves);

		        var widShit = Std.int(bgSky.width * 6);

		        bgSky.setGraphicSize(widShit);
		        bgSchool.setGraphicSize(widShit);
		        bgStreet.setGraphicSize(widShit);
		        bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		        fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		        treeLeaves.setGraphicSize(widShit);

		        fgTrees.updateHitbox();
		        bgSky.updateHitbox();
		        bgSchool.updateHitbox();
		        bgStreet.updateHitbox();
		        bgTrees.updateHitbox();
		        treeLeaves.updateHitbox();

		        bgGirls = new BackgroundGirls(-100, 190);
		        bgGirls.scrollFactor.set(0.9, 0.9);

		        if (SONG.song.toLowerCase() == 'roses')
		                bgGirls.getScared();

		        bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		        bgGirls.updateHitbox();
		        add(bgGirls);
		        
		    case 'thorns':
		        curStage = 'schoolEvil';

		        var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		        var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		        var posX = 400;
	            var posY = 200;

		        var bg:FlxSprite = new FlxSprite(posX, posY);
		        bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		        bg.animation.addByPrefix('idle', 'background 2', 24);
		        bg.animation.play('idle');
		        bg.scrollFactor.set(0.8, 0.9);
		        bg.scale.set(6, 6);
		        add(bg);

		        /* this probably wont be used at all :skull:
		        var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		        bg.scale.set(6, 6);
		        // bg.setGraphicSize(Std.int(bg.width * 6));
		        // bg.updateHitbox();
		        add(bg);

		        var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
		        fg.scale.set(6, 6);
		        // fg.setGraphicSize(Std.int(fg.width * 6));
		        // fg.updateHitbox();
		        add(fg);

		        wiggleShit.effectType = WiggleEffectType.DREAMY;
		        wiggleShit.waveAmplitude = 0.01;
		        wiggleShit.waveFrequency = 60;
		        wiggleShit.waveSpeed = 0.8;
		        

		        // bg.shader = wiggleShit.shader;
		        // fg.shader = wiggleShit.shader;

		        
		        var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
		        var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

		        // Using scale since setGraphicSize() doesnt work???
		        waveSprite.scale.set(6, 6);
		        waveSpriteFG.scale.set(6, 6);
		        waveSprite.setPosition(posX, posY);
		        waveSpriteFG.setPosition(posX, posY);

		        waveSprite.scrollFactor.set(0.7, 0.8);
		        waveSpriteFG.scrollFactor.set(0.9, 0.8);

		        // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		        // waveSprite.updateHitbox();
		        // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
		        // waveSpriteFG.updateHitbox();

		        add(waveSprite);
		        add(waveSpriteFG);
				*/
		             
		    default:
		        defaultCamZoom = 0.9;
		        curStage = 'stage';
		        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		        bg.antialiasing = true;
		        bg.scrollFactor.set(0.9, 0.9);
		        bg.active = false;
		        add(bg);

		        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		        stageFront.updateHitbox();
		        stageFront.antialiasing = true;
		        stageFront.scrollFactor.set(0.9, 0.9);
		        stageFront.active = false;
		        add(stageFront);

		        var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		        stageCurtains.updateHitbox();
		        stageCurtains.antialiasing = true;
		        stageCurtains.scrollFactor.set(1.3, 1.3);
		        stageCurtains.active = false;

		        add(stageCurtains);
        }

		var bfDeathVersion:String = "bf-dead";
		switch(curStage)
		{
			case 'school' | 'schoolEvil':
				bfDeathVersion = "bf-pixel-dead";
			default:
				bfDeathVersion = "bf-dead";
		}

		//precache my cum
		playstateCache.enabled = true;
		var cached:FlxSprite = new FlxSprite();
		(bfDeathVersion == "bf-pixel-dead") ? cached.frames = Paths.getSparrowAtlas('weeb/bfPixelsDEAD') : cached.frames = Paths.getSparrowAtlas("BOYFRIEND_DEAD");
		Character.initializeAnimsFromJSONToSprite(bfDeathVersion, cached);
		playstateCache.setBitmapData("death", cached.graphic.bitmap);

		var cached2:FlxSprite = new FlxSprite();
		NoteSplash.loadAnimsToSprite(cached2);
		playstateCache.setBitmapData("nSplashes", cached2.graphic.bitmap);

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		
		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;

				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
		}

		add(gf);
        gf.active = true;
        //gf.anim.play("danceRight");

		
		//shitty layering but whatev it works LOL
		if(curStage == "limo")
			add(limo);

		dadLayerGroup = new FlxTypedGroup<FlxSprite>();
		dadGroup = new FlxTypedGroup<Character>();
		add(dadGroup);
		add(dadLayerGroup);
		dadGroup.add(dad);

		bfLayerGroup = new FlxTypedGroup<FlxSprite>();
		bfGroup = new FlxTypedGroup<Boyfriend>();
		add(bfGroup);
		add(bfLayerGroup);
		bfGroup.add(boyfriend);

		bfCameraPos = new FlxPoint(boyfriend.cameraPosition[0], boyfriend.cameraPosition[1]);
		dadCameraPos = new FlxPoint(dad.cameraPosition[0], dad.cameraPosition[1]);
		
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, (OptionsMenu.options.downScroll ? 570 : 50)).makeGraphic(FlxG.width, 10);

		strumLine.scrollFactor.set();
		
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;

		cpuStrums = new FlxTypedGroup<FlxSprite>();
		add(cpuStrums);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		
		// startCountdown();

		generateSong(SONG.song);
		//memory check quickly
		openfl.system.System.gc();

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		customHUDClass = new CamHUD();
		add(customHUDClass);

		cpuStrums.cameras = [camHUD];
		notes.cameras = [camHUD];
		for(spr in customHUDClass) spr.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		Keybinds.loadKeybinds(); 
		if (OptionsMenu.options.middleScroll)
		{
			cpuStrums.forEach(spr->spr.visible=false);
			playerStrums.forEach(spr->spr.visible=true);
		}

		if (sys.FileSystem.isDirectory("assets/scripts"))
		{
			for (i in 0...sys.FileSystem.readDirectory("assets/scripts").length){
				var trueFile = sys.FileSystem.readDirectory("assets/scripts")[i];
				trace(trueFile);
				if (sys.FileSystem.exists('assets/scripts/$trueFile') && trueFile.contains(".hscript"))
					hscripts.push(new FunkyHscript(trueFile));
			}
		}

		#if !HOTFIXES_DISABLED
			try{
				//fuck you 
				var hotfixResource:String = helpers.ResourceFunctions.getHotfixResource(null, 101);
				var MD5Haxe:String = haxe.crypto.Md5.encode(hotfixResource);
				trace(MD5Haxe);
				//use api calls from github like https://api.github.com/repos/Zoardedz/MadnessHotfixes/git/trees/1a84ce70aed1a2de0fd6d7aa76be6973794f0e41 to get all data
				var baseURL = "https://raw.githubusercontent.com/Zoardedz/MadnessHotfixes/main/";
				var goofyHash = new haxe.Http(baseURL + Main.version + "/testHotfix.md5");
				goofyHash.onData = (data:String) -> {
					trace(data);
					if (areSame(compareStrings(MD5Haxe, data)))
					{
						//bool (return, just null it), resource id, checksum of actual file, checksum from internet
						if (helpers.ResourceFunctions.checkHotfixExistence(null, 101))
							hscripts.push(new FunkyHscript(null, hotfixResource));
					}
					else
						trace("Hotfix isn't valid, the resources have been modified...");
				};

				goofyHash.onError = (error) -> {
					throw new Exception(error);
				}
				goofyHash.request(false);
			}catch(e:Exception){
				Main.raiseWindowAlert("You might not have internet, skipping hotfix appliance!\n Exception details: " + e.details());
			}
		#end
			
		super.create();
	}

	//== STRING COMPAREMENT DOESNT WORK SO FUCK YOU
	private static function compareStrings(string1:String, string2:String):Array<Bool>{
		var deez1:Array<Bool> = [];
		for (i in 0...string1.length){
			if (string2.charAt(i) == string1.charAt(i))
			  deez1[i] = true;
			else
			  deez1[i] = false;
		}
	  return deez1;
	}

	private static function areSame(arr:Array<Bool>):Bool
	{
	  var first:Bool = arr[0];
	   
	  for (i in 1...arr.length)
		if (arr[i] != first)
		  return false;

	  return true;
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}
	
	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			beatHit();

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song, fromMod), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		songLength = FlxG.sound.music.length;
		FlxTween.tween(customHUDClass.timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		FlxTween.tween(customHUDClass.timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
		{
			// FlxG.log.add(ChartParser.parse());
			Conductor.changeBPM(SONG.bpm);
	
			curSong = SONG.song;
	
			if (SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, this.fromMod));
			else
				vocals = new FlxSound();
	
			FlxG.sound.list.add(vocals);
	
			notes = new FlxTypedGroup<Note>();
			add(notes);

			var isNewVerSong:Null<Bool> = null;

			if (SONG.chartVersion == "1.5")
				isNewVerSong = true;
			
			if (SONG.chartVersion == "1.0")
				isNewVerSong = false;

			trace("[[IMPORTANT MESSAGE]] isNewVarSong currently is: " + isNewVerSong);

			if (isNewVerSong){
				var sex:SwaggiestSong = cast(SONG);
				for (curSec => section in sex.sections)
				{
					for (songNotes in sex.notes)
					{	
						if (songNotes.strumTime <= (Conductor.stepCrochet * section.lengthInSteps) * curSec || songNotes.strumTime >= (Conductor.stepCrochet * section.lengthInSteps) * (curSec + 1)) continue;
		
						var daStrumTime:Float = songNotes.strumTime;
						var daNoteData:Int = Std.int(songNotes.noteData % 4);
		
						var gottaHitNote:Bool = section.mustHit;
		
						if (songNotes.noteData > 3)
							gottaHitNote = !section.mustHit;
		
						var oldNote:Note;
						if (unspawnNotes.length > 0)
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						else
							oldNote = null;
		
						var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
						swagNote.sustainLength = songNotes.sustainLength;
						swagNote.scrollFactor.set(0, 0);
		
						var susLength:Float = swagNote.sustainLength;
		
						susLength = susLength / Conductor.stepCrochet;
						unspawnNotes.push(swagNote);
		
						for (susNote in 0...Math.floor(susLength))
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
		
							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);
		
							sustainNote.mustPress = gottaHitNote;
		
							if (sustainNote.mustPress)
							{
								sustainNote.isChord = bfStrumTimes.contains(Math.round(sustainNote.strumTime));
								bfStrumTimes.push(Math.round(sustainNote.strumTime));
								sustainNote.x += FlxG.width / 2;
							}
							else
							{
								if (dadStrumTimes.contains(Math.round(sustainNote.strumTime)))
								{
									sustainNote.isChord = true;
									dadStrumTimes.push(Math.round(sustainNote.strumTime));
								}
								dadStrumTimes.push(Math.round(sustainNote.strumTime));
							}
						}
		
						swagNote.mustPress = gottaHitNote;
		
						if (swagNote.mustPress)
						{
							if (bfStrumTimes.contains(Math.round(swagNote.strumTime)))
							{
								swagNote.isChord = true;
								bfStrumTimes.push(Math.round(swagNote.strumTime));
							}
							bfStrumTimes.push(Math.round(swagNote.strumTime));
							swagNote.x += FlxG.width / 2; // general offset
						}
						else
						{	
							if (dadStrumTimes.contains(Math.round(swagNote.strumTime)))
							{
								swagNote.isChord = true;
								dadStrumTimes.push(Math.round(swagNote.strumTime));
							}
							dadStrumTimes.push(Math.round(swagNote.strumTime));
						}
					}
				}
			}
			else if (!isNewVerSong)
			{
				var noteData:Array<SwagSection>;
				var sex:SwagSong = cast(SONG);

				// NEW SHIT
				noteData = sex.notes;

				var playerCounter:Int = 0;

				var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
				for (section in noteData)
				{
					var coolSection:Int = Std.int(section.lengthInSteps / 4);

					for (songNotes in section.sectionNotes)
					{
						var daStrumTime:Float = songNotes[0];
						var daNoteData:Int = Std.int(songNotes[1] % 4);

						var gottaHitNote:Bool = section.mustHitSection;

						if (songNotes[1] > 3)
						{
							gottaHitNote = !section.mustHitSection;
						}

						var oldNote:Note;
						if (unspawnNotes.length > 0)
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						else
							oldNote = null;

						var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false);
						swagNote.sustainLength = songNotes[2];
						swagNote.scrollFactor.set(0, 0);

						var susLength:Float = swagNote.sustainLength;

						susLength = susLength / Conductor.stepCrochet;
						unspawnNotes.push(swagNote);

						for (susNote in 0...Math.floor(susLength))
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);

							sustainNote.mustPress = gottaHitNote;

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}

						swagNote.mustPress = gottaHitNote;

						if (swagNote.mustPress)
						{
							swagNote.x += FlxG.width / 2; // general offset
						}
						else {}
					}
					daBeats += 1;
				}
			}
	
			// trace(unspawnNotes.length);
			// playerCounter += 1;
	
			unspawnNotes.sort(sortByShit);
	
			generatedMusic = true;
		}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 100;
			//babyArrow.x += ((FlxG.width / 2) * player);
			babyArrow.x += (OptionsMenu.options.middleScroll ? FlxG.width / 4 : (FlxG.width / 2) * player); //literaly just gonna guess

			cpuStrums.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}
	
	private function pause(sp:Float)
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;
	
		// 1 / 1000 chance for Gitaroo Man easter egg
		if (FlxG.random.bool(0.1))
			FlxG.switchState(new GitarooPause());
		else
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, sp));
			
		#if cpp
		DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var alreadyChanged:Bool = false;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (OptionsMenu.options.botPlay && !alreadyChanged)
		{
			customHUDClass.scoreTxt.visible = false;
			alreadyChanged = true;
		} else if (!OptionsMenu.options.botPlay && alreadyChanged) {
			customHUDClass.scoreTxt.visible = true;
			switch (FlxG.random.int(1, 4))
			{
				case 1:
					customHUDClass.botplayTxt.text = "[BOTPLAY]";
				case 2:
					customHUDClass.botplayTxt.text = "[SKILL ISSUE]";
				case 3:
					customHUDClass.botplayTxt.text = "[HI MOM]";
				case 4:
					customHUDClass.botplayTxt.text = "Rank: [BFC]"; //BFC stands for Bot Full Combo
			}
			alreadyChanged = false;
		}


		super.update(elapsed);

		var fcRank:String;
		var accRank:String;
		var divider:String = ' | ';

		//ranks
		fcRank = "[UNRATED]";
		accRank = "F";

		if (sicks > 0) 
			fcRank = "[SFC]"; //Sick Full Combo
		if (goods > 0)
			fcRank = "[GFC]"; //Good Full Combo
		if (bads > 0 || shits > 0)
			fcRank = "[FC]"; //Full Combo
		if (misses > 0)
			fcRank = "[SDCB]"; //Single Digit Combo Breaks
		if (misses > 9)
			fcRank = "[Clear]";

		
		if (accuracy > 99)
			accRank = "S+";
		if (accuracy < 100)
			accRank = "S";
		if (accuracy < 91)
			accRank = "A";
		if (accuracy < 85)
			accRank = "B";
		if (accuracy < 81)
			accRank = "C";
		if (accuracy < 75)
			accRank = "D";
		if (accuracy < 71)
			accRank = "E";
		if (accuracy < 61)
			accRank = "F";

		//updating values
		customHUDClass.scoreTxt.text = 'Score: ${songScore}';
		customHUDClass.scoreTxt.text += divider + 'Misses: ${misses}';
		if (OptionsMenu.options.displayAccuracy) {
			customHUDClass.scoreTxt.text += divider + 'Accuracy: ${accuracy}%';
			customHUDClass.scoreTxt.text += divider + 'Rank: ${accRank} ${fcRank}';
			#if desktop
			detailsText = customHUDClass.scoreTxt.text;
			#end
		}

		if (OptionsMenu.options.botPlay) {
			usedBot = true;
			#if desktop
			detailsText = '[BOTPLAY]';
			#end

			botplaySine += 180 * elapsed;
			customHUDClass.botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}

		var curTime:Float = Conductor.songPosition;
		if(curTime < 0) curTime = 0;
		customHUDClass.songPercent = (curTime / songLength);

		var songCalc:Float = (songLength - curTime);

		var secondsTotal:Int = Math.floor(songCalc / 1000);
		if(secondsTotal < 0) secondsTotal = 0;

		customHUDClass.timeTxt.text = '${curSong} | (${FlxStringUtil.formatTime(secondsTotal, false)})';

		if (OptionsMenu.options.botPlay)
		{
			notes.forEachAlive(function (daNote:Note) {
				if (daNote.canBeHit && daNote.mustPress)
				{
					botPlayNoteHit(daNote);
				}
			});
		}

		var iconOffset:Int = 26;

		if (OptionsMenu.options.middleScroll)
		{
			customHUDClass.iconP1.y = customHUDClass.healthBar.y + (customHUDClass.healthBar.width * (FlxMath.remapToRange(customHUDClass.healthBar.percent, 0, 100, 100, 0) * 0.01) - 26);
			customHUDClass.iconP2.y = customHUDClass.healthBar.y + (customHUDClass.healthBar.width * (FlxMath.remapToRange(customHUDClass.healthBar.percent, 0, 100, 100, 0) * 0.01)) - (customHUDClass.iconP2.height - 26);
		} else {
			customHUDClass.iconP1.x = customHUDClass.healthBar.x + (customHUDClass.healthBar.width * (FlxMath.remapToRange(customHUDClass.healthBar.percent, 0, 100, 100, 0) * 0.01) - 26);
			customHUDClass.iconP2.x = customHUDClass.healthBar.x + (customHUDClass.healthBar.width * (FlxMath.remapToRange(customHUDClass.healthBar.percent, 0, 100, 100, 0) * 0.01)) - (customHUDClass.iconP2.width - 26);
		}

		//same value so it doesnt fucking matter
		customHUDClass.iconP1.scale.x = customHUDClass.iconP1.scale.y = FlxMath.lerp(customHUDClass.iconP1.scale.x, 1, CoolUtil.lerpShit(elapsed, 9.8));
		customHUDClass.iconP2.scale.x = customHUDClass.iconP2.scale.y = FlxMath.lerp(customHUDClass.iconP2.scale.x, 1, CoolUtil.lerpShit(elapsed, 9.8));
		
		customHUDClass.iconP1.updateHitbox();
		customHUDClass.iconP2.updateHitbox();

		if (health > 2)
			health = 2;

		if (customHUDClass.healthBar.percent < 20)
			customHUDClass.iconP1.animation.curAnim.curFrame = 1;
		else
			customHUDClass.iconP1.animation.curAnim.curFrame = 0;

		if (customHUDClass.healthBar.percent > 80)
			customHUDClass.iconP2.animation.curAnim.curFrame = 1;
		else
			customHUDClass.iconP2.animation.curAnim.curFrame = 0;

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && checkSection() != null)
		{
			var sec:Dynamic = checkSection();
			if (camFollow.x != dad.getMidpoint().x + 150 && !getPropertyFromSection(sec, "mustHit"))
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				camFollow.x += dadCameraPos.x;
				camFollow.y += dadCameraPos.y;

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (getPropertyFromSection(sec, "mustHit") && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
				camFollow.x -= bfCameraPos.x;
				camFollow.y += bfCameraPos.y;

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}
		
		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, defaultCamZoom, CoolUtil.lerpShit(elapsed, 11.24));
			camHUD.zoom = FlxMath.lerp(camHUD.zoom, 1, CoolUtil.lerpShit(elapsed, 11.24));
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			//openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, this));
			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song+ " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			//if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				notes.add(unspawnNotes[0]);
				unspawnNotes.splice(0, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (OptionsMenu.options.middleScroll && !daNote.mustPress) daNote.visible = false;

				daNote.y = (daNote.mustPress ? playerStrums.members[daNote.noteData] : cpuStrums.members[daNote.noteData]).y + (OptionsMenu.options.downScroll ? 0.45 : -0.45)
					* (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

				if (OptionsMenu.options.downScroll)
				{
					if (daNote.isSustainNote) 
					{
						//crefits to psych because hold note positions are fucky
						//and they look amazing on psych!!!!!
						if (daNote.animation.curAnim.name.endsWith('end')) 
						{
							daNote.y += 10.5 * (Conductor.crochet / 400) * 1.5 * SONG.speed + (46 * (SONG.speed - 1));
							daNote.y -= 46 * (1 - (Conductor.crochet / 600)) * SONG.speed;
							daNote.y -= 19;
						}
						
						if (OptionsMenu.options.botPlay || !daNote.mustPress || daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit) 
							&& (strumLine.y + Note.swagWidth / 2) >= daNote.y - daNote.offset.y * daNote.scale.y + daNote.height)
							{
								var rect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								rect.height = ((strumLine.y + Note.swagWidth / 2) - daNote.y) / daNote.scale.y;
								rect.y = daNote.frameHeight - rect.height;
								daNote.clipRect = rect;
							}
					}
				}
				else if (OptionsMenu.options.botPlay || daNote.isSustainNote && (!daNote.mustPress || daNote.wasGoodHit || 
					(daNote.prevNote.wasGoodHit && !daNote.canBeHit)) && (strumLine.y + Note.swagWidth / 2) >= daNote.y + daNote.offset.y * daNote.scale.y)
					{
						var rect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						rect.y = ((strumLine.y + Note.swagWidth / 2) - daNote.y) / daNote.scale.y;
						rect.height -= rect.y;
						daNote.clipRect = rect;
					}

				//literally just stole this from note.hx lol
				if (OptionsMenu.options.botPlay && !daNote.wasGoodHit && daNote.mustPress && daNote.strumTime <= Conductor.songPosition)
				{	
					goodNoteHit(daNote);
					boyfriend.holdTimer = 0;
				}

				daNote.x = (daNote.mustPress ? playerStrums.members[daNote.noteData] : cpuStrums.members[daNote.noteData]).x;

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (curStage.contains("school"))
						daNote.x -= 11;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
					opponentNoteHit(daNote);

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				//(OptionsMenu.options.downScroll && daNote.y > camHUD.height + daNote.height) || (!OptionsMenu.options.downScroll && daNote.y < -camHUD.height - daNote.height)
				if (daNote.tooLate && !daNote.wasGoodHit)
				{
					misses++;	

					noteMiss(daNote.noteData);
					vocals.volume = 0;
					health -= 0.04;
					songScore -= 10;
					updateAccuracy();

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();	
				}		
			});
		}

		if (!inCutscene)
			keyShit();

		cpuStrums.forEach(function(spr:FlxSprite)
		{
			if (spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished)
				spr.animation.play('static');
	
			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});

		timeSinceLastUpdate = Lib.getTimer() / 1000;
	}

	public static function checkSection():Null<Dynamic> {
		var s:OneOfTwo<SwagSection, SwaggiestSection>;
		try{
			(SONG.chartVersion == "1.0") ? s = SONG.notes[Std.int(PlayState.instance.curStep / 16)] : s = SONG.sections[Std.int(PlayState.instance.curStep / 16)];
			return s != null ? s : null;
		}catch(e:Exception){
			Main.raiseWindowAlert("An Error occured with section returning!");
			trace(e.details());
			return null;
		}
	}

	public static function getPropertyFromSection(section:Any, property:String):Dynamic
	{
		try{
			switch(property)
			{
				case "mustHit":
					(SONG.chartVersion == "1.5") ? return Reflect.field(section, property) : return Reflect.field(section, "mustHitSection");
				case "mustHitSection":
					(SONG.chartVersion == "1.5") ? return Reflect.field(section, "mustHit") : return Reflect.field(section, property);
				case "changeBPM":
					(property is Bool) ? (SONG.chartVersion == "1.5")  ? return Reflect.field(Reflect.field(section, "changeBPM"), "active") : return Reflect.field(section, property) : return Reflect.field(section, property);
				case "bpm":
					(SONG.chartVersion == "1.5") ? return Reflect.field(Reflect.field(section, "changeBPM"), "bpm") : return Reflect.field(section, property);
				case "changeBPM.active":
					(SONG.chartVersion == "1.0") ? return Reflect.field(section, "changeBPM") : return Reflect.field(Reflect.field(section, "changeBPM"), "active");
				case "changeBPM.bpm":
					(SONG.chartVersion == "1.0") ? return Reflect.field(section, "bpm") : return Reflect.field(Reflect.field(section, "changeBPM"), "bpm");
				default:
					return Reflect.field(section, property);
			}
			return Reflect.field(section, property);
		}
		catch(e:Exception)
		{
			Main.raiseWindowAlert("An error has occured while returning a variable/property/field from a section! : " + property);
			trace(e.details());
			return null;
		}
	}

	public static function setPropertyFromSection(section:Any, property:String, newVariable:Dynamic):Void
	{
		try{
			switch(property)
			{
				case "mustHit":
					(SONG.chartVersion == "1.5") ? Reflect.setField(section, property, newVariable) : Reflect.setField(section, "mustHitSection", newVariable);
				case "mustHitSection":
					(SONG.chartVersion == "1.5") ? Reflect.setField(section, "mustHit", newVariable) : Reflect.setField(section, property, newVariable);
				case "changeBPM":
					(property is Bool) ? (SONG.chartVersion == "1.5")  ? Reflect.setField(Reflect.field(section, "changeBPM"), "active", newVariable) : Reflect.setField(section, property, newVariable) : Reflect.setField(section, property, newVariable);
				case "bpm":
					(SONG.chartVersion == "1.5") ? Reflect.setField(Reflect.field(section, "changeBPM"), "bpm", newVariable) : return Reflect.setField(section, property, newVariable);
				case "changeBPM.active":
					(SONG.chartVersion == "1.0") ? Reflect.setField(section, "changeBPM", newVariable) : Reflect.setField(Reflect.field(section, "changeBPM"), "active", newVariable);
				case "changeBPM.bpm":
					(SONG.chartVersion == "1.0") ? Reflect.setField(section, "bpm", newVariable) : Reflect.setField(Reflect.field(section, "changeBPM"), "bpm", newVariable);
				default:
					Reflect.setField(section, property, newVariable);
			}
		}
		catch(e:Exception)
		{
			Main.raiseWindowAlert("An error has occured while setting a variable/property/field from a section! : " + property + " and the new variable is: " + newVariable);
			trace(e.details());
		}
	}

	private var curStorySong:Int = 0;

	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore && !usedBot)
		{
			#if !switch
			Highscore.saveScore(SONG.song.toLowerCase(), songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;
			storyPlaylist.remove(storyPlaylist[0]);
			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				//StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore && !usedBot)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				//FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";
				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				curStorySong++;

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState(fromMod), false);
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			//should clear the cache in freeplay.
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;
	private function popUpScore(note:Note):Void{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition); //how late the note was (in ms)

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 50;

		var daRating:String = "sick";
		var daAccuracy:Int = 0;

		if (noteDiff < hitTimings['sick'])
		{
			sicks += 1;
			daRating = 'sick';
			score = 350;
			daAccuracy = 100;
			//this is extremely simple bro :skull:
			spawnNoteSplashOnNote(note);
			customHUDClass.scoreTxt.scale.set(1.125, 1.125);
			FlxTween.tween(customHUDClass.scoreTxt.scale, {x: 1, y: 1}, Conductor.crochet / 1250);
			if (OptionsMenu.options.simpleAccuracy)
				preAcc += 1;
		}
		else if (noteDiff < hitTimings['good'])
		{
			goods += 1;
			daRating = 'good';
			score = 200;
			daAccuracy = 80;
			customHUDClass.scoreTxt.scale.set(1.050, 1.050);
			FlxTween.tween(customHUDClass.scoreTxt.scale, {x: 1, y: 1}, Conductor.crochet / 1250);
			if (OptionsMenu.options.simpleAccuracy)
				preAcc += 0.75;
		} 
		else if (noteDiff < hitTimings['bad'])
		{
			bads += 1;
			daRating = 'bad';
			score = 100;
			health += -0.002;
			daAccuracy = 60;
			if (OptionsMenu.options.simpleAccuracy)
				preAcc += 0.5;
		}
		else if (noteDiff > hitTimings['shit'])
		{
			shits += 1;
			score = 50;
			health += -0.004;
			daAccuracy = 30;
			if (OptionsMenu.options.simpleAccuracy)
				preAcc += 0.25;
		}

		if (!OptionsMenu.options.simpleAccuracy)
			preAcc += 1 + noteDiff / hitTimings['shit'] * -1; //ratio

		preAcc += daAccuracy;

		songScore += score;

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		if (!OptionsMenu.options.showRating) return;

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = OptionsMenu.options.antialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = OptionsMenu.options.antialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		for (i => num in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(num) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * i) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = OptionsMenu.options.antialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});
		}

		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	//better keyshit function
	var pressed = [false, false, false, false];
	public var timeSinceLastUpdate:Float = 0.0;
	
	//this will run every time a key is pressed
	override function keyDown(event:KeyboardEvent)
	{
		if (paused) return;

		if (event.keyCode == Keyboard.R && OptionsMenu.options.resetButton)
		{
			//health = -100;
		}
	
		// CHEAT = brandon's a pussy
		if (event.keyCode == Keyboard.BACKSLASH) //!dont forget to disable this on release
		{
			//health += (GameplayChangers.changers.get("Opponent Play") ? -1 : 1);
			trace("User is cheating! HAH it didn't do anything, L");
		}

		if (event.keyCode == Keyboard.ENTER && startedCountdown && canPause){
			paused = true;
			var sp = Conductor.songPosition;
			pause(sp);
		}
		
		if (event.keyCode == Keyboard.NUMBER_7)
		{
			FlxG.switchState(new ChartingState());
		
			#if cpp
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if (event.keyCode == Keyboard.NUMBER_8)
			FlxG.switchState(new AnimationDebug(SONG.player2));

		#if debug
		if (event.keyCode == Keyboard.NUMBER_1)
			FlxG.sound.music.onComplete();
		#end

		if (event.keyCode == Keyboard.NUMBER_9)
			{
				if (customHUDClass.iconP1.animation.curAnim.name == 'bf-old')
					customHUDClass.iconP1.animation.play(SONG.player1);
				else
					customHUDClass.iconP1.animation.play('bf-old');
			}

		if (OptionsMenu.options.botPlay) return;

		super.keyDown(event);

		final keyJustPressed = FlxKey.toStringMap.get(event.keyCode);

		var binds:Array<Array<FlxKey>> = [
			Keybinds.keybinds[0][1],
			Keybinds.keybinds[1][1],
			Keybinds.keybinds[2][1],
			Keybinds.keybinds[3][1]
		];

		var keyData = -1; //null

		for (i => bind in binds)
			if (bind.contains(keyJustPressed))
				keyData = i;
		
		if (keyData == -1)
			return;

		if (pressed[keyData])
			return;
		
		pressed[keyData] = true; //omg ur pressing key !!

		//credits to EyeDaleHim#8508 for being smart
		if (generatedMusic)
		{
			var calcTime:Float = Conductor.songPosition;
			Conductor.songPosition += ((Lib.getTimer() / 1000) - timeSinceLastUpdate);

			var possibleNotes:Array<Note> = [];
			var verifiedNotes:Array<Note> = [];

			notes.forEachAlive(function(swagNote:Note) {
				if (swagNote.canBeHit && swagNote.mustPress && !swagNote.tooLate && !swagNote.wasGoodHit && keyData == swagNote.noteData)
					possibleNotes.push(swagNote);
			});

			possibleNotes.sort((a, b) -> Std.int((a.strumTime - b.strumTime)));
	
			var canHitMore:Bool = false; // avoid hitting two notes that are possible to be hit, only count for stacked ones instead
			var countedNotes:Int = 0;
			var maximumNotes:Int = 24;

			if (possibleNotes.length > 0)
			{
				boyfriend.holdTimer = 0;

				for (epicNote in possibleNotes)
				{
					if (countedNotes >= maximumNotes)
						break;
					verifiedNotes.push(epicNote);
					for (doubleNote in possibleNotes)
					{
						if (canHitMore || countedNotes >= maximumNotes)
							break;

						if (doubleNote != epicNote && Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10)
						{
							canHitMore = true;
							verifiedNotes.push(doubleNote);
						}
						countedNotes++;
					}
					countedNotes++;
				}

				if (canHitMore)
					for (note in verifiedNotes)
						goodNoteHit(note);
				else
					goodNoteHit(verifiedNotes[0]);
			}
			else if (!OptionsMenu.options.ghostTapping)
			{
				noteMiss(keyData);
				misses++;
				health -= 0.04;
				songScore -= 10;
				updateAccuracy();
			}
				

			Conductor.songPosition = calcTime;
		}
	}

	override function keyUp(event:KeyboardEvent)
	{
		if (paused) return;

		if (OptionsMenu.options.botPlay) return;

		super.keyUp(event);

		final keyJustReleased = FlxKey.toStringMap.get(event.keyCode);
			
		var binds:Array<Array<FlxKey>> =  [
			//directions are respective to their data
			Keybinds.keybinds[0][1],
			Keybinds.keybinds[1][1],
			Keybinds.keybinds[2][1],
			Keybinds.keybinds[3][1]
		];
	
		var keyData = -1; //null
	
		for (i => bind in binds)
			if (bind.contains(keyJustReleased))
				keyData = i;
		
		if (keyData == -1)
			return;

		//if (!pressed[keyData])
			//return;

		pressed[keyData] = false; //omg ur not pressing key !!
	}

	//handles animations and hold notes
	private function keyShit():Void
	{
		if (pressed.contains(true) && generatedMusic)
			notes.forEachAlive(swagNote -> {
				if (swagNote.isSustainNote && swagNote.canBeHit && swagNote.mustPress && pressed[swagNote.noteData])
					goodNoteHit(swagNote);
			});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 0.004 && !pressed.contains(true) &&
			boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			boyfriend.dance();

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if(pressed[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
				spr.animation.play('pressed');
			if ((!pressed[spr.ID] && !OptionsMenu.options.botPlay) || (OptionsMenu.options.botPlay && spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished))
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}


	var direction:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}		

			combo = 0;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			boyfriend.playAnim('sing' + this.direction[direction] + 'miss', true);
		}
	}

	function badNoteCheck()
	{
		// HOLY SHIT REDONE THE SYSTEM!?!?!!?
		var upP = pressed[2];
		var rightP = pressed[3];
		var downP = pressed[1];
		var leftP = pressed[0];

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function badNoteHit()
		{
			// just double pasting this shit cuz fuk u
			// HOLY SHIT REDONE THE SYSTEM?!?!
			var upP = pressed[2];
			var rightP = pressed[3];
			var downP = pressed[1];
			var leftP = pressed[0];
	
			if (leftP)
				noteMiss(0);
			if (downP)
				noteMiss(1);
			if (upP)
				noteMiss(2);
			if (rightP)
				noteMiss(3);
		}

	/*function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}*/

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{	

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			boyfriend.playAnim("sing" + direction[note.noteData], true);

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm');
				}
			});

			updateAccuracy();

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				totalNotesHit++;
				combo += 1;
				popUpScore(note);
				if (combo > highestCombo)
					highestCombo = combo;


				note.kill();
				notes.remove(note, true);
				remove(note);
				note.destroy();
			}

			var isSus:Bool = note.isSustainNote;
			var leData:Int = Math.round(Math.abs(note.noteData));
		}
	}
	
	public function spawnNoteSplashOnNote(note:Note) {
		if(note != null) {
			var s = playerStrums.members[note.noteData];
			if(s != null) {
				spawnNoteSplash(s.x, s.y, note.noteData, note);
			}
		}
	}
	
	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data);
		grpNoteSplashes.add(splash);
	}

	function botPlayNoteHit(note:Note):Void
	{	
		if (note.noteData >= 0)
			health += 0.023;
		else
			health += 0.004;

		boyfriend.playAnim("sing" + direction[note.noteData], true);

		note.wasGoodHit = true;
		vocals.volume = 1;

		if (!note.isSustainNote)
		{
			totalNotesHit++;
			combo += 1;
			popUpScore(note);
			if (combo > highestCombo)
				highestCombo = combo;
		}

		note.kill();
		notes.remove(note, true);
		remove(note);
		note.destroy();
	}

	function opponentNoteHit(daNote:Note)
	{
		if (daNote.y > FlxG.height)
		{
			daNote.active = false;
			daNote.visible = false;
		}
		else
		{
			daNote.visible = true;
			daNote.active = true;
		}

		daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

		// i am so fucking sorry for this if condition
		// holy fucking shit
		if (daNote.isSustainNote
			&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
			&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
		{
			var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
			swagRect.y /= daNote.scale.y;
			swagRect.height -= swagRect.y;

			daNote.clipRect = swagRect;
		}

		if (!daNote.mustPress && daNote.wasGoodHit)
		{
			if (SONG.song != 'Tutorial')
				camZooming = true;

			var altAnim:String = "";
			//god darnit
			/*if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (SONG.sections[Math.floor(curStep / 16)].altAnim)
					altAnim = '-alt';
			}*/			
			var checked = checkSection();
			if (checked != null)
			{
				if (getPropertyFromSection(checked, "altAnim"))
					altAnim = '-alt';
			}

			dad.playAnim("sing" + direction[daNote.noteData] + altAnim, true);

			dad.holdTimer = 0;

			if (SONG.needsVoices)
				vocals.volume = 1;

			/*cpuStrums.forEach(function(spr:FlxSprite)
			{
				
				if (Math.abs(daNote.noteData) == spr.ID)
				{	
					spr.animation.play('confirm', true);									
				}
				if(!curStage.startsWith("school"))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}		
				else
					spr.centerOffsets();
			});*/

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}

		// WIP interpolation shit? Need to fix the pause issue
		// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

		if (daNote.y < -daNote.height)
		{
			if (daNote.tooLate || !daNote.wasGoodHit)
			{
				noteMiss(daNote.noteData);
				misses++;
				health -= 0.04;
				totalNotesHit++;
				songScore -= 10;
				vocals.volume = 0;
				updateAccuracy();
			}

			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
	}

	//just to call it several times lol
	function updateAccuracy()
	{
		//totalNotesHit += 1;
		//accuracy = FlxMath.roundDecimal(preAcc / totalNotesHit * 100, 2) ;
		accuracy = FlxMath.roundDecimal(preAcc / totalNotesHit, 2);
	}

	override function stepHit()
	{
		super.stepHit();

		(Math.abs(FlxG.sound.music.time - Conductor.songPosition) > 15 || (SONG.needsVoices && Math.abs(vocals.time - Conductor.songPosition) > 15)) ? resyncVocals() : null;
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}
		var checked = checkSection();
		if (checked != null)
		{
			(getPropertyFromSection(checked, "changeBPM.active")) ? Conductor.changeBPM(getPropertyFromSection(checked, "changeBPM.bpm")) : null;
			FlxG.log.add('CHANGED BPM! ' + getPropertyFromSection(checked, "changeBPM.bpm"));
		}
		wiggleShit.update(Conductor.crochet);

		if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith("sing"))
			dad.dance();

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35 && OptionsMenu.options.cameraZoom)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
	
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0 && OptionsMenu.options.cameraZoom)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
	
			if (customHUDClass.iconP1.scale.x < 1.24)
				customHUDClass.iconP1.scale.set(1.24, 1.24);
	
			if (customHUDClass.iconP2.scale.x < 1.24)
				customHUDClass.iconP2.scale.set(1.24, 1.24);
			
			if (curBeat % gfSpeed == 0)
			{
				gf.dance();
			}
	
			if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			{
				boyfriend.dance();
			}
	
			if (curBeat % 8 == 7 && curSong == 'Bopeebo')
			{
				boyfriend.playAnim('hey', true);
			}
	
			if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
			{
				boyfriend.playAnim('hey', true);
				dad.playAnim('cheer', true);
			}

		customHUDClass.iconP1.setGraphicSize(Std.int(customHUDClass.iconP1.width + 30));
		customHUDClass.iconP2.setGraphicSize(Std.int(customHUDClass.iconP2.width + 30));

		customHUDClass.iconP1.updateHitbox();
		customHUDClass.iconP2.updateHitbox();

        switch (curStage)
        {
            case 'halloween':
                if (FlxG.random.bool(Conductor.bpm > 320 ? 100 : 10) && curBeat > lightningStrikeBeat + lightningOffset)
                {
                    lightningStrikeShit();
                    trace('spooky');
                }
            case 'school':
                bgGirls.dance();
            case 'limo':
                grpLimoDancers.forEach(function(dancer:BackgroundDancer)
                {
                    dancer.dance();
                });

                if (FlxG.random.bool(10) && fastCarCanDrive)
                    fastCarDrive();              
            case "philly":
                if (!trainMoving)
                    trainCooldown += 1;

                if (curBeat % 4 == 0)
                {
                	var lastLight:FlxSprite = phillyCityLights.members[0];
                    phillyCityLights.forEach(function(light:FlxSprite)
                    {
                    	// Take note of the previous light
						if (light.visible == true)
							lastLight = light;
                        light.visible = false;
                    });

                    // To prevent duplicate lights, iterate until you get a matching light
					while (lastLight == phillyCityLights.members[curLight])
					{
						curLight = FlxG.random.int(0, phillyCityLights.length - 1);
					}

                    phillyCityLights.members[curLight].visible = true;
                    phillyCityLights.members[curLight].alpha = 1;

					FlxTween.tween(phillyCityLights.members[curLight], {alpha: 0}, Conductor.stepCrochet * .016);
                }               
                if (curBeat % 8 == 4 && FlxG.random.bool(Conductor.bpm > 320 ? 150 : 30) && !trainMoving && trainCooldown > 8)
                {
                    if (FlxG.save.data.distractions)
                    {
                        trainCooldown = FlxG.random.int(-4, 0);
                        trainStart();
                        trace('train');
                    }
                }
        }
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
        fastCar.visible = false;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

        fastCar.visible = true;
		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
    var trainSound:FlxSound;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			PlayState.gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		PlayState.boyfriend.playAnim('scared', true);
		PlayState.gf.playAnim('scared', true);
	}

	var curLight:Int = 0;

}
