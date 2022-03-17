package;

import flixel.FlxG;
import Controls;

class ClientSettings
{
    public static var downScroll:Bool = false;
    public static var ghostTapping:Bool = true;
    public static var noteskin:String = "Edited";

    public static function saveSettings()
    {
        FlxG.save.data.downScroll = downScroll;
        FlxG.save.data.ghostTapping = ghostTapping;
        FlxG.save.data.noteskin = noteskin;
    }

    public static function loadSettings()
    {
        if(FlxG.save.data.downScroll != null) downScroll = FlxG.save.data.downScroll;
        if(FlxG.save.data.ghostTapping != null) ghostTapping = FlxG.save.data.ghostTapping;
        if(FlxG.save.data.noteskin != null) noteskin = FlxG.save.data.noteskin;
    }
}