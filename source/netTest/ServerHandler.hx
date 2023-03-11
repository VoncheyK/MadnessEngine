package netTest;

import flixel.util.typeLimit.OneOfTwo;
import haxe.Exception;
import openfl.Lib;
import flixel.math.FlxRect;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.util.FlxSort;
import Section;
import Song;
import flixel.system.FlxSound;
import options.OptionsMenu;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import netTest.schemaShit.ChatState;
import io.colyseus.Room;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if desktop
import sys.thread.Thread;
#end
import io.colyseus.Client;
import flixel.FlxG;
import flixel.FlxSprite;
import SpecialKeys;

using StringTools;

class ServerHandler extends MusicBeatState
{
	// put server location in the client thing
	private var cliente = new Client(SpecialKeys.host);
	private var room:Room<ChatState>;
	var acceptsControls:Bool = true;
	// String = name(key), Character = sprite and shit
	#if (haxe >= "4.0.0")
	var players:Map<String, Character> = [];
	#else
	var players:Map<String, Character> = new Map<String, Character>();
	#end

	/**strum shit**/
	var strumLine:FlxSprite;

	private var startingSong:Bool = false;

	var notes:FlxTypedGroup<Note>;
	var strumLineNotes:FlxTypedGroup<FlxSprite>;
	var playerStrums:FlxTypedGroup<FlxSprite>;
	var enemyStrums:FlxTypedGroup<FlxSprite>;

	var strumAccordingToPlr:Map<String, FlxTypedGroup<FlxSprite>> = new Map<String, FlxTypedGroup<FlxSprite>>();
	var charAccordingToPlr:Map<String, Character> = new Map<String, Character>();
	var scoreAccordingToPlr:Map<String, Int> = new Map<String, Int>();
	var plrScoreText:FlxText;
	var enemyScoreText:FlxText;

	private var cumHudlol:FlxCamera;

	private var initialized:Bool = false;

	var dadStrumTimes:Array<Int> = [];
	var bfStrumTimes:Array<Int> = [];

	public static var SONG:Dynamic;

	private var vocals:FlxSound;
	private var inst:FlxSound;

	private var generatedMusic:Bool = false;
	private var unspawnNotes:Array<Note> = [];

	private var curSong:String = '';

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;
	var lastReportedPlayheadPosition:Int = 0;

	//these are playerIds
	public var player:String = "";
	public var enemy:String = "";
	//0 = plr, 1 = enemy
	public var playerIds:haxe.ds.Vector<String>;

	public var boyfriend:Boyfriend;
	public var dad:Character;

	public var areBothClientsLoaded:Bool = false;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.playMusic(Paths.inst(SONG.song, 'fleetway'), 1, false);
		// FlxG.sound.music.onComplete = endSong;
		vocals.play();
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function getPropertyFromSection(section:Any, property:String):Dynamic
		{
			try{
				switch(property)
				{
					case "mustHit":
						(SONG.chartVersion == "1.5") ? return Reflect.field(section, property) : return Reflect.field(section, "mustHitSection");
					case "mustHitSection":
						(SONG.chartVersion == "1.5") ? return Reflect.field(section, "mustHit") : return Reflect.field(section, property);
					case "changeBPM":
						(property is Bool) ? (SONG.chartVersion == "1.5")  ? return Reflect.field(Reflect.field(section, "changeBPM"), "active") : return Reflect.field(section, property) : return Reflect.field(section, property);
					case "bpm":
						(SONG.chartVersion == "1.5") ? return Reflect.field(Reflect.field(section, "changeBPM"), "bpm") : return Reflect.field(section, property);
					case "changeBPM.active":
						(SONG.chartVersion == "1.0") ? return Reflect.field(section, "changeBPM") : return Reflect.field(Reflect.field(section, "changeBPM"), "active");
					case "changeBPM.bpm":
						(SONG.chartVersion == "1.0") ? return Reflect.field(section, "bpm") : return Reflect.field(Reflect.field(section, "changeBPM"), "bpm");
					default:
						return Reflect.field(section, property);
				}
				return Reflect.field(section, property);
			}
			catch(e:Exception)
			{
				Main.raiseWindowAlert("An error has occured while returning a variable/property/field from a section! : " + property);
				trace(e.details());
				return null;
			}
		}
	
