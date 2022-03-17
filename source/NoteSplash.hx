package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class NoteSplash extends FlxSprite
{
	public static var colors:Array<String> = ['purple', 'blue', 'green', 'red'];

	var colorsThatDontChange:Array<String> = ['purple', 'blue', 'green', 'red'];

	public function new(nX:Float, nY:Float, color:Int)
	{
		x = nX;
		y = nY;
		super(x, y);
		frames = Paths.getSparrowAtlas('NOTE_splashes', 'shared');
		for (i in 0...colorsThatDontChange.length)
		{
			animation.addByPrefix('splash ' + colorsThatDontChange[i], 'notesplash ' + colorsThatDontChange[i], 24, false);
		}
		//animation.play('splash');
		antialiasing = true;
		updateHitbox();
		makeSplash(nX, nY, color);
	}

	public function makeSplash(nX:Float, nY:Float, color:Int) 
	{
        setPosition(nX - 105, nY - 110);
		angle = FlxG.random.int(0, 360);
        alpha = 0.6;
        animation.play('splash ' + colors[color], true);
		animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
		//offset.set(500, 200);
        updateHitbox();
    }

	override public function update(elapsed) 
	{
        if (animation.curAnim.finished)
		{
            kill();
        }

        super.update(elapsed);
    }

}
