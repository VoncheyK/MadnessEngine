package;

import flixel.FlxSprite;

class HscriptSprites extends FlxSprite
{
    var id:String;

    public static var createdObjects:Array<String> =
    [

    ];

    public function new(x:Float, y:Float, id:String, File:String)
    {
        super(x, y);

        this.id = id;

        createSprite(x, y, id, File);
    }

    public function createSprite(x:Float, y:Float, id:String, File:String)
    {
        var newObjectSprite = new FlxSprite(x, y, File);
        
        add(newObjectSprite);
    }
}