import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

typedef PlayerFrame = {
	var x:Float;
	var y:Float;
	var velocity:FlxPoint;
	var acceleration:FlxPoint;
	var time:Float;
}

typedef HoldsObj = {
	var left:Float;
	var right:Float;
	var up:Float;
	var down:Float;
	var jump:Float;
}

typedef PrevState = {
	var ?jump:Bool;
	var ?touchingFoor:Bool;
}

class Player extends FlxSprite {
	var holds:HoldsObj;
	var real:Bool;

	public var touchingFloor:Bool;

	var hurting:Bool;
	var jumping:Bool;
	var jumpTime:Float;

	var prevState:PrevState;

	static inline final JUMP_VELOCITY = 150;
	static inline final RUN_ACCELERATION = 800;
	static inline final GRAVITY = 800;
	static inline final JUMP_START_TIME = 0.16;

	public function new(real = true) {
		super(100, 300);
		if (!real) {
			alpha = 0.7;
		}

		loadGraphic(AssetPaths.pat__png, true, 48, 32);
		offset.set(15, 10);
		setSize(14, 19);

		animation.add('stand', [0]);
		animation.add('run', [0, 1, 1, 2, 2], 12);
		animation.add('in-air', [2, 3], 8);
		animation.add('setup', [4]);
		animation.add('kick', [5]);
		animation.add('shoot', [6]);
		animation.add('hurt', [7]);

		maxVelocity.set(150, 200);

		holds = {
			left: 0,
			right: 0,
			up: 0,
			down: 0,
			jump: 0
		};

		prevState = {
			jump: null,
			touchingFoor: null
		}

		hurting = false;
		jumping = false;
		jumpTime = 0.0;

		touchingFloor = false;
		this.real = real;

		drag.set(1000, 0);
	}

	override public function update(elapsed:Float) {
		if (real) {
			var vel = handleInputs(elapsed);

			if (!touchingFloor) {
				vel = vel * 2 / 3;
			}

			jumpTime -= elapsed;

			acceleration.set(vel * RUN_ACCELERATION, GRAVITY);

			var jumpPressed = FlxG.keys.anyPressed([Z, SPACE]);

			if (!prevState.jump && jumpPressed && touchingFloor) {
				jumping = true;
				jumpTime = JUMP_START_TIME;
			}

			if (jumping) {
				velocity.y = -JUMP_VELOCITY;

				if (!jumpPressed || jumpTime <= 0) {
					jumping = false;
					jumpTime = 0;
				}

				if (touchingFloor && jumpTime != JUMP_START_TIME) {
					jumping = false;
					jumpTime = 0;
				}
			}

			handlePrevState(jumpPressed);
		}

		if (flipX && acceleration.x < 0) {
			flipX = false;
		}

		if (!flipX && acceleration.x > 0) {
			flipX = true;
		}

		handleAnimation();

		touchingFloor = false;

		super.update(elapsed);
	}

	public function updatePosition(frame:PlayerFrame) {
		x = frame.x;
		y = frame.y;
		acceleration = frame.acceleration;
		velocity = frame.velocity;
	}

	function handleAnimation() {
		if (touchingFloor) {
			if (velocity.x != 0.0) {
				animation.play('run');
			} else {
				animation.play('stand');
			}

			// TODO: add pre-kick, pre-shoot stuff
		} else {
			if (hurting) {
				animation.play('hurt');
			} else {
				animation.play('in-air');
			}
		}
	}

	function handleInputs(elapsed:Float):Float {
		var vel:Float = 0.0;
		if (FlxG.keys.pressed.LEFT) {
			vel = -1;
			holds.left += elapsed;
		} else {
			holds.left = 0;
		}

		if (FlxG.keys.pressed.RIGHT) {
			vel = 1;
			holds.right += elapsed;
		} else {
			holds.right = 0;
		}

		if (FlxG.keys.pressed.UP) {
			holds.up += elapsed;
		} else {
			holds.up = 0;
		}

		if (FlxG.keys.pressed.DOWN) {
			holds.down += elapsed;
		} else {
			holds.down = 0;
		}

		if (FlxG.keys.anyPressed([Z, SPACE])) {
			holds.jump += elapsed;
		} else {
			holds.jump = 0;
		}

		if (FlxG.keys.pressed.LEFT && FlxG.keys.pressed.RIGHT) {
			if (holds.right > holds.left) {
				vel = -1;
			} else {
				vel = 1;
			}
		}

		return vel;
	}

	function handlePrevState(jumpPressed:Bool) {
		prevState = {
			jump: jumpPressed,
			touchingFoor: touchingFloor
		}
	}
}
