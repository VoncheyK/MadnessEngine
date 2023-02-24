package hscript;

import haxe.macro.Expr;

class ClassHolder {
    public var cachedFunctions:Map<String, Function>;
    public var cachedVariables:Map<String, Var>;
    private var classTypeDef:TypeDefinition;

    public function new(typdef:TypeDefinition) {
        cachedFunctions = new Map<String, Function>();
        cachedVariables = new Map<String, Var>();
        classTypeDef = typdef;

        cacheFromTypedef();
    }

    private function cacheFromTypedef():Void {
        /*final fields:Array<Field> = classTypeDef.fields;
        for (field in fields){
            switch(field.kind){
                case haxe.macro.Expr.Function(fn):
                    if (cachedFunctions.get(field.name) == null)
                        cachedFunctions.set(field.name, fn);
                    else
                        trace('FUNCTION ALREADY EXISTS! FUNCTION REDECLARATION! ' + field.name);
            }
        }*/
    }

    /*public var cachedFunctions:Map<String, FunctionDecl> = [];
    public var cachedVariables:Map<String, VarDecl> = [];
    private var decl:ModuleDecl = null;
    private var classInfo:ClassDecl;
    private var _interp:Interp;

    public function new(declaration:ModuleDecl) {
        decl = declaration;
        _interp = new Interp();
        //yanni suggested me enumParameters
        classInfo = cast(Type.enumParameters(decl)[0]);
        cacheClass();
    }

    public static function cacheClassFromHaxeClass():Void {
        //Reflect.setField becomes a star
        constructClass(decl);
    }

    public function callFunction(name:String, funcArgs:Array<Dynamic> = null):Void {
        final field = findFunction(name);
        var ret:Dynamic = null;

        if (field != null){
            var prevVals:Map<String, Dynamic> = [];
            for (i => arg in field.args){
                var val:Dynamic = null;
                if (funcArgs != null && i < funcArgs.length)
                    val = funcArgs[i];
                else if (arg.value != null)
                    //https://tenor.com/view/breaking-bad-walter-white-yo-gif-26891796
                    val = _interp.expr(arg.value);

                if (_interp.variables.exists(arg.name)) 
                    prevVals.set(arg.name, _interp.variables.get(arg.name));

                _interp.variables.set(arg.name, val);    
            }

            ret = _interp.execute(field.expr);

            for (arg in field.args) {
                if (prevVals.exists(arg.name)) 
                    _interp.variables.set(arg.name, prevVals.get(arg.name));
                else 
                    _interp.variables.remove(arg.name);
            }
        }
    }

    public function findVariable(name:String):VarDecl {
        if (cachedVariables.get(name) != null)
            return cachedVariables.get(name);

        for (field in classInfo.fields){
            switch(field.kind){
                case KVar(varman):
                    return varman;
                case _:
            }
        }

        trace("WARNING: FINDVARIABLE RETURNED NULL FOR VARIABLE NAME: " + name);
        return null;
    }

    public function findFunction(name:String):FunctionDecl {
        if (cachedFunctions.get(name) != null)
            return cachedFunctions.get(name);

        //if null
        for (field in classInfo.fields){
            switch(field.kind){
                case KFunction(f):
                    return f;
                case _:
            }
        }

        //if- WHAT THE FUCK
        trace("WARNING: FINDFUNCTION RETURNED NULL FOR FUNCTION NAME: " + name);
        return null;
    }

    private function cacheClass():Void {
        for (field in classInfo.fields){
            switch(field.kind){
                case FieldKind.KFunction(fun):
                    if(cachedFunctions.get(field.name) == null)
                        cachedFunctions.set(field.name, fun);
                case FieldKind.KVar(varman):
                    if (cachedVariables.get(field.name) == null)
                        cachedVariables.set(field.name, varman);

                    //https://tenor.com/view/breaking-bad-walter-white-yo-gif-26891796
                    if (varman.expr != null) 
                        this._interp.variables.set(field.name, this._interp.expr(varman.expr));
            }
        }
    }*/
}