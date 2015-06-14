package ;
import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.MouseEvent;
import openfl.Assets;

/**
 * ...
 * @author Al
 */
class Tile extends Sprite
{

	public var pathable:Bool;
	var variation:Int;
	public var mapX:Int;
	public var mapY:Int;
	public var permanent:Bool;
	
	var period:Int;
	public var bmp:Bitmap;
	var bottom:Bitmap;
	
	var state:String;
	var destructionTimeLeft:Int;
	var nextSwitchTime:Int;
	
	var overlay:Sprite;
	
	public var bonus:Bonus;
	
	public function new(x:Int,y:Int,pathable:Bool) 
	{
		super();
		variation = 0;
		this.pathable = pathable;
		mapX = x;
		mapY = y;
		permanent = false;
		this.x = mapX * Main.tilesize;
		this.y = mapY * Main.tilesize;
		
		bmp = null;
		bottom = null;
		addEventListener(MouseEvent.CLICK, onClick);
		destructionTimeLeft = 0;
		overlay = new Sprite();
		addChild(overlay);
		this.setNo();
		nextSwitchTime = -1;
		if ( Math.random() < 0.2)	{
			nextSwitchTime = Main.framesPassed + 300 + Math.round(Math.random() * 9) * 400;
		}
		bonus = null;
	}
	
	public function onClick(e) {
		trace(mapX, mapY);
	}
	
	function fixUnit(unit:Unit):Bool {
		var px:Float = unit.x + unit.sizeX / 2;
		var py:Float = unit.y + unit.sizeY;
		var d:Float = Main.tilesize / 2;
		if ( Main.getTileAt(px + d, py).pathable ) {
			unit.x += d;
			return true;
		}
		if ( Main.getTileAt(px - d, py).pathable ) {
			unit.x -= d;
			return true;
		}
		if ( Main.getTileAt(px, py + d).pathable ) {
			unit.y += d;
			return true;
		}
		if ( Main.getTileAt(px, py - d).pathable ) {
			unit.y -= d;
			return true;
		}
		return false;
	}
	
	public function setNo() {
		alpha = 1.0;
		graphics.clear();
		overlay.graphics.clear();
		changeBmp(null);
		//graphics.beginFill(0x080808);
		//graphics.drawRect(0, 0, Main.tilesize, Main.tilesize);
		//graphics.endFill();
		pathable = false;
		state = "no";		
		if ( Main.player != null ) {
			if (Main.getTileAt(Main.player.x + Main.player.sizeX / 2, Main.player.y + Main.player.sizeY) == this ) {						
				if (!fixUnit(Main.player)) {
					Main.player.kill();
				} else {
					Main.player.takeDamage(2);
				}
			}
		}
		if ( Main.enemies != null ) {
			for (e in Main.enemies ) {
				if ( Main.getTileAt(e.x + e.sizeX / 2, e.y + e.sizeY / 2) == this ) {
					fixUnit(e);
					if ( e.unitType == "shakal" ) {
						e.takeDamage(2);
					}
				}
			}
		}
		if ( this.bonus != null ) {
			this.bonus.remove();
		}
	}
	
	public function setGround() {
		alpha = 1.0;
		graphics.clear();
		overlay.graphics.clear();
		changeBmp("ground");
		pathable = true;
		state = "ground";
	}
	
	function changeBmp(param:String) {
		if ( bmp != null ) {
			removeChild(bmp);
			bmp = null;
		}
		if ( bottom != null ) {
			removeChild(bottom);
			bottom = null;
		}
		if ( param == "ground" ) {			
			bmp = new Bitmap(Assets.getBitmapData("img/tile_ground_01.png"));
			addChildAt(bmp, 0);			
			bottom = new Bitmap(Assets.getBitmapData("img/tile_underground_01.png"));
			bottom.y = Main.tilesize;
			addChildAt(bottom, 1);
		}
	}
	
