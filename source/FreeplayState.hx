package;

import Song.SwagSong;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import Sys.sleep;

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	public static var songPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];
	private var scoreBG:FlxSprite;
	private var bg:FlxSprite;

	public static var songData:Map<String, Array<SwagSong>> = [];

	var text:FlxText;

	#if PRELOAD_ALL
	var leText:String = "Press SPACE to listen to the Song";
	var size:Int = 16;
	#end

	override function create()
	{
		persistentUpdate = true;
 
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		//uh soft coded songs in freeplay
		//this should work???
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));

		for (i in 0...initSonglist.length)
		{
			var data = initSonglist[i].split(":");
			var meta = new SongMetadata(data[0], Std.parseInt(data[1]), data[2]);

			var diffs = [];
			var diffsThatExist = ["Easy","Normal","Hard"];

			if (diffsThatExist.contains("Easy"))
				FreeplayState.loadDiff(0, meta.songName, diffs);
			if (diffsThatExist.contains("Normal"))
				FreeplayState.loadDiff(1, meta.songName, diffs);
			if (diffsThatExist.contains("Hard"))
				FreeplayState.loadDiff(2, meta.songName, diffs);

			songData.set(data[0],diffs);

			songs.push(meta);
		}

		#if PRELOAD_ALL
		if (!songPlaying) Conductor.changeBPM(102);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.scrollType = "Center";
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - scoreText.width, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.alignment = CENTER;
		diffText.font = scoreText.font;
		diffText.x = scoreBG.getGraphicMidpoint().x;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));
			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;
			FlxG.stage.addChild(texFel);
			// scoreText.textField.htmlText = md;
			trace(md);
		 */

		#if PRELOAD_ALL
		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
		text = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
		add(text);

		FlxTween.tween(text, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		FlxTween.tween(textBG, {y: FlxG.height - 18}, 2, {ease: FlxEase.elasticInOut});
		#end

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	var instPlaying:Int = -1;
	public static var curPlayingTxt:String = "N/A";
	private static var vocals:FlxSound = null;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if(space)
		{
			#if PRELOAD_ALL
			if(instPlaying != curSelected)
			{
				destroyFreeplayVocals();
				FlxG.sound.music.volume = 0;

				var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());

				if (PlayState.SONG.needsVoices)
					vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
				else
					vocals = new FlxSound();

				curPlayingTxt = songs[curSelected].songName.toLowerCase();

				FlxG.sound.list.add(vocals);
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
				vocals.play();
				vocals.persist = true;
				vocals.looped = true;
				vocals.volume = 0.7;

				instPlaying = curSelected;
				songPlaying = true;

				trace('playing ' + poop);

				text.text = 'Playing ' + songs[curSelected].songName + '!';
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					text.text = leText;
				});

				var song;
				try
				{
					song = songData.get(songs[curSelected].songName)[curDifficulty];
					if (song != null)
					{
						Conductor.changeBPM(song.bpm);
					}
					trace("bpm should be " + song.bpm);
				}
				catch(ex)
				{trace(ex);}
			}
			else
			{
				trace("already playing!");

				text.text = 'This song is already playing!';
				new FlxTimer().start(0.6, function(tmr:FlxTimer)
				{
					text.text = leText;
				});
			}
			#end
		}
		else if (accepted)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;

			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);

			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;

			destroyFreeplayVocals();
		}

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		scoreText.x = FlxG.width - scoreText.width - 5;
		scoreBG.width = scoreText.width;
		scoreBG.x = scoreText.x;
		diffText.x = scoreBG.x + (scoreBG.width / 2) - (diffText.width / 2);
	}

	public static function destroyFreeplayVocals()
	{
		if(vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "< EASY >";
			case 1:
				diffText.text = '< NORMAL >';
			case 2:
				diffText.text = "< HARD >";
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
			iconArray[i].scale.x = 1;
			iconArray[i].scale.y = 1;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		//we can do cool stuff with the beat
		bg.scale.x += 0.04;
		bg.scale.y += 0.04;
		FlxTween.tween(bg, {"scale.x": 1, "scale.y": 1}, 0.1);

		FlxG.camera.shake(0.0018, 0.1);
	}

	public static function loadDiff(diff:Int, songName:String, array:Array<SwagSong>)
	{
		try {
			array.push(Song.loadFromJson(Highscore.formatSong(songName, diff), songName));
		} catch(e) {
			trace(e);
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}