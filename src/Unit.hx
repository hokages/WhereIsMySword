package ;
import flash.display.Bitmap;
import flash.display.Sprite;
import openfl.Assets;

/**
 * ...
 * @author Al
 */
class Unit extends Collidable
{	
	
	public var monstersOut:Int;
	public var hp:Int;
	public var hpMax:Int;
	public var movespeed:Float;
	var dx:Float;
	var dy:Float;
	public var unitType:String;
	var cooldown:Int;
	public var attackSpeed:Int;
	public var bmp:Bitmap;
	public var spriteDX:Float;
	public var spriteDY:Float;
	public var charge:Int;
	public var bonus:String;
	public var tail:Sprite;
	public var tailBmp:Array<Bitmap>;
	public var shadow:Bitmap;
	public var animationBmp:Array<Bitmap>;
	
	//AI stuff
	public var prevTile:Tile; 
	public var bored:Bool;
	public var aiAngle:Float;
	
	public function new() 
	{
		super();		
		dx = 0;
		dy = 0;
		type = "unit";
		unitType = "default";
		hp = hpMax;
		attackSpeed = 60;
		cooldown = 0;
		dmg = 0;
		bmp = null;
		source = null;
		spriteDX = 0;
		spriteDY = 0;
		charge = 0;
		bonus = null;
		tail = null;
		tailBmp = new Array<Bitmap>();
		tailState = 0;
		shadow = null;
		animationBmp = new Array<Bitmap>();
		prevTile = null;
		bored = false;
	}
	
	public function moveDir(angle:Float) {
		dx = movespeed * Math.cos(angle);
		dy = movespeed * Math.sin(angle);
	}
	
	override
	public function tick() {
		if ( Main.framesPassed % 15 == 0 )	{
			if ( unitType == "shakal" ) {
				if ( animState == 0 ) {
					setAnimTo(1);
				} else {
					setAnimTo(0);
				}
			}
		}
		if ( Main.framesPassed % 15 == 0 )	updateTail();
		if ( charge > 0 ) {
			chargeAdd( -1);			
		}
		if ( animState != 0 ) {
			if ((this != Main.player) && (this.unitType != "shakal") && ( charge <= 0 )) {
				resetAnim();
			}
		}
		if ( cooldown > 0 ) --cooldown;
		if ( canMoveToX(x+dx)) {
			x += dx;
			dx = 0.9 * dx;
		} else {
			dx = 0;
		}
		if ( canMoveToY(y+dy)) {
			y += dy;		
			dy = 0.9 * dy;		
		} else {
			dy = 0;
		}
		if ( this == Main.player ) {
			if (( Math.abs(dx) > 0.3 ) || ( Math.abs(dy) > 0.3 )) {
				if ( Main.framesPassed % 5 == 0 ) {
					updateAnim();
				}			
			} else {
				resetAnim();
			}
		}
	}
	
	public function draw() {
		graphics.clear();		
		if ( bmp != null ) {
			bmp.x = spriteDX;
			bmp.y = spriteDY;
			addChild(bmp);
		} else {
			graphics.beginFill(0xffffff);
			graphics.drawRect(0,0,this.sizeX,this.sizeY);
			graphics.endFill();
		}
		if ( shadow != null ) {
			addChild(shadow);
			shadow.y = sizeY + 8;
		}
		//graphics.beginFill(0xffffff);
		//graphics.drawRect(0,0,this.sizeX,this.sizeY);
		//graphics.endFill();
	}
	
	public function canMoveToX(x:Float):Bool {
		if ( x + Main.field.x < 0 ) return false;
		if ( x + Main.field.x + sizeX/2 > Main.fullStageWidth )	return false;
		return canMoveTo(x, y);
	}
	
	public function canMoveToY(y:Float):Bool {
		if ( y + Main.field.y < 0 ) return false;
		if ( y + Main.field.y + sizeY > Main.fullStageHeight )	return false;
		return canMoveTo(x, y);
	}
	
	public function canMoveTo(x:Float, y:Float):Bool {
		if ( flying )	return true;
		return Main.getTileAt(x+sizeX/2,y+sizeY).pathable;
	}
	
	override
	public function push(angle:Float, dist:Float) {
		if ( immovable )	return;
		if ( canMoveToX(x + dist * Math.cos(angle))) {
			x += dist * Math.cos(angle);
		}
		if ( canMoveToY(y + dist * Math.sin(angle))) {
			y += dist * Math.sin(angle);
		}
	}
	
