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

class PlayState extends FlxState
{
	var k1:Float = 1;
	var k2:Float = 1;
	var k3:Float = 1;

	var X:Float;
	var Y:Float;

	var dX:Float;
	var dY:Float;

	var dt:Float;

	var dataX:Array<Int> = [];
	var dataY:Array<Float> = [];

	var canvas:FlxSprite;
	var graph:FlxSprite;
	var title:FlxText;

	var ok:FlxButton;

	var f:Input;
	var z:Input;
	var r:Input;

	final STEP:Int = 4;
	var graphDrawer:FlxTimer;

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

		f = new Input("K1:", 20, title.height + canvas.height + 10);
		z = new Input("K2:", 20, (title.height + canvas.height + 10) + 25);
		r = new Input("K3:", 20, (title.height + canvas.height + 10) + 50);

		ok = new FlxButton(200, title.height + canvas.height + 10, "", onClick);
		ok.loadGraphic(AssetPaths.ok__png, true, 56, 20);

		graphDrawer = new FlxTimer();

		add(f);
		add(z);
		add(r);
		add(canvas);
		add(graph);
		add(ok);

		for (i in 0...Std.int(canvas.width))
		{
			if (i < Std.int(canvas.width / 8))
				dataX.push(0);
			else
				dataX.push(160);
			dataY.push(0);
			plot(canvas, i, dataX[i], 0xffff0000);
		}

		setDefaults();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	// Plots a pixel at the given coordinates in the canvas sprite.
	function plot(TO_PLOT:FlxSprite, x:Int, y:Int, color:Int)
	{
		TO_PLOT.graphic.bitmap.lock();
		TO_PLOT.graphic.bitmap.setPixel32(x, Std.int(canvas.height / 1.25) - y, color);
		TO_PLOT.graphic.bitmap.unlock();
	}

	function onClick()
	{
		k1 = Std.parseInt(f.textBox.text) * 0.001;
		k2 = Std.parseInt(z.textBox.text) * 0.001;
		k3 = Std.parseInt(r.textBox.text) * 0.001;

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
			// trace("X:", X, "Y:", Y, "dX:", dX, "dY:", dY, "Color:", graph.graphic.bitmap.getPixel(index, Std.int(Y)));
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
		X = 0;
		Y = 0;

		dX = 0.0;
		dY = 0.0;
		dt = 1 / 60;
	}
}
