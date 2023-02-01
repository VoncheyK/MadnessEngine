package netTest.schemaShit;

import io.colyseus.serializer.schema.Schema;
import io.colyseus.serializer.schema.types.*;
import netTest.schemaShit.Player.IntermissionClient;

class IntermissionState extends Schema 
{
    @:type("map", IntermissionClient)
    public var players: MapSchema<IntermissionClient> = new MapSchema<IntermissionClient>();
}