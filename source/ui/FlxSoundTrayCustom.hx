package ui;

import flixel.util.FlxAxes;
import flash.geom.Rectangle;
#if FLX_SOUND_SYSTEM
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.system.ui.FlxSoundTray;
#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

class FlxSoundTrayCustom extends FlxSoundTray {
	var data:BitmapData;
	var rect:Rectangle;
	var cornerSize:Int = 10;
	var _height:Int = 30;

	var bgColor = 0xFFBA1313;

	var _shadow:Array<Bitmap>;

	@:keep
	override public function new()
	{
		super();

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		var bg:Bitmap = new Bitmap(data = new BitmapData(_width, _height, false, bgColor));
		//makeBitmapGraphic(data, _width, _height, bgColor); // hell nah
		screenCenterX();
		addChild(bg);

		var textFormat:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 10, 0xFFFFFFFF);
		textFormat.align = TextFormatAlign.CENTER;
		var shadowFormat:TextFormat = new TextFormat(FlxAssets.FONT_DEFAULT, 10, 0xFF000000);
		shadowFormat.align = TextFormatAlign.CENTER;

		var textShadow:TextField = new TextField();
		textShadow.width = bg.width;
		textShadow.height = bg.height;
		textShadow.x -= 1;
		textShadow.y = 15;
		textShadow.multiline = true;
		textShadow.wordWrap = true;
		textShadow.selectable = false;
		#if flash
		textShadow.embedFonts = true;
		textShadow.antiAliasType = AntiAliasType.NORMAL;
		textShadow.gridFitType = GridFitType.PIXEL;
		#end
		textShadow.defaultTextFormat = shadowFormat;
		textShadow.text = "VOLUME";
		addChild(textShadow);

		var text:TextField = new TextField();
		text.width = bg.width;
		text.height = bg.height;
		text.y = 16;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;
		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#end
		text.defaultTextFormat = textFormat;
		text.text = "VOLUME";
		addChild(text);

		var bx:Int = 9;
		var by:Int = 13;
		var bx2:Int = 10;
		var by2:Int = 14;

		_shadow = new Array();
		_bars = new Array();

		for (i in 0...10)
		{
			var barsShadow:Bitmap = new Bitmap(new BitmapData(4, i + 1, false, 0xFF000000));
			barsShadow.x = bx;
			barsShadow.y = by;
			addChild(barsShadow);
			_shadow.push(barsShadow);
			bx += 6;
			by--;
		}

		for (i in 0...10)
		{
			var bars:Bitmap = new Bitmap(new BitmapData(4, i + 1, false, 0xFFFFFFFF));
			bars.x = bx2;
			bars.y = by2;
			addChild(bars);
			_bars.push(bars);
			bx2 += 6;
			by2--;
		}

		y = -height;
		visible = false;
	}

	override public function update(MS:Float):Void
	{
		if (_timer > 0)
		{
			_timer -= MS / 1000;
		}
		else if (y > -height)
		{
			y -= (MS / 1000) * FlxG.height * 2;

			if (y <= -height)
			{
				visible = false;
				active = false;

				// Save sound prefs
				FlxG.save.data.mute = FlxG.sound.muted;
				FlxG.save.data.volume = FlxG.sound.volume;
				FlxG.save.flush();
			}
		}
	}

	override public function show(Silent:Bool = false):Void
	{
		if (!Silent)
		{
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		}

		_timer = 1;
		y = 0;
		visible = true;
		active = true;

		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}

		for (i in 0..._shadow.length)
		{
			if (i < globalVolume)
			{
				_shadow[i].alpha = 1;
			}
			else
			{
				_shadow[i].alpha = 0.5;
			}
		}

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
			{
				_bars[i].alpha = 1;
			}
			else
			{
				_bars[i].alpha = 0.5;
			}
		}
	}

	public function screenCenterX():Void // screen center x fr
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (FlxG.width - _width) / 2;
	}

	public function screenCenterY():Void // screen center y fr
	{
		y = (FlxG.height - _height) / 2;
	}

	function makeBitmapGraphic(bitmapData:BitmapData, w, h, color:Int)
	{
		var noColor = 0x0;
		bitmapData.fillRect(new Rectangle(0, 190, bitmapData.width, bitmapData.height), noColor);

		bitmapData.fillRect(new Rectangle(0, bitmapData.height - (cornerSize * 2), cornerSize * 2, cornerSize * 2), noColor);
		drawCircleCornerOnBitmap(bitmapData, false, true, color);
		bitmapData.fillRect(new Rectangle(bitmapData.width - (cornerSize * 2), bitmapData.height - (cornerSize * 2), cornerSize * 2, cornerSize * 2), noColor);
		drawCircleCornerOnBitmap(bitmapData, true, true, color);
	}

	function drawCircleCornerOnBitmap(bitmapData:BitmapData, flipX:Bool, flipY:Bool, color:Int)
	{
		var antiX:Float = (bitmapData.width - cornerSize);
		var antiY:Float = flipY ? (bitmapData.height - 1) : 0;
		if(flipY) antiY -= 2;
		bitmapData.fillRect(new Rectangle((flipX ? antiX : 1), Std.int(Math.abs(antiY - 8)), 10, 3), color);
		if(flipY) antiY += 1;
		bitmapData.fillRect(new Rectangle((flipX ? antiX : 2), Std.int(Math.abs(antiY - 6)),  9, 2), color);
		if(flipY) antiY += 1;
		bitmapData.fillRect(new Rectangle((flipX ? antiX : 3), Std.int(Math.abs(antiY - 5)),  8, 1), color);
		bitmapData.fillRect(new Rectangle((flipX ? antiX : 4), Std.int(Math.abs(antiY - 4)),  7, 1), color);
		bitmapData.fillRect(new Rectangle((flipX ? antiX : 5), Std.int(Math.abs(antiY - 3)),  6, 1), color);
		bitmapData.fillRect(new Rectangle((flipX ? antiX : 6), Std.int(Math.abs(antiY - 2)),  5, 1), color);
		bitmapData.fillRect(new Rectangle((flipX ? antiX : 8), Std.int(Math.abs(antiY - 1)),  3, 1), color);
	}
}
#end
