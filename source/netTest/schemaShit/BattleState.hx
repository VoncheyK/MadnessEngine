package netTest.schemaShit;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class BattleState extends Schema
{
    @:type("map", Player)
    public var players:MapSchema<Player> = new MapSchema<Player>();
}
