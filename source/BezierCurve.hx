package;

import helpers.Vector3;

class BezierCurve 
{
    public static function squaredBezier(p0:Vector3, p1:Vector3, t:Float){return (1-t) * p0 + t * p1;}
    public static function cubicBezier(p0:Vector3, p1:Vector3, p2:Vector3, t:Float){return Math.pow((1-t), 2) * p0 + 2*(1-t)*t*p1+Math.pow(t, 2)*p2;}
    public static function quadraticBezier(p0:Vector3, p1:Vector3, p2:Vector3, p3:Vector3, t:Float){return Math.pow((1-t), 3)*p0+3*Math.pow((1-t), 2)*p1+3*(1-t)*Math.pow(t, 2)*p2+Math.pow(t, 3)*p3;}
}