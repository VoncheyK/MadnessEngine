package;

import hscript.AbstractHolder;
import hscript.InterpEx;
import hscript.ParserEx;

using StringTools;

enum ScriptTypes{
	HBasic;
	HClass;
}

class FunkyHscript {
	public var parser:ParserEx = null;
	public var interpreter:InterpEx = null;
	public var vars:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var fileName:String = "";
	//fullreload means that it restarts the script (allows use of update again)
	public var fullReload:Bool = false;
	public var scriptType:ScriptTypes;

	public var class_instance:AbstractHolder;

	//PLEASE HAVE THEM PUBLIC OR STATIC SO THEY ARE ACCESSIBLE IF YOU HAVE FULLRELOAD ON
	public var scriptSprites:Map<String, flixel.FlxSprite> = [];

	private function determineScriptType(fileData:String):Void {
		if (fileData.contains("script_type")){
			final l = fileData.split("\n");
			for (splitLine in 0...l.length){
				if (l[splitLine].contains("=") && l[splitLine].contains("script_type")){
					final theTimeHasCome:Array<String> = l[splitLine].split("=");
					if (theTimeHasCome[1].contains("HBasic"))
						scriptType = ScriptTypes.HBasic;
					else if (theTimeHasCome[1].contains("HClass"))
						scriptType = ScriptTypes.HClass;
					return;
				}
			}
		}else
			scriptType = ScriptTypes.HBasic;
	}

	//NOTE TO SELF: ARGUMENTS ARE TO BE DETERMINED IN A JSON/TXT FILE OR TO BE AUTOMATICALLY READ AND PARSED THROUGH THE METHOD ABOVE
	//ARGUMENTS VALUES ARE TO BE DETERMINED BY THAT FILE AS THE CODE WONT AUTOMATICALLY CUM VALUES INTO IT AND EXPECT IT TO WORK
	public function new(fileName:String, ?fileDir:String, ?fileData:String, ?args:Array<Dynamic>) {
		try {
			parser = new ParserEx();
			interpreter = new InterpEx();
			this.fileName = fileName;

			if (fileDir != null)
				determineScriptType(sys.io.File.getContent(fileDir));
			else
				determineScriptType(fileData);

			if (scriptType == ScriptTypes.HBasic){
				parser.allowJSON = true;
				parser.allowTypes = true;
				parser.allowMetadata = true;
				var parsed = parser.parseString((fileDir != null) ? sys.io.File.getContent(fileDir) : ((fileData != null) ? fileData : null), fileDir);
				interpreter.allowPublicVariables = true;
				interpreter.allowStaticVariables = true;
				
				interpreter.variables.set("require", resolveRequire);

				interpreter.execute(parsed);
			} else if (scriptType == ScriptTypes.HClass){
				final dat = (fileDir != null) ? sys.io.File.getContent(fileDir) : fileData;

				interpreter.addModule(dat);

				class_instance = interpreter.createScriptClassInstance(this.fileName, args);

				interpreter.variables.set("super", class_instance.superClass);
			}

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

			parser = new ParserEx();
			interpreter = new InterpEx();

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
			parser = new ParserEx();
			interpreter = new InterpEx();

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