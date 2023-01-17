package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Timer;
import lime.tools.Platform;

class PlayState extends FlxState
{
	var k1:Float = 1;
	var k2:Float = 1;
	var k3:Float = 1;

	var X:Float;
	var Y:Float;

	var dX:Float;
	var dY:Float;

	var dt:Float = 1 / 10;

	var dataX:Array<Float> = [];
	var dataY:Array<Float> = [];

	var canvas:FlxSprite;
	var graph:FlxSprite;
	var title:FlxText;

	var ok:FlxButton;

	var fbox:Input;
	var zbox:Input;
	var rbox:Input;
	var dTbox:Input;
	var graphDrawer:FlxTimer;

	final STEP:Int = 4;

	override public function create()
	{
		super.create();

		title = new FlxText(0, 0, FlxG.width, "Second order dynamics - Interactive viewer");
		title.setFormat("assets/data/font.ttf", 8);
		add(title);

		canvas = new FlxSprite(0, title.height);
		canvas.makeGraphic(FlxG.width, 400, 0xffffffff, true);

		graph = new FlxSprite(0, title.height);
		graph.makeGraphic(FlxG.width, Std.int(canvas.height), FlxColor.TRANSPARENT, true);
		graph.alpha = 1;

		fbox = new Input("F:", 1, 20, title.height + canvas.height + 10);
		zbox = new Input("Z:", 1, 20, (title.height + canvas.height + 10) + 25);
		rbox = new Input("R:", 1, 20, (title.height + canvas.height + 10) + 50);
		dTbox = new Input("dT:", 1 / 60, 20, (title.height + canvas.height + 10) + 75);

		ok = new FlxButton(250, title.height + canvas.height + 10, "", onClick);
		ok.loadGraphic(AssetPaths.ok__png, true, 56, 20);

		graphDrawer = new FlxTimer();

		add(fbox);
		add(zbox);
		add(rbox);
		add(dTbox);

		add(canvas);
		add(graph);
		add(ok);

		var lastValue:Float = 0;
		for (i in 0...Std.int(canvas.width))
		{
			if (i % 100 == 0)
			{
				lastValue = Math.random() * 50;
				Y = lastValue;
			}
			dataX.push(lastValue);
			dataY.push(0);
			plot(canvas, i, dataX[i], 0xffff0000);

			// plot to canvas for y= 0 in color green
			plot(canvas, i, 0, 0xff00ff00);
		}

		setDefaults();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	// Plots a pixel at the given coordinates in the canvas sprite.
	function plot(TO_PLOT:FlxSprite, x:Float, y:Float, color:Int)
	{
		TO_PLOT.graphic.bitmap.lock();
		TO_PLOT.graphic.bitmap.setPixel32(Std.int(x), Std.int(TO_PLOT.height * 0.5 - y), color);
		TO_PLOT.graphic.bitmap.unlock();
	}

	function onClick()
	{
		dt = dTbox.getValue();

		// Compute k1,k2,k3 values
		var f = fbox.getValue();
		var z = zbox.getValue();
		var r = rbox.getValue();

		k1 = z / (Math.PI * f);
		k2 = 1 / ((2 * Math.PI * f) * (2 * Math.PI * f));
		k3 = (r * z) / (2 * Math.PI * f);

		var index:Int = 0;
		graphDrawer.cancel();
		graphDrawer.start(1 / 60, function(v:FlxTimer)
		{
			// Calculate the new values for the second order system
			for (i in 0...STEP)
			{
				plot(graph, index, Std.int(dataY[index]), 0x00ffffff);

				calculate(index);
				dataY[index] = Y;
				plot(graph, index, Std.int(Y), 0xff0000ff);
				index++;
			}
		}, Std.int(canvas.width / STEP));

		setDefaults();
	}

	function calculate(index:Int)
	{
		dX = (dataX[index] - X) / dt;
		X = dataX[index];

		Y = Y + dY * dt;
		dY = dY + dt * (X + (k3 * dX) - Y - (k1 * dY)) / k2;
	}

	function setDefaults()
	{
		dX = 0.0;
		dY = 0.0;
		X = 0.0;
		Y = 0.0;
	}
}
//
