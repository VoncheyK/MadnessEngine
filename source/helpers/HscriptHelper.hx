package helpers;

import hscript.Expr.ModuleDecl;
import hscript.Expr.ClassDecl;
import hscript.Expr.FieldKind;
import hscript.Expr.FieldAccess;
import haxe.macro.Expr;

class HscriptHelper{
    private static var p:Position;
    private static var macroo:hscript.Macro;

    private static function convertMetadata(meta:hscript.Expr.Metadata):Metadata {
		var ret:Array<MetadataEntry> = [];
		var convertedParams:Null<Array<haxe.macro.Expr>> = null;

		for (k => metadata in meta) {
			if (metadata.params != null)
				convertedParams.push(macroo.convert(metadata.params[k]));

			ret.push({name: metadata.name, pos: p, params: (metadata.params != null) ? convertedParams : null});
		}

		return ret;
    }

    private static function convertAccessField(access:FieldAccess):Access {
        return switch (access){
            case AInline:
                Access.AInline;
            case AMacro:
                Access.AMacro;
            case AOverride:
                Access.AOverride;
            case APrivate:
                Access.APrivate;
            case APublic:
                Access.APublic;
            case AStatic:
                Access.AStatic;
        }
    }

	public static function convert(){
		
	}
    
    inline static public function makeTypePath(t:{pack:Array<String>, name:String, ?params:Array<TypeParam>, ?sub:String}):TypePath
        return {pack: t.pack, params: t.params, sub: t.sub, name: t.name};
    
	public static function constructClass(module:ModuleDecl, pos:Position):TypeDefinition {
		p = pos;
		macroo = new hscript.Macro(p);
		final moduleParameters:Array<Dynamic> = module.getParameters();
		var ret:Array<Field> = [];

		for (param in moduleParameters) {
			switch (module.getName()) {
				case "DClass":
					final casted:ClassDecl = cast(param);
					final className:String = casted.name;

					var theimplementers:Array<TypePath> = [];
					for (implementation in casted.implement)
						theimplementers.push(makeTypePath(macroo.convertType(implementation).getParameters()[0]));

					final typeKind:TypeDefKind = TDClass((casted.extend != null ? makeTypePath(macroo.convertType(casted.extend).getParameters()[0]) : null),
					theimplementers, false, false, false);

					var classer = macro class $className {};
					
					classer.isExtern = casted.isExtern;
					classer.name = casted.name;
					// this shit doesnt exist!!
					classer.params = null;
					classer.meta = convertMetadata(casted.meta);

					classer.kind = typeKind;
					// make it able to be import ClassName -able;
					classer.pack = [];
					classer.pos = p;

					for (functionShit in casted.fields) {
						switch (functionShit.kind) {
							case FieldKind.KFunction(fn):
								var accessShit:Array<Access> = [];
								// ohhh yeah baby this is where shit gets firey
								var arguments:Array<FunctionArg> = [];

								for (acc in functionShit.access)
									accessShit.push(convertAccessField(acc));

								for (arg in fn.args)
									arguments.push({
										name: arg.name,
										opt: (arg.opt != null) ? arg.opt : false,
										type: (arg.t != null) ? macroo.convertType(arg.t) : null,
										value: (arg.value != null) ? macroo.convert(arg.value) : null
									});

								ret.push({
									name: functionShit.name,
									access: accessShit,
									kind: FFun({ret: (fn.ret != null) ? macroo.convertType(fn.ret) : null,
										expr: (fn.expr != null) ? macroo.convert(fn.expr) : null, args: arguments}),
									pos: pos,
									meta: (functionShit.meta != null) ? convertMetadata(functionShit.meta) : null
								});
							case FieldKind.KVar(varDecl):
								final variableName:String = functionShit.name;
								var accessShit:Array<Access> = [];

								for (acc in functionShit.access)
									accessShit.push(convertAccessField(acc));

								ret.push({
									name: variableName,
									access: accessShit,
									kind: FVar((varDecl.type != null ? macroo.convertType(varDecl.type) : null),
										(varDecl != null ? macroo.convert(varDecl.expr) : null)),
									pos: pos,
									meta: (functionShit.meta != null ? convertMetadata(functionShit.meta) : null),
								});
								trace(ret);
						}
					}
					classer.fields = ret;

                return classer;
			}
		}
		return null;
	}
}