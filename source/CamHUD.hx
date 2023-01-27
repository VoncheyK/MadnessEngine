package;

//multipurpose playstate camhud
import flixel.util.FlxColor;
import flixel.FlxG;
import options.OptionsMenu;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.FlxSprite;

class CamHUD extends flixel.group.FlxSpriteGroup
{
    public var healthBar:FlxBar;
    public var healthBarBG:FlxSprite;
    public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;

    public var scoreTxt:FlxText;
    public var botplayTxt:FlxText;

    public var timeTxt:FlxText;
    public var timeBarBG:AttachedSprite;
    public var timeBar:FlxBar;

	public var songPercent:Float = 0;
   
    public function new(){
        super();

        healthBarBG = new FlxSprite(0, (OptionsMenu.options.middleScroll ? FlxG.height / 2 : (OptionsMenu.options.downScroll ? 45 : FlxG.height * 0.85)) ).loadGraphic(Paths.image('healthBar'));
		if (OptionsMenu.options.middleScroll)
			healthBarBG.x = FlxG.width /2 + 300;
		else
			healthBarBG.screenCenter(X);
		//make it even
		healthBarBG.setGraphicSize(Math.floor(healthBarBG.width), Math.floor(healthBarBG.height + 2));
		healthBarBG.updateHitbox();
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), PlayState,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		//healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.createFilledBar(FlxColor.fromRGB(PlayState.dad.iconColor[0], PlayState.dad.iconColor[1], PlayState.dad.iconColor[3]), 
		FlxColor.fromRGB(PlayState.boyfriend.iconColor[0], PlayState.boyfriend.iconColor[1], PlayState.boyfriend.iconColor[2]));
		// healthBar
		add(healthBar);
		//healthBar.divideBarByThreeAndSetColours();

		if (OptionsMenu.options.middleScroll)
		{
			healthBar.angle = 90;
			healthBarBG.angle = 90;
		}

        var showTime:Bool = (OptionsMenu.options.showTimeBar);

        timeTxt = new FlxText(0, OptionsMenu.options.middleScroll ? OptionsMenu.options.downScroll ? 30 : FlxG.height * 0.95 : healthBarBG.y + (OptionsMenu.options.downScroll ? 15 : -30));
		timeTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		
		timeBarBG = new AttachedSprite('timeBar');
        timeBarBG.screenCenter();
        timeBarBG.x = timeTxt.x-44;
        timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
        timeBarBG.scrollFactor.set();
        timeBarBG.alpha = 0;
        timeBarBG.visible = showTime;
        timeBarBG.color = FlxColor.BLACK;
        timeBarBG.xAdd = -4;
        timeBarBG.yAdd = -4;

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(FlxColor.BLACK, FlxColor.CYAN);
		timeBar.numDivisions = 800;
		timeBar.alpha = 0;
		timeBar.visible = showTime;
		add(timeBarBG);
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

        scoreTxt = new FlxText(0, OptionsMenu.options.downScroll ? FlxG.height - 35 : 35, FlxG.width, "", 20);
        scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        scoreTxt.scrollFactor.set();
        scoreTxt.borderSize = 1.25;
        add(scoreTxt);

        iconP1 = new HealthIcon(PlayState.SONG.player1, true);
        if (OptionsMenu.options.middleScroll)
			iconP1.x = ( healthBar.x - (iconP1.width / 2) ) + 300;
		else
			iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

        iconP2 = new HealthIcon(PlayState.SONG.player2, false);
		if (OptionsMenu.options.middleScroll)
			iconP2.x = ( healthBar.x - (iconP2.width / 2) ) + 300;
		else
			iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

        botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		if(OptionsMenu.options.downScroll)
			botplayTxt.y = timeBarBG.y - 78;
		if(OptionsMenu.options.middleScroll) {
			if(OptionsMenu.options.downScroll)
				botplayTxt.y = botplayTxt.y - 78;
			else
				botplayTxt.y = botplayTxt.y + 78;
		}

		botplayTxt.setFormat(Paths.font("vcr.ttf"), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.size = 32;
		botplayTxt.borderSize = 2;
		botplayTxt.visible = OptionsMenu.options.botPlay;
		botplayTxt.cameras = [PlayState.instance.camCustom];
		add(botplayTxt);

		switch (FlxG.random.int(1, 4))
		{
			case 1:
				botplayTxt.text = "[BOTPLAY]";
			case 2:
				botplayTxt.text = "[SKILL ISSUE]";
			case 3:
				botplayTxt.text = "[HI MOM]";
			case 4:
				botplayTxt.text = "Rank: [BFC]"; //BFC stands for Bot Full Combo
		}

    }
}