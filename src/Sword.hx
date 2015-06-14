package ;
import flash.display.Sprite;
import openfl.Assets;

/**
 * ...
 * @author Al
 */
class Sword extends Projectile
{
	public var destCurrentX:Float;
	public var destCurrentY:Float;
	public var destGlobalX:Float;
	public var destGlobalY:Float;
	public var state:String;
	public var pattern:String;
	public var nextPattern:String;
	public var collizionPoints:Array<Float>;
	public var angleDest:Float;
	var dstAngle:Float;

	public function new() 
	{
		super(Main.projTypeSword);
		destCurrentX = 0;
		destCurrentY = 0;
		destGlobalX = 0;
		destGlobalY = 0;
		state = "ok";
		pattern = "circling";
		nextPattern = "";	
		bmp.x = -34;
		bmp.y = -39;
		collizionPoints = new Array<Float>();
		collizionPoints[0] = -8;
		collizionPoints[1] = 0;
		collizionPoints[2] = 8;
		collizionPoints[3] = 18;
		dstAngle = 0;
		angleDest = 0;
	}
	
	public function changePattern(target:String) {
		if ( state == "ok" ) {
			pattern = target;
			state = "init";
		} else {
			nextPattern = target;
		}
		updateDestinationGlobal();
	}
	
	override
	public function tick() {
		updateCollizionGroup();
		if ( state == "ok" ) {
			if ( nextPattern != "" ) {
				pattern = nextPattern;
				state = "init";
				nextPattern = "";
				updateDestinationGlobal();
				return;
			}
			updateDestinationLocal();			
			if ( pattern == "circling" ) {
				//x = destCurrentX;
				//y = destCurrentY;
				moveTowards(destCurrentX, destCurrentY);
				angleDest = Math.atan2(y - Main.player.y, x - Main.player.x);
				modAngleToDest();
			} else {
				var res:Bool = moveTowards(destCurrentX, destCurrentY);			
				if ( pattern == "jump" ) {
					if (!res) {
						changePattern("circling");
					}
				}
			}
		}
		if ( state == "init" ) {
			if ( distance(x,y,destGlobalX, destGlobalY) < optimalRangeForStart()) {
				state = "ok";
			} else {
				moveTowards(destGlobalX, destGlobalY);				
			}
			updateDestinationGlobal();
		}
		angle = rotation * Math.PI / 180;		
	}
	
	function moveTowards(tx:Float, ty:Float):Bool {
		if ( distance(x, y, tx, ty) < (speed+1)/2 ) {
			return false;
		}
		var angle:Float = Math.atan2(ty - y,tx - x);
		x += speed * Math.cos(angle);
		y += speed * Math.sin(angle);		
		return true;
	}
	
	function optimalRangeForStart():Float {
		if ( pattern == "circling" )	return Main.tilesize * 4;
		return Main.tilesize;
	}
	
	function updateDestinationGlobal() {
		if ( pattern == "circling" )	{
			destGlobalX = Main.player.x;
			destGlobalY = Main.player.y;
		}
		if ( pattern == "jump" ) {
			destGlobalX = Main.player.x;
			destGlobalY = Main.player.y;
		}
		if ( pattern == "boss" ) {
			destGlobalX = Main.bossX;
			destGlobalY = Main.bossY;
		}
		rotation = Math.atan2(destGlobalY - y, destGlobalX - x) * 180 / Math.PI;
	}
	
	function updateDestinationLocal() {
		if ( pattern == "circling" )	{
			dstAngle = (6 * (Main.framesPassed % 60) % 360) / 180 * Math.PI;
			destCurrentX = Main.player.x + Main.player.sizeX / 2 + Main.tilesize * (2 + Main.swordCharges * 0.5) * Math.cos(dstAngle);
			destCurrentY = Main.player.y + Main.player.sizeY / 2 + Main.tilesize * (2 + Main.swordCharges * 0.5) * Math.sin(dstAngle);
//			rotation = dstAngle * 180 / Math.PI;
			if ( Math.random() < 0.005 ) {
				swapToJumpPattern();
			}
		}
		if ( pattern == "jump" ) {
			destCurrentX = Main.player.x + Main.player.sizeX / 2 + Main.tilesize * 4 * Math.cos(dstAngle);
			destCurrentY = Main.player.y + Main.player.sizeY / 2 + Main.tilesize * 4 * Math.sin(dstAngle);
			rotation = dstAngle * 180 / Math.PI;
		}
		if ( pattern == "boss" ) {
			if ( distance(x, y, destCurrentX, destCurrentY) < Main.tilesize ) {
				dstAngle = dstAngle + Math.PI * 0.5 + Math.random() * Math.PI * 1.0;
				Main.bossDealDamage(dmg * 2);				
				var soundfx1 = Assets.getSound("audio/sword_hit.wav");
				soundfx1.play();
				Main.strikeBoss(dstAngle);
			}
			destCurrentX = Main.bossX + Main.tilesize * 4 * Math.cos(dstAngle);
			destCurrentY = Main.bossY + Main.tilesize * 4 * Math.sin(dstAngle);
			rotation = dstAngle * 180 / Math.PI;
		}
	}
	
	function swapToJumpPattern() {
		dstAngle = ((6 * (Main.framesPassed % 60)) + 180 % 360) / 180 * Math.PI;
		changePattern("jump");
	}
	
	override
	public function checkCollizion(other:Collidable):Bool {
		if ( other == this.source )	return false;
		if ( other.type == this.type) {
			for ( i in 0...collizionPoints.length) {
				var cx:Float = this.x + collizionPoints[i] * Math.cos(angle);
				var cy:Float = this.y + collizionPoints[i] * Math.sin(angle);
				if ( distance(cx, cy, other.x, other.y) < this.projType.hbRad + other.sizeX )	return true;
			}
			return false;
		} else {
			for ( i in 0...collizionPoints.length) {
				var cx:Float = this.x + collizionPoints[i] * Math.cos(angle);
				var cy:Float = this.y + collizionPoints[i] * Math.sin(angle);
				if (other.distanceOuterTo(cx, cy) < this.projType.hbRad )	return true;
			}
			return false;
		}
		
	}
	
	public function updateCollizionGroup() {
		for ( object in collizionGroup.keys() ) {
			if ( Main.framesPassed - collizionGroup.get(object) > 30 ) {
				collizionGroup.remove(object);
			}
		}
	}
	
	public var turnRate:Float = 0.03;
	public function modAngleToDest() {
		if ( Math.abs(angle - angleDest) < Math.PI * turnRate ) {
			angle = angleDest;
		} else {
			if ( Math.abs(angle - angleDest) > Math.PI ) {
				if ( angle < angleDest )	angle -= Math.PI * turnRate;
				else angle += Math.PI * turnRate;				
			} else {
				if ( angle > angleDest )	angle -= Math.PI * turnRate;
				else angle += Math.PI * turnRate;
			}
		}
		rotation = angle * 180 / Math.PI;
	}
}