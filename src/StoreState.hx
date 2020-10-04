import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxBitmapFont;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.text.FlxBitmapText;
import openfl.utils.Assets;

typedef BarItem = {
	var ?bought:Bool;
	var bar:FlxSprite;
	var ?item:FlxSprite;
	var ?name:FlxBitmapText;
	var ?type:String;
	var ?cost:Int;
	var ?costDisplay:FlxBitmapText;
}

class StoreState extends FlxState {
	var level:Int;
	var lives:Int;
	var playerHealth:Int;
	var coins:Int;

	var position:Int;

	var divBars:Array<BarItem>;

	public function new(level = 0, lives:Int, playerHealth:Int, coins:Int) {
		super();

		this.level = level;
		this.lives = lives;
		this.playerHealth = playerHealth;
		this.coins = coins;
	}

	override public function create() {
		super.create();

		FlxG.mouse.visible = false;

		// camera.pixelPerfectRender = true;
		// remove vvv when going live
		FlxG.scaleMode = new PixelPerfectScaleMode();

		bgColor = 0xff181425;

		var textBytes = Assets.getText(AssetPaths.miniset__fnt);
		var XMLData = Xml.parse(textBytes);
		var fontAngelCode = FlxBitmapFont.fromAngelCode(AssetPaths.miniset__png, XMLData);

		divBars = [];

		for (i in 0...Levels.stores[level].items.length) {
			var item = Levels.stores[level].items[i];

			var bar = new FlxSprite(90, i * 45, AssetPaths.div_bar__png);
			if (i != 0) {
				bar.color = 0xff5a6988;
			}

			var text = new FlxBitmapText(fontAngelCode);
			text.setPosition(116, i * 45 + 18);
			text.text = item.name;
			text.color = 0xffffffff;
			text.letterSpacing = -1;
			text.scale.set(1, 1);

			var costText = new FlxBitmapText(fontAngelCode);
			costText.setPosition(200, i * 45 + 20);
			costText.text = item.cost + '';
			costText.color = 0xffffffff;
			costText.letterSpacing = -1;
			costText.scale.set(2, 2);

			var displayItem = new SimpleItem(98, i * 45 + 14, item.type);

			add(bar);
			add(text);
			add(costText);
			add(displayItem);

			divBars.push({
				bought: false,
				bar: bar,
				name: text,
				type: item.type,
				item: displayItem,
				cost: item.cost,
				costDisplay: costText
			});
		}

		var text = new FlxBitmapText(fontAngelCode);
		text.setPosition(132, 155);
		text.text = 'NEXT LEVEL';
		text.color = 0xffffffff;
		text.scale.set(2, 2);

		var bar = new FlxSprite(90, 3 * 45, AssetPaths.div_bar__png);
		bar.color = 0xff5a6988;

		add(text);
		add(bar);

		divBars.push({
			bar: bar
		});
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		move();

		if (FlxG.keys.anyJustPressed([SPACE, ENTER])) {
			purchase();
		}
	}

	function move() {
		var moved = false;
		if (FlxG.keys.justPressed.DOWN) {
			if (position == 3) {
				position = 0;
			} else {
				position++;
			}

			moved = true;
		}

		if (FlxG.keys.justPressed.UP) {
			if (position == 0) {
				position = 3;
			} else {
				position--;
			}

			moved = true;
		}

		if (moved) {
			for (i in 0...divBars.length) {
				if (i == position) {
					divBars[i].bar.color = 0xffffffff;
				} else {
					divBars[i].bar.color = 0xff5a6988;
				}
			}
		}
	}

	function purchase() {
		if (position == 3) {
			nextLevel();
		} else {
			var item:BarItem = divBars[position];

			if (coins < item.cost) {
				// play bad sound
			}

			if (!item.bought && coins > item.cost) {
				item.costDisplay.destroy();
				item.name.destroy();
				item.item.destroy();
				coins -= item.cost;

				switch (item.type) {
					case 'hearts':
						playerHealth += 1;
					case 'three-hearts':
						playerHealth += 3;
					case 'life':
						lives += 1;
				}
			}
		}
	}

	function nextLevel() {
		FlxG.switchState(new PlayState(level + 1, lives, playerHealth, coins));
	}
}
