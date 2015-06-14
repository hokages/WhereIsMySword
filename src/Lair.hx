package ;
import flash.display.Bitmap;
import openfl.Assets;

/**
 * ...
 * @author Al
 */
class Lair extends Unit
{
	public var spawnRate:Int;
	public var monstersMax:Int;
	var spawnCooldown:Int;
	public var monsterSizeX:Int;
	public var monsterSizeY:Int;
	public var monsterMS:Float;
	public var monsterAS:Int;
	public var monsterHP:Int;
	public var monsterType:String;
	public var monsterBmp:String;
	public static var liarsOut:Int = 0;

	public function new() 
	{
		super();
		immovable = true;
		++liarsOut;
		var soundfx1 = Assets.getSound("audio/capm_birth.wav");
		soundfx1.play();
	}
	
	public function spawnUnit() {
		if ( monstersOut >= monstersMax ) {
			return;
		}
		++monstersOut;
		spawnCooldown = spawnRate;
		var newMonster = new Unit();
		newMonster.sizeX = monsterSizeX;
		newMonster.sizeY = monsterSizeY;
		newMonster.movespeed = monsterMS;
		newMonster.hpMax = monsterHP;
		newMonster.hp = monsterHP;
		newMonster.attackSpeed = monsterAS;
		newMonster.unitType = monsterType;
		newMonster.source = this;
		newMonster.bmp = new Bitmap(Assets.getBitmapData(monsterBmp));
		if ( newMonster.unitType == "shakal" ) {
			newMonster.spriteDY = -1;
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/shakal.png")));
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/shakal01.png")));
		}
		if ( newMonster.unitType == "default" ) {
			newMonster.spriteDY = -1;
			newMonster.shadow = new Bitmap(Assets.getBitmapData("img/enemy_melee_shadow.png"));
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/enemy_melee_01.png")));
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/enemy_melee_02.png")));
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/enemy_melee_03.png")));
		}
		if ( newMonster.unitType == "ranged" ) {
			newMonster.spriteDY = -5;
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/range.png")));
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/range01.png")));
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/range01.png")));
		}
		if ( newMonster.unitType == "biggun" ) {
			newMonster.spriteDY = -31;
			newMonster.spriteDX = -32;
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/big_gun.png")));
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/big_gun_01.png")));
			newMonster.animationBmp.push(new Bitmap(Assets.getBitmapData("img/big_gun_02.png")));
			newMonster.shadow = new Bitmap(Assets.getBitmapData("img/big_gun_shadow.png"));
		}
		Main.addUnit(newMonster, Math.round(x/Main.tilesize), Math.round(y/Main.tilesize));
	}
	
	override
	public function tick() {
		super.tick();
		--spawnCooldown;
		if ( spawnCooldown <= 0 ) {
			spawnUnit();
		}
	}
	
	override
	public function kill() {
		--liarsOut;
		var soundfx1 = Assets.getSound("audio/camp_dead.wav");
		soundfx1.play();
		super.kill();
		if ( Main.tutotalOn ) {
			Main.tutorial(3);
		}
	}
}