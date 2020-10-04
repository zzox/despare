import flixel.FlxSprite;

class SimpleItem extends FlxSprite {
	var anim:String;

	public function new(x:Int, y:Int, anim:String) {
		super(x, y);

		loadGraphic(AssetPaths.icons__png, true, 16, 16);

		animation.add('shoes', [0]);
		animation.add('life', [1]);
		animation.add('heart', [2]);
		animation.add('three-hearts', [3]);
		animation.add('mid-proj', [4]);
		animation.add('strong-proj', [5]);
		animation.add('coin', [6]);

		this.anim = anim;
	}

	override public function update(elapsed:Float) {
		animation.play(anim);
		super.update(elapsed);
	}
}
