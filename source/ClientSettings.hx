package;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import flixel.FlxG;
import Controls;

class ClientSettings
{
    public static var downScroll:Bool = false;
    public static var middleScroll:Bool = false;
    public static var ghostTapping:Bool = true;
    public static var botPlay:Bool = false;
    public static var noteskin:String = "Normal";
    public static var displayAccuracy:Bool = true;
    public static var showTimeBar:Bool = true;
    public static var showTimeTxt:Bool = true;
    public static var framerate:Int = 60;

    	// Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		// Key Bind, Name for ControlsSubState
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [W, UP],
		'note_right' => [D, RIGHT],

		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
        'pause' => [ENTER, ESCAPE],
		'reset' => [R, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		// trace(defaultKeys);
	}

    public static function saveSettings()
    {
        FlxG.save.data.downScroll = downScroll;
        FlxG.save.data.middleScroll = downScroll;
        FlxG.save.data.ghostTapping = ghostTapping;
        FlxG.save.data.botPlay = botPlay;
        FlxG.save.data.noteskin = noteskin;
        FlxG.save.data.displayAccuracy = displayAccuracy;
        FlxG.save.data.showTimeBar = showTimeBar;
        FlxG.save.data.showTimeTxt = showTimeTxt;
        FlxG.save.data.framerate = framerate;

        var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'von'); // Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
    }

    public static function loadSettings()
    {
        if(FlxG.save.data.downScroll != null) downScroll = FlxG.save.data.downScroll;
        if(FlxG.save.data.middleScroll != null) middleScroll = FlxG.save.data.middleScroll;
        if(FlxG.save.data.ghostTapping != null) ghostTapping = FlxG.save.data.ghostTapping;
        if(FlxG.save.data.botPlay != null) botPlay = FlxG.save.data.botPlay;
        if(FlxG.save.data.noteskin != null) noteskin = FlxG.save.data.noteskin;
        if(FlxG.save.data.displayAccuracy != null) displayAccuracy = FlxG.save.data.displayAccuracy;
        if(FlxG.save.data.showTimeBar != null) showTimeBar = FlxG.save.data.showTimeBar;
        if(FlxG.save.data.showTimeTxt != null) showTimeTxt = FlxG.save.data.showTimeTxt;
        
        if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}

        var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'von');
		if (save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
        
        //this will save your last volume
        if (FlxG.save.data.volume != null) FlxG.sound.volume = FlxG.save.data.volume;
        if (FlxG.save.data.mute != null) FlxG.sound.muted = FlxG.save.data.mute;
    }

    public static function get_setting(setting)
    {
        return setting;
    }

    public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);
	}

	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if (copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}