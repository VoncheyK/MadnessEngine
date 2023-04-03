package hscript;

@:forward
@:access(hscript.ClassHolder)
abstract AbstractHolder(ClassHolder) from ClassHolder {
    private function resolveField(name:String):Dynamic {
        switch (name) {
            case "superClass":
                return this.superClass;
            case "createSuperClass":
                return this.createSuperClass;
            case "findFunction":
                return this.findFunction;
            case "callFunction":
                return this.callFunction;
            case _:
                if (this.findFunction(name) != null) {
                    var fn = this.findFunction(name);
                    var nargs = 0;
                    if (fn.args != null) {
                        nargs = fn.args.length;
                    }

                    switch (nargs) {
                        //_ has to be an Array<Dynamic>
                        case _: this.callFunction.bind(name, _);
                    }
                } else if (this.findVariable(name) != null) {
                    var v = this.findVariable(name);
                    
                    var varValue:Dynamic = null;
                    if (this._interp.variables.exists(name) == false) {
                        if (v.expr != null) {
                            varValue = this._interp.expr(v.expr);
                            this._interp.variables.set(name, varValue);
                        }
                    } else {
                        varValue = this._interp.variables.get(name);
                    }
                    return varValue;
                } else if (Reflect.isFunction(Reflect.getProperty(this.superClass, name))) {
                    return Reflect.getProperty(this.superClass, name);
                } else if (Reflect.hasField(this.superClass, name)) {
                    return Reflect.field(this.superClass, name);
                } else if (this.superClass != null && (this.superClass is ClassHolder)) {
                    var superClassHolder:AbstractHolder = cast(this.superClass, ClassHolder);
                    try {
                        return superClassHolder.fieldRead(name);
                    } catch (e:Dynamic) { } 
                }
        }
        
        if (this.superClass == null) {
            throw "field '" + name + "' does not exist in script class '" + this.className + "'";
        } else{
            throw "field '" + name + "' does not exist in script class '" + this.className + "' or super class '" + Type.getClassName(Type.getClass(this.superClass)) + "'";
        }
    }
    
    @:op(a.b) private function fieldRead(name:String):Dynamic {
        return resolveField(name);
    }
    
    @:op(a.b) private function fieldWrite(name:String, value:Dynamic) {
        switch (name) {
            case _:
                if (this.findVariable(name) != null) {
                    this._interp.variables.set(name, value);
                    return value;
                } else if (Reflect.hasField(this.superClass, name)) {
                    Reflect.setProperty(this.superClass, name, value);
                    return value;
                } else if (this.superClass != null && (this.superClass is ClassHolder)) {
                    var superClassHolder:AbstractHolder = cast(this.superClass, ClassHolder);
                    try {
                        return superClassHolder.fieldWrite(name, value);
                    } catch (e:Dynamic) { } 
                }
        }
        
        if (this.superClass == null) {
            throw "field '" + name + "' does not exist in script class '" + this.className + "'";
        } else{
            throw "field '" + name + "' does not exist in script class '" + this.className + "' or super class '" + Type.getClassName(Type.getClass(this.superClass)) + "'";
        }
    }
}