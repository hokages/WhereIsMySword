package ;

/**
 * ...
 * @author Al
 */
class AI
{

	var followPlayer:Bool;
	public var shootDist:Float;
	public var followDist:Float;
	public function new() 
	{
		followPlayer = true;
		followDist = 0;
	}
	
	public function tick(unit:Unit) {
		var angleToPlayer:Float = Math.atan2(Main.player.y - unit.y, Main.player.x - unit.x);
		if ( followPlayer ) {
			if ( unit.distanceTo(Main.player) > followDist ) {
				var angle:Float = angleToPlayer;
				for ( i in 0...8 ) {
					if ( unit.canMoveTo(unit.x + 2 * unit.movespeed * Math.cos(angle), unit.y + 2 * unit.movespeed * Math.sin(angle)) ) {
						unit.moveDir(angle);
						break;
					} else {
						angle += Math.PI * 0.25;
					}
				}
			}
		}
		if ((unit.unitType != "shakal") && ( unit.distanceTo(Main.player) < shootDist )) {
			unit.shoot(angleToPlayer);
		}
		if ( unit.bored ) {
			if ( unit.canMoveTo(unit.x + 2 * unit.movespeed * Math.cos(unit.aiAngle), unit.y + 2 * unit.movespeed * Math.sin(unit.aiAngle)) ) {
				unit.moveDir(unit.aiAngle);
			}
		}
		if ( Main.framesPassed % 120 == 0 ) {
			checkBoredom(unit);
		}
	}
	
	public function checkBoredom(unit:Unit) {
		var tile:Tile = Main.getTileAt(unit.x + unit.sizeX / 2, unit.y + unit.sizeY);
		unit.bored = ( tile == unit.prevTile );
		unit.aiAngle = Math.random() * Math.PI * 2;
		unit.prevTile = tile;
	}
	
}