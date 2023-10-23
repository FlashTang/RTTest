import openfl.display.BitmapData;
import openfl.display.Bitmap;
import zygame.display.ZMovieClip;
import zygame.core.Start;
class Main extends Start {

    public function new(){
        super(1024,600,true);
    }



    override public function onInit():Void{
        super.onInit();
        //this.stage.color = 0x000000;
		var zmc = ZMovieClip.fromSpritesheet(SpritesheetFormat.ADOBE_ANIMATE_JSON,"assets/run/run_format_JSON.json");
        addChild(zmc);

        zmc.x = 200;

        zmc.y = 200;
        zmc.play();
    }

}