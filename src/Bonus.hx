package ;
import flash.display.Bitmap;
import flash.display.Sprite;
import openfl.Assets;

/**
 * ...
 * @author Al
 */
class Bonus extends Sprite
{
	var type:String;
	var tile:Tile;
	public var bmpName:String;
	public static var activeBonuses:Int = 0;
	
	public function new(t:String,loc:Tile ) 
	{
		super();
		type = t;
		tile = loc;
		if ( tile.bonus != null ) {
			tile.bonus.remove();
		}
		tile.bonus = this;
		draw();
		Main.field.addChild(this);
		++activeBonuses;
	}
	
	function draw() {
		if ( type == "build" )	bmpName = "img/Bonus_B.png";
		if ( type == "lifesteal" )	bmpName = "img/Bonus_V.png";
		if ( type == "bomb" )	bmpName = "img/Bonus_E.png";
		if ( type == "heal" )	bmpName = "img/Bonus_H.png";
		if ( type == "sword" )	bmpName = "img/Bonus_Sword.png";
		//graphics.beginFill(0x00ff00);
		//graphics.drawRect(1, 1, Main.tilesize-2, Main.tilesize-2);
		//graphics.endFill();
		x = tile.x;
		y = tile.y;
		var bmp = new Bitmap(Assets.getBitmapData(bmpName));
		bmp.x = -27;
		bmp.y = -27;
		addChild(bmp);
	}
	
	public function pickup() {
		if (( type == "build" )
			|| ( type == "lifesteal" )
			|| ( type == "bomb" )
			|| ( type == "heal" )) {
			Main.player.bonus = type;
			if (Main.bonusIcon.numChildren > 0)	Main.bonusIcon.removeChildAt(0);
			Main.bonusIcon.addChild(new Bitmap(Assets.getBitmapData(bmpName)));
			Main.bonusIcon.visible = true;
		}
		if (type == "sword" ) {
			++Main.swordCharges;
			Main.sword.scaleX = 1.0 + 0.2 * Main.swordCharges;
			Main.sword.scaleY = 1.0 + 0.15 * Main.swordCharges;
			Main.sword.dmg = 2 + Math.ceil(Main.swordCharges/2);
			Main.sword.collizionPoints[3 + Main.swordCharges] = 14 + 8 * Main.swordCharges;
			Main.projTypeSword.hbRad = 9 + Main.swordCharges;
		}
		this.remove();	
		var soundfx1 = Assets.getSound("audio/bonus_pickup.wav");
		soundfx1.play();
	}
	
	public function remove() {
		Main.field.removeChild(this);
		tile.bonus = null;		
		--activeBonuses;
	}
	
	static function checkTile(x:Int, y:Int):Bool {
		if ( Main.getTileAt(x*Main.tilesize, y*Main.tilesize) == Main.tileAir )	return false;		
		if ( Main.tilemap[x][y].pathable == false)	return false;
		return (Main.tilemap[x][y].bonus == null);
	}
	
	public static function placeBonus(tp:String, x:Int, y:Int ) {		
		var tile:Tile = null;
		if ( checkTile(x,y) ) {
			tile = Main.tilemap[x][y];
		}
		var dx:Int = 0;
		var dy:Int = 0;
		var t:Int = 0;
		while (!checkTile(x + dx, y + dy)) {			
			if (t == 0) {
				++dx;
			}
			if ( t == 1 ) {
				++dy;
			}
			if ( checkTile(x + dx, y + dy))	{
				tile = Main.tilemap[x + dx][y + dy];
				break;
			}
			if ( checkTile(x - dx, y + dy))	{
				tile = Main.tilemap[x - dx][y + dy];
				break;
			}
			if ( checkTile(x - dx, y - dy))	{
				tile = Main.tilemap[x - dx][y - dy];
				break;
			}
			if ( checkTile(x + dx, y - dy))	{
				tile = Main.tilemap[x + dx][y - dy];
				break;
			}
			if ( checkTile(x + dx, y))	{
				tile = Main.tilemap[x + dx][y];
				break;
			}
			if ( checkTile(x - dx, y))	{
				tile = Main.tilemap[x - dx][y];
				break;
			}
			if ( checkTile(x, y+dy))	{
				tile = Main.tilemap[x][y + dy];				
				break;
			}
			if ( checkTile(x, y-dy))	{
				tile = Main.tilemap[x][y - dy];				
				break;
			}
			++t;
			if ( t > 1 ) {
				t = 0;
			}
			if (( dx > Main.mapsizeX ) || (dy > Main.mapsizeY)) {
				return;
			}
		}
		new Bonus(tp, tile);
	}
}