	public function shoot(angle:Float) {			
		if ( cooldown <= 0 ) {
			chargeAdd(2);
			if ( charge >= 10 ) {
				setAnimTo(2);
			} else if ( charge >= 5 ) {
				setAnimTo(1);
			} else {
				setAnimTo(0);
			}
			if ( charge >= 15 ) {
			var projType:ProjectileType = null;
			if ( unitType == "default" ) {
				projType = Main.projMeeleCrescent;
			}
			if ( unitType == "ranged" ) {
				projType = Main.projRangedSmall;
			}
			if ( unitType == "biggun" ) {
				projType = Main.projRangedBig;
			}
			var proj:Projectile = new Projectile(projType);
			proj.setAngle(angle);
			Main.field.addChild(proj);
			proj.x = this.x + this.sizeX / 2;
			proj.y = this.y + this.sizeY / 2;
			Main.collidables.push(proj);
			proj.source = this;
			cooldown = attackSpeed;
			charge = 0;
			}
		}
	}
	
	function chargeAdd(val:Int) {
		charge += val;
	}
	
	override
	public function takeDamage(dmg:Int) {
		if ( dmg > 0 ) {
			hp -= dmg;			
			if ( this == Main.player ) {
				Main.drawHearts();
				var soundfx1 = Assets.getSound("audio/player_hit.wav");
				soundfx1.play();
			}
			if ( hp <= 0 ) {
				kill();
			}
		}
	}
	
	public function heal(val:Int) {		
		if (( this == Main.player ) && (hp<hpMax)) {
			var soundfx1 = Assets.getSound("audio/hp_up.wav");
			soundfx1.play();			
		}		
		this.hp += val;
		if ( hp > hpMax ) {
			hp = hpMax;
		}
		Main.drawHearts();
	}
	
	public function kill() {
		if ( Main.lifesteal ) {
			Main.player.heal(1);
		}
		if ( source != null ) {
			--source.monstersOut;
		}
		Main.enemies.remove(this);
		new Corpse(this);
		if ( this.parent == Main.field ) {
			destroy();		
		}		
		if ( Main.enemies.length <= 0 ) {
			if ( Main.player.hp > 0 ) {
				Main.sword.changePattern("boss");
			}
		}
		hp = 0;
		if ( this == Main.player ) {
			Main.pauseGame(Main.textDefeat);
		}
	}
	
	override
	public function checkCollizion(other:Collidable):Bool {
		if ((other == this.source) || (this == other.source))	return false;
		if (( Math.abs(this.x + this.sizeX/2 - other.x - other.sizeX/2) < (this.sizeX / 2 + other.sizeX / 2)) &&
			( Math.abs(this.y - other.y) < (this.sizeY / 2 + other.sizeY / 2)))	return true;
		return false;
	}
	
	function safeTileAt(x:Int, y:Int):Tile {
		if (( x < 0) || (y < 0) || (x >= Main.mapsizeX) || (y >= Main.mapsizeY)) {
			return Main.tileAir;
		} else {
			return Main.tilemap[x][y];
		}
	}
	
