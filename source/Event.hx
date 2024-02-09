package;

import haxe.Exception;
import haxe.Constraints.Function;

class Event
{
    //this contains information for the event
    public var step:Null<Int>;
    public var event:String;
    public var isDead:Null<Bool> = false;
    public var param1:String;
    public var param2:String;
    public var characterKey:String = null;

    public function new(step:Int, event:String, param1:String, param2:String, ?characterKey:String){
        this.step = step; this.event = event; this.param1 = param1; this.param2 = param2; this.characterKey = characterKey;
    }

    public function invoke():Void {
        try{
            convertNameToFunction(event)();
            isDead = true;
        }catch(e:Exception){
            Main.raiseWindowAlert('An error has occured while invoking an event!\n Exception data: ${e.details()}\n Event: $event\n Step: $step\n');
        }
    }

    //thank you atpx8
    public function destroy():Void
        untyped __cpp__('delete (void*){0}.GetPtr()', this);

    public function convertNameToFunction(rawEventName:String):Function {
        //this is so the actual event name looks and is customizable NOTE TO SELF: ADD HSCRIPT HANDLABLE/CUSTOM EVENTS!!
        try{
            switch(rawEventName){
                case 'Change Character':
                    return changeCharacter;//Reflect.field(this, "changeCharacter");
                default:
                    throw new Exception("This event name does not exist in function form!");
                    return null;
            }
        }catch(e:Exception){
            Main.raiseWindowAlert('Converting name to function has failed!\n Exception details: ${e.details()}\n Event name: $rawEventName');
            return null;
        }
        return null;
    }

    private function changeCharacter():Void
    {
        
    }
}