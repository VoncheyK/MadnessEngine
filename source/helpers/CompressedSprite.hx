package helpers;

import flixel.FlxSprite;
import openfl.utils.ByteArray;
import haxe.io.Bytes;
import sys.io.File;
import openfl.display.BitmapData;
import haxe.zip.Compress;

class CompressedSprite extends flixel.FlxSprite
{
    public function new(x:Float, y:Float, graphic:String)
    {
        super(x, y);
        var bytes:Bytes = File.getBytes(graphic);
        var compressed:Bytes = Compress.run(bytes, 0);
        loadGraphic(graphic);
        var bpd:BitmapData;
        bpd = BitmapData.fromBytes(ByteArray.fromBytes(compressed));
        pixels = bpd;
    }
}