package;

import flixel.FlxG;
import Controls;

class ClientSettings
{
    public static var downScroll:Bool = false;
    public static var middleScroll:Bool = false;
    public static var ghostTapping:Bool = true;
    public static var botPlay:Bool = false;
    public static var noteskin:String = "Edited";
    public static var displayAccuracy:Bool = true;
    public static var showTimeBar:Bool = true;
    public static var showTimeTxt:Bool = true;

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
        
        //this will save your last volume
        if (FlxG.save.data.volume != null) FlxG.sound.volume = FlxG.save.data.volume;
        if (FlxG.save.data.mute != null) FlxG.sound.muted = FlxG.save.data.mute;
    }
}