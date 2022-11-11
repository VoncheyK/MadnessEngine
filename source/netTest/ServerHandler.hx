package netTest;

import hxcpp.StaticRegexp;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import netTest.schemaShit.Player;
import netTest.schemaShit.ChatState;
import flixel.FlxSubState;
import ui.Prompt;
import io.colyseus.Room;
import netTest.schemaShit.BattleState;
import netTest.schemaShit.Player;
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
	// put server location in the client thing
	private var cliente = new Client(SpecialKeys.host);
	private var room:Room<ChatState>;
	var prompt:MultiPrompt;
	var acceptsControls:Bool = true;
	// String = name(key), Character = sprite and shit
	#if (haxe >= "4.0.0")
	var players:Map<String, Character> = [];
	#else
	var players:Map<String, Character> = new Map<String, Character>();
	#end

	/**strum shit**/
	var strumLine:FlxSprite;

	var strumLineNotes:FlxTypedGroup<FlxSprite>;
	var playerStrums:FlxTypedGroup<FlxSprite>;

	var local:Player = null;

	#if (haxe >= "4.0.0")
	var strumAccordingToPlr:Map<Player, FlxTypedGroup<FlxSprite>> = [];
	#else
	var strumAccordingToPlr:Map<Player, FlxTypedGroup<FlxSprite>> = new Map<Player, FlxTypedGroup<FlxSprite>>();
	#end

	private var cumHudlol:FlxCamera;

	override function create()
	{
		FlxG.mouse.visible = true;

		cumHudlol = new FlxCamera();
		cumHudlol.bgColor.alpha = 0;
		FlxG.cameras.add(cumHudlol);

		// handle server stuff
		// init the j
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
			Application.current.window.alert(radminPath,
				"Error! Could not locate Radmin VPN, you need this so people don't get your real ip from the serverlist!");
		}

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('multiplayerBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 0.7));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		strumLine = new FlxSprite(0, 25).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		strumLine.cameras = [cumHudlol];
		playerStrums.cameras = [cumHudlol];

		haxe.Timer.delay(function()
		{
			this.cliente.getAvailableRooms("chat", function(err, rooms)
			{
				if (err != null)
				{
					trace("ERROR! " + err);
					return;
				}
				for (room in rooms)
				{
					trace("RoomAvailable:");
					trace("roomId: " + room.roomId);
					trace("clients: " + room.clients);
					trace("maxClients: " + room.maxClients);
					trace("metadata: " + room.metadata);
				}
			});
		}, 3000);

		this.cliente.joinOrCreate("chat", [
			"name" => FlxG.save.data.gjUser,
			"accessToken" => FlxG.save.data.gjToken,
			"authorizationKey" => SpecialKeys.authorizationKey,
			"map" => "stage",
			"password" => ""
		], ChatState, function(err, room)
		{
			if (err != null)
			{
				trace("ERROR! " + err);
				return;
			}
			this.room = room;

			this.room.state.players.onAdd = function(player, key)
			{
				trace("PLAYER ADDED AT: ", key);
				strumAccordingToPlr.set(player, generateStaticArrows(player.__refId - 2));
				this.room.send("getSessionIdOfClient", "");
				this.room.onMessage("returnSessionId", function(message)
				{
					if (key == message)
					{
						local = this.room.state.players.get(key);
					}
				});

				player.triggerAll();
			}

			
			this.room.state.players.onChange = function(plr:Player, k:String)
				{
					trace("PLAYER CHANGED AT: ", k);
					var holdingArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
					var controlArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
	
					var strum = strumAccordingToPlr.get(plr);
					var arrowKeyPressed:Int = 0;
					if (plr.left)
					{
						arrowKeyPressed = 0;
					}
					else if (plr.down)
					{
						arrowKeyPressed = 1;
					}
					else if(plr.up)
					{
						arrowKeyPressed = 2;
					}
					else if (plr.right)
					{
						arrowKeyPressed = 3;
					}
					strum.members[arrowKeyPressed].animation.play('pressed');
				}

			this.room.state.players.onRemove = function(player, key)
			{
				trace("PLAYER REMOVED AT: ", key);
				// memory cleaning process
				strumAccordingToPlr.get(player).destroy();
				strumAccordingToPlr.remove(player);
			}

			this.room.onStateChange += function(state:ChatState)
			{
				trace("STATE CHANGE: " + Std.string(state));
			}

			this.room.onError += function(code:Int, message:String)
			{
				trace("ROOM ERROR: " + code + " => " + message);
			};

			this.room.onLeave += function()
			{
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
			else if (controls.UP_R)
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

	/*lmao copying strum line code from playstate cuz lazy*/
	private function generateStaticArrows(player:Int):FlxTypedGroup<FlxSprite>
	{
		var deez:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
			babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			switch (Math.abs(i))
			{
				case 0:
					babyArrow.x += Note.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					deez.add(babyArrow);
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
					deez.add(babyArrow);
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
					deez.add(babyArrow);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					deez.add(babyArrow);
			}
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
		return deez;
	}
}