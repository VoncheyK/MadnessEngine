package netTest;

import netTest.schemaShit.Player.IntermissionClient;
import flixel.FlxSprite;
import io.colyseus.Client;
import io.colyseus.Room;
import netTest.schemaShit.IntermissionState;
import flixel.FlxG;
import flixel.text.FlxText;
import openfl.events.KeyboardEvent;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
#if desktop
import sys.io.Process;
import sys.FileSystem;
#end
import ui.Prompt;

class Intermission extends MusicBeatState 
{
    var client:Client = new Client(SpecialKeys.host);
    private var room:Room<IntermissionState>;
	private var prompt:MultiPrompt;
	private var acceptsControls:Bool = true;

    private var textPerPlayer:Map<String, FlxText> = new Map<String, FlxText>();

    private function handleOnRoomJoin(error, room:Room<IntermissionState>):Void{
        if (error != null)
			{
				Main.raiseWindowAlert("An error has occured with multiplayer! " + error.message);
				return;
			}
        this.room = room;
        
        this.room.state.players.onAdd = function(plr, key) {
            this.room.send("setPlayerName", FlxG.save.data.gjUser);
            var i:Int = -1;
            //for (z in 0...this.room.state.players.length) i++;
			this.room.sessionId == this.room.state.players.indexes.get(0) ? i = 0 : (this.room.sessionId == this.room.state.players.indexes.get(1) ? i = 1 : null); 
            trace(i);
            var text:FlxText = new FlxText(250 + (i * 300), 425, 0, i == 0 ? FlxG.save.data.gjUser : this.room.state.players.get(this.room.state.players.indexes.get(1)).gjName, 24);
            text.color = FlxColor.RED;
            add(text);
            textPerPlayer.set(key, text);
        }
    }

    private function onKeyDown(e:KeyboardEvent):Void {
		if (acceptsControls){
			switch(e.keyCode){
				case FlxKey.G:
					textPerPlayer.get(room.sessionId).color = FlxColor.fromRGB(0, 255, 148);
					this.room.send("readyChange", true);
				case FlxKey.ESCAPE:
					FlxG.switchState(new MainMenuState());
				default:
			}
		}
    }

    override function create(){
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
			prompt.back.alpha = 0.6;
			acceptsControls = true;
			prompt.onYes = function()
			{
				new Process('powershell', [".\\" + radminPath]);
				prompt.setButtons(None);
				prompt.exists = false;
				prompt.close();
			}
			prompt.onNo = function()
			{
				FlxG.switchState(new MainMenuState());
				prompt.setButtons(None);
				prompt.exists = false;
				prompt.close();
			}
			openSubState(prompt);
		}
		else
		{
			Main.raiseWindowAlert("Error! Could not locate Radmin VPN, you need this so people don't get your real IP someway!");
		}
	
	
        var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image("multiplayerBG"));
        bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 0.7));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

        client.joinOrCreate("intermission", ["name" => FlxG.save.data.gjUser,
        "accessToken" => FlxG.save.data.gjToken,
        "authorizationKey" => SpecialKeys.authorizationKey],
        IntermissionState, handleOnRoomJoin);
    
        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
    }

    override function update(e:Float){
        super.update(e);
		if (this.room != null && this.room.state != null && this.room.state.players != null){
		    final plr:Null<String> = this.room.state.players.indexes.get(0);
			final enemy:Null<String> = this.room.state.players.indexes.get(1);
			final actualPlr:IntermissionClient = this.room.state.players.get(plr);
			final actualEnemy:IntermissionClient = this.room.state.players.get(enemy);
			if (plr != null && enemy != null && actualPlr.ready == true && actualEnemy.ready == true){
				//shut down
				this.room = null;
				this.client = null;
				this.textPerPlayer = null;
				FlxG.switchState(new Director());
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			}
		}
    }
}