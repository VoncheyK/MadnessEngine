package helpers;

#if desktop
import sys.FileSystem;
#end
import openfl.utils.Assets;
import openfl.utils.AssetLibrary;

class Modsupport
{
    //lets go baby modsupport!!

    public static function init(modRoot:String, mods:Array<String>)
    {
        for(mod in mods)
        {
            var modDir:String = Paths.mods(mod);
            //register library (modDir)
            addToLibrary(mod, modDir);
            for(file in FileSystem.readDirectory(modDir))
            {
                trace(file);
            }
        }
    }

    public static function addToLibrary(name:String, directory:String)
    {
        if (!Assets.hasLibrary(name))
            Assets.registerLibrary(name, AssetLibrary.fromFile(directory));
        else
            trace('Already added to library!');
    }

    public static function addMod()
    {

    }
}