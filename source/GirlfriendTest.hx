package;

import flxanimate.FlxAnimate;

using StringTools;

class GirlfriendTest extends FlxAnimate
{
    public var danced:Bool = false;
	//FUCK IT, ILL TRACK THE ANIM MYSELF
	public var curAnim:String = '';
    public var animOffsets:Map<String, Array<Dynamic>>;

    public function new(x:Float, y:Float)
    {
        super(x, y, "assets/shared/images/atlas/");
        animOffsets = new Map<String, Array<Dynamic>>();
        active = true;
        antialiasing = true;

        anim.addBySymbol('cheer', 'GF Cheer', 24, false, 0, 0);
        anim.addBySymbol('singLEFT', 'GF left note', 24, false, 0, -19);
        anim.addBySymbol('singRIGHT', 'GF Right Note',24, false, 0, -20);
        anim.addBySymbol('singUP', 'GF Up Note', 24, false, 0, 4);
        anim.addBySymbol('singDOWN', 'GF Down Note', 24, false, 0, -20);
        anim.addBySymbolIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], 24, false, -2, -2);
        anim.addBySymbolIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 24, false, 0, -9);
        anim.addBySymbolIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], 24, false, 0, -9);
        anim.addBySymbolIndices('hairBlow', 'GF Dancing Beat Hair blowing', [0, 1, 2, 3], 24, true, 45, -8);
        anim.addBySymbolIndices('hairFall', 'GF Dancing Beat Hair Landing', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], 24, false, 0, -9);
        anim.addBySymbol('scared', 'GF FEAR', 24, true, -2, -17);

        play('danceRight');

        dance();
    }

    public function dance(?forced:Bool = false)
    {
        if (!curAnim.startsWith('hair'))
        {
            danced = !danced;
            (danced) ? play('danceRight', forced) : play('danceLeft', forced);
        }
    }

    public function play(?name:String = "", ?force:Bool = false, ?reverse:Bool = false)
    {
		curAnim = name;
        switch(name)
        {
            case 'singLEFT':
               danced = true;
            case 'singRIGHT':
               danced = false;
            case 'singUP' | 'singDOWN':
               danced = !danced;
            default:
        }
        anim.play(name, force, reverse);
    }

    override function update(elapsed:Float)
    {
        if (curAnim == "hairFall" && anim.finished)
            play('danceRight');
			
        super.update(elapsed);
    }   
}
