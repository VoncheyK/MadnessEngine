package helpers;
#if desktop
import sys.FileSystem;
#end
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.AssetLibrary;
import lime.utils.Assets;

import FreeplayState;

class Modsupport
{
    //lets go baby modsupport!!
    //stupid ass sex ??

    public static var modz:Array<String> = [];

    public static function init(modRoot:String, mods:Array<String>)
    {
        modz = mods;

        for(mod in mods)
        {
        
            var modDir:String = Paths.mods(mod);

            trace('Mod init. Name: ${mod}, Directory: ${modDir}');
            trace('Path should be: ${Paths.modtxt(mod, 'freeplaySonglist')}');

            addFreeplaySongs(mod);
            
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

    public static function addFreeplaySongs(mod:String)
    {

            var initSonglist = CoolUtil.coolTextFile(Paths.modtxt(mod, 'freeplaySonglist'));

            for (i in 0...initSonglist.length)
            {
                var data = initSonglist[i].split(":");
                FreeplayState.pushSong(data[0]+":"+Std.parseInt(data[1])+":"+data[2]);

            }     
    }      
    
}