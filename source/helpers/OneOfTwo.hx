package helpers;

import haxe.ds.Either;

abstract OneOfTwo<TypeA, TypeB>(Either<TypeA, TypeB>) from Either<TypeA, TypeB> to Either<TypeA, TypeB>{
    @:from inline static function fromA<TypeA, TypeB>(a:TypeA):OneOfTwo<TypeA, TypeB> {
        return Left(a);
    }

    @:from inline static function fromB<TypeA, TypeB>(b:TypeB):OneOfTwo<TypeA, TypeB> {
        return Right(b);
    }

    public function returnVar():Dynamic{
        return switch(this){
            case Left(l): l;
            case Right(r): r;
        };
    }

    public function returnVarWithType<T:TypeA & TypeB>():T{
        return switch(this){
            //WATCH WHAT HAPPENS WHEN I CAST A SPELL I DONT KNOW
            case Left(l): cast l;
            case Right(r): cast r;
        };
    }

    public function new(that:Either<TypeA, TypeB>){this = that;}

    public function retLeftNRight():{left:TypeA, right:TypeB}
    {
        var ret:{left:TypeA, right:TypeB} = {left: null, right: null};
        switch(this){
            case Left(a): ret.left = a;
            case Right(b): ret.right = b;
        }
        return ret;
    }

    @:to inline function toA():Null<TypeA> return switch(this) {
        case Left(a): a; 
        default: null;
    }
    
    @:to inline function toB():Null<TypeB> return switch(this) {
        case Right(b): b;
        default: null;
    }
}