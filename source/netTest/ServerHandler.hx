package netTest;

import options.OptionsMenu;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import hxcpp.StaticRegexp;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.FlxG;
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

	#if (haxe >= "4.0.0")
	var strumAccordingToPlr:Map<String, FlxTypedGroup<FlxSprite>> = [];
	var charAccordingToPlr:Map<String, Character> = [];
	#else
	var strumAccordingToPlr:Map<String, FlxTypedGroup<FlxSprite>> = new Map<String, FlxTypedGroup<FlxSprite>>();
	var charAccordingToPlr:Map<String, Character> = new Map<String, Character>();
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
				strumAccordingToPlr.set(key, generateStaticArrows(player.__refId - 2));
				player.triggerAll();
			}

			this.room.state.players.onRemove = function(player, key)
			{
				trace("PLAYER REMOVED AT: ", key);
				// memory cleaning process
				strumAccordingToPlr.get(key).destroy();
				strumAccordingToPlr.remove(key);
			}

			this.room.onStateChange += function(state:ChatState)
			{
				// trace("STATE CHANGE: " + Std.string(state));
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

			this.room.onMessage("notePress", function(message)
			{
				for (plr => strum in strumAccordingToPlr)
					if (this.room.sessionId != plr)
					{
						strum.members[message.notedata].animation.play("pressed");
						trace('${message.notedata} has been pressed');
					}
			});

			this.room.onMessage("noteRaised", function(message)
			{
				for (plr => strum in strumAccordingToPlr)
					if (this.room.sessionId != plr)
					{
						strum.members[message.notedata].animation.play("static");
						trace('${message.notedata} has been unpressed');
					}
			});
		});

		Keybinds.loadKeybinds();
		OptionsMenu.loadSettings();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}

	private var pressed = [false, false, false, false];

	private function onKeyDown(event:KeyboardEvent)
	{
		if (acceptsControls)
		{
			final keyJustPressed = FlxKey.toStringMap.get(event.keyCode);

			final binds:Array<Array<FlxKey>> = [
				Keybinds.keybinds[0][1],
				Keybinds.keybinds[1][1],
				Keybinds.keybinds[2][1],
				Keybinds.keybinds[3][1]
			];
			var notedata:Int = -1; // null
			for (i => bind in binds)
				if (bind.contains(keyJustPressed))
					notedata = i;
			
			if (notedata == -1)
				return;
			
			if (pressed[notedata])
				return;

			pressed[notedata] = true;
			this.room.send("notePress", {notedata: notedata, clientname: FlxG.save.data.gjUser});
			// notePress
		}
	}

	private function onKeyUp(event:KeyboardEvent)
	{
		if (acceptsControls)
		{
			final keyJustPressed = FlxKey.toStringMap.get(event.keyCode);

			final binds:Array<Array<FlxKey>> = [
				Keybinds.keybinds[0][1],
				Keybinds.keybinds[1][1],
				Keybinds.keybinds[2][1],
				Keybinds.keybinds[3][1]
			];
			var notedata:Int = -1; // null
			for (i => bind in binds)
				if (bind.contains(keyJustPressed))
					notedata = i;

			if (notedata == -1)
				return;

			pressed[notedata] = false;
			this.room.send("noteRaised", {notedata: notedata, clientname: FlxG.save.data.gjUser});
			// noteRaised
		}
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