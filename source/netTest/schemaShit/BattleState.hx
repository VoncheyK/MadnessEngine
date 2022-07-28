package netTest.schemaShit;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class BattleState extends Schema
{
    @:type("player")
    public var entities:ArraySchema<Player>;
}
