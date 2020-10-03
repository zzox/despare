import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tile.FlxTileblock;
import flixel.util.FlxColor;

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

class Player extends FlxSprite {
	var holds:HoldsObj;
	var real:Bool;

	public var touchingFloor:Bool;

	static inline final JUMP_VELOCITY = 200;
	static inline final RUN_ACCELERATION = 800;
	static inline final GRAVITY = 800;

	public function new(real = true) {
		super(100, 300);
		makeGraphic(10, 12, real ? FlxColor.GREEN : FlxColor.RED);
		setSize(10, 12);

		maxVelocity.set(120, 200);

		holds = {
			left: 0,
			right: 0,
			up: 0,
			down: 0,
			jump: 0
		};

		this.real = real;
		touchingFloor = false;

		drag.set(1000, 0);
	}

	override public function update(elapsed:Float) {
		if (real) {
			var vel = updateInputs(elapsed);

			if (!touchingFloor) {
				vel = vel * 2 / 3;
			}

			acceleration.set(vel * RUN_ACCELERATION, GRAVITY);

			if (FlxG.keys.anyPressed([Z, SPACE]) && touchingFloor) {
				velocity.y = -JUMP_VELOCITY;
			}
		}

		touchingFloor = false;

		super.update(elapsed);
	}

	public function updatePosition(frame:PlayerFrame) {
		x = frame.x;
		y = frame.y;
		acceleration = frame.acceleration;
		velocity = frame.velocity;
	}

	function updateInputs(elapsed:Float):Float {
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
}
