package netTest;

import netTest.schemaShit.Player;
import netTest.schemaShit.ChatState;
import flixel.FlxSubState;
import ui.Prompt;
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
import SpecialKeys;
import GameJolt;

class ServerHandler extends MusicBeatState
{
	//put server location in the client thing
	private var cliente = new Client(SpecialKeys.host);
	private var room:Room<ChatState>;
	var prompt:MultiPrompt;
	var acceptsControls:Bool = true;
	//String = name(key), Character = sprite and shit
	#if (haxe >= "4.0.0")
	var players:Map<String, Character> = [];
	#else
	var players:Map<String, Character> = new Map<String, Character>();
	#end

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
			prompt = new MultiPrompt("\nRadmin VPN required\n for Multiplayer. Run it?", Yes_No);
			acceptsControls = false;
			prompt.back.alpha = 0.6;
			prompt.onYes = function()
				{
					new Process('powershell', [".\\" + radminPath]);
					prompt.setButtons(None);
					acceptsControls = true;
					prompt.exists = false;
					prompt.close();
				}
			prompt.onNo = function()
				{
					FlxG.switchState(new MainMenuState());
					prompt.setButtons(None);
					acceptsControls = true;
					prompt.exists = false;
					prompt.close();		
				}
				openSubState(prompt);
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
				this.cliente.getAvailableRooms("chat", function(err, rooms)
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

		this.cliente.create("chat", ["name" => FlxG.save.data.gjUser, "accessToken" => FlxG.save.data.gjToken, "authorizationKey" => SpecialKeys.authorizationKey, "map" => "stage", "password" => ""], ChatState, function(err, room){
			if (err != null) {
				trace("ERROR! " + err);
				return;
			}
			this.room = room;

			this.room.state.players.onAdd = function(player, key) {
                trace("PLAYER ADDED AT: ", key);
            }

			this.room.state.players.onRemove = function(player, key) {
                trace("PLAYER REMOVED AT: ", key);
            }
			
			this.room.onStateChange += function(state)
			{
				trace("STATE CHANGE: " + Std.string(state));
			}

			this.room.onError += function(code: Int, message: String) {
                trace("ROOM ERROR: " + code + " => " + message);
            };

			this.room.onLeave += function() {
                trace("ROOM LEAVE");
            }

			this.room.send("message", "Funne Message");

			this.room.onMessage("message", function(message)
				{
					trace("onMessage: 'message' => " + message);
				});
		});
	}

	override function update(elapsed:Float)
	{
		if (acceptsControls)
			{
				if (controls.DOWN_P)
				{
					this.room.send("downP", "");
				}
				else if (controls.DOWN_R)
				{
					this.room.send("downR", "");
				}
			
				if (controls.UP_P)
				{
					this.room.send("upP", "");
				}
				else if(controls.UP_R)
				{
					this.room.send("upR", "");
				}

				if (controls.LEFT_P)
				{
					this.room.send("leftP", "");
				}
				else if (controls.LEFT_R)
				{
					this.room.send("leftR", "");
				}

				if (controls.RIGHT_P)
				{
					this.room.send("rightP", "");
				}
				else if (controls.RIGHT_R)
				{
					this.room.send("rightR", "");
				}
			}

		super.update(elapsed);
	}
}