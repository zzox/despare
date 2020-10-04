import Slimey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.util.helpers.FlxBounds;

typedef Spawner = {
	var spot:TiledObject;
	var time:Float;
}

class PlayState extends FlxState {
	var _darkCollision:FlxTilemap;
	var _darkForeground:FlxTilemap;
	var _playerCollision:FlxTilemap;
	var _player:Player;
	var _player2:Null<Player>;

	var _spawners:Array<Spawner>;

	public var _slimeys:FlxTypedGroup<Slimey>;

	var playerIndex:Int;
	var _framesets:Array<Array<Player.PlayerFrame>>;
	var _framesetIndexes:Array<Int>;
	var _ghosts:FlxTypedGroup<Player>;
	var _ghostFeet:FlxTypedGroup<FlxSprite>;

	var time:Float;

	var lives:Int;
	var coins:Int;
	var items:Array<String>;

	var _whiteOverlay:FlxSprite;
	var _blackOverlay:FlxSprite;

	static inline final MULTIPLIER_TIME = 16;

	public function new(?lives:Int, ?coins:Int, ?items:Array<String>) {
		super();

		if (lives == null) {
			lives = 3;
			coins = 0;
			items = [];
		} else {
			this.lives = lives;
			this.coins = lives;
			this.items = items.copy();
		}
	}

	override public function create() {
		super.create();

		FlxG.mouse.visible = false;

		// camera.pixelPerfectRender = true;
		// remove vvv when going live
		FlxG.scaleMode = new PixelPerfectScaleMode();

		camera.followLerp = 0.5;

		bgColor = 0xffc0cbdc;

		createMap();
		startLevel(true);

		time = 0.0;

		// for every new level
		playerIndex = 0;
		_framesets = [[]];
		_framesetIndexes = [];
	}

	override public function update(elapsed:Float) {
		time += elapsed;

		playerFrames();

		_player.touchingFloor = _player.isTouching(FlxObject.DOWN);

		_ghosts.forEach(ghost -> {
			ghost.touchingFloor = ghost.isTouching(FlxObject.DOWN);
		});

		handleSpawns(elapsed);

		_slimeys.forEach((slimey) -> {
			if (slimey.deadTime < 0) {
				slimey.destroy();
				var dead = _slimeys.remove(slimey, true);
				dead = null;
			}
		});

		super.update(elapsed);

		if (_player.deadTime < 0) {
			startLevel(false);
		}

		FlxG.collide(_darkCollision, _player);
		FlxG.collide(_playerCollision, _player);
		FlxG.collide(_darkCollision, _slimeys);
		FlxG.collide(_darkCollision, _ghosts);
		FlxG.collide(_playerCollision, _ghosts);
		FlxG.overlap(_slimeys, _player, _player.hurtBySlimey);
		FlxG.overlap(_slimeys, _ghosts, _player.hurtBySlimey);

		if (_player2 != null) {
			FlxG.collide(_darkCollision, _player2);
			FlxG.collide(_playerCollision, _player2);
		}
	}