	public function activateBonus() {
		if ( bonus != null ) {			
			if ( bonus == "build" ) {
				var mx:Int = Main.getTileAt(x + sizeX / 2, y + sizeY).mapX;				
				var my:Int = Main.getTileAt(x + sizeX / 2, y + sizeY).mapY;
				safeTileAt(mx+1,my).buildGround();
				safeTileAt(mx+1,my+1).buildGround();
				safeTileAt(mx + 1,my - 1).buildGround();
				safeTileAt(mx-1,my).buildGround();
				safeTileAt(mx-1,my+1).buildGround();
				safeTileAt(mx-1,my-1).buildGround();
				safeTileAt(mx,my+1).buildGround();
				safeTileAt(mx, my - 1).buildGround();
				var soundfx1 = Assets.getSound("audio/bonus_build.wav");
				soundfx1.play();
			}
			if ( bonus == "lifesteal" ) {
				Main.lifeStealOn();
				var soundfx1 = Assets.getSound("audio/bonus_vamp.wav");
				soundfx1.play();
			}
			if ( bonus == "bomb" ) {
				var centerX:Float = Main.getTileAt(this.x + this.sizeX /2,this.y + this.sizeY /2).x + Main.tilesize /2;
				var centerY:Float = Main.getTileAt(this.x + this.sizeX /2,this.y + this.sizeY /2).y + Main.tilesize /2;
				var offset:Float;
				var angle:Float;
				var spd:Float;
				Main.explosionX = centerX;
				Main.explosionY = centerY;
				Main.explosionProgress = 6;
				for ( i in 0...128 ) {
					//offset = Main.tilesize * Math.random() * 0.5;
					offset = 0;
					angle = (i / 128 ) * Math.PI * 2;
					//spd = (0.03 + i * 0.06 / 64) * Main.tilesize;
					spd = (0.18) * Main.tilesize;
					Main.field.addChild(ExpandingParticle.getParticle(centerX + offset * Math.cos(angle), centerY + offset * Math.sin(angle),
															0xff0000 , 2, 30, 0, 0, spd * Math.cos(angle), spd * Math.sin(angle)));
				}
				for ( c in Main.collidables ) {
					if ((c.type == "bullet") && (c != Main.sword) && ( c.distance(c.x, c.y, centerX - Main.tilesize / 2, centerY - Main.tilesize / 2) < Main.tilesize * 5 )) {
						c.destroy();
					}					
				}
				for ( e in Main.enemies ) {
					if (e.distance(e.x, e.y, centerX - Main.tilesize / 2, centerY - Main.tilesize / 2) < Main.tilesize * 4 ) {
						e.kill();
					}					
				}
				var mx:Int = Main.getTileAt(x + sizeX / 2, y + sizeY).mapX;				
				var my:Int = Main.getTileAt(x + sizeX / 2, y + sizeY).mapY;
				safeTileAt(mx+1,my).explosionDamage();
				safeTileAt(mx+1,my+1).explosionDamage();
				safeTileAt(mx + 1,my - 1).explosionDamage();
				safeTileAt(mx-1,my).explosionDamage();
				safeTileAt(mx-1,my+1).explosionDamage();
				safeTileAt(mx-1,my-1).explosionDamage();
				safeTileAt(mx,my+1).explosionDamage();
				safeTileAt(mx,my-1).explosionDamage();
				safeTileAt(mx+2,my-1).explosionDamage();
				safeTileAt(mx-2,my-1).explosionDamage();
				safeTileAt(mx+2,my+1).explosionDamage();
				safeTileAt(mx-2,my+1).explosionDamage();
				safeTileAt(mx+2,my).explosionDamage();
				safeTileAt(mx - 2, my).explosionDamage();
				safeTileAt(mx,my+2).explosionDamage();
				safeTileAt(mx,my-2).explosionDamage();
				safeTileAt(mx+1,my-2).explosionDamage();
				safeTileAt(mx+1,my+2).explosionDamage();
				safeTileAt(mx-1,my+2).explosionDamage();
				safeTileAt(mx - 1, my - 2).explosionDamage();				
				var soundfx1 = Assets.getSound("audio/bonus_expl.wav");
				soundfx1.play();
			}
			if ( bonus == "heal" ) {
				Main.healOn();
				var soundfx1 = Assets.getSound("audio/bonus_hp.wav");
				soundfx1.play();
			}
			Main.bonusIcon.visible = false;
			bonus = null;
		}
	}
	
	var tailState:Int;
	public function updateTail() {
		if ( tail != null ) {
			if (tail.numChildren > 0)	tail.removeChildAt(0);
			tail.addChild(tailBmp[tailState]);
			++tailState;
			if ( tailState > 3 ) 	tailState = 0;
		}
	}
	
	var animState:Int = 1;
	public function resetAnim() {
		setAnimTo(0);
		//animState = 0;
		//updateAnim();
	}
	
	public function updateAnim() {
		setAnimTo(animState);
		++animState;
		if ( animState >= animationBmp.length)	animState = 0;
	}
	
	public function setAnimTo(anim:Int) {
		if ( animationBmp.length == 0 ) {
			return;
		}
		animState = anim;		
		if ( bmp != null ) {
			removeChild(bmp);
		}
		if ( animationBmp[anim] != null ) {
			bmp = animationBmp[anim];
			addChild(bmp);
			bmp.x = spriteDX;
			bmp.y = spriteDY;
		}
	}

}