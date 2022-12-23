package;

import haxe.rtti.Meta;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.events.EventType;
import openfl.events.Event;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	
	private var controls(get, never):Controls;

	public var hscripts:Array<FunkyHscript> = [];

	private var callable:Bool = true;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		//var stateFlx:Dynamic = FlxG.state;
		//var stateMusicBeat:MusicBeatState = stateFlx;

		for (script in hscripts)
			script.call("create", []);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);

		super.create();
	}

	override function destroy()
	{
		for(script in hscripts)
			script.call("destroy", []);

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
		super.destroy();
	}

	public static function switchState(newState:FlxUIState, ?oldState:FlxUIState)
	{
		FlxG.switchState(newState);
		return oldState != null ? oldState : newState;
	}

	private function keyDown(event:KeyboardEvent)
	{
		for(script in hscripts){
			if (callable) {script.call("keyDown", [event]);}
		}

		if (event.keyCode == Keyboard.F5){
			callable = false;
			for (hscript in hscripts)
				hscript.wipeExceptVarsAndExecute("script", callable);
		}
	}

	private function keyUp(event:KeyboardEvent)
	{
		for(script in hscripts) { if(callable) {script.call("keyUp", [event]);}}
	}

	override function update(elapsed:Float)
	{
		for (script in hscripts){ if (callable){script.call("update", [elapsed]);}}

		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	override function onFocus()
	{
		for (script in hscripts) script.call("onFocus", []);
		super.onFocus();
	}

	override function onFocusLost()
	{
		for (script in hscripts) script.call("onFocusLost", []);
		super.onFocusLost();
	}

	public function stepHit():Void
	{
		for (script in hscripts){ if(callable) {script.call("stepHit", []);}}
		try if (curStep % 4 == 0) beatHit();
	}

	public function beatHit():Void
	{
		for (script in hscripts){if(callable) {script.call("beatHit", []);}}
	}

}