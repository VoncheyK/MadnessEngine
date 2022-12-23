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

    public static function addFreeplaySongs(mod:String)
    {
		if(FileSystem.exists('assets/mods/${mod}/data/freeplaySonglist.txt'))
		{
			var initSonglist = CoolUtil.coolTextFile(Paths.modtxt(mod, 'freeplaySonglist'));

			for (i in 0...initSonglist.length)
			{
				var data = initSonglist[i].split(":");
                trace('songName: ${data[0]}, mod: ${data[1]}');
				FreeplayState.pushSong(data[0]+":"+data[1]);
			}
		}
		else
			trace('ERROR: PATH DOESNT EXIST. ${Paths.modtxt(mod, 'freeplaySonglist')}');
    }      
    
}