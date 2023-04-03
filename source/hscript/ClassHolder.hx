package hscript;

import io.colyseus.state_listener.StateContainer.DataChange;
import hscript.Expr;

typedef ClassDeclEx = {> ClassDecl,
    @:optional var imports:Map<String, Array<String>>;
    @:optional var pkg:Array<String>;
}

//gonna find a way to work this with actual classes
class ClassHolder {
    public var cachedFunctions:Map<String, FunctionDecl> = [];
    public var cachedVariables:Map<String, VarDecl> = [];
    public var cachedFields:Map<String, FieldDecl> = null;
    public var classInfo:ClassDeclEx;
    public var _interp:InterpEx;
    public var superClass:Dynamic = null;
    public var className(get, null):String;

    private function get_className():String {
        var name = "";
        if (classInfo.pkg != null) {
            name += classInfo.pkg.join(".");
        }
        name += classInfo.name;
        return name;
    }

    public static var hscriptClasses:Map<String, ClassHolder>;
    
    public static function getClasses():Map<String, ClassHolder>
        return hscriptClasses;
       
    public static function getClassByName(name:String):ClassHolder
        return hscriptClasses.get(name);
    
    public function new(declaration:ClassDeclEx, args:Array<Dynamic>) {
        _interp = new InterpEx();
        //yanni suggested me enumParameters
        classInfo = declaration;//cast(Type.enumParameters(decl)[0]);
        cacheClass();

        //then find if new exists
        final leThing = findFunction("new");
        if (leThing != null)
            callFunction("new", args);
        //important
        if (superClass == null && classInfo.extend != null) 
            @:privateAccess _interp.error(ECustom("super() not called"));
        else if (classInfo.extend != null) 
            createSuperClass(args);    
    }

    public function createSuperClass(args:Array<Dynamic>){
        if (args == null)
            args = [];

        var extendString = new Printer().typeToString(classInfo.extend);

        if (classInfo.pkg != null && extendString.indexOf(".") == 1)
            extendString = classInfo.pkg.join(".") + "." + extendString;
        
        var classDescriptor = InterpEx.findScriptClassDescriptor(extendString);
        if (classDescriptor != null) {
            var abstractSuperClass:AbstractHolder = new ClassHolder(classDescriptor, args);
            superClass = abstractSuperClass;
        } else {
            var c = Type.resolveClass(extendString);
            if (c == null) {
                @:privateAccess _interp.error(ECustom("could not resolve super class: " + extendString));
            }
            superClass = Type.createInstance(c, args);
        }
    }

    public function callFunction(name:String, funcArgs:Array<Dynamic> = null):Dynamic {
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
        } else {
            //because this implies that the function was not found, lets say for example: the function is in the super class, therefore:
            var fixedArgs = [];
            for (a in funcArgs) {
                if ((a is ClassHolder)) {
                    fixedArgs.push(cast(a, ClassHolder).superClass);
                } else {
                    fixedArgs.push(a);
                }
            }
            ret = Reflect.callMethod(superClass, Reflect.field(superClass, name), fixedArgs);
        }
        return ret;
    }

    public function findVariable(name:String):VarDecl {
        if (cachedVariables.get(name) != null)
            return cachedVariables.get(name);
        for (field in classInfo.fields){
            if (field.name == name){
                switch(field.kind){
                    case KVar(varman):
                        return varman;
                    case _:
                }
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
            if (field.name == name){
                switch(field.kind){
                    case KFunction(f):
                        return f;
                    case _:
                }
            }
        }
        //if- WHAT THE FUCK
        trace("WARNING: FINDFUNCTION RETURNED NULL FOR FUNCTION NAME: " + name);
        return null;
    }

    public function findField(name:String):FieldDecl{
        if(cachedFields.get(name) != null)
            return cachedFields.get(name);
    
        for (field in classInfo.fields){
            if (field.name == name)
                return field;
        }

        trace("WARNING: FINDFIELD RETURN WITH NULL FOR FIELD: " + name);
        return null;
    }

    private function cacheClass():Void {
        for (field in classInfo.fields){
            cachedFields.set(field.name, field);
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
    }
}