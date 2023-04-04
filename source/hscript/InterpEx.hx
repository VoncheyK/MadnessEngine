package hscript;

import haxe.PosInfos;
import hscript.Interp;
import hscript.ClassHolder.ClassDeclEx;
import hscript.Expr;

@:access(hscript.ClassHolder)
@:access(hscript.AbstractHolder)
class InterpEx extends Interp {
    private var _nextCallObject:Dynamic = null;
    private var _proxy:AbstractHolder;

    public function new(proxy:AbstractHolder = null) {
        super();
        _proxy = proxy;
        variables.set("Type", Type);
        variables.set("Math", Math);
        variables.set("Std", Std);

        variables.set("trace", Reflect.makeVarArgs(function(el) {
			var inf = posInfos();
			var v = el.shift();
			if (el.length > 0)
				inf.customParams = el;
			haxe.Log.trace(Std.string(v), inf);
		}));
    }

    override function fcall( o:Dynamic, f:String, args:Array<Dynamic> ):Dynamic {
        if ((o is ClassHolder)) {
            _nextCallObject = null;
            final proxy:ClassHolder = cast(o, ClassHolder);
            return proxy.callFunction(f, args);
        }
		return super.fcall(o, f, args);
	}

    private static var _scriptClassDescriptors:Map<String, ClassDeclEx> = new Map<String, ClassDeclEx>();
    
    private static function registerScriptClass(c:ClassDeclEx) {
        var name = c.name;

        if (c.pkg != null) {
            name = c.pkg.join(".") + "." + name;
        }
        _scriptClassDescriptors.set(name, c);
    }

    public static function findScriptClassDescriptor(name:String) 
        return _scriptClassDescriptors.get(name);

    override function cnew(cl:String, args:Array<Dynamic>):Dynamic {
        if (_scriptClassDescriptors.exists(cl)){
            final proxy:AbstractHolder = new ClassHolder(_scriptClassDescriptors.get(cl), args);
            return proxy;
        }else if (_proxy != null){
            if (_proxy.classInfo.pkg != null){
                final packagedClass = _proxy.classInfo.pkg.join(".") + "." + cl;
                if (_scriptClassDescriptors.exists(packagedClass)) {
                    var proxy:AbstractHolder = new ClassHolder(_scriptClassDescriptors.get(packagedClass), args);
                    return proxy;
                }
            }
        

            if (_proxy.classInfo.imports != null && _proxy.classInfo.imports.exists(cl)) {
                var importedClass = _proxy.classInfo.imports.get(cl).join(".");
                if (_scriptClassDescriptors.exists(importedClass)) {
                    var proxy:AbstractHolder = new ClassHolder(_scriptClassDescriptors.get(importedClass), args);
                    return proxy;
                }
                
                var c = Type.resolveClass(importedClass);
                if (c != null) {
                    return Type.createInstance(c, args);
                }
            }
        }

        return super.cnew(cl, args);
    }

    override function assign( e1:Expr, e2:Expr ):Dynamic {
        var v = expr(e2);
        switch ( Tools.expr(e1) ) {
            case EIdent(id):
                if (_proxy != null && _proxy.superClass != null && Reflect.hasField(_proxy.superClass, id)) {
                    Reflect.setProperty(_proxy.superClass, id, v);
                    return v;
                }
            case _:    
        }
        return super.assign(e1, e2);
    }

    override function call( o:Dynamic, f:Dynamic, args:Array<Dynamic> ):Dynamic {
        if (o == null && _nextCallObject != null) {
            o = _nextCallObject;
        }
		final r = super.call(o, f, args);
        _nextCallObject = null;
        return r;
	}

    override function get( o:Dynamic, f:String ):Dynamic {
        if ( o == null ) error(EInvalidAccess(f));
        if ((o is ClassHolder)) {
            var proxy:AbstractHolder = cast(o, ClassHolder);
            if (proxy._interp.variables.exists(f)) {
                return proxy._interp.variables.get(f);
            } else if (proxy.superClass != null && Reflect.hasField(proxy.superClass, f)) {
                return Reflect.getProperty(proxy.superClass, f);
            } else {
                try {
                    return proxy.resolveField(f);
                } catch (e:Dynamic) { }
                error(EUnknownVariable(f));
            }
        }
        return super.get(o, f);
    }

    override function set( o:Dynamic, f:String, v:Dynamic ):Dynamic {
        if ( o == null ) error(EInvalidAccess(f));
        if ((o is ClassHolder)) {
            var proxy:ClassHolder = cast(o, ClassHolder);
            if (proxy._interp.variables.exists(f)) {
                proxy._interp.variables.set(f, v);
            } else if (proxy.superClass != null && Reflect.hasField(proxy.superClass, f)) {
                Reflect.setProperty(proxy.superClass, f, v);
            } else {
                error(EUnknownVariable(f));
            }
            return v;
        }
        return super.set(o, f, v);
    }

    override function resolve(id:String, doException:Bool = true):Dynamic {
        _nextCallObject = null;
        if (id == "super" && _proxy != null) {
            if (_proxy.superClass == null) {
                return _proxy.superConstructor;
            } else {
                return _proxy.superClass;
            }
        } else if (id == "this" && _proxy != null) {
            return _proxy;
        }
        
		var l = locals.get(id);
		if( l != null )
			return l.r;
		var v = variables.get(id);
		if (v == null && !variables.exists(id)) {
            if (_proxy != null && _proxy.findFunction(id) != null) {
                _nextCallObject = _proxy;
                return _proxy.resolveField(id);
            } else if (_proxy != null && _proxy.superClass != null && (Reflect.hasField(_proxy.superClass, id) || Reflect.getProperty(_proxy.superClass, id) != null)) {
                _nextCallObject = _proxy.superClass;
                return Reflect.getProperty(_proxy.superClass, id);
            } else if (_proxy != null) {
                try {
                    var r = _proxy.resolveField(id);
                    _nextCallObject = _proxy;
                    return r;
                } catch (e:Dynamic) {}
                error(EUnknownVariable(id));
            } else {
                error(EUnknownVariable(id));
            }
        }
        return v;
    }

    public function addModule(moduleContents:String) {
        var parser = new hscript.ParserEx();
        var decls = parser.parseModule(moduleContents);

        registerModule(decls);
    }
    
    public function createScriptClassInstance(className:String, args:Array<Dynamic> = null):AbstractHolder {
        if (args == null) {
            args = [];
        }
        var r:AbstractHolder = cnew(className, args);
        return r;
    }

    override function posInfos():PosInfos{
        #if hscriptPos
		if (curExpr != null)
			return cast {fileName: curExpr.origin, lineNumber: curExpr.line};
		#end
		return cast {fileName: "hscript", lineNumber: 0};
    }

    public function registerModule(module:Array<ModuleDecl>) {
        var pkg:Array<String> = null;
        var imports:Map<String, Array<String>> = [];
        for (decl in module) {
            switch (decl) {
                case DPackage(path):
                    pkg = path;
                case DImport(path, _):
                    var last = path[path.length - 1];
                    imports.set(last, path);
                case DClass(c):
                    var extend = c.extend;
                    if (extend != null) {
                        var superClassPath = new Printer().typeToString(extend);
                        if (imports.exists(superClassPath)) {
                            switch (extend) {
                                case CTPath(_, params):
                                    extend = CTPath(imports.get(superClassPath), params);
                                case _:    
                            }
                        }
                    }

                    var classDecl:ClassDeclEx = {
                        imports: imports,
                        pkg: pkg,
                        name: c.name,
                        params: c.params,
                        meta: c.meta,
                        isPrivate: c.isPrivate,
                        extend: extend,
                        implement: c.implement,
                        fields: c.fields,
                        isExtern: c.isExtern
                    };
                    registerScriptClass(classDecl);
                case DTypedef(_):
                    //unsupport, might add soon..
            }
        }
    }
}