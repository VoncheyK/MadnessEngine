package;

import haxe.ds.IntMap;
import hscript.Interp;
import hscript.Parser;

class FunkyHscript {
	public var parser:Parser = null;
	public var interpreter:Interp = null;
	public var vars:Map<String, Dynamic> = new Map<String, Dynamic>();
	public var fileName:String = "";

	public function new(fileName:String) {
		try {
			trace(fileName);
			parser = new Parser();
			interpreter = new Interp();

			parser.allowJSON = true;
			parser.allowTypes = true;
			parser.allowMetadata = true;
			var parsed = parser.parseString(sys.io.File.getContent(Paths.script(fileName)), fileName);
			interpreter.allowPublicVariables = true;
			interpreter.allowStaticVariables = true;
			
			interpreter.variables.set("require", function(name:String):Class<Dynamic>{
				if (name == "SpecialKeys" || name == "GJKeys" || name == "GameJolt" || name == "netTest.ServerHandler" || name == "netTest.Director" || name == "netTest.schemaShit.BattleState" || name == "netTest.schemaShit.ChatState" || name == "netTest.schemaShit.Player")
					return null;

				return Type.resolveClass(name);
			});

			this.fileName = fileName;

			interpreter.execute(parsed);
			
			call("main", []);
		} catch (e:haxe.Exception) {
			trace('Exception: ${e},\n Message: ${e.message},\n Details: ${e.details()},\n Stack: ${e.stack},\n HScript line: ${interpreter.posInfos().lineNumber}');
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
			trace('Exception: ${e},\n Message: ${e.message},\n Details: ${e.details()},\n Stack: ${e.stack},\n HScript line: ${interpreter.posInfos().lineNumber}');
		}
	}

	public function reExecute(fileName:String):Void {
		try {
			var parsed = parser.parseString(sys.io.File.getContent(Paths.script(fileName)), fileName);
			var e = interpreter.execute(parsed);
		} catch (e:haxe.Exception) {
			trace('Exception: ${e},\n Message: ${e.message},\n Details: ${e.details()},\n Stack: ${e.stack},\n HScript line: ${interpreter.posInfos().lineNumber}');
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
			interpreter.variables.set("require", function(name:String):Class<Dynamic>{
				if (name == "SpecialKeys" || name == "GJKeys" || name == "GameJolt" || name == "netTest.ServerHandler" || name == "netTest.Director" || name == "netTest.schemaShit.BattleState" || name == "netTest.schemaShit.ChatState" || name == "netTest.schemaShit.Player")
					return null;

				return Type.resolveClass(name);
			});

			reExecute(fileName);
			interpreter.publicVariables = publics;
			interpreter.staticVariables = statics;

			callable = true;
			
			call("main", []);
		} catch (e:haxe.Exception) {
			trace('Exception: ${e},\n Message: ${e.message},\n Details: ${e.details()},\n Stack: ${e.stack},\n HScript line: ${interpreter.posInfos().lineNumber}');
		}
	}

	public function wipeAndExecute(fileName:String):Void {
		try {
			wipeData();
			parser = new Parser();
			interpreter = new Interp();

			interpreter.allowPublicVariables = true;
			interpreter.allowStaticVariables = true;
			interpreter.variables.set("require", function(name:String):Class<Dynamic>{
				if (name == "SpecialKeys" || name == "GJKeys" || name == "GameJolt" || name == "netTest.ServerHandler" || name == "netTest.Director" || name == "netTest.schemaShit.BattleState" || name == "netTest.schemaShit.ChatState" || name == "netTest.schemaShit.Player")
					return null;

				return Type.resolveClass(name);
			});

			parser.allowJSON = true;
			parser.allowTypes = true;
			parser.allowMetadata = true;

			reExecute(fileName);
			call("main", []);
		} catch (e:haxe.Exception) {
			trace('Exception: ${e},\n Message: ${e.message},\n Details: ${e.details()},\n Stack: ${e.stack},\n HScript line: ${interpreter.posInfos().lineNumber}');
		}
	}
}