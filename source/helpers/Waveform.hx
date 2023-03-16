package helpers;

import flixel.addons.ui.FlxUIState;
import lime.utils.UInt8Array;
import lime.media.AudioBuffer;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import flixel.tweens.FlxTween;

class Waveform
{
	public var data:UInt8Array;
	public var numChannels:Int;
	public var sampleRate:Int;
	public var numSamples:Float;
	public var buffer:AudioBuffer;

	// for other usage.
	public var averageAmplitude:Float;

	public function new(filePath:String)
	{
		if (FileSystem.exists(filePath))
		{
			var buffer = AudioBuffer.fromBytes(File.getBytes(filePath));
			this.buffer = buffer;
			data = buffer.data;
			numChannels = buffer.channels;
			sampleRate = buffer.sampleRate;
			numSamples = data.length / numChannels;
		}
	}

	public function getAvgAmplitude():Float
	{
		var sum:Float = 0;

		for (i in 0...Std.int(numSamples))
		{
			var sampleSum:Float = 0;
			for (j in 0...numChannels)
				sampleSum += Math.abs(data[i * numChannels + j]);
			sum += sampleSum / numChannels;
		}
		averageAmplitude = sum / numSamples;

		return averageAmplitude;
	}

    public function getIntensity(position:Float):Float {
        var sum:Float = 0;

        var startSample = Math.floor(position / 1000 * buffer.sampleRate);
        var endSample = Math.floor((position + 1000 / 60) / 1000 * buffer.sampleRate);

        for (i in startSample...endSample) {
            var sampleSum:Float = 0;
            for (j in 0...numChannels) {
                sampleSum += Math.abs(data[i * numChannels + j]);
            }
            sum += sampleSum / numChannels;
        }    

        var averageAmplitudeSample = sum / (endSample - startSample + 1);
        var maxAmplitude = Math.pow(2, 15);
        var intensity = (averageAmplitudeSample - averageAmplitude) / maxAmplitude;

        return intensity;
    }

	public function getCurrentAvgAmplitude(position:Float):Float
	{
        var sum:Float = 0;

        var startSample = Math.floor(position / 1000 * buffer.sampleRate);
        var endSample = Math.floor((position + 1000 / 60) / 1000 * buffer.sampleRate);
    
        for (i in startSample...endSample) {
            var sampleSum:Float = 0;
            for (j in 0...numChannels) {
                sampleSum += Math.abs(data[i * numChannels + j]);
            }
            sum += sampleSum / numChannels;
        }
    
        var averageAmplitude = sum / (endSample - startSample + 1);
        return averageAmplitude;
	}
}

class ImprovedBeatState extends FlxUIState
{
	public var data:Waveform;
	public var baseAmp:Float;
    public var sprite:flixel.FlxSprite;

	public function new(songName:String)
	{
		super();
		data = new Waveform(songName);

		baseAmp = data.getAvgAmplitude();
	}

    override function create(){
        sprite = new flixel.FlxSprite(500, 500).loadGraphic(Paths.image("logo"));
        sprite.x = (FlxG.width / 2) - (sprite.width / 2);
        sprite.y = (FlxG.height / 2) - (sprite.height / 2);
        add(sprite);
    }

	override function update(delta:Float)
	{
        var curAmplitude = data.getCurrentAvgAmplitude(FlxG.sound.music.time);

		if (curAmplitude > baseAmp || curAmplitude == baseAmp)
			beatHit(curAmplitude);

		super.update(delta);
	}

	public function beatHit(amp:Float):Void
	{        
        var scale = Math.min(Math.abs(baseAmp - amp) / 10, 2) / 1.25;
        trace(scale);
        if (scale <= 0)
            scale = 1;

        FlxTween.tween(sprite.scale, { x: scale, y: scale }, 0.1, { type: FlxTweenType.ONESHOT } );
	}
}

class TestState extends ImprovedBeatState
{
	public function new(songName:String, ?mod:String)
	{
        FlxG.sound.playMusic(Paths.inst(songName, mod));
		super(Paths.instPath(songName, mod));
	}
}