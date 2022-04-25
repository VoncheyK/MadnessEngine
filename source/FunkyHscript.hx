package;

//import js.lib.webassembly.Table;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import hscript.Parser;
import haxe.ds.StringMap;
import hscript.Interp;
import lime.utils.Assets;
import sys.FileSystem;

using StringTools;

class FunkyHscript
{
    public var script:String = '';
	public var interp:hscript.Interp;

    public function new(script:String) {
        init(script);
		execute();

		// heck yea
		interp.variables.set("addScript", function(hscriptFile:String, ?ignoreRunning:Bool = false) {
			var daScript = hscriptFile + ".lua";
			var push = false;

			daScript = Paths.getPreloadPath(daScript);
			if (FileSystem.exists(daScript)) {
				push = true;
			}

			if (push)
			{
				if(!ignoreRunning)
				{
					for (hsInstance in PlayState.instance.hsArray)
					{
						if(hsInstance.script == daScript)
						{
							return;
						}
					}
				}
				PlayState.instance.hsArray.push(new FunkyHscript(daScript)); 
				return;
			}
		});

		// setup vars :()
		interp.variables.set("SongNameLowercase", PlayState.SONG.song.toLowerCase());
        interp.variables.set("SongName", PlayState.SONG.song);
		interp.variables.set("Speed", PlayState.instance.songSpeed);
		interp.variables.set("BPM", PlayState.SONG.bpm);

		interp.variables.set("curStep", 0);
		interp.variables.set("curBeat", 0);

		interp.variables.set("Math", Math);
			interp.variables.set("openCoolLink", function(link:String){
			FlxG.openURL(link);
		});

		// gonna add these individualy
		interp.variables.set("camGame", PlayState.instance.camGame);
		interp.variables.set("camHud", PlayState.instance.camHUD);

		// wtf is this
		interp.variables.set("camCustom", PlayState.instance.camCustom);

        interp.variables.set("bf", PlayState.boyfriend);
		interp.variables.set("dad", PlayState.dad);
		interp.variables.set("gf", PlayState.gf);

        interp.variables.set("strumLineNotes", PlayState.instance.strumLineNotes);
        interp.variables.set("playerStrums", PlayState.instance.playerStrums);
        interp.variables.set("cpuStrums", PlayState.instance.cpuStrums);
		interp.variables.set("scoreTxt", PlayState.instance.scoreTxt);

		interp.variables.set("tweenObject", function(object:Dynamic, result:Dynamic, time:Float, ease:String) { 
			var newTween = FlxTween.tween(object, result, time, {ease: getFlxEaseByString(ease)});
		});

		interp.variables.set("changeSpeed", function(speed:Float, time:Float) { 
			PlayState.instance.changeSpeed(speed, time);
		});

		call('onCreate', []);
    }

    public function init(scriptPath):Void
    {
        if (Assets.exists(scriptPath))
		{
			script = CoolUtil.useless(scriptPath);
		}
		else
		{
			script = "trace('No script was found. Ignoring!')";
		}

		interp = new Interp();
    }

    public function execute() {
        var parser = new Parser();
        var program = parser.parseString(script);
        interp.execute(program);
    }

    public function call(func_name:String, args:Array<Dynamic>) {
        if (interp.variables.exists(func_name))
            return;

        var method = interp.variables.get(func_name);
        Reflect.callMethod(interp, method, args);
    }

	function getFlxEaseByString(?ease:String = '') {
		switch(ease.toLowerCase().trim()) {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepInOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}
}
