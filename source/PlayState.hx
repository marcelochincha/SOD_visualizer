package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Timer;
import haxe.macro.Expr.Case;
import lime.tools.Platform;
import openfl.sensors.Accelerometer;

class PlayState extends FlxState
{
	var C:Float;
	var S:Float;
	var g:Float;
	var k:Float;
	var viewZoom:FlxPoint;

	var canvas:FlxSprite;
	var graph:FlxSprite;
	var title:FlxText;

	var ok:FlxButton;

	var vbox:Input;
	var tbox:Input;
	var kbox:Input;
	var gbox:Input;
	var dtbox:Input;
	var zoomBox:Input;

	var graphDrawer:FlxTimer;

	var MODE = 1;

	final TO_RAD = Math.PI / 180;

	override public function create()
	{
		super.create();

		title = new FlxText(0, 2, FlxG.width, "Second order dynamics - Proyectile simulation");
		title.setFormat("assets/data/font.ttf", 8);
		add(title);

		canvas = new FlxSprite(0, title.height);
		canvas.makeGraphic(FlxG.width, 200, 0xffffffff, true);

		graph = new FlxSprite(0, title.height);
		graph.makeGraphic(FlxG.width, Std.int(canvas.height), FlxColor.TRANSPARENT, true);
		graph.alpha = 1;

		ok = new FlxButton(250, title.height + canvas.height + 10, "", onClick);
		ok.loadGraphic(AssetPaths.ok__png, true, 56, 20);

		vbox = new Input("V:", 1, 20, title.height + canvas.height + 10);
		tbox = new Input("T:", 1, 20, (title.height + canvas.height + 10) + 25);
		kbox = new Input("K:", 0.01, 20, (title.height + canvas.height + 10) + 50);
		gbox = new Input("G:", 9.8, 20, (title.height + canvas.height + 10) + 75);

		// Add axis labels
		var xLabel = new FlxText(FlxG.width - 15, title.height + canvas.height - 25, 20, "X");
		xLabel.setFormat("assets/data/font.ttf", 8, FlxColor.RED);

		var yLabel = new FlxText(0, title.height + 10, 20, "Y");
		yLabel.setFormat("assets/data/font.ttf", 8, FlxColor.BLUE);

		// ZOOM box goes UNDER X and Y OK button
		dtbox = new Input("dt:", 0.01, ok.x, (title.height + canvas.height + 10) + 50);
		zoomBox = new Input("Zo:", 1, ok.x, (title.height + canvas.height + 10) + 75);

		graphDrawer = new FlxTimer();

		FlxG.mouse.useSystemCursor = true;

		add(vbox);
		add(tbox);
		add(kbox);
		add(gbox);
		add(dtbox);
		add(zoomBox);

		add(canvas);
		add(graph);
		add(ok);

		add(yLabel);
		add(xLabel);

		setDefaults();

		// Add lines for axis to canvas
		for (i in 0...FlxG.width)
		{
			plot(canvas, i, 0, FlxColor.RED);
			if (i % 10 == 0)
				plot(canvas, i, 1, FlxColor.RED);
		}

		// Do it vertically
		for (i in 0...Std.int(canvas.height))
		{
			plot(canvas, 0, i, FlxColor.BLUE);
			if (i % 10 == 0)
				plot(canvas, 1, i, FlxColor.BLUE);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.justPressed.ENTER)
			onClick();

		if (FlxG.keys.justPressed.T)
			MODE = 1;
		if (FlxG.keys.justPressed.G)
			MODE = 0;
	}

	// Plots a pixel at the given coordinates in the canvas sprite.
	function plot(TO_PLOT:FlxSprite, x:Float, y:Float, color:Int)
	{
		TO_PLOT.graphic.bitmap.lock();
		TO_PLOT.graphic.bitmap.setPixel32(Std.int(x), Std.int(TO_PLOT.height - y - 1), color);
		TO_PLOT.graphic.bitmap.unlock();
	}

	function onClick()
	{
		// Clear graphics graph
		graph.graphic.bitmap.fillRect(graph.graphic.bitmap.rect, FlxColor.TRANSPARENT);

		k = kbox.getValue();
		g = gbox.getValue();

		C = vbox.getValue() * Math.cos(tbox.getValue() * TO_RAD);
		S = vbox.getValue() * Math.sin(tbox.getValue() * TO_RAD);

		trace("C: " + C + " S: " + S + " k: " + k + " g: " + g); // Start draw

		var prevPoint = new FlxPoint(0, 0);

		var zoom:Float = zoomBox.getValue();
		var t:Float = 0;
		var dt:Float = dtbox.getValue();

		graphDrawer.cancel();
		graphDrawer.start(1 / 60, function(v:FlxTimer)
		{
			var currentPoint = new FlxPoint(X(t), Y(t));

			// plot(graph, currentPoint.x * (1 / (0.3125 * zoom)), currentPoint.y * (0.3125 / zoom), 0xff970000);

			// Interpolate between points
			var x:Float = prevPoint.x;
			var y:Float = prevPoint.y;

			while (x < currentPoint.x)
			{
				plot(graph, x / zoom, y / zoom, if (MODE == 1) 0xff009719 else 0xff970097);
				x += 0.05;
				y = ((currentPoint.y - prevPoint.y) / (currentPoint.x - prevPoint.x)) * (x - prevPoint.x) + prevPoint.y;
			}

			prevPoint = currentPoint;

			Sys.println("X: " + currentPoint.x + " Y: " + currentPoint.y);

			if (currentPoint.y < 0)
			{
				// trace("GOT");
				graphDrawer.cancel();
			}
			t += dt;
		}, 0);

		setDefaults();
	}

	function calculate(index:Int) {}

	function setDefaults()
	{
		viewZoom = new FlxPoint(1, 1000);
	}

	function X(t:Float)
	{
		switch (MODE)
		{
			case 0:
				return C * t;
			case 1:
				return C / k * (1 - Math.exp(-k * t));
		}
		return 0;
	}

	function Y(t:Float)
	{
		switch (MODE)
		{
			case 0:
				return S * t - ((g / 2) * t * t);
			case 1:
				return -(1 / k) * (S + (g / k)) * (Math.exp(-k * t) - 1) - (g / k) * t;
		}
		return 0;
	}
}
