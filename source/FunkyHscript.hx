package;

import haxe.ds.IntMap;
import hscript.Interp;
import hscript.Parser;

class FunkyHscript {
	public var parser:Parser = null;
	public var interpreter:Interp = null;
	public var vars:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var fileName:String = "";

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
		if (name == "SpecialKeys" || name == "GJKeys" || name == "GameJolt" || name == "netTest.ServerHandler" || name == "netTest.Director" || name == "netTest.schemaShit.BattleState" || name == "netTest.schemaShit.ChatState" || name == "netTest.schemaShit.Player")
			return null;

		return Type.resolveClass(name);
	}

	public function wipeExceptVarsAndExecute(fileName:String, callable:Bool):Void {
		try {
			var publics:Dynamic = interpreter.publicVariables;
			var statics:Dynamic = interpreter.staticVariables;

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