	function createMap() {
		var map = new TiledMap(AssetPaths.one__tmx);

		_darkCollision = new FlxTilemap();
		_darkCollision.loadMapFromArray(cast(map.getLayer('dark-collision'), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.tiles__png,
			map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);

		_darkForeground = new FlxTilemap();
		_darkForeground.loadMapFromArray(cast(map.getLayer('dark-foreground'), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.tiles__png,
			map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		_darkForeground.setPosition(0, -4);

		_playerCollision = new FlxTilemap();
		_playerCollision.loadMapFromArray(cast(map.getLayer('player-collision'), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.tiles__png,
			map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		_playerCollision.visible = false;

		// set world bounds
		// set camera bounds

		camera.setScrollBoundsRect(32, 32, 640 - 32, 360 - 32);
		FlxG.worldBounds.set(0, 0, 640, 360);
	}

	function createEntities() {
		// MD:
		_player = new Player(232 + playerIndex * 32, 336, true, this, 3);

		camera.follow(_player);

		_ghosts = new FlxTypedGroup<Player>();
		_ghostFeet = new FlxTypedGroup<FlxSprite>();
		for (i in 0...playerIndex) {
			var g:Player = new Player(232 + playerIndex * 32, 336, false, this, 3);

			_ghosts.add(g);
			_ghostFeet.add(g.foot);
			_framesetIndexes.push(0);
		}

		_slimeys = new FlxTypedGroup<Slimey>();
		// var _battys = new FlxTypedGroup<Batty>();
	}

	function playerFrames() {
		// _player2Frames.push({
		// 	x: _player.x,
		// 	y: _player.y,
		// 	acceleration: new FlxPoint(_player.acceleration.x, _player.acceleration.y),
		// 	velocity: new FlxPoint(_player.velocity.x, _player.velocity.y),
		// 	kickingTime: _player.kickingTime,
		// 	time: time
		// });

		_framesets[playerIndex].push({
			x: _player.x,
			y: _player.y,
			acceleration: new FlxPoint(_player.acceleration.x, _player.acceleration.y),
			velocity: new FlxPoint(_player.velocity.x, _player.velocity.y),
			kickingTime: _player.kickingTime,
			hurtTime: _player.hurtTime,
			hurting: _player.hurting,
			time: time
		});

		// for loop of all indexed players below the current playerIndex
		var i = 0;
		_ghosts.forEach((ghost) -> {
			var nextIndex:Int = _framesetIndexes[i] + 1;

			if (nextIndex < _framesets[i].length) {
				if (_framesets[i][nextIndex].time <= time) {
					ghost.updatePosition(_framesets[i][nextIndex]);
					_framesetIndexes[i]++;
				} else {
					trace('bad frame');
				}
			} else {
				if (ghost.deadTime == 0) {
					ghost.deadTime = Player.DEAD_TIME;
				}

				if (ghost.visible && ghost.deadTime < 0) {
					ghost.visible = false;
				}
			}
			i++;
		});

		// if (_player2 != null) {

		// 	var nextIndex:Int = _player2FramesIndex + 1;
		// 	var nextIndex:Int = _player2FramesIndex + 1;

		// 	if (_player2Frames[nextIndex].time <= time) {
		// 		_player2.updatePosition(_player2Frames[nextIndex]);
		// 		_player2FramesIndex++;
		// 	} else {
		// 		trace('bad!!!');
		// 	}
		// }

		// if (FlxG.keys.justPressed.A) {
		// 	trace('new player here!!!');
		// 	_player2 = new Player(false, this, 1); // health doesn't matter here
		// 	time = 0;
		// 	add(_player2);
		// }
	}

	function handleSpawns(elapsed:Float) {
		for (spawner in _spawners) {
			if (spawner.time <= 0) {
				if (spawner.spot.properties.get('enemy') == 'slimey') {
					_slimeys.add(new Slimey(this, spawner.spot.x, spawner.spot.y, spawner.spot.properties.get('direction'),
						Std.parseInt(spawner.spot.properties.get('level'))));
				}

				spawner.time = Std.parseFloat(spawner.spot.properties.get('frequency'));
			}

			var elapsedMultiplier:Int = Math.floor(time / MULTIPLIER_TIME) + 1;
			trace(elapsedMultiplier);
			spawner.time -= elapsed * elapsedMultiplier;
		}
	}

	public function killLevel() {
		FlxTween.tween(_blackOverlay, {alpha: 1.0}, 0.5);
	}

	function startLevel(start:Bool) {
		if (!start) {
			_slimeys.destroy();
			_player.destroy();
			_ghosts.destroy();
			_ghostFeet.destroy();
			_blackOverlay.destroy();
			_whiteOverlay.destroy();

			// ghost/recording stuff
			playerIndex++;
			_framesets.push([]);

			lives -= 1;

			if (lives == 0) {
				gameOver();
			}
		}

		_framesetIndexes = [];

		createEntities();

		var map = new TiledMap(AssetPaths.one__tmx);

		_blackOverlay = new FlxSprite();
		_blackOverlay.makeGraphic(320, 180, 0xff181425);
		_blackOverlay.scrollFactor.set(0, 0);

		_whiteOverlay = new FlxSprite();
		_whiteOverlay.makeGraphic(320, 180, 0xffffffff);
		_whiteOverlay.scrollFactor.set(0, 0);
		_whiteOverlay.alpha = 0;

		_spawners = [];

		var s = cast(map.getLayer('spawners'), TiledObjectLayer).objects;

		s.map(item -> _spawners.push({spot: item, time: 0.0}));

		add(_darkCollision);
		add(_player);
		add(_player.foot);
		add(_ghosts);
		add(_ghostFeet);
		add(_slimeys);
		add(_darkForeground);
		add(_playerCollision);
		add(_whiteOverlay);
		add(_blackOverlay);

		time = 0;

		FlxTween.tween(_blackOverlay, {alpha: 0}, 0.5);
	}

	function nextLevel() {
		FlxG.switchState(new PlayState(lives, coins, items));
	}

	function gameOver() {
		trace('game overe!!!!!!');
		FlxG.switchState(new PlayState());
	}
}
