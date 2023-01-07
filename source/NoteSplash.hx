package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
		super(x, y);

		var skin:String = 'noteSplashes';

		loadAnims(skin);
		textureLoaded = skin;

		setupNoteSplash(x, y, note);
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = 0.6;

		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + note + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
	}

	public static function loadAnimsToSprite(sprite:FlxSprite)
	{
		sprite.frames = Paths.getSparrowAtlas("noteSplashes");
		for (i in 1...3) {
			sprite.animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			sprite.animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			sprite.animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			sprite.animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
	}

	function loadAnims(skin:String) {
		frames = flixel.graphics.FlxGraphic.fromBitmapData(PlayState.instance.playstateCache.getBitmapData("nSplashes")).atlasFrames;
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, 24, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, 24, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, 24, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, 24, false);
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}