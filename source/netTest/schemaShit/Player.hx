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
}
