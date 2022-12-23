package;

import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.geom.Rectangle;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.events.MouseEvent;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxG;

class OutputMenu extends FlxBasic
{
    private var sprites:FlxTypedGroup<FlxSprite>;
    private var appendedText:String = "";
    private var clickable = false;
    private var isConsoleShown:Bool = false;
    public function new()
    {
        super();
        //cum cum cum cum
        haxe.Log.trace = (arg, ?pos) -> {
            var formatted:String = 'Class: ${pos.className} Line: ${pos.lineNumber} $arg';
            appendedText += formatted;
		}
        sprites = new FlxTypedGroup<FlxSprite>();
        var stateFlx:flixel.FlxState = FlxG.state;
        stateFlx.add(sprites);
        //yeah thats basically it
        //add the place for the console out of bounds
        var blackOverlay:FlxSprite = new FlxSprite(0, -100).makeGraphic(500, 200, flixel.util.FlxColor.BLACK);
        blackOverlay.x = (FlxG.width / 2) - (blackOverlay.width / 2);
        blackOverlay.ID = 1;
        blackOverlay.active = true;
        var blackGraphic:FlxSprite = new FlxSprite(0, 40).makeGraphic(700, 40, flixel.util.FlxColor.BLACK);
        blackGraphic.x = (FlxG.width / 2) - (blackGraphic.width / 2);
        blackGraphic.ID = 2;
        var clickHere:FlxText = new FlxText(blackGraphic.x, blackGraphic.y, 0, "<CLICK HERE TO VIEW THE CONSOLE>", 12);
        clickHere.setFormat(Paths.font("vcr.ttf"));
        clickHere.ID = 0;
        sprites.add(clickHere);
        sprites.add(blackOverlay);
        sprites.add(blackGraphic);

        FlxG.stage.addEventListener(MouseEvent.CLICK, mouseClick);
        FlxG.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
    }

    private function mouseMove(event:MouseEvent)
    {
        final coordinates:openfl.geom.Point = new openfl.geom.Point(event.stageX, event.stageY);
        final rect:Rectangle = new Rectangle(0, 40, 200, 40);
        rect.x = (FlxG.width / 2) - (rect.width / 2);
        if (rect.containsPoint(coordinates) && !isConsoleShown)
        {
            sprites.forEach((spr) -> {
                if (spr.ID == 0 || spr.ID == 2)
                    FlxTween.tween(spr, {y: 200}, .5, {ease: FlxEase.linear, onComplete: function(tween:FlxTween){clickable = true;}});
            });
        }
        else if (!rect.containsPoint(coordinates))
        {
            sprites.forEach((spr) -> {
                if (spr.ID == 0 || spr.ID == 2)
                    FlxTween.tween(spr, {y: -200}, .5, {ease: FlxEase.linear, onComplete: function(t:FlxTween){clickable = false;}});
            });
        }
    }

    private function mouseClick(event:MouseEvent)
    {
        if (clickable) {
            final coords = new openfl.geom.Point(event.stageX, event.stageY);
            sprites.forEach((spr) -> {
                trace(spr);
                if (spr.ID == 0 || spr.ID == 2)
                {
                    var rect:openfl.geom.Rectangle = spr.getScreenBounds().copyToFlash();
                    if (rect.containsPoint(coords))
                        trace("open console");
                }
            });
        }
    }
}