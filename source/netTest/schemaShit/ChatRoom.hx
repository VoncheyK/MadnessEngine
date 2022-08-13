package netTest.schemaShit;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;

class ChatRoom extends Schema
{
    @:type("player")
    public var players:ArraySchema<Player> = new ArraySchema<Player>();
}
