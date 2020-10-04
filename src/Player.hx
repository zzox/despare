import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFilterFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

typedef PlayerFrame = {
	var x:Float;
	var y:Float;
	var velocity:FlxPoint;
	var acceleration:FlxPoint;
	var time:Float;
	var kickingTime:Float;
	var hurtTime:Float;
	var hurting:Bool;
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

	public var hurting:Bool;
	public var hurtTime:Float;

	var jumping:Bool;
	var jumpTime:Float;

	public var _health:Int;

	public var deadTime:Float;

	public var kickingTime:Float;
	public var foot:FlxSprite;

	var _scene:PlayState;

	static inline final JUMP_VELOCITY = 150;
	static inline final RUN_ACCELERATION = 800;
	static inline final HIT_JUMP_DISTANCE = 10;
	static inline final GRAVITY = 800;
	static inline final JUMP_START_TIME = 0.16;
	static inline final PRE_KICK = 0.00;
	static inline final KICK_TIME = 0.3;
	static inline final HURT_TIME = 1.0;
	static inline final REALLY_HURT = 0.2;
	public static inline final DEAD_TIME = 1.0;

	var HURT_FLASHES:Array<Int> = [0, 1, 1, 0, 1, 1];
	var REALLY_HURT_FLASHES:Array<Int> = [0, 0, 1, 1, 1, 1];
	var hurtFlashIndex:Int = 0;

	public function new(x:Int, y:Int, real, scene:PlayState, _health:Int) {
		super(x, y);

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

		foot = new FlxSprite(x, y);
		foot.visible = false;
		// foot.makeGraphic(16, 16, FlxColor.GREEN);
		foot.setSize(16, 16);

		handleFoot();

		maxVelocity.set(150, 200);

		holds = {
			left: 0,
			right: 0,
			up: 0,
			down: 0,
			jump: 0
		};

		hurting = false;
		jumping = false;
		jumpTime = 0.0;
		kickingTime = 0.0;
		deadTime = 0.0;
		this._health = _health;

		trace('this._health');
		trace(_health);
		trace(this._health);

		touchingFloor = false;
		this.real = real;
		_scene = scene;

		drag.set(1000, 0);
	}

	override public function update(elapsed:Float) {
		if (deadTime > 0) {
			deadTime -= elapsed;
			velocity.set(0, 0);
			acceleration.set(0, 0);
			color = 0x000000;
			animation.play('hurt');
			super.update(elapsed);

			if (!real) {
				alpha = deadTime / DEAD_TIME * 0.7;
			}
			return;
		}

		var reallyHurt = hurtTime > HURT_TIME - REALLY_HURT;
		if (hurting) {
			if (reallyHurt) {
				alpha = HURT_FLASHES[hurtFlashIndex];
			} else {
				alpha = REALLY_HURT_FLASHES[hurtFlashIndex];
			}

			hurtFlashIndex++;
			if (hurtFlashIndex == HURT_FLASHES.length) {
				hurtFlashIndex = 0;
			}

			// reset
			if (hurtTime < 0) {
				hurting = false;
				hurtFlashIndex = 0;
				alpha = 1;
			}

			if (!real && alpha == 1) {
				alpha = 0.7;
			}
		}

		if (real) {
			var vel = handleInputs(elapsed);

			if (!touchingFloor) {
				vel = vel * 2 / 3;
			}

			if ((kickingTime > 0 && touchingFloor) || reallyHurt) {
				vel = 0;
			}

			if (!reallyHurt /* || (hurting && vel == 0)*/) {
				acceleration.set(vel * RUN_ACCELERATION, GRAVITY);
			}

			hurtTime -= elapsed;
			jumpTime -= elapsed;
			kickingTime -= elapsed;

			var jumpPressed = FlxG.keys.anyJustPressed([Z, SPACE]);
			var kickPressed = FlxG.keys.anyJustPressed([X, TAB]);

			if (!reallyHurt) {
				if (jumpPressed && touchingFloor && kickingTime < 0) {
					jumping = true;
					jumpTime = JUMP_START_TIME;
				}

				if (jumping) {
					velocity.y = -JUMP_VELOCITY;

					if (!FlxG.keys.anyPressed([Z, SPACE]) || jumpTime <= 0 || (touchingFloor && jumpTime != JUMP_START_TIME)) {
						jumping = false;
						jumpTime = 0;
					}
				}

				if (kickPressed && kickingTime < 0) {
					kickingTime = KICK_TIME;
				}
			}
		} else {
			if (deadTime < 0) {
				return;
			}
		}

		if (flipX && acceleration.x < 0) {
			flipX = false;
		}

		if (!flipX && acceleration.x > 0) {
			flipX = true;
		}

		handleFoot();
		handleAnimation();

		touchingFloor = false;

		super.update(elapsed);
	}

	public function updatePosition(frame:PlayerFrame) {
		x = frame.x;
		y = frame.y;
		acceleration = frame.acceleration;
		velocity = frame.velocity;
		kickingTime = frame.kickingTime;
		hurtTime = frame.hurtTime;
		hurting = frame.hurting;
	}

	function handleFoot() {
		if (flipX) {
			// to carry over to hit calls
			foot.flipX = true;
			foot.setPosition(x + 18, y - 2);
		} else {
			foot.flipX = false;
			foot.setPosition(x - 16, y - 2);
		}

		if (kickingTime > 0 && kickingTime < KICK_TIME - PRE_KICK) {
			// LATER: combine these
			FlxG.overlap(_scene._slimeys, foot, hurtSlimey);
		}
	}

	public function hurtBySlimey(enemy:Slimey, p:Player) {
		if (real && (enemy.hurtTime > 0 || hurtTime > 0)) {
			return;
		}

		var hitJump:Float = enemy.y - p.y;
		if (Math.abs((p.x + (p.width / 2)) - (enemy.x + (enemy.width / 2))) < HIT_JUMP_DISTANCE
			&& hitJump > 10
			&& hitJump < 20
			&& p.velocity.y > 0) {
			enemy.jumpMe();
			if (p.real) {
				velocity.set(velocity.x, -maxVelocity.y);
			}
			return;
		}

		if (!p.real) {
			return;
		}

		if (enemy.velocity.x < 0) {
			velocity.set(-maxVelocity.x, -maxVelocity.y);
		} else if (enemy.velocity.x > 0) {
			velocity.set(maxVelocity.x, -maxVelocity.y);
		} else {
			velocity.set(0, -maxVelocity.y);
		}

		hurting = true;
		hurtTime = HURT_TIME;

		_health -= 1;
		trace('player health');
		trace(_health);

		if (_health == 0) {
			deadTime = DEAD_TIME;
			if (real) {
				_scene.killLevel();
			}
		}
	}

	function hurtSlimey(slimey:Slimey, t:Player) {
		slimey.kickMe(t);
	}

	function handleAnimation() {
		if (kickingTime > 0) {
			if (kickingTime < KICK_TIME - PRE_KICK) {
				animation.play('kick');
			} else {
				animation.play('setup');
			}

			return;
		}

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
}
