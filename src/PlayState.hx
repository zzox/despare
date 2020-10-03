import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.math.FlxPoint;
import flixel.system.scaleModes.PixelPerfectScaleMode;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState {
	var _darkCollision:FlxTilemap;
	var _darkForeground:FlxTilemap;
	var _playerCollision:FlxTilemap;
	var _player:Player;
	var _player2:Null<Player>;

	var _player2Frames:Array<Player.PlayerFrame>;
	var _player2FramesIndex:Int = 0;

	var time:Float;

	override public function create() {
		super.create();

		FlxG.mouse.visible = false;

		// camera.pixelPerfectRender = true;
		// remove vvv when going live
		FlxG.scaleMode = new PixelPerfectScaleMode();

		bgColor = 0xffc0cbdc;

		createMap();
		createEntities();

		add(_darkCollision);
		add(_player);
		add(_darkForeground);

		time = 0.0;
		_player2Frames = [];
	}

	override public function update(elapsed:Float) {
		time += elapsed;

		_player.touchingFloor = _player.isTouching(FlxObject.DOWN);

		super.update(elapsed);

		playerFrames();

		FlxG.collide(_darkCollision, _player);
		FlxG.collide(_playerCollision, _player);

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
		_darkCollision.alpha = 1;

		_darkForeground = new FlxTilemap();
		_darkForeground.loadMapFromArray(cast(map.getLayer('dark-foreground'), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.tiles__png,
			map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		_darkForeground.alpha = 1;
		_darkForeground.setPosition(0, -4);

		_playerCollision = new FlxTilemap();
		_playerCollision.loadMapFromArray(cast(map.getLayer('dark-foreground'), TiledTileLayer).tileArray, map.width, map.height, AssetPaths.tiles__png,
			map.tileWidth, map.tileHeight, FlxTilemapAutoTiling.OFF, 1, 1, 1);

		// set world bounds
		// set camera bounds

		camera.setScrollBoundsRect(0, 0, 640, 360);
		FlxG.worldBounds.set(0, 0, 640, 360);
	}

	function createEntities() {
		_player = new Player(true);

		camera.follow(_player);
	}

	function playerFrames() {
		_player2Frames.push({
			x: _player.x,
			y: _player.y,
			acceleration: _player.acceleration,
			velocity: _player.velocity,
			time: time
		});

		if (_player2 != null) {
			var nextIndex:Int = _player2FramesIndex + 1;

			if (_player2Frames[nextIndex].time <= time) {
				_player2.updatePosition(_player2Frames[nextIndex]);
				_player2FramesIndex++;
			} else {
				trace('bad!!!');
			}
		}

		if (FlxG.keys.justPressed.A) {
			trace('new player here!!!');
			_player2 = new Player(false);
			time = 0;
			add(_player2);
		}
	}
}
