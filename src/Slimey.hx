import flixel.FlxObject;
import flixel.FlxSprite;

class Slimey extends FlxSprite {
	// TODO: move to globals
	static inline final GRAVITY = 800;
	static inline final BASE_VELOCITY = 100;
	static inline final HURT_TIME = 0.7;
	static inline final DEAD_TIME = 1.0;

	public var hurtTime:Float;

	var hurting:Bool;

	var direction:String;
	var level:Int;
	var _health:Int;

	public var deadTime:Float;

	var HURT_FLASHES:Array<Int> = [0, 1, 1, 0, 1, 1];
	var hurtFlashIndex:Int = 0;

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
		hurtTime = 0;
		deadTime = 0;
	}

	override public function update(elapsed:Float) {
		if (deadTime > 0) {
			color = 0x000000;
			deadTime -= elapsed;
			alpha = deadTime / DEAD_TIME;
		}

		hurtTime -= elapsed;

		acceleration.y = GRAVITY;

		if (flipX && velocity.x < 0) {
			flipX = false;
		}

		if (!flipX && velocity.x > 0) {
			flipX = true;
		}

		if (hurting) {
			if (isTouching(FlxObject.DOWN)) {
				velocity.x = 0;
			}

			if (deadTime == 0.0) {
				alpha = HURT_FLASHES[hurtFlashIndex];
				hurtFlashIndex++;
				if (hurtFlashIndex == HURT_FLASHES.length) {
					hurtFlashIndex = 0;
				}

				if (hurtTime < 0) {
					hurting = false;
					hurtFlashIndex = 0;
					alpha = 1;
				}
			}
		} else {
			if (direction == 'right') {
				velocity.x = level * BASE_VELOCITY;
			} else {
				velocity.x = -level * BASE_VELOCITY;
			}
		}

		handleAnimation();

		super.update(elapsed);
	}

	function handleAnimation() {
		if (hurtTime > 0 || deadTime != 0) {
			animation.play('hurt');
		} else {
			animation.play('move');
		}
	}

	public function kickMe(foot:FlxSprite) {
		if (!hurting) {
			_health -= 1;

			if (_health == 0) {
				die();
			}
		}

		hurtTime = HURT_TIME;
		hurting = true;

		if (foot.flipX) {
			velocity.set(200, -200);
		} else {
			velocity.set(-200, -200);
		}
	}

	public function jumpMe() {
		if (!hurting) {
			_health -= 1;

			if (_health == 0) {
				die();
			}
		}

		hurting = true;
		hurtTime = HURT_TIME * 2;
		velocity.set(0, 0);
	}

	function die() {
		deadTime = DEAD_TIME;
	}
}
