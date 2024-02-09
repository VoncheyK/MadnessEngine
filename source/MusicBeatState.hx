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

	public var curStep(default, set):Int = 0;
	public var curBeat(default, set):Int = 0;
	
	private var controls(get, never):Controls;

	public var hscripts:Array<FunkyHscript> = [];

	private var callable:Bool = true;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	//no update tomfoolery for events
	private function set_curStep(newStep:Int):Int {
		return curStep = newStep;
	}
	
	private function set_curBeat(newBeat:Int):Int {
		return curBeat = newBeat;
	}

	private inline function callOnHscripts(functionName:String, ?args:Null<Array<Dynamic>>)
		for (script in hscripts) callable ? script.call(functionName, (args == null ? [] : args)) : null;

	override function create()
	{
		//Leaving this code here for when I need it.
		//var stateMusicBeat:MusicBeatState = cast(FlxG.state, MusicBeatState);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);

		super.create();
	}

	override function destroy()
	{
		callOnHscripts("destroy", []);

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
		super.destroy();
	}

	public static function switchState(newState:FlxUIState, ?oldState:FlxUIState)
	{
		FlxG.switchState(newState);

		//i figured that this gets called after onLoad in LoadingState.
		if (newState is netTest.ServerHandler)
			cast(newState, netTest.ServerHandler).loaded();

		return oldState != null ? oldState : newState;
	}

	private function keyDown(event:KeyboardEvent)
	{
		if (event.keyCode == Keyboard.F5){
			callable = false;
			for (hscript in hscripts)
				hscript.wipeExceptVarsAndExecute(hscript.fileName, callable);
		}

		callOnHscripts("keyDown", [event]);
	}

	private function keyUp(event:KeyboardEvent)
		callOnHscripts("keyUp", [event]);
	

	override function update(elapsed:Float)
	{
		callOnHscripts("update", [elapsed]);

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
		callOnHscripts("onFocus", []);
		super.onFocus();
	}

	override function onFocusLost()
	{
		callOnHscripts("onFocusLost", []);
		super.onFocusLost();
	}

	public function stepHit():Void
	{
		callOnHscripts("onStep", [curStep]);
		try if (curStep % 4 == 0) beatHit();
	}

	public function beatHit():Void
		callOnHscripts("onBeat", [curBeat]);
}
