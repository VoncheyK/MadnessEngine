package helpers;

import flixel.math.FlxPoint;
import helpers.Vector3;

class TransformRotation
{
    public static function rotatePos90Degrees(point:FlxPoint){
        var x:Float = point.x;
        var y:Float = point.y;
        
        return new FlxPoint(-y, x);
    }
    
    
    public static function rotateNeg90Degrees(point:FlxPoint)
    {
        var x:Float = point.x;
        var y:Float = point.y;
        
        return new FlxPoint(y, -x);
    }
    
    
    public static function rotate180Degrees(point:FlxPoint)
    {
        var x:Float = point.x;
        var y:Float = point.y;
        
        return new FlxPoint(-x, -y);
    }
    
    public static function normalTransform(point:FlxPoint, target:FlxPoint){
        var x:Float = point.x;
        var y:Float = point.y;
        
        var tarX:Float = target.x;
        var tarY:Float = target.y;
        
        return new FlxPoint(x + (tarX), y + (tarY));
    }
    
    public static function methodTransformation(point:FlxPoint, method:Methods)
    {
        Methods.method(point);
    }
}

class Methods
{
    public static var methods:Array<String> = ["transformX", "transformY", "transformOrigin","inverseOrigin"];
    public static var method:String = "transformX"; //idrk default is X
    
    public static function transformX(pos:FlxPoint)
    {
        for (methodology in methods){
            if (method != methodology){
                method = methods[0];
            }
        }

        return new FlxPoint(pos.x, -pos.y);
    }
    
    public static function transformY(pos:FlxPoint)
    {
        for (methodology in methods){
            if (method != methodology){
                method = methods[0];
            }
        }

        return new FlxPoint(-pos.x, pos.y);
    }
    
    public static function transformOrigin(pos:FlxPoint){
        for (methodology in methods){
            if (method != methodology){
                method = methods[0];
            }
        }
        return new FlxPoint(-pos.x, -pos.y);
    }
    
    public static function inverseOrigin(pos:FlxPoint)
    {
            for (methodology in methods){
        if (method != methodology){
            method = methods[0];
        }
    }
        return new FlxPoint(-pos.y, -pos.x);
    }
}