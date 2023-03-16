package;

import haxe.ds.IntMap;
import hscript.Interp;
import hscript.Parser;

class FunkyHscript {
	public var parser:Parser = null;
	public var interpreter:Interp = null;
	public var vars:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var fileName:String = "";
	//fullreload means that it restarts the script (allows use of update again)
	public var fullReload:Bool = false;

	//PLEASE HAVE THEM PUBLIC OR STATIC SO THEY ARE ACCESSIBLE IF YOU HAVE FULLRELOAD ON
	public var scriptSprites:Map<String, flixel.FlxSprite> = [];

	public function new(?fileName:String, ?fileData:String):Void {
		try {
			parser = new Parser();
			interpreter = new Interp();

			parser.allowJSON = true;
			parser.allowTypes = true;
			parser.allowMetadata = true;
			var parsed = parser.parseString((fileName != null) ? sys.io.File.getContent(Paths.script(fileName)) : ((fileData != null) ? fileData : null), fileName);
			interpreter.allowPublicVariables = true;
			interpreter.allowStaticVariables = true;
			
			interpreter.variables.set("require", resolveRequire);

			this.fileName = fileName;

			interpreter.execute(parsed);

			var publics:Map<String, Dynamic> = interpreter.publicVariables;
			var statics:Map<String, Dynamic> = interpreter.staticVariables;
			
			for (name => val in publics){
				vars.set(name, val);

				if (val is flixel.FlxSprite)
					scriptSprites.set(name, val);
			}
			
			for (name => val in statics){
				vars.set(name, val);

				if (val is flixel.FlxSprite)
					scriptSprites.set(name, val);
			}

			if (vars.get("fullReload") != null)
				fullReload = vars.get("fullReload");

			call("main", []);
		} catch (e:haxe.Exception) {
			windowAlertLmao(e);
		}
	}

	public function call(Function:String, Arguments:Array<Dynamic>) {
		if (interpreter == null || parser == null) {
			trace("Interpreter is: " + interpreter + " parser is: " + parser);
			return;
		}
		if (!interpreter.variables.exists(Function))
			return;
			
		try {
			Reflect.callMethod(interpreter, interpreter.variables.get(Function), Arguments);
		} catch (e:haxe.Exception) {
			windowAlertLmao(e);
		}
	}

	public function reExecute(fileName:String):Void {
		try {
			var parsed = parser.parseString(sys.io.File.getContent(Paths.script(fileName)), fileName);
			var e = interpreter.execute(parsed);
		} catch (e:haxe.Exception) {
			windowAlertLmao(e);
		}
	}

	public function wipeData():Void {
		parser = null;
		interpreter.variables = null;
		interpreter.publicVariables = null;
		interpreter.staticVariables = null;
		interpreter = null;
		vars = null;
	}

	private function windowAlertLmao(e:haxe.Exception){
		Main.raiseWindowAlert("An error has occured with Hscript:\n
		" + e.details() + "\nHscript line: " +
		interpreter.posInfos().lineNumber + "\nMessage: " + e.message);
	}

	private function resolveRequire(name:String):Class<Dynamic>{
		if (name == "SpecialKeys" || name == "GJKeys" || name == "GameJolt" || name == "netTest.ServerHandler" || name == "netTest.Intermission" || name == "netTest.ServerSendGet" || name == "netTest.schemaShit.IntermissionState" || name == "netTest.Director" || name == "netTest.schemaShit.BattleState" || name == "netTest.schemaShit.ChatState" || name == "netTest.schemaShit.Player")
			return null;

		return Type.resolveClass(name);
	}

	public function wipeExceptVarsAndExecute(fileName:String, callable:Bool):Void {
		try {
			var publics:Map<String, Dynamic> = interpreter.publicVariables;
			var statics:Map<String, Dynamic> = interpreter.staticVariables;
			
			parser = null;
			interpreter.variables = null;
			interpreter = null;
			vars = null;

			parser = new Parser();
			interpreter = new Interp();

			parser.allowJSON = true;
			parser.allowTypes = true;
			parser.allowMetadata = true;

			interpreter.allowPublicVariables = true;
			interpreter.allowStaticVariables = true;
			interpreter.variables.set("require", resolveRequire);

			reExecute(fileName);
			interpreter.publicVariables = publics;
			interpreter.staticVariables = statics;

			callable = true;
			
			call("main", []);
			if (fullReload){
				call("create", []);
				for (key in scriptSprites.keys()){
					vars.remove(key);

					if (interpreter.publicVariables.exists(key))
						interpreter.publicVariables.remove(key);

					if (interpreter.staticVariables.exists(key))
						interpreter.staticVariables.remove(key);

					scriptSprites.remove(key);
				}
			}
		} catch (e:haxe.Exception) {
			windowAlertLmao(e);
		}
	}

	public function wipeAndExecute(fileName:String):Void {
		try {
			wipeData();
			parser = new Parser();
			interpreter = new Interp();

			interpreter.allowPublicVariables = true;
			interpreter.allowStaticVariables = true;
			interpreter.variables.set("require", resolveRequire);

			parser.allowJSON = true;
			parser.allowTypes = true;
			parser.allowMetadata = true;

			reExecute(fileName);
			call("main", []);
		} catch (e:haxe.Exception) {
			windowAlertLmao(e);
		}
	}
}