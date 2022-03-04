package;

import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import PlayState;

class Stages extends FlxSprite
{
    var halloweenLevel:Bool;
    var isHalloween:Bool;
    public var curStage:String = "";
    public var stageToAdd:Array<Dynamic>;
    public var groupToAdd:Map<String, FlxTypedGroup<Dynamic>> = [];
    public var defaultCamZoom:Float = 1;
    //just took this from kade because of layerin shit
    public var bgToAdd:Map<String, Dynamic> = [];
	public var animatedBG:Array<FlxSprite> = [];
	public var layInFront:Array<Array<FlxSprite>> = [[], [], []];
    public function new(stage:String)
    {
        super();

        curStage = stage;
        defaultCamZoom = 1;

        switch (curStage)
        {
            case 'spooky':
	        	halloweenLevel = true;
                isHalloween = true;

		    	var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	        	var halloweenBG = new FlxSprite(-200, -100);
		    	halloweenBG.frames = hallowTex;
	        	halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	        	halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	        	halloweenBG.animation.play('idle');
	        	halloweenBG.antialiasing = true;
                bgToAdd["halloweenBG"] = halloweenBG;
	        	stageToAdd.push(halloweenBG);		    	
		    case 'philly':
		        var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		        bg.scrollFactor.set(0.1, 0.1);
                bgToAdd["bg"] = bg;
		        stageToAdd.push(bg);

	            var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		        city.scrollFactor.set(0.3, 0.3);
		        city.setGraphicSize(Std.int(city.width * 0.85));
		        city.updateHitbox();
                bgToAdd["city"] = city;
                stageToAdd.push(city);	        

		        var phillyCityLights = new FlxTypedGroup<FlxSprite>();
                groupToAdd["phillyCityLights"] = phillyCityLights;
                stageToAdd.push(phillyCityLights);

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
                bgToAdd["steetBehind"] = streetBehind;
                stageToAdd.push(streetBehind);

	            var phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		        bgToAdd["phillyTrain"] = phillyTrain;
                stageToAdd.push(phillyTrain);

		        var trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		        FlxG.sound.list.add(trainSound);

		        // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		        var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	            bgToAdd["street"] = street;
                stageToAdd.push(street);
		    case 'limo':
		        defaultCamZoom = 0.90;
                
		        var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		        skyBG.scrollFactor.set(0.1, 0.1);
                bgToAdd["skyBG"] = skyBG;
		        stageToAdd.push(skyBG);

		        var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		        bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		        bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		        bgLimo.animation.play('drive');
		        bgLimo.scrollFactor.set(0.4, 0.4);
                bgToAdd["bgLimo"] = bgLimo;
		        stageToAdd.push(bgLimo);

                var fastCar:FlxSprite;
                //!paste this later

		        var grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
                groupToAdd["grpLimoDancers"] = grpLimoDancers;
		        stageToAdd.push(grpLimoDancers);

		        for (i in 0...5)
		        {
		            var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		            dancer.scrollFactor.set(0.4, 0.4);
		            grpLimoDancers.add(dancer);
                    bgToAdd['dancer'+i] = dancer;
		        }

		        var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		        overlayShit.alpha = 0.5;
		        // add(overlayShit);

		        // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		        // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		        // overlayShit.shader = shaderBullshit;

		        var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		        var limo = new FlxSprite(-120, 550);
		        limo.frames = limoTex;
		        limo.animation.addByPrefix('drive', "Limo stage", 24);
		        limo.animation.play('drive');
		        limo.antialiasing = true;
                layInFront[0].push(limo);
                bgToAdd["limo"] = limo;

		        var fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		        // add(limo);
		        
		    case 'mall':
		       	defaultCamZoom = 0.80;

		       	var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		       	bg.antialiasing = true;
		       	bg.scrollFactor.set(0.2, 0.2);
		       	bg.active = false;
		       	bg.setGraphicSize(Std.int(bg.width * 0.8));
		       	bg.updateHitbox();
                bgToAdd["bg"] = bg;
		       	stageToAdd.push(bg);

		       	var upperBoppers = new FlxSprite(-240, -90);
		       	upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		       	upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		       	upperBoppers.antialiasing = true;
		       	upperBoppers.scrollFactor.set(0.33, 0.33);
		       	upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		       	upperBoppers.updateHitbox();
                bgToAdd["upperBoppers"] = upperBoppers;
		       	stageToAdd.push(upperBoppers);
                animatedBG.push(upperBoppers);

		       	var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		       	bgEscalator.antialiasing = true;
		       	bgEscalator.scrollFactor.set(0.3, 0.3);
		       	bgEscalator.active = false;
		       	bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		       	bgEscalator.updateHitbox();
                bgToAdd['bgEscalator'] = bgEscalator;
		       	stageToAdd.push(bgEscalator);

		       	var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		       	tree.antialiasing = true;
		       	tree.scrollFactor.set(0.40, 0.40);
                bgToAdd["tree"] = tree;
		       	stageToAdd.push(tree);

		       	var bottomBoppers = new FlxSprite(-300, 140);
		       	bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		       	bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		       	bottomBoppers.antialiasing = true;
	           	bottomBoppers.scrollFactor.set(0.9, 0.9);
	           	bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		       	bottomBoppers.updateHitbox();
                bgToAdd["bottomBoppers"] = bottomBoppers;
		       	stageToAdd.push(bottomBoppers);
                animatedBG.push(bottomBoppers);

		       	var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		       	fgSnow.active = false;
		       	fgSnow.antialiasing = true;
                bgToAdd["fgSnow"] = fgSnow;
		       	stageToAdd.push(fgSnow);

		       	var santa = new FlxSprite(-840, 150);
		       	santa.frames = Paths.getSparrowAtlas('christmas/santa');
		       	santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		       	santa.antialiasing = true;
                bgToAdd["santa"] = santa;
		       	stageToAdd.push(santa);
                animatedBG.push(santa);
				
		    case 'mallEvil':
		        var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		        bg.antialiasing = true;
		        bg.scrollFactor.set(0.2, 0.2);
		        bg.active = false;
		        bg.setGraphicSize(Std.int(bg.width * 0.8));
		        bg.updateHitbox();
		        stageToAdd.push(bg);

		        var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		        evilTree.antialiasing = true;
		        evilTree.scrollFactor.set(0.2, 0.2);
		        stageToAdd.push(evilTree);

		        var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	            evilSnow.antialiasing = true;
		        stageToAdd.push(evilSnow);
		    case 'school':
		        // defaultCamZoom = 0.9;

		        var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		        bgSky.scrollFactor.set(0.1, 0.1);
		        stageToAdd.push(bgSky);

		        var repositionShit = -200;

		        var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		        bgSchool.scrollFactor.set(0.6, 0.90);
		        stageToAdd.push(bgSchool);

		        var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		        bgStreet.scrollFactor.set(0.95, 0.95);
		        stageToAdd.push(bgStreet);

		        var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		        fgTrees.scrollFactor.set(0.9, 0.9);
		        stageToAdd.push(fgTrees);

		        var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		        var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		        bgTrees.frames = treetex;
		        bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		        bgTrees.animation.play('treeLoop');
		        bgTrees.scrollFactor.set(0.85, 0.85);
		        stageToAdd.push(bgTrees);

		        var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		        treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		        treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		        treeLeaves.animation.play('leaves');
		        treeLeaves.scrollFactor.set(0.85, 0.85);
		        stageToAdd.push(treeLeaves);

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

		        var bgGirls = new BackgroundGirls(-100, 190);
		        bgGirls.scrollFactor.set(0.9, 0.9);

		        if (PlayState.bgGirlsScared)
		            bgGirls.getScared();

		        bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
		        bgGirls.updateHitbox();
		        stageToAdd.push(bgGirls);
		        
		    case 'schoolEvil':
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
		        stageToAdd.push(bg);

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
		        stageToAdd.push(bg);

		        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		        stageFront.updateHitbox();
		        stageFront.antialiasing = true;
		        stageFront.scrollFactor.set(0.9, 0.9);
		        stageFront.active = false;
		        stageToAdd.push(stageFront);

		        var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		        stageCurtains.updateHitbox();
		        stageCurtains.antialiasing = true;
		        stageCurtains.scrollFactor.set(1.3, 1.3);
		        stageCurtains.active = false;

		        stageToAdd.push(stageCurtains);
        }
    }
    var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

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
			gf.playAnim('hairBlow');
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

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

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
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}