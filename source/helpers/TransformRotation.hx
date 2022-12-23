package helpers;

import flixel.math.FlxPoint;
import helpers.Vector3;

class TransformRotation
{
    inline public static function rotatePos90Degrees(point:FlxPoint){
        var x:Float = point.x;
        var y:Float = point.y;
        
        return new FlxPoint(-y, x);
    }
    
    
    inline public static function rotateNeg90Degrees(point:FlxPoint)
    {
        var x:Float = point.x;
        var y:Float = point.y;
        
        return new FlxPoint(y, -x);
    }
    
    
    inline public static function rotate180Degrees(point:FlxPoint)
    {
        var x:Float = point.x;
        var y:Float = point.y;
        
        return new FlxPoint(-x, -y);
    }
    
    inline public static function normalTransform(point:FlxPoint, target:FlxPoint){
        var x:Float = point.x;
        var y:Float = point.y;
        
        var tarX:Float = target.x;
        var tarY:Float = target.y;
        
        return new FlxPoint(x + (tarX), y + (tarY));
    }
    
    public static function methodTransformation(point:FlxPoint, method:String)
    {
        //Reflect.callMethod(method, "method",point);
        if (Reflect.field(Methods, method))
            Reflect.callMethod(Methods, Reflect.field(Methods, method), [point]);
    }
}

class Methods
{    
    inline public static function transformX(pos:FlxPoint)
    {
        return new FlxPoint(pos.x, -pos.y);
    }
    
    inline public static function transformY(pos:FlxPoint)
    {
        return new FlxPoint(-pos.x, pos.y);
    }
    
    inline public static function transformOrigin(pos:FlxPoint){
        return new FlxPoint(-pos.x, -pos.y);
    }
    
    inline public static function inverseOrigin(pos:FlxPoint)
    {
        return new FlxPoint(-pos.y, -pos.x);
    }
}