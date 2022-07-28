package helpers;

class Vector3Base {
    public function new(_x:Float, _y:Float, _z:Float) {
        x = _x;
        y = _y;
        z = _z;
    }

    public var x : Float;
    public var y : Float;
    public var z : Float;
}

@:forward
abstract Vector3(Vector3Base) to Vector3Base from Vector3Base {

    inline public function new ( _x, _y, _z ) {
        this = new Vector3Base(_x,_y,_z);
    }

    @:op(A * B)
    @:commutative
    public function multiply_Float(rhs:Float) : Vector3 {
        return new Vector3(this.x * rhs, this.y * rhs, this.z * rhs);
    }

    @:op(A * B)
    @:commutative
    public function multiply_Int(rhs:Int) : Vector3 {
        return new Vector3(this.x * cast(rhs, Float), this.y * cast(rhs,Float), this.z * cast(rhs,Float));
    }

    @:op(A *= B)
    @:commutative
    public function multiply_equal_Float(rhs:Float) : Vector3{
        this.x *= rhs;
        this.y *= rhs;
        this.z *= rhs;
        return this;
    }

    @:op(A + B)
    @:commutative
    public function add_Vector3(rhs:Vector3) : Vector3 {
        return new Vector3( this.x + rhs.x, this.y + rhs.y, this.z + rhs.z);
    }

    @:op(A += B)
    public function add_equal_Vector3(rhs:Vector3) : Vector3 {
        this.x += rhs.x;
        this.y += rhs.y;
        this.z += rhs.z;
        return this;
    }
}