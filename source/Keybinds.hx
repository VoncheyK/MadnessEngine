package;

import flixel.util.FlxColor;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Controls.Control;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.input.FlxBaseKeyList;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import options.OptionsMenu;

//!also improve menu because it sucks
/**
    will work as menu and as data saver or some shit
**/
class Keybinds extends MusicBeatSubstate
{
    var grpKeybinds:FlxTypedGroup<Alphabet>;//direction keybind text
    var curSelected:Int;
    
    var text:FlxText;
    static public var keybinds:Array<Array<Dynamic>> = [];
    var e:Array<Int> = [27, 20, 13, 18, 8];

    override function create() {

        loadKeybinds();

        var bg = new FlxSprite(0,0).loadGraphic(Paths.image("menuBGBlue"));
        bg.scrollFactor.set();
        add(bg);

        grpKeybinds = new FlxTypedGroup<Alphabet>();
        add(grpKeybinds);

        for (i => value in keybinds)
        {
            var thing = new Alphabet(0,0, value[0] + " keybind - " + cast(value[1][0], FlxKey).toString(), true); 
            thing.isMenuItem = true;
            thing.targetY = i;
            grpKeybinds.add(thing);
        }

        text = new FlxText(0, 100, 0, "PRESS ANY KEY");
        text.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE);
        text.visible = false;
        add(text);

        text.screenCenter(X);
		
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDown);

        super.create();
    }

    public function new() {
        super();      
    }

    var settingKeybind = false;

    function keyDown(event:KeyboardEvent)
    {
        if (event.keyCode == Keyboard.UP)
            changeSelection(-1);
        if (event.keyCode == Keyboard.DOWN)
            changeSelection(1);

        if (event.keyCode == Keyboard.ESCAPE)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            if (settingKeybind)
                settingKeybind = text.visible = false;
            else
            {
                close();
                OptionsMenu.inKeyBindsMenu = false;
            }
        }

        var curKey:FlxKey = keybinds[curSelected][1][0];

        if(event.keyCode == Keyboard.ENTER)
            text.visible = settingKeybind = true;

        if(settingKeybind && !e.contains(event.keyCode))
        {
            FlxG.sound.play(Paths.sound('confirmMenu'));
            trace(keybinds[curSelected][0] + ": " +  curKey);
            keybinds[curSelected][1][0] = event.keyCode;
            curKey = keybinds[curSelected][1][0];

            //thoguht of something
            Reflect.setProperty(FlxG.save.data, keybinds[curSelected][0] + "Bind",  curKey.toString());
            grpKeybinds.members[curSelected].changeText(keybinds[curSelected][0] + " keybind - " +  curKey.toString());
            FlxG.save.flush();
            settingKeybind = text.visible = false;
        }
    }

    function changeSelection(change:Int = 0)
    {
        //sound fuck you
        FlxG.sound.play(Paths.sound('scrollMenu'));

        curSelected += change;

        if (curSelected > 3)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = 3;

        var bullShit:Int = 0;
        grpKeybinds.forEach(key -> { //ilike this more than function(sth:blah)
            key.targetY = bullShit - curSelected;
			bullShit++;

            key.alpha = 0.6;
            if (key.targetY == 0)
                key.alpha = 1;
        });
    }

    public static function loadKeybinds()
    {
        keybinds = [
            ["left", [FlxKey.fromString(FlxG.save.data.leftBind), LEFT]],
            ["down", [FlxKey.fromString(FlxG.save.data.downBind), DOWN]],
            ["up", [FlxKey.fromString(FlxG.save.data.upBind), UP]],
            ["right", [FlxKey.fromString(FlxG.save.data.rightBind), RIGHT]]
        ];
    }
}