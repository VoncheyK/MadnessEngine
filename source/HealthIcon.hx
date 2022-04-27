package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	private var char:String = '';
	private var isPlayer:Bool = false;
	private var isOldIcon:Bool = false;
	public var sprTracker:FlxSprite;
	public var size:Int;

	public function new(char:String = 'bf', isPlayer:Bool = false, size:Int = 150)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		this.size = size;
		changeIcon(char);
		scrollFactor.set();
	}

	public function swapOldIcon()
	{
		if (isOldIcon = !isOldIcon)
			changeIcon('bf-old');
		else
			changeIcon('bf');
	}

	public function changeIcon(char:String)
	{
		if (this.char != char)
		{
			var name:String = 'icons/' + char;
			if (!Paths.assetExists('images/' + name + '.png', IMAGE))
				name = 'icons/icon-' + char;
			if (!Paths.assetExists('images/' + name + '.png', IMAGE))
				name = 'icons/icon-face';
			var file:Dynamic = Paths.image(name);
			loadGraphic(file, true, size, size);

			animation.add(char, [0, 1], 0, false, isPlayer);
			animation.play(char);
			this.char = char;

			antialiasing = true;
			if (char.endsWith('-pixel')) antialiasing = false;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function getCharacter():String {
		return char;
	}
}
