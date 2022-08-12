package ui;

//week 7 code
import netTest.ServerHandler;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSubState;
import GameJolt;
import netTest.Director;

class Prompt extends FlxSubState
{
	public static var MARGIN:Float = 100;
	
	var style:ButtonStyle;
	var buttons:TextMenuList;
	var field:AtlasText;
	public var back:FlxSprite;

	public var onYes:Dynamic = null;
	public var onNo:Dynamic = null;
	
	override public function new(text:String, style:ButtonStyle = Ok)
	{
		this.style = style;
		super(0x80000000);
		buttons = new TextMenuList(Horizontal);
		field = new AtlasText(0, 0, text, Bold);
		field.scrollFactor.set(0, 0);
	}

	override function create()
	{
		super.create();
		field.y = 100;
		field.screenCenter(X);
		add(field);
		createButtons();
		add(buttons);
	}

	public function createBg(width:Int, height:Int, color:FlxColor = 0xFF808080)
	{
		back = new FlxSprite();
		back.makeGraphic(width, height, color, false, 'prompt-bg');
		back.screenCenter(XY);
		add(back);
		members.unshift(members.pop());
	}

	public function createBgFromMargin(?margin:Float = 100, color:FlxColor = 0xFF808080)
	{
		createBg(Std.int(FlxG.width - 2 * margin), Std.int(FlxG.height - 2 * margin), color);
	}

	public function setButtons(style:ButtonStyle)
	{
		if (this.style != style)
		{
			this.style = style;
			createButtons();
		}
	}

	public function createButtons()
	{
		while (buttons.members.length > 0)
		{
			buttons.remove(buttons.members[0], true).destroy();
		}
		switch (style)
		{
			case Ok:
				createButtonsHelper('ok');
			case Yes_No:
				createButtonsHelper('yes', 'no');
			case Custom(yes, no):
				createButtonsHelper(yes, no);
			case None:
				buttons.exists = false;
		}
	}

	public function createButtonsHelper(item1:String, ?item2:String)
	{
		buttons.exists = true;
		var btn1:TextMenuItem = buttons.createItem(null, null, item1, null, function()
		{
			onYes();
		});
		btn1.screenCenter(X);
		btn1.y = FlxG.height - btn1.height - 100;
		btn1.scrollFactor.set(0, 0);
		if (item2 != null)
		{
			btn1.x = FlxG.width - btn1.width - 100;
			var btn2:TextMenuItem = buttons.createItem(null, null, item2, null, function()
			{
				onNo();
			});
			btn2.x = 100;
			btn2.y = FlxG.height - btn1.height - 100;
			btn2.scrollFactor.set(0, 0);
		}
	}

	public function setText(text:String)
	{
		field.text = text;
		field.screenCenter(X);
	}
}

class MultiPrompt extends Prompt
{
    public function new(text:String, buttonStyle:ButtonStyle = Yes_No)
        {
            super(text, buttonStyle);
            create();
            createBgFromMargin(120, 0xFF808080);
            back.scrollFactor.set(0,0);
        }

    /*public function showLoginPrompt(show:Bool)
        {
            var svPrompt = new MultiPrompt("\nGameJolt Authentication\n Required", None);
            var whatthej = function(iinput:Void->Void)
                {
                    var d = show ? "Login to GameJolt?" : null;
                    if (d != null) 
                    {
                            svPrompt.setText(d);
                            svPrompt.setButtons(Yes_No);
                            svPrompt.buttons.getItem('yes').fireInstantly = true;
                            svPrompt.onYes = function()
                                {
                                    svPrompt.setText('Redirecting.');
                                    svPrompt.setButtons(None);
                                    GameJoltInfo.changeState = new Director();
                                    GameJoltInfo.fontPath = 'assets/fonts/emptyLetters.ttf';
                                    GameJoltInfo.font = Paths.font('emptyLetters.ttf');
                                    trace("SwitchedState");
                                    FlxG.switchState(new GameJoltLogin());
                                    svPrompt.close();
                                    svPrompt = null;
                                    iinput();
                                }
                            svPrompt.onNo = function() 
                                {
                                    trace("Cancelled");
									svPrompt.close();
                                    FlxG.switchState(new MainMenuState());
                                } 
                    }
                    else
                        {
                            svPrompt.setText('Connecting...');
                            trace("Connected");
                            switch(GameJoltAPI.getStatus())
                            {
                                case true:
                                    FlxG.switchState(new ServerHandler());
                                case false:
                                    svPrompt.setText('\nFailed to connect!\n\n\n\n Redirecting to GameJolt\n\n Log in screen.');
                                    GameJoltInfo.changeState = new Director();
                                    GameJoltInfo.fontPath = 'assets/fonts/emptyLetters.ttf';
                                    GameJoltInfo.font = Paths.font('emptyLetters.ttf');
                                    FlxG.switchState(new GameJoltLogin());
                                    svPrompt.close();
                                    svPrompt = null;
                            }

                            iinput();
                        }
                }  

        svPrompt.openCallback = function()
        {
            trace("Callback");
        }
        
        return svPrompt;
        }*/
}