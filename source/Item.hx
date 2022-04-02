package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

class Item extends FlxSprite{
	public var forceX:Float = Math.NEGATIVE_INFINITY;
	public var targetY:Float = 0;
	public var targetX:Float = 0;
	public var yMult:Float = 120;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;
	public var scrollType:String = "";

    public function new(x:Float, y:Float) {
		super(x, y);
		antialiasing = true;
	}

	override function update(elapsed:Float) {
		var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);
		var scaledX = FlxMath.remapToRange(targetX, 0, 1, 0, 1.3);
		var lerpVal:Float = CoolUtil.bound(elapsed * 9.6, 0, 1);

		switch (scrollType) {
			case "Classic":
				y = FlxMath.lerp(y, (scaledY * yMult) + (FlxG.height * 0.48), lerpVal);
				if (forceX != Math.NEGATIVE_INFINITY) {
					x = forceX;
				}
				else {
					x = FlxMath.lerp(x, (targetY * 20) + 90, lerpVal);
				}

			case "Vertical":
				y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.5), lerpVal);
				x = FlxMath.lerp(x, (targetY * 0) + 308, lerpVal);
				x += targetX / (openfl.Lib.current.stage.frameRate / 60);

			case "Horizontal":
				screenCenter(Y);
				x = FlxMath.lerp(x, (scaledX * 200) + (FlxG.width * 0.5), lerpVal);
				x -= 12.5;

			case "C-Shape":
				y = FlxMath.lerp(y, (scaledY * 65) + (FlxG.height * 0.39), lerpVal);

				x = FlxMath.lerp(x, Math.exp(scaledY * 0.8) * 70 + (FlxG.width * 0.1), lerpVal);
				if (scaledY < 0)
					x = FlxMath.lerp(x, Math.exp(scaledY * -0.8) * 70 + (FlxG.width * 0.1), lerpVal);

				if (x > FlxG.width + 30)
					x = FlxG.width + 30;
			case "D-Shape":
				y = FlxMath.lerp(y, (scaledY * 90) + (FlxG.height * 0.45), lerpVal);

				x = FlxMath.lerp(x, Math.exp(scaledY * 0.8) * -70 + (FlxG.width * 0.35), lerpVal);
				if (scaledY < 0)
					x = FlxMath.lerp(x, Math.exp(scaledY * -0.8) * -70 + (FlxG.width * 0.35), lerpVal);

				if (x < -900)
					x = -900;
			case "Center":
				screenCenter(X);

				y = FlxMath.lerp(y, (scaledY * 120) + (FlxG.height * 0.48), 0.30);
				// x = FlxMath.lerp(x, (targetY * 20) + 90, 0.30);
		}

		super.update(elapsed);
	}
}