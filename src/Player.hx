import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tile.FlxTileblock;
import flixel.util.FlxColor;

typedef InputObj = {
	var left:Bool;
	var right:Bool;
	var up:Bool;
	var down:Bool;
	var jump:Bool;
	var ?time:Float;
}

typedef HoldsObj = {
	var left:Float;
	var right:Float;
	var up:Float;
	var down:Float;
	var jump:Float;
}

class Player extends FlxSprite {
	var inputs:InputObj;
	var holds:HoldsObj;

	public var touchingFloor:Bool;

	static inline final JUMP_VELOCITY = 200;
	static inline final RUN_ACCELERATION = 800;
	static inline final GRAVITY = 800;

	public function new(?fake:Bool) {
		super(100, 300);
		makeGraphic(10, 12, fake ? FlxColor.GREEN : FlxColor.RED);
		setSize(10, 12);

		maxVelocity.set(120, 200);

		inputs = {
			left: false,
			right: false,
			up: false,
			down: false,
			jump: false
		};

		holds = {
			left: 0,
			right: 0,
			up: 0,
			down: 0,
			jump: 0
		};

		touchingFloor = false;

		drag.set(1000, 0);
	}

	override public function update(elapsed:Float) {
		updateHolds(elapsed);

		var vel:Float = 0.0;
		if (inputs.right) {
			vel = 1;
		}

		if (inputs.left) {
			vel = -1;
		}

		if (inputs.left && inputs.right) {
			if (holds.right > holds.left) {
				vel = -1;
			} else {
				vel = 1;
			}
		}

		if (!touchingFloor) {
			vel = vel * 2 / 3;
		}

		acceleration.set(vel * RUN_ACCELERATION, GRAVITY);

		if (inputs.jump && touchingFloor) {
			velocity.y = -JUMP_VELOCITY;
		}

		touchingFloor = false;

		super.update(elapsed);

		x = Math.round(x);
		y = Math.round(y);
	}

	public function changeInputs(inputs:InputObj) {
		this.inputs = inputs;
	}

	function updateHolds(elapsed:Float) {
		if (inputs.left) {
			holds.left += elapsed;
		} else {
			holds.left = 0;
		}

		if (inputs.right) {
			holds.right += elapsed;
		} else {
			holds.right = 0;
		}

		if (inputs.up) {
			holds.up += elapsed;
		} else {
			holds.up = 0;
		}

		if (inputs.down) {
			holds.down += elapsed;
		} else {
			holds.down = 0;
		}

		if (inputs.jump) {
			holds.jump += elapsed;
		} else {
			holds.jump = 0;
		}
	}
}
