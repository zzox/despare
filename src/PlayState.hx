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

typedef PlayerFrame = {
	var x:Float;
	var y:Float;
	var velocity:FlxPoint;
	var acceleration:FlxPoint;
}

class PlayState extends FlxState {
	var _darkCollision:FlxTilemap;
	var _darkForeground:FlxTilemap;
	var _playerCollision:FlxTilemap;
	var _player:Player;
	var _player2:Null<Player>;

	var _player2Inputs:Array<Player.InputObj>;
	var _player2InputsIndex:Int = 0;

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

		_player2Inputs = [];
		time = 0.0;
	}

	override public function update(elapsed:Float) {
		time += elapsed;

		_player.touchingFloor = _player.isTouching(FlxObject.DOWN);

		super.update(elapsed);

		playerInputs();

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
		_player = new Player();

		camera.follow(_player);
	}

	function playerInputs() {
		var input:Player.InputObj = {
			left: FlxG.keys.pressed.LEFT,
			right: FlxG.keys.pressed.RIGHT,
			up: FlxG.keys.pressed.UP,
			down: FlxG.keys.pressed.DOWN,
			jump: FlxG.keys.anyPressed([SPACE, Z]),
			time: time
		};

		_player.changeInputs(input);

		_player2Inputs.push(input);

		if (_player2 != null) {
			var nextIndex:Int = _player2InputsIndex + 1;

			if (_player2Inputs[nextIndex].time <= time) {
				_player2.changeInputs(_player2Inputs[nextIndex]);
				_player2InputsIndex++;
			} else {
				trace('bad!!!');
			}
		}

		if (FlxG.keys.justPressed.A) {
			trace('new player here!!!');
			_player2 = new Player(true);
			time = 0;
			add(_player2);
		}
	}
}
