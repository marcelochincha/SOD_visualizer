import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.ui.FlxInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Input extends FlxTypedGroup<FlxObject>
{
	public var textBox:FlxInputText;

	var x10:FlxSprite;
	var textLabel:FlxText;

	override public function new(label:String, x:Float, y:Float):Void
	{
		super();

		textLabel = new FlxText(x, y - 1, 100, label);
		textLabel.setFormat(AssetPaths.font__ttf, 8, FlxColor.WHITE);

		textBox = new FlxInputText(x + textLabel.width + 2, y, 36, "", 13);
		textBox.setFormat(AssetPaths.numfont__ttf, 16, FlxColor.BLACK);

		textBox.maxLength = 5;
		textBox.text = "1000";

		x10 = new FlxSprite(x + textLabel.width + 2 + textBox.width + 2, y + 2);
		x10.loadGraphic(AssetPaths.x10__png);

		add(x10);
		add(textLabel);
		add(textBox);
	}
}