	//shut up already
	private function timerThing():Void {
		//loop until room isnt null
		if (this.room == null){
			timerThing();
			return;
		}
		this.room.send("playerHasLoaded", null);
	}
		
	public function loaded():Void {
		if (this.room != null)
			this.room.send("playerHasLoaded", null);
		else{
			//wait until room isnt null or something
			Thread.create(function() {
				var timer = new haxe.Timer(3000);
				timer.run = timerThing;
			});
		}
	}

	private function generateSong(songname:String)
	{
		trace(songname);
		Conductor.changeBPM(SONG.bpm);
		curSong = SONG.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song, 'fleetway'));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var isNewVerSong:Null<Bool> = null;

		if (SONG.chartVersion == "1.5")
			isNewVerSong = true;

		if (SONG.chartVersion == "1.0")
			isNewVerSong = false;

		trace("[[IMPORTANT MESSAGE]] isNewVarSong currently is: " + isNewVerSong);

		if (isNewVerSong)
		{
			var sex:SwaggiestSong = cast(SONG);
			for (curSec => section in sex.sections)
			{
				// var it : { s:Array<SwagNote> } = SONG.notes;
				for (songNotes in section.sectionNotes)
				{
					if (songNotes.strumTime <= (Conductor.stepCrochet * section.lengthInSteps) * curSec
						|| songNotes.strumTime >= (Conductor.stepCrochet * section.lengthInSteps) * (curSec + 1))
						continue;

					var daStrumTime:Float = songNotes.strumTime;
					var daNoteData:Int = Std.int(songNotes.noteData % 4);

					var gottaHitNote:Bool = section.mustHit;

					if (songNotes.noteData > 3)
						gottaHitNote = !section.mustHit;

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.sustainLength = songNotes.sustainLength;
					swagNote.scrollFactor.set(0, 0);

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						sustainNote.mustPress = gottaHitNote;

						if (sustainNote.mustPress)
						{
							sustainNote.isChord = bfStrumTimes.contains(Math.round(sustainNote.strumTime));
							bfStrumTimes.push(Math.round(sustainNote.strumTime));
							sustainNote.x += FlxG.width / 2;
						}
						else
						{
							if (dadStrumTimes.contains(Math.round(sustainNote.strumTime)))
							{
								sustainNote.isChord = true;
								dadStrumTimes.push(Math.round(sustainNote.strumTime));
							}
							dadStrumTimes.push(Math.round(sustainNote.strumTime));
						}
					}

					swagNote.mustPress = gottaHitNote;

					if (swagNote.mustPress)
					{
						if (bfStrumTimes.contains(Math.round(swagNote.strumTime)))
						{
							swagNote.isChord = true;
							bfStrumTimes.push(Math.round(swagNote.strumTime));
						}
						bfStrumTimes.push(Math.round(swagNote.strumTime));
						swagNote.x += FlxG.width / 2; // general offset
					}
					else
					{
						if (dadStrumTimes.contains(Math.round(swagNote.strumTime)))
						{
							swagNote.isChord = true;
							dadStrumTimes.push(Math.round(swagNote.strumTime));
						}
						dadStrumTimes.push(Math.round(swagNote.strumTime));
					}
				}
			}
		}
		else if (!isNewVerSong)
		{
			var noteData:Array<SwagSection>;
			var sex:SwagSong = cast(SONG);

			// NEW SHIT
			noteData = sex.notes;

			var playerCounter:Int = 0;

			var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
			for (section in noteData)
			{
				var coolSection:Int = Std.int(section.lengthInSteps / 4);

				for (songNotes in section.sectionNotes)
				{
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false);
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set(0, 0);

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

						var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);

						sustainNote.mustPress = gottaHitNote;

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2; // general offset
						}
					}

					swagNote.mustPress = gottaHitNote;

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else
					{
					}
				}
				daBeats += 1;
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	override function create()
	{
		FlxG.mouse.visible = true;
		FlxG.autoPause = false;

		cumHudlol = new FlxCamera();
		cumHudlol.bgColor.alpha = 0;
		FlxG.cameras.add(cumHudlol);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('multiplayerBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 0.7));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		strumLine = new FlxSprite(0, (OptionsMenu.options.downScroll ? 570 : 50)).makeGraphic(FlxG.width, 10);

		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		enemyStrums = new FlxTypedGroup<FlxSprite>();
		add(enemyStrums);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		add(playerStrums);

		enemyStrums.cameras = [cumHudlol];
		strumLine.cameras = [cumHudlol];
		strumLineNotes.cameras = [cumHudlol];
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

		playerIds = new haxe.ds.Vector<String>(1);
			
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
				Main.raiseWindowAlert("An error has occured with multiplayer! " + err.message);
				return;
			}
			this.room = room;

			this.room.state.players.onAdd = function(player, key)
			{
				trace("onAdd is broken, I can't seem to trace the key. Hm.");
				//But this somehow works?
				strumAccordingToPlr.set(key, generateStaticArrows(key));
				var nullablePlayer:Null<String> = this.room.state.players.indexes.get(0);
				var nullableEnemy:Null<String> = this.room.state.players.indexes.get(1);
				//should save this data to server aswell, too lazy to do that
				playerIds[0] = nullablePlayer;
				playerIds[1] = nullableEnemy;
				(nullablePlayer != null) ? this.room.send("setPlayer", nullablePlayer) : null;
				(nullableEnemy != null) ? this.room.send('setEnemy', nullableEnemy) : null;
				setupCharacter(key);
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
				if (plrScoreText != null && enemyScoreText != null){
					plrScoreText.text = 'Score: ${this.room.state.players.get(this.room.state.players.indexes.get(0)).score}';
					enemyScoreText.text = 'Score: ${this.room.state.players.get(this.room.state.players.indexes.get(1)).score}';
				}
			}

			this.room.onError += function(code:Int, message:String)
			{
				trace("ROOM ERROR: " + code + " => " + message);
			};

			this.room.onLeave += function()
			{
				trace("ROOM LEAVE");
			}

			this.room.onMessage("message", (message) ->
			{
				trace("onMessage: 'message' => " + message);
			});

			this.room.onMessage("syncScore", (message) -> {
				this.scoreAccordingToPlr.set(player, message.plrScore);
				this.scoreAccordingToPlr.set(enemy, message.enemyScore);
			});

			this.room.onMessage("notePress", (message) ->
			{
				for (plr in strumAccordingToPlr.keys())
					//leaving this here for now
					if (this.room.sessionId != plr)
					{
						if (message.goodHit)
							opponentNoteHit(message.goodHit, message.notedata);
					}
						
			});

			this.room.onMessage("noteRaised", (message) ->
			{
				for (plr in strumAccordingToPlr.keys()){
					if (this.room.sessionId != plr)
						opponentNoteHit(false, message.notedata);
				}		
			});

			this.room.onMessage("playerAndEnemy", (message) -> {
				this.player = message.player;
				this.enemy = message.enemy;
				this.playerIds[0] = message.player;
				this.playerIds[1] = message.enemy;
				//trace(message);
			});
		});

		Keybinds.loadKeybinds();
		OptionsMenu.loadSettings();

		SONG = Song.loadFromJson('chaos-hard', 'chaos');

		generateSong(SONG.song);
		
		startingSong = true;
		
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		
		notes.cameras = [cumHudlol];

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}

	override function destroy(){
		super.destroy();
		Main.dumpCache();
		if (this.room != null)
			this.room.leave(true);
	
		this.room = null;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}

	var direction:Array<String> = ["LEFT", "DOWN", "UP", "RIGHT"];

	function noteMiss(direction:Int = 1):Void
	{
		//trace('lmao bozo you MISSED');
	}

	function opponentNoteHit(goodHit:Bool, data:Int)
	{
		try{
			if (goodHit)
				enemyStrums.members[data].animation.play("confirm");
			else
				enemyStrums.members[data].animation.play("static");
		}catch(e:Exception){
			trace(e);
		}
	}

	var timeSinceLastUpdate:Float = 0.0;

	override function update(elapsed:Float)
	{	
		try{
			if (this.room != null && this.room.state != null && this.room.state.players != null && !areBothClientsLoaded){
				var vecArr:haxe.ds.Vector<Bool> = new haxe.ds.Vector(1);
				for (k in 0...this.room.state.players.length)
					vecArr[k] = this.room.state.players.get(this.room.state.players.indexes.get(k)).loaded;
				
				if (vecArr[0] == vecArr[1] == true)
					areBothClientsLoaded = true;
			}
				
			if (areBothClientsLoaded){
				super.update(elapsed);
				if (startingSong && enemyStrums != null && playerStrums != null)
				{
					Conductor.songPosition += FlxG.elapsed * 1000;
					if (Conductor.songPosition >= 0)
						startSong();
				}
				else if (!startingSong && enemyStrums != null && playerStrums != null)
				{
					// Conductor.songPosition = FlxG.sound.music.time;
					Conductor.songPosition += FlxG.elapsed * 1000;

					songTime += FlxG.game.ticks - previousFrameTime;
					previousFrameTime = FlxG.game.ticks;

					// Interpolation type beat
					if (Conductor.lastSongPos != Conductor.songPosition)
					{
						songTime = (songTime + Conductor.songPosition) / 2;
						Conductor.lastSongPos = Conductor.songPosition;
					}
				}

				if (unspawnNotes[0] != null && enemyStrums != null && playerStrums != null)
				{
					notes.add(unspawnNotes[0]);
					unspawnNotes.splice(0, 1);
				}

				if (generatedMusic && enemyStrums != null && playerStrums != null)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						(!daNote.mustPress) ? daNote.visible = true : null;

						//LMFAOOOOOOOOOOO CRY ABOUT IT
						var strum:FlxTypedGroup<FlxSprite>;
						if (daNote.mustPress)
							strum = playerStrums;
						else
							strum = enemyStrums;

						daNote.y = strum.members[daNote.noteData].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

						if (OptionsMenu.options.downScroll)
						{
							if (daNote.isSustainNote)
							{
								// crefits to psych because hold note positions are fucky
								// and they look amazing on psych!!!!!
								if (daNote.animation.curAnim.name.endsWith('end'))
								{
									daNote.y += 10.5 * (Conductor.crochet / 400) * 1.5 * SONG.speed + (46 * (SONG.speed - 1));
									daNote.y -= 46 * (1 - (Conductor.crochet / 600)) * SONG.speed;
									daNote.y -= 19;
								}

								if (!daNote.mustPress || daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit) 
									&& (strumLine.y + Note.swagWidth / 2) >= daNote.y - daNote.offset.y * daNote.scale.y + daNote.height)
									{
										var rect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										rect.height = ((strumLine.y + Note.swagWidth / 2) - daNote.y) / daNote.scale.y;
										rect.y = daNote.frameHeight - rect.height;
										daNote.clipRect = rect;
									}
							}
						}
						else if (daNote.isSustainNote
							&& (!daNote.mustPress || daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))
							&& (strumLine.y + Note.swagWidth / 2) >= daNote.y + daNote.offset.y * daNote.scale.y)
						{
							var rect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							rect.y = ((strumLine.y + Note.swagWidth / 2) - daNote.y) / daNote.scale.y;
							rect.height -= rect.y;
							daNote.clipRect = rect;
						}

						daNote.x = strum.members[daNote.noteData].x;

						if (daNote.isSustainNote)
							daNote.x += daNote.width / 2 + 20;

						//if (!daNote.mustPress && daNote.wasGoodHit)
						//	opponentNoteHit(daNote);


						// (OptionsMenu.options.downScroll && daNote.y > camHUD.height + daNote.height) || (!OptionsMenu.options.downScroll && daNote.y < -camHUD.height - daNote.height)
						if (daNote.tooLate && !daNote.wasGoodHit)
						{
							// misses++;

							noteMiss(daNote.noteData);
							vocals.volume = 0;
							// health -= 0.04;
							// songScore -= 10;
							// updateAccuracy();

							daNote.active = false;
							daNote.visible = false;

							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
				}

				if (enemyStrums != null){
					enemyStrums.forEach((spr:FlxSprite) -> {
						if (spr.animation.curAnim.name == 'confirm')
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else
								spr.centerOffsets();
					});
				}

				initialized ? keyShit() : null;

				timeSinceLastUpdate = Lib.getTimer() / 1000;
			}
		}catch(e:Exception){
			trace(e.message);
		}
	}

	private function keyShit():Void
	{
		if (pressed.contains(true) && generatedMusic)
			notes.forEachAlive(swagNote -> {
				if (swagNote.isSustainNote && swagNote.canBeHit && swagNote.mustPress && pressed[swagNote.noteData])
					goodNoteHit(swagNote);
			});

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if(pressed[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
				spr.animation.play('pressed');
			if ((!pressed[spr.ID]) || (spr.animation.curAnim.name == "confirm" && spr.animation.curAnim.finished))
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function resyncVocals():Void
	{
		if (vocals != null && areBothClientsLoaded){
			vocals.pause();

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time;
			vocals.time = Conductor.songPosition;
			vocals.play();
		}
	}

	private function checkSection():Null<Dynamic> {
			var s:OneOfTwo<SwagSection, SwaggiestSection>;
			try{
				(SONG.chartVersion == "1.0") ? s = SONG.notes[Std.int(curStep / 16)] : s = SONG.sections[Std.int(curStep / 16)];
				return s != null ? s : null;
			}catch(e:Exception){
				Main.raiseWindowAlert("An Error occured with section returning!");
				trace(e.details());
				return null;
			}
	}

	override function beatHit()
	{
		if (areBothClientsLoaded){
			super.beatHit();

			if (generatedMusic)
				notes.sort(FlxSort.byY, FlxSort.DESCENDING);
	
			if (checkSection() != null)
			{
				var checked = checkSection();
				(getPropertyFromSection(checked, "changeBPM.active")) ? Conductor.changeBPM(getPropertyFromSection(checked, "changeBPM.bpm")) : null;
				FlxG.log.add('CHANGED BPM! ' + getPropertyFromSection(checked, "changeBPM.bpm"));
			}
		}
	}

	override function stepHit()
	{
		if (areBothClientsLoaded){
			super.stepHit();
			(Math.abs(FlxG.sound.music.time - Conductor.songPosition) > 15
			|| (SONG.needsVoices && Math.abs(vocals.time - Conductor.songPosition) > 15)) ? resyncVocals() : null;
		}
		
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			/*if (note.noteData >= 0)
					health += 0.023;
				else
					health += 0.004; */

			// boyfriend.playAnim("sing" + direction[note.noteData], true);

			strumAccordingToPlr.get(this.room.sessionId).forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm');
				}
			});

			// updateAccuracy();

			note.wasGoodHit = true;
			vocals.volume = 1;

			//handling this here to reduce message count
			var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition); //how late the note was (in ms)

			if (noteDiff < PlayState.hitTimings['sick'])
				this.room.send("notePress", {notedata: note.noteData, clientname: FlxG.save.data.gjUser, goodHit: true, rating: 'sick'});
			else if (noteDiff < PlayState.hitTimings['good'])
				this.room.send("notePress", {notedata: note.noteData, clientname: FlxG.save.data.gjUser, goodHit: true, rating: 'good'});
			else if (noteDiff < PlayState.hitTimings['bad'])
				this.room.send("notePress", {notedata: note.noteData, clientname: FlxG.save.data.gjUser, goodHit: true, rating: 'bad'});
			else if (noteDiff < PlayState.hitTimings['shit'])
				this.room.send("notePress", {notedata: note.noteData, clientname: FlxG.save.data.gjUser, goodHit: true, rating: 'shit'});

			if (!note.isSustainNote)
			{
				// totalNotesHit++;
				// combo += 1;
				// popUpScore(note);

				note.kill();
				notes.remove(note, true);
				remove(note);
				note.destroy();
			}
		}
	}

	private var pressed = [false, false, false, false];

	private function onKeyDown(event:KeyboardEvent)
	{
		if (acceptsControls && areBothClientsLoaded)
		{
			final keyJustPressed = FlxKey.toStringMap.get(event.keyCode);
			
			if (event.keyCode == FlxKey.ESCAPE)
				MusicBeatState.switchState(new MainMenuState());

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
			this.room.send("notePress", {notedata: notedata, clientname: FlxG.save.data.gjUser, goodHit: false});
			//strumAccordingToPlr.get(this.room.sessionId).members[notedata].animation.play('pressed');

			// credits to EyeDaleHim#8508 for being smart
			if (generatedMusic)
			{
				var calcTime:Float = Conductor.songPosition;
				Conductor.songPosition += ((Lib.getTimer() / 1000) - timeSinceLastUpdate);

				var possibleNotes:Array<Note> = [];
				var verifiedNotes:Array<Note> = [];

				notes.forEachAlive(function(swagNote:Note)
				{
					if (swagNote.canBeHit && swagNote.mustPress && !swagNote.tooLate && !swagNote.wasGoodHit && notedata == swagNote.noteData)
						possibleNotes.push(swagNote);
				});

				possibleNotes.sort((a, b) -> Std.int((a.strumTime - b.strumTime)));

				var canHitMore:Bool = false; // avoid hitting two notes that are possible to be hit, only count for stacked ones instead
				var countedNotes:Int = 0;
				var maximumNotes:Int = 24;

				if (possibleNotes.length > 0)
				{
					for (epicNote in possibleNotes)
					{
						if (countedNotes >= maximumNotes)
							break;
						verifiedNotes.push(epicNote);
						for (doubleNote in possibleNotes)
						{
							if (canHitMore || countedNotes >= maximumNotes)
								break;

							if (doubleNote != epicNote && Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10)
							{
								canHitMore = true;
								verifiedNotes.push(doubleNote);
							}
							countedNotes++;
						}
						countedNotes++;
					}

					if (canHitMore)
						for (note in verifiedNotes)
							goodNoteHit(note);
					else
						goodNoteHit(verifiedNotes[0]);
				}
				else if (!OptionsMenu.options.ghostTapping)
				{

					noteMiss(notedata);
					// misses++;
					// health -= 0.04;
					// songScore -= 10;
					// updateAccuracy();
				}
				Conductor.songPosition = calcTime;
			}
		}
	}

	private function onKeyUp(event:KeyboardEvent)
	{
		if (acceptsControls && areBothClientsLoaded)
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
			//strumAccordingToPlr.get(this.room.sessionId).members[notedata].animation.play('static');
			// noteRaised
		}
	}

	private function setupCharacter(plrId:String):Void {
		if (plrId == playerIds[0]){
			//boyfry
			boyfriend = new Boyfriend(770, 450, "bf");
			charAccordingToPlr.set(plrId, boyfriend);
			add(boyfriend);
			plrScoreText = new FlxText(800, 700, 0, "Score: ", 15);
			plrScoreText.color = FlxColor.BLUE;
			add(plrScoreText);
		}else if (plrId == playerIds[1]){
			dad = new Character(100, 100, "bf", true);
			charAccordingToPlr.set(plrId, dad);
			add(dad);
			enemyScoreText = new FlxText(100, 700, 0, "Score: ", 15);
			enemyScoreText.color = FlxColor.BLUE;
			add(enemyScoreText);
		}
	}

	/*lmao copying strum line code from playstate cuz lazy*/
	private function generateStaticArrows(playerId:String):FlxTypedGroup<FlxSprite>
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
				case 1:
					babyArrow.x += Note.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 2:
					babyArrow.x += Note.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += Note.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
			}
			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

		    (playerId == this.room.sessionId) ? playerStrums.add(babyArrow) : enemyStrums.add(babyArrow);

			babyArrow.animation.play('static');
			babyArrow.x += 100;
			babyArrow.x += (OptionsMenu.options.middleScroll ? FlxG.width / 4 : (FlxG.width / 2) * ((playerId == this.room.sessionId) ? 1 : 0));

			strumLineNotes.add(babyArrow);
			deez.add(babyArrow);
		}
		//this.room.send("setEnemy", this.room.state.players.indexes.get(1));

		//this.room.send("getPlayer");
		initialized = true;
		return deez;
	}
}