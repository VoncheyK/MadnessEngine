package helpers;

#if desktop
import Sys;
#end

//i did this because of the macro context plague
class Current{
    public static var cur:String;
    
    public function new() {
        cur = Sys.getCwd();
    }
}