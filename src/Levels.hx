typedef Store = {
	var items:Array<StoreItems>;
}

typedef StoreItems = {
	var name:String;
	var type:String;
	var cost:Int;
}

class Levels {
	public static var levels:Array<Dynamic> = [
		{
			text: 'World One',
			required: 10,
			map: AssetPaths.one__tmx
		}
	];

	public static var stores:Array<Store> = [
		{
			items: [
				{
					name: 'Heart',
					type: 'heart',
					cost: 5
				},
				{
					name: 'Heart',
					type: 'heart',
					cost: 5
				},
				{
					name: 'Three hearts',
					type: 'three-hearts',
					cost: 10
				}
			]
		}
	];
}
