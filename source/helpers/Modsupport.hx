package helpers;
#if desktop
import sys.FileSystem;
#end
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import lime.utils.Assets;

import FreeplayState;

class Modsupport
{
    //lets go baby modsupport!!
    //stupid ass sex ??

    public static var modz:Array<String> = [];
    public static var modMeta:Array<ModMetadata> = [];

    public static function init(modRoot:String, mods:Array<String>)
    {
        modz = mods;
        trace(mods);
        for(mod in mods)
        {
            var modDir:String = Paths.mods(mod);

            trace('Path should be: ${'mods/$mod/data/freeplaySonglist.txt'}');

            //register mod
            modMeta.push(new ModMetadata(
                mod, 
                FileSystem.readDirectory('mods/$mod/weeks/'), 
                FileSystem.readDirectory('mods/$mod/characters/'), 
                FileSystem.readDirectory('mods/$mod/songs/'), 
                FileSystem.readDirectory('mods/$mod/data/'),
                FileSystem.readDirectory('mods/$mod/images/'),
                FileSystem.readDirectory('mods/$mod/sounds/'),
                'mods/$mod/'
            ));

            addToLibrary(mod, modDir);
        }
    }

    public static function addToLibrary(name:String, modDir:String)
    {
        if (!Assets.hasLibrary(name))
            Assets.registerLibrary(name, AssetLibrary.fromFile(modDir));
        else
            trace('Already added to library!');
    }

    public static function addFreeplaySongs(mod:String)
    {
        var modByMeta:ModMetadata = null;
        for (meta in modMeta)
        {
            if (meta.name == mod)
                modByMeta = meta;
        }
        if (modByMeta == null)
            trace('MOD METADATA IS INVALID. MOD NAME: $mod');

        for (song in modByMeta.songs)
            FreeplayState.pushSong(song, modByMeta);
    }      
    
}

class ModMetadata
{   
    public var name:String;
    public var weeks:Array<String>;
    public var characters:Array<String>;
    public var songs:Array<String>;
    public var images:Array<String>;
    public var songJsons:Array<String>;
    public var sounds:Array<String>;
    public var directory:String;

    public function new(name:String, weeks:Array<String>, characters:Array<String>, 
        songs:Array<String>, songJsons:Array<String>, images:Array<String>, sounds:Array<String>, directory:String)
        {this.name = name; this.weeks = weeks; this.characters = characters; this.songs = songs;
            this.songJsons = songJsons; this.images = images; this.sounds = sounds; this.directory = directory;}
}