import flixel.FlxObject;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.ds.StringMap;
import openfl.display.Stage;

class Input extends FlxTypedGroup<FlxObject>
{
	public var textBox:FlxInputText;

	var textLabel:FlxText;

	var sign:Int = 1;

	override public function new(label:String, initalValue:Float, x:Float, y:Float):Void
	{
		super();

		textLabel = new FlxText(x, y - 1, 28, label);
		textLabel.setFormat(AssetPaths.font__ttf, 8, FlxColor.WHITE);

		textBox = new FlxInputText(x + textLabel.width + 2, y, 150, "", 13);
		textBox.setFormat(AssetPaths.numfont__ttf, 16, FlxColor.BLACK, FlxTextAlign.RIGHT);
		textBox.maxLength = 16;
		textBox.customFilterPattern = ~/[^0-9^.-]*/g;
		textBox.filterMode = FlxInputText.CUSTOM_FILTER;

		textBox.text = Std.string(initalValue);

		add(textLabel);
		add(textBox);
	}

	public function getValue():Float
	{
		return Std.parseFloat(textBox.text);
	}
}