	public function tick() {
		if ( state == "ground" ) {
			if ( destructionTimeLeft > 0 ) {
				--destructionTimeLeft;
				if ( destructionTimeLeft % 2 == 0 ) {
					overlay.graphics.clear();
					overlay.graphics.beginFill(0x000000, 0.6 - Math.min(Math.max(destructionTimeLeft / 300, 0.0), 0.6));					
					overlay.graphics.drawRect(0, 0, Main.tilesize, Main.tilesize);
					overlay.graphics.endFill();					
				}
				if ( destructionTimeLeft == 90 ) {
					if ( Main.player != null ) {
						if ( Main.player.distanceOuterTo(this.x, this.y) < Main.tilesize * 4 ) {
							Main.tileDownSound.play();
						}
					}					
				}
				if ( destructionTimeLeft < 30 ) {
					y += 0.6;
				}
				if  (destructionTimeLeft == 0 ) {
					setNo();
					return;
				}
			}
			if (( Main.framesPassed >= nextSwitchTime ) && (nextSwitchTime >= 0)) {
				nextSwitchTime = Main.framesPassed + 1200;
				markForDestruction();
			}
		}
		if ( state == "no" ) {
			if (( Main.framesPassed >= nextSwitchTime ) && (nextSwitchTime >= 0)) {
				nextSwitchTime = Main.framesPassed + 900;
				markForDestruction();
			}
			if ( destructionTimeLeft > 0 ) {
				--destructionTimeLeft;
				if ( destructionTimeLeft <= 300 ) {
					if ( destructionTimeLeft >= 60 ) {
						alpha = (360 - destructionTimeLeft) / 300;
						this.scaleX = 0.5 + alpha * 0.5;
						this.scaleY = 0.5 + alpha * 0.5;
						this.x = (mapX + 0.25 * (1 - alpha)) * Main.tilesize;
						this.y = (mapY + 0.25 * (1 - alpha)) * Main.tilesize + 24;
					} else {
						alpha = 1.0;
						y -= 0.4;// * (60 - destructionTimeLeft);
					}
				} else {
					this.scaleX = 0.5;
					this.scaleY = 0.5;
					this.x = (mapX + 0.25) * Main.tilesize;
					this.y = (mapY + 0.25) * Main.tilesize;
				}
				//if ( destructionTimeLeft % 2 == 0 ) {
					//overlay.graphics.clear();
					//overlay.graphics.beginFill(0x808080, 0.8 - Math.min(Math.max(destructionTimeLeft / 300, 0.0), 0.8));
					//overlay.graphics.drawRect(0, 0, Main.tilesize, Main.tilesize);
					//overlay.graphics.endFill();
				//}
				if  (destructionTimeLeft == 0 ) {
					y = mapY * Main.tilesize;
					setGround();					
					this.scaleX = 1.0;
					this.scaleY = 1.0;
				}
			}
		}
	}
	
	public function markForDestruction() {
		if (!permanent) {
			y = mapY * Main.tilesize;
			destructionTimeLeft = 270 + Math.round(Math.random() * 60);
			if ( state == "no" ) {
				changeBmp("ground");
				alpha = 0.0;
				y = mapY * Main.tilesize + 24;
			}
		}
	}
	
	public function buildGround() {
		if (!permanent) {
			destructionTimeLeft = 0;
			y = mapY * Main.tilesize;
			if ( state != "ground" ) {
				markForDestruction();
				destructionTimeLeft = 60;
				//setGround();
				//var cp:Corpse = new Corpse(null);
				//cp.x = x;
				//cp.y = y;
				//cp.addChild(new Bitmap(Assets.getBitmapData("img/tile_ground_01.png")));
				//cp.graphics.beginFill(0x808080);
				//cp.graphics.drawRect(0, 0, Main.tilesize, 16);
				//cp.graphics.endFill();
				//cp.blendMode = BlendMode.LIGHTEN;	
				if ( nextSwitchTime == -1 ) {
					nextSwitchTime = Main.framesPassed + 300 + Math.round(Math.random() * 10) * 60;
				}
			}
		}
	}
	
	public function explosionDamage() {
		if (!permanent) {
			if ( state == "ground" ) {
				if ( nextSwitchTime > 0 ) {
					if (( nextSwitchTime - Main.framesPassed > 60 ) && (destructionTimeLeft <= 0)) {
						if ( Math.random() < 0.7 ) {
							nextSwitchTime -= 900;
						}
					}
				} else {
					if ( Math.random() < 0.4 ) {
						nextSwitchTime = Main.framesPassed + Math.round(Math.random() * 15);
					}
				}
			}
		}
	}
	
}