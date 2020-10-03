import flixel.FlxSprite;

class Slimey extends FlxSprite {
	// TODO: move to globals
	static inline final GRAVITY = 800;
	static inline final BASE_VELOCITY = 100;

	var hurting:Bool = false;
	var direction:String;
	var level:Int;
	var _health:Int;

	public function new(x:Int, y:Int, direction:String, level:Int) {
		super(x, y);

		loadGraphic(AssetPaths.slimey__png, true, 24, 24);
		animation.add('move', [0, 0, 1], 10);
		animation.add('hurt', [2]);

		setSize(18, 11);
		offset.set(4, 9);

		// max velocity and drag

		this.direction = direction;
		this.level = level;
		_health = level + 1;
	}

	override public function update(elapsed:Float) {
		acceleration.y = GRAVITY;

		if (flipX && velocity.x < 0) {
			flipX = false;
		}

		if (!flipX && velocity.x > 0) {
			flipX = true;
		}

		if (direction == 'right') {
			velocity.x = level * BASE_VELOCITY;
		} else {
			velocity.x = -level * BASE_VELOCITY;
		}

		handleAnimation();

		super.update(elapsed);
	}

	function handleAnimation() {
		if (hurting) {
			animation.play('hurt');
		} else {
			animation.play('move');
		}
	}
}
