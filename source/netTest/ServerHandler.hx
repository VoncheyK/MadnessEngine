package netTest;

import io.colyseus.Room;
import netTest.schemaShit.BattleState;
import lime.app.Application;
#if desktop
import sys.io.Process;
import sys.FileSystem;
import Sys;
#end
import io.colyseus.Client;
import flixel.FlxG;
import flixel.FlxSprite;

class ServerHandler extends MusicBeatState
{

	private var cliente = new Client("ws://localhost:2567");
	private var room:Room<BattleState>;

	override function create()
	{
		FlxG.mouse.visible = true;

		//handle server stuff
		//init the j
		var radminPath:String = "radmin/RvRvpnGui";
		#if windows
		radminPath += ".exe";
		#end

		if (FileSystem.exists("./" + radminPath))
		{
			#if linux
			radminPath = "./" + radminPath;
			#end
			new Process('powershell', [".\\" + radminPath]);
		}
		else
		{
			Application.current.window.alert(radminPath, "Error! Could not locate Radmin VPN, you need this so people don't get your real ip from the serverlist!");
		}

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('multiplayerBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 0.7));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		haxe.Timer.delay(function() {
				this.cliente.getAvailableRooms("", function(err, rooms)
					{
						if (err != null)
							{
								trace("ERROR! " + err);
								return;
							}
						for (room in rooms) {
							trace("RoomAvailable:");
							trace("roomId: " + room.roomId );
							trace("clients: " + room.clients);
							trace("maxClients: " + room.maxClients);
							trace("metadata: " + room.metadata);
						}
					});
		}, 3000);

		this.cliente.joinOrCreate("state_handler", [], BattleState, function(err, room){
			if (err != null) {
                trace("ERROR! " + err);
                return;
            }

            this.room = room;
			this.room.state.players.onAdd = function(player, key) {
                trace("PLAYER ADDED AT: ", key);
            }
		});
	}
}