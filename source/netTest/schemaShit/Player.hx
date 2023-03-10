// 
// THIS FILE HAS BEEN GENERATED AUTOMATICALLY
// DO NOT CHANGE IT MANUALLY UNLESS YOU KNOW WHAT YOU'RE DOING
// 
// GENERATED USING @colyseus/schema 1.0.36
// 
package netTest.schemaShit;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class Player extends Schema {
	@:type("boolean")
	public var left: Bool = false;

	@:type("boolean")
	public var right: Bool = false;

	@:type("boolean")
	public var up: Bool = false;

	@:type("boolean")
	public var down: Bool = false;

	@:type("boolean")
	public var loaded: Bool = false;

	@:type("int")
	public var score:Int = 0;
}

//define mini-player class here:
class IntermissionClient extends Schema {
	@:type("boolean")
	public var ready: Bool = false;

	@:type("string")
	public var gjName: String = "default";
}