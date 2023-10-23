package zygame.display;
import openfl.Vector;
import openfl.display.Shape;
import openfl.events.TimerEvent;
import openfl.utils.Timer;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.Assets;
import openfl.display.DisplayObject;
import openfl.media.Sound;
import openfl.display.Sprite;

enum SpritesheetFormat {
	ADOBE_ANIMATE_JSON;
	ADOBE_ANIMATE_STARLING;
}

typedef ADOBE_ANIMATE_JSON_RAW = {
	var frames:Dynamic;
	var meta:ADOBE_ANIMATE_JSON_Meta;
}

typedef ADOBE_ANIMATE_JSON = {
	var frames:Array<JFrame>;
	var meta:ADOBE_ANIMATE_JSON_Meta;
}

typedef ADOBE_ANIMATE_JSON_Meta = {
	var app:String;
	var version:String;
	var image:String;
	var format:String;
	var size:{x:Int, y:Int};
	var scale:Float;
}

typedef JFrame = {
	var frame:{
		x:Int,
		y:Int,
		w:Int,
		h:Int
	};
	var rotated:Bool;
	var trimmed:Bool;
	var spriteSourceSize:{
		x:Int,
		y:Int,
		w:Int,
		h:Int
	};
	var sourceSize:{x:Int, y:Int};
}

class ZMovieClip extends Sprite {
	public function new() {
		super();
	}

	public var numFrames:Int = 0;

	private var frames:Array<DisplayObject> = [];

	public static function fromSpritesheet(format:SpritesheetFormat, path:String):ZMovieClip {
		var zmc:ZMovieClip = new ZMovieClip();
		var animate_raw:ADOBE_ANIMATE_JSON_RAW = haxe.Json.parse(Assets.getText(path));
		var animate:ADOBE_ANIMATE_JSON = {frames: [], meta: animate_raw.meta};
		for (n in Reflect.fields(animate_raw.frames)) {
			animate.frames.push(Reflect.field(animate_raw.frames, n));
		}
		var idx = path.length - 1;
		if(StringTools.contains(path,"/")){
			while(path.charAt(idx) != "/"){
				--idx;
			}
		}
	 
	 	zmc.bitmapData =  Assets.getBitmapData('${path.substr(0,idx)}/${animate.meta.image}');
		
		for (frame in animate.frames) {
			// var bmd_sub:BitmapData = new BitmapData(frame.spriteSourceSize.w,frame.spriteSourceSize.h,true,0xffff00ff);
			// bmd.unlock();
			// bmd_sub.copyPixels(bmd,new Rectangle(frame.frame.x,frame.frame.y,frame.frame.w,frame.frame.h),new Point(frame.spriteSourceSize.x,frame.spriteSourceSize.y),null,null,true);
			// bmd_sub.lock();
			// var bm:Bitmap = new Bitmap(bmd_sub);
			// zmc.addFrame(bm);

			var bsize:Point = new Point(zmc.bitmapData.width,zmc.bitmapData.height);
			
			var shape:Shape = new Shape();
			shape.graphics.beginBitmapFill(zmc.bitmapData,null,false,true);
			shape.graphics.lineStyle(2,0xff0000);
			shape.graphics.drawTriangles(
				ofArray([0.0,0,		frame.frame.w,0,	frame.frame.w,frame.frame.h,	0,frame.frame.h]),
				ofArray([0,1,3,	1,2,3]),
				ofArray([
						(0.0+frame.frame.x)/bsize.x,
						(0.0+frame.frame.y)/bsize.y,

						(0.0+frame.frame.x+frame.frame.w)/bsize.x,
						(0.0+frame.frame.y)/bsize.y,

						(0.0+frame.frame.x+frame.frame.w)/bsize.x,
						(0.0+frame.frame.y+frame.frame.h)/bsize.y,

						(0.0+frame.frame.x)/bsize.x,
						(0.0+frame.frame.y+frame.frame.h)/bsize.y,

				])
			);
			shape.graphics.endFill();
			shape.x = frame.spriteSourceSize.x;
			shape.y = frame.spriteSourceSize.y;
			zmc.addFrame(shape);

		}

		return zmc;
	}

	private var bitmapData:BitmapData = null;
	
	public function addFrame(frame:DisplayObject, duration:Float = -1, sound:Sound = null) {
		frame.visible = false;
		addChild(frame);
		frames.push(frame);
		++numFrames;
	}
	var timer:Timer;
	var currentFrame:UInt = 0;
	var lastDisplayed:DisplayObject = null;
	public function play() {
		if(timer == null){
			timer = new Timer(1000/60);
			timer.addEventListener(TimerEvent.TIMER,function (e:TimerEvent) {
				if(lastDisplayed != null) lastDisplayed.visible = false;
				if(currentFrame > frames.length - 1){
					currentFrame = 0;
				}
				var display = frames[currentFrame];
				display.visible = true;
				lastDisplayed = display;
				++currentFrame;
			});
		}
		timer.start();
	}

	public inline static function ofArray<T>(array:Array<T>):Vector<T> {
		var vector:Vector<T> = new Vector<T>();
		for (i in 0...array.length) {
			vector[i] = cast array[i];
		}
		return vector;
	}
}
