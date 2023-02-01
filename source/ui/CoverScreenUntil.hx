package ui;

import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;

class CoverScreenUntil extends FlxSpriteGroup
{
    public var bg:FlxSprite;
    public var text:Alphabet;

    public function new(appendedText:String){
        super();

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(33, 0, 127));
        bg.alpha = 0.7;
        add(bg);

        text = new Alphabet(0, 0, 'Please wait until $appendedText.', true, false, 0, 0.73);
        add(text);
		text.x = (FlxG.width - text.width) / 2;
        text.y = (FlxG.height - text.height) / 2;
        text.antialiasing = true;
    }
}