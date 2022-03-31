/*
package;

import js.lib.webassembly.Table;
import haxe.ds.StringMap;
import hscript.Interp;
import lime.utils.Assets;

using StringTools;

class FunkyHscript
{
    public static var script:String = '';
	public static var interp:hscript.Interp;

    public static function callInterp(func_name:String, args:Array<Dynamic>){
        if (!interp.variables.exists(func_name)) {return;}
        
        var method = interp.variables.get(func_name);
        Reflect.callMethod(interp,method,args);
	}

    public static function init(scriptPath):Void
    {
        if (Assets.exists(scriptPath))
		{
			script = CoolUtil.useless(scriptPath);
		}else{
			script = "trace('No script was found. Ignoring!')";
		}

        interp = new hscript.Interp();
		var parser = new hscript.Parser();
		var program = parser.parseString(script);

        interp.execute(program);
    }
}
*/