package ;

import aze.display.SparrowTilesheet;
import aze.display.TileLayer;
import aze.display.TilesheetEx;
import aze.display.TileSprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flash.media.Sound;
import flash.text.TextField;
import flash.text.TextFormat;
import openfl.Assets;

/**
 * ...
 * @author Al
 */

class Main extends Sprite 
{
	static var layer:TileLayer;
	var inited:Bool;
	public static var framesPassed:Int = 0;
	public static var tilemap:Array<Array<Tile>>;
	public static var tilesize:Int = 16;
	public static var tileAir:Tile = new Tile( -1, -1, false);
	
	public static var mapsizeX:Int = 44;
	public static var mapsizeY:Int = 24;
	public static var field:Sprite;
	public static var player:Unit = null;
	public static var sword:Sword;
	public static var swordCharges:Int = 0;
	
	
	public static var fullStageWidth:Int;
	public static var fullStageHeight:Int;
	
	public static var collidables:Array<Collidable>;
	public static var enemies:Array<Unit>;
	public static var corpses:List<Corpse>;
	public static var particles:List<ExpandingParticle> = new List<ExpandingParticle>();
	
	var aiSimpleFollow:AI;
	var aiSimpleRanged:AI;
	
	public static var gameProgress:Int;
	public static var bossHpMax:Int;
	public static var bossHp:Int;
	public static var bossX:Int = 400;
	public static var bossY:Int = 0;
	public static var bossHpBar:Sprite;
	public static var bossHpBarBase:Sprite;
	
	public static var bossHead:Sprite;
	public static var bossHeadXBase:Int = 388;
	public static var bossHeadYBase:Int = 122 - 143;
	public static var bossHeadXD:Int = 0;
	public static var bossHeadYD:Int = 0;
	
	public static var bossHeadShake:Int = 0;
	public static var bossHeadStrike:Int = 0;
	public static var bossHeadStrikeAngle:Float;
	
	public static var bossHand:Sprite;
	public static var bossHandXBase:Int = 388;
	public static var bossHandYBase:Int = 122 - 143;
	public static var bossHandXD:Int = 0;
	public static var bossHandYD:Int = 0;
	public static var bossHandBmp:Array<Bitmap> = new Array<Bitmap>();
	
	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	public static var projMeeleCrescent:ProjectileType;
	public static var projRangedSmall:ProjectileType;
	public static var projRangedBig:ProjectileType;
	public static var projTypeSword:ProjectileType;
	public static var projTypeBoss:ProjectileType;
	public static var mainInstance;
	static function initProjectiles() {
		
		projMeeleCrescent = new ProjectileType();
		projMeeleCrescent.speed = 4.0;
		projMeeleCrescent.dmg = 1;
		projMeeleCrescent.hbRad = 13;
		projMeeleCrescent.ttl = 10;
		projMeeleCrescent.bmp = "img/bullet melee 01.png";
		projMeeleCrescent.bmpDX = -42;
		projMeeleCrescent.bmpDY = -61;
		projMeeleCrescent.destroyAfterHit = false;
		
		projRangedSmall = new ProjectileType();
		projRangedSmall.speed = 3;
		projRangedSmall.dmg = 1;
		projRangedSmall.hbRad = 4;
		projRangedSmall.ttl = 180;
		projRangedSmall.bmpDX = -27;
		projRangedSmall.bmpDY = -28;
		projRangedSmall.bmp = "img/bullet range 01.png";
		
		projRangedBig = new ProjectileType();
		projRangedBig.speed = 2.5;
		projRangedBig.dmg = 3;
		projRangedBig.hbRad = 7;
		projRangedBig.ttl = 240;
		projRangedBig.bmpDX = -37;
		projRangedBig.bmpDY = -37;
		projRangedBig.bmp = "img/bullet big gun 01.png";
		
		projTypeSword = new ProjectileType();
		projTypeSword.speed = 3.0;
		projTypeSword.dmg = 2;
		projTypeSword.hbRad = 9;
		projTypeSword.destroyAfterHit = false;
		projTypeSword.bmp = "img/sword00.png";
		
		projTypeBoss = new ProjectileType();
		projTypeBoss.speed = 4;
		projTypeBoss.dmg = 2;
		projTypeBoss.hbRad = 15;
		projTypeBoss.ttl = 300;
		projTypeBoss.bmpDX = -44+15;
		projTypeBoss.bmpDY = -44+15;
		projTypeBoss.destroyAfterHit = true;
		projTypeBoss.bmp = "img/bullet hand.png";
	}
	
	public static var bonusIcon:Sprite = new Sprite();
	static var hearts:Array<Bitmap> = new Array<Bitmap>();
	static var heartsDead:Array<Bitmap> = new Array<Bitmap>();
	public function initHearts() {
		for ( i in 0...player.hpMax) {
			hearts[i] = new Bitmap(Assets.getBitmapData("img/heart.png"));
			hearts[i].x = fullStageWidth - 20;
			hearts[i].y = 5 + i * 20;			
			addChild(hearts[i]);
			heartsDead[i] = new Bitmap(Assets.getBitmapData("img/heart_empty.png"));
			heartsDead[i].x = fullStageWidth - 20;
			heartsDead[i].y = 5 + i * 20;			
			addChild(heartsDead[i]);
		}
	}
	
	public static function drawHearts() {
		for ( i in 0...player.hpMax) {
			hearts[i].visible = ( i < player.hp );
			heartsDead[i].visible = !( i < player.hp );
		}
	}
	
	static var globalFilter:Sprite;
	static var backGround:Bitmap;
	public static var tileDownSound:Sound;
	
	function init() 
	{
		if (inited) return;
		mainInstance = this;
		inited = true;
		tileAir.permanent = true;
		tileDownSound = Assets.getSound("audio/tile_down.wav");
		//tileDownSound.play();
		var soundfx1 = Assets.getSound("audio/capm_birth.wav");
		soundfx1.play();
			
		fullStageWidth = 800;
		fullStageHeight = stage.stageHeight;
		
		//backGround = new Bitmap(Assets.getBitmapData("img/back00.png"));
		var bmp = Assets.getBitmapData("img/back00.png");
		var sheet:TilesheetEx = new TilesheetEx(bmp);			
		var r:Rectangle = cast bmp.rect.clone();
		
		sheet.addDefinition("back", r, bmp);
		layer = new TileLayer(sheet, false);
		addChildAt(layer.view, 0);		
		layer.x = fullStageWidth / 2;
		layer.y = fullStageHeight / 2;
		var back = new TileSprite(layer, "back");
		back.mirror = 1;
		back.x = 0;
		back.y = 0;
		layer.addChild(back);
		
		//addChildAt( backGround, 0);
		field = new Sprite();
		addChildAt(field, 1);
		globalFilter = new Sprite();
		resetGlobalFilter();
		addChild(globalFilter);
		field.x = 50;
		field.y = 72;
		tilemap = new Array<Array<Tile>>();
		for ( i in 0...mapsizeX ) {
			tilemap[i] = new Array<Tile>();
			for ( j in 0...mapsizeY ) {
				tilemap[i][j] = new Tile(i, j, true);
				field.addChild(tilemap[i][j]);	
				//tilemap[i][j].setGround();
			}
		}
		
		for ( i in 0...19 ) {
			for ( j in 0...9 ) {
				tilemap[i][j].setGround();
			}
		}
		for ( i in 20...40 ) {
			for ( j in 0...24 ) {
				tilemap[i][j].setGround();
			}
		}
		for ( i in 1...19 ) {
			for ( j in 11...24 ) {
				tilemap[i][j].setGround();
				//if ( Math.random() < 0.3)	tilemap[i][j].markForDestruction();
			}
		}
		tilemap[19][6].setGround();
		tilemap[19][7].setGround();
		tilemap[10][9].setGround();
		tilemap[10][10].setGround();
		
		//hand
		for ( i in 9...17 ) {
			for ( j in 0...4 ) {
				tilemap[i][j].setNo();
				tilemap[i][j].permanent = true;
			}
		}		
		for ( i in 17...19 ) {
			for ( j in 0...3 ) {
				tilemap[i][j].setNo();
				tilemap[i][j].permanent = true;
			}
		}
		
		//head
		for ( i in 20...35 ) {
			for ( j in 0...2 ) {
				tilemap[i][j].setNo();
				tilemap[i][j].permanent = true;
			}
		}
		for ( i in 20...30 ) {
			tilemap[i][2].setNo();
			tilemap[i][2].permanent = true;
		}
		for ( i in 20...29 ) {
			tilemap[i][3].setNo();
			tilemap[i][3].permanent = true;
		}
		
		//future lairs
		tilemap[25][10].permanent = true;
		tilemap[26][10].permanent = true;
		tilemap[25][15].permanent = true;
		tilemap[26][15].permanent = true;
		tilemap[8][16].permanent = true;
		tilemap[9][16].permanent = true;
		tilemap[5][18].permanent = true;
		tilemap[6][18].permanent = true;
		tilemap[11][11].permanent = true;
		tilemap[12][11].permanent = true;
		tilemap[17][15].permanent = true;
		tilemap[18][15].permanent = true;
		tilemap[22][15].permanent = true;
		tilemap[23][15].permanent = true;
		tilemap[30][19].permanent = true;
		tilemap[31][19].permanent = true;
		tilemap[33][13].permanent = true;
		tilemap[34][13].permanent = true;
		tilemap[31][3].permanent = true;
		tilemap[32][3].permanent = true;
		tilemap[42][5].permanent = true;
		tilemap[41][5].permanent = true;
		tilemap[37][11].permanent = true;
		tilemap[38][11].permanent = true;
		tilemap[6][4].permanent = true;
		tilemap[7][4].permanent = true;
		tilemap[7][5].permanent = true;
		tilemap[8][5].permanent = true;
		tilemap[15][8].permanent = true;
		tilemap[16][8].permanent = true;
		
		var testMap:Array<Int> = [0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0,
1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1];
		var tmI:Int = 0;
		var tmJ:Int = 0;
		for ( val in testMap ) {			
			if ( val == 0 ) {
				tilemap[tmI][tmJ].setNo();
			} else {
				tilemap[tmI][tmJ].setGround();
			}
			++tmI;
			if ( tmI >= mapsizeX ) {
				tmI = 0;
				++tmJ;
			}
		}
		
		collidables = new Array<Collidable>();
		enemies = new Array<Unit>();
		corpses = new List<Corpse>();
		field.g
		initProjectiles();		
		
		player = new Unit();
		player.sizeX = 9;
		player.sizeY = 23;
		player.movespeed = 1.5;
		player.hpMax = 10;
		player.hp = player.hpMax;
		player.bmp = new Bitmap(Assets.getBitmapData("img/hero right00.png"));
		player.spriteDY = -39;
		player.spriteDX = -54;
		player.animationBmp.push(new Bitmap(Assets.getBitmapData("img/hero right00.png")));
		player.animationBmp.push(new Bitmap(Assets.getBitmapData("img/hero right01.png")));
		player.animationBmp.push(new Bitmap(Assets.getBitmapData("img/hero right02.png")));
		player.animationBmp.push(new Bitmap(Assets.getBitmapData("img/hero right03.png")));
		addUnit(player, 0, 0);
		
		player.tail = new Sprite();
		player.addChildAt(player.tail, 0);
		player.tail.x = -10;
		player.tail.y = 4;
		player.tailBmp[0] = new Bitmap(Assets.getBitmapData("img/tailr00.png"));
		player.tailBmp[1] = new Bitmap(Assets.getBitmapData("img/tailr01.png"));
		player.tailBmp[2] = new Bitmap(Assets.getBitmapData("img/tailr02.png"));
		player.tailBmp[3] = new Bitmap(Assets.getBitmapData("img/tailr03.png"));
		
		initHearts();
		drawHearts();
		
		sword = new Sword();
		sword.setAngle(0);
		Main.field.addChild(sword);
		sword.x = player.x;
		sword.y = player.y;
		Main.collidables.push(sword);
		sword.source = player;
		
		//AI setup
		aiSimpleFollow = new AI();
		aiSimpleFollow.shootDist = tilesize * 3;
		aiSimpleFollow.followDist = tilesize * 1.5;
		
		aiSimpleRanged = new AI();
		aiSimpleRanged.shootDist = tilesize * 20;
		aiSimpleRanged.followDist = tilesize * 10;
		
		bossHead = new Sprite();
		bossHead.addChild(new Bitmap(Assets.getBitmapData("img/head.png")));
		bossHead.x = bossHeadXBase;
		bossHead.y = bossHeadYBase;
		addChildAt(bossHead, 1);
		
		bossHand = new Sprite();
		bossHandBmp.push(new Bitmap(Assets.getBitmapData("img/hand.png")));
		bossHandBmp.push(new Bitmap(Assets.getBitmapData("img/hand01.png")));
		bossHand.visible = false;
		addChild(bossHand);
		
		//placeLair("default", 25, 10);
		gameProgress = 105;		
		bossHpMax = 1000;
		bossHp = bossHpMax;		
		bossHpBarBase = new Sprite();
		bossHpBarBase.addChild(new Bitmap(Assets.getBitmapData("img/frame.png")));
		bossHpBarBase.x = 50;
		
		bossHpBar = new Sprite();
		bossHpBar.addChild(new Bitmap(Assets.getBitmapData("img/hp bar.png")));
		addChild(bossHpBar);
		addChild(bossHpBarBase);
		bossHpBar.x = 57;
		
		
		
		bonusIcon.x = 10-27;
		bonusIcon.y = 8-27;
		addChild(bonusIcon);
		bonusIcon.visible = false;
		//bonus
		//Bonus.placeBonus("bomb", 1, 0);
		//tutotalOn = false;
		
		trackProgress();
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
		addEventListener(Event.ENTER_FRAME, onFrame);		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onUp);
		
		
		pauseScreen = new Sprite();
		pauseScreen.x = 200;
		pauseScreen.y = 200;		
		pauseScreen.visible = false;
		addChild(pauseScreen);
		//pauseGame(textManual);
		tutorial(0);
	}
	
	static var keymap:Map<Int,Bool> = new Map<Int,Bool>();
	
	function onDown(e) {	
		//trace(e.keyCode);
		keymap.set(e.keyCode, true);						
		if (e.keyCode == 32) {
			//space
			if ( !pause ) {
			if ( sword.pattern == "boss" ) {
				if (( enemies.length > 0 ) || tutotalOn ) {
					sword.changePattern("circling");
				}
			} else {
				if ( player.hp > 0 ) {
					sword.changePattern("boss");
				}
			}
			} else {
				if ( player.hp > 0 ) {
					continueGame();
				}
			}
		}
		if (e.keyCode == 38 ) {
			
		}
		if (e.keyCode == 40 ) {
			
		}
		if (e.keyCode == 37 ) {
			
		}
		if ( e.keyCode == 79 ) {
			Main.resetGame();
		}
		if ( pause && tutotalBonus) {
			if (( e.keyCode == 82 ) || ( e.keyCode == 69 ) || ( e.keyCode == 84 )) {
				continueGame(); 		
				tutotalBonus = false;
			}
		} else if ( !pause ) {
		if ( e.keyCode == 82 ) {
			//R
			player.activateBonus();
		}
		if ( e.keyCode == 69 ) {
			//E
			player.activateBonus();
		}
		if ( e.keyCode == 84 ) {
			//T
			player.activateBonus();
			
		}
		}
		
	}
	
	function onUp(e) {
		keymap.set(e.keyCode, false);
		if (e.keyCode == 32 ) {
			//space
		}
	}
	
	static function placeLair(type:String,x:Int,y:Int) {
		var testLair = new Lair();		
		if ( type == "shakal" ) {
			testLair.sizeX = 28;
			testLair.sizeY = 16;
			testLair.hpMax = 7;
			testLair.hp = 7;
			testLair.bmp = new Bitmap(Assets.getBitmapData("img/camp_shakal.png"));
			testLair.spriteDX = -10;
			testLair.spriteDY = -8;
			testLair.spawnRate = 120;
			testLair.monstersMax = 3;
			testLair.monsterSizeX = 20;
			testLair.monsterSizeY = 12;
			testLair.monsterMS = 1.3;
			testLair.monsterAS = 0;
			testLair.monsterHP = 1;
			testLair.monsterType = "shakal";
			testLair.monsterBmp = "img/shakal.png";
		}
		if ( type == "default" ) {
			testLair.sizeX = 32;
			testLair.sizeY = 16;
			testLair.hpMax = 10;
			testLair.hp = 10;
			testLair.bmp = new Bitmap(Assets.getBitmapData("img/camp_melee.png"));
			testLair.spriteDX = -14;
			testLair.spriteDY = -14;
			testLair.spawnRate = 300;
			testLair.monstersMax = 4;
			testLair.monsterSizeX = 20;
			testLair.monsterSizeY = 24;
			testLair.monsterMS = 0.8;
			testLair.monsterAS = 120;
			testLair.monsterHP = 3;
			testLair.monsterType = "default";
			testLair.monsterBmp = "img/enemy_melee_01.png";
		}
		if ( type == "ranged" ) {
			testLair.sizeX = 32;
			testLair.sizeY = 16;
			testLair.hpMax = 10;
			testLair.hp = 10;
			testLair.bmp = new Bitmap(Assets.getBitmapData("img/camp_range.png"));			
			testLair.spriteDX = -16;
			testLair.spriteDY = -12;
			testLair.spawnRate = 300;
			testLair.monstersMax = 3;
			testLair.monsterSizeX = 24;
			testLair.monsterSizeY = 16;
			testLair.monsterMS = 0.6;
			testLair.monsterAS = 120;
			testLair.monsterHP = 1;
			testLair.monsterType = "ranged";
			testLair.monsterBmp = "img/range.png";
		}
		if ( type == "biggun" ) {
			testLair.sizeX = 32;
			testLair.sizeY = 16;
			testLair.hpMax = 20;
			testLair.hp = 20;
			testLair.bmp = new Bitmap(Assets.getBitmapData("img/camp_big_gun.png"));			
			testLair.spriteDX = -16;
			testLair.spriteDY = -20;
			testLair.spawnRate = 480;
			testLair.monstersMax = 2;
			testLair.monsterSizeX = 14;
			testLair.monsterSizeY = 14;
			testLair.monsterMS = 0.5;
			testLair.monsterAS = 240;
			testLair.monsterHP = 5;
			testLair.monsterType = "biggun";
			testLair.monsterBmp = "img/big_gun.png";
		}
		testLair.unitType = "lair";
		addUnit(testLair, x, y);
	}
	
	static function trackProgress() {
		var bossPercent:Float = 100 * bossHp / bossHpMax;	//100% ... 0
		bossPercent = 100 * bossHpBar.scaleX;
		var borderLine:Int;
		if ( bossPercent < gameProgress ) {
			if ( !tutotalOn ) {				
				borderLine = 100;
				if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
					placeLair("default", 30, 16);
					gameProgress = borderLine;
				}
			}
			borderLine = 95;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("shakal", 25, 10);
				gameProgress = borderLine;				
			}
			borderLine = 90;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("default", 25, 15);
				gameProgress = borderLine;
			}
			borderLine = 85;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("ranged", 8, 16);
				gameProgress = borderLine;
			}
			borderLine = 80;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("default", 7, 5);
				gameProgress = borderLine;
			}			
			borderLine = 75;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("default", 5, 18);
			//	placeLair("default", 31, 3);
				placeLair("ranged", 42, 5);
				gameProgress = borderLine;
			}
			borderLine = 70;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("ranged", 30, 19);
				gameProgress = borderLine;
			}
			borderLine = 65;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("default", 11, 11);
				gameProgress = borderLine;
			}
			borderLine = 60;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("biggun", 30, 19);
				gameProgress = borderLine;
			}
			borderLine = 55;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("default", 22, 15);
				gameProgress = borderLine;
			}
			borderLine = 50;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("default", 15, 8);
				placeLair("ranged", 31, 3);
				placeLair("biggun", 17, 15);
				gameProgress = borderLine;
			}
			borderLine = 40;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("default", 22, 15);
				placeLair("ranged", 30, 19);
				gameProgress = borderLine;
			}
			borderLine = 30;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("default", 6, 4);
				placeLair("biggun", 7, 5);
				gameProgress = borderLine;
			}
			borderLine = 25;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("ranged", 31, 3);
				placeLair("ranged", 33, 13);
				placeLair("ranged", 5, 18);
				placeLair("ranged", 15, 8);
				gameProgress = borderLine;
			}
			borderLine = 20;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("biggun", 42, 5);
				placeLair("biggun", 30, 19);
				gameProgress = borderLine;
			}
			borderLine = 10;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("default", 11, 11);
				placeLair("default", 3, 11);
				placeLair("ranged", 7, 5);
				placeLair("ranged", 5, 18);
				gameProgress = borderLine;
			}
			borderLine = 5;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				placeLair("biggun", 31, 3);
				placeLair("biggun", 6, 4);
				placeLair("biggun", 17, 15);
				placeLair("default", 15, 8);
				placeLair("default", 22, 15);
				gameProgress = borderLine;
			}
			borderLine = 0;
			if (( bossPercent <= borderLine ) && (gameProgress > borderLine)) {
				pauseGame(textWin);
				gameProgress = borderLine;
			}
		}
	}
	
	function onFrame(e) {				
		layer.render();
		if ( pause && tutotalOn && (tutotalLessonCurrent == 1 )) {
			if ( keymap.get(37) || keymap.get(65) ) continueGame(); 
			if ( keymap.get(38) || keymap.get(87) ) continueGame(); 
			if ( keymap.get(39) || keymap.get(68) ) continueGame(); 
			if ( keymap.get(40) || keymap.get(83) ) continueGame(); 		
		}
		if ( pause )	return;		
		++framesPassed;	
		if ( tutotalOn ) {
			if (( framesPassed >= 60 ) && ( Main.player.distanceOuterTo(0, 0) > 8)) {
				tutorial(1);
			}
			if (((framesPassed >= 800 ) || ( enemies.length > 2 )) && (gameProgress < 100)) {
				tutorial(2);
			}
		}
		if ( gameProgress <= 70 ) {
			if ( framesPassed % 10 == 0 ) {
				chargeBossHand(5);
			}
			if ( Lair.liarsOut <= 0 ) {
				chargeBossHand(2);
			}
			if ( bossHandCharge > 200 ) {
				bossHandCharge = 0;
				bossHandOn();
			}
		}
		if ( framesPassed % 180 == 0 ) {
			bossHeadShake = 1;
		}
		if ( bossHand.visible ) {
			++bossHandTimer;
			bossHandUpdate();			
		}
		shakeBossHead();
		if ( framesPassed % 600 == 0 ) {
			if ( Bonus.activeBonuses < 3 ) {
				var rnd:Int = Math.floor(Math.random() * 4);
				if (( swordCharges < 4 ) && ( swordCharges < (100 - gameProgress) / 20 )) {
					rnd = Math.floor(Math.random() * 5);
				}
				if ( rnd == 0 ) Bonus.placeBonus("build", Math.floor(Math.random() * mapsizeX), Math.floor(Math.random() * mapsizeY));
				if ( rnd == 1 ) Bonus.placeBonus("lifesteal", Math.floor(Math.random() * mapsizeX), Math.floor(Math.random() * mapsizeY));
				if ( rnd == 2 ) Bonus.placeBonus("bomb", Math.floor(Math.random() * mapsizeX), Math.floor(Math.random() * mapsizeY));
				if ( rnd == 3 ) Bonus.placeBonus("heal", Math.floor(Math.random() * mapsizeX), Math.floor(Math.random() * mapsizeY));
				if ( rnd == 4 ) Bonus.placeBonus("sword", Math.floor(Math.random() * mapsizeX), Math.floor(Math.random() * mapsizeY));
			}
		}
		
		for ( i in 0...mapsizeX ) {
			for ( j in 0...mapsizeY ) {
				tilemap[i][j].tick();
			}
		}
		
		var dx:Int = 0;
		var dy:Int = 0;
		if ( keymap.get(37) || keymap.get(65) ) --dx; 
		if ( keymap.get(38) || keymap.get(87) ) --dy; 
		if ( keymap.get(39) || keymap.get(68) ) ++dx; 
		if ( keymap.get(40) || keymap.get(83) ) ++dy; 		
		if ( dx * dy == 0 ) {
			if ( dx > 0 ) player.moveDir(0 * Math.PI / 180);
			if ( dx < 0 ) player.moveDir( -180 * Math.PI / 180);
			if ( dy > 0 ) player.moveDir(90 * Math.PI / 180);
			if ( dy < 0 ) player.moveDir(-90 * Math.PI / 180);
		} else {
			player.moveDir(Math.atan2(dy, dx));
		}
		for ( enemy in enemies ) {
			if ( enemy.unitType == "default" ) {
				aiSimpleFollow.tick(enemy);
			}
			if ( enemy.unitType == "ranged" ) {
				aiSimpleRanged.tick(enemy);
			}
			if ( enemy.unitType == "biggun" ) {
				aiSimpleRanged.tick(enemy);
			}
			if ( enemy.unitType == "shakal" ) {
				aiSimpleFollow.tick(enemy);
			}
		}
		for ( object in collidables ) {			
			object.tick();
			for ( another in collidables ) {
				if (( object != another ) && ((object.flying == another.flying) || (object.type == "bullet"))) {
					if ( object.checkCollizion(another) ) {
						if (( object.type == "unit" ) && (object.type == another.type)) {
							var dist:Float = tilesize * 0.2;
							object.push(Math.atan2(another.y - object.y, another.x - object.x), -dist);
							another.push(Math.atan2(another.y - object.y, another.x - object.x), dist);
						}
						if ( object.type == "bullet" ) {
							if (( object.source == Main.player ) || (another == Main.player)) {
							if ( another.type == "unit" ) {
								if ( !object.collizionGroup.exists(another) ) {
									object.collizionGroup.set(another, framesPassed);
									another.takeDamage(object.dmg);
									if (object.destroyAfterHit)	object.destroy();
									if (object == sword) {										
										var soundfx1 = Assets.getSound("audio/sword_hit.wav");
										soundfx1.play();
									}
								}
							}
							}
							if ((object == sword) && (another.type == "bullet" )) {
								another.destroy();
								var soundfx1 = Assets.getSound("audio/reflect.wav");
								soundfx1.play();
							}
						}
					}
				}
			}			
		}
		
		//sword second!
		sword.modAngleToDest();
		for ( another in collidables ) {
			if (( sword != another ) && (another != player)) {				
				if ( sword.checkCollizion(another) ) {				
					if ( another.type == "unit" ) {
						if ( !sword.collizionGroup.exists(another) ) {
							sword.collizionGroup.set(another, framesPassed);
							another.takeDamage(sword.dmg);
							var soundfx1 = Assets.getSound("audio/sword_hit.wav");
							soundfx1.play();
						}
					}
					if (another.type == "bullet") {
						another.destroy();
						var soundfx1 = Assets.getSound("audio/reflect.wav");
						soundfx1.play();
					}
				}
			}
		}			
		
		for ( corpse in corpses ) {
			corpse.decay();
		}
		
		//bonus
		if ( getTileAt(player.x + player.sizeX/2, player.y + player.sizeY).bonus != null ) {
			getTileAt(player.x + player.sizeX/2, player.y + player.sizeY).bonus.pickup();
		}
		if ( getTileAt(player.x + player.sizeX/2, player.y + player.sizeY/2).bonus != null ) {
			getTileAt(player.x + player.sizeX/2, player.y + player.sizeY/2).bonus.pickup();
		}
		if ( getTileAt(player.x + player.sizeX/2, player.y).bonus != null ) {
			getTileAt(player.x + player.sizeX/2, player.y).bonus.pickup();
		}
		if ( lifestealTime > 0 ) {
			--lifestealTime;
			globalFilter.alpha = 0.002 * (20 + lifestealTime % 60);
			if ( lifestealTime <= 0 ) {
				lifeStealOff();
			}
		}
		if ( healTime > 0 ) {
			--healTime;
			globalFilter.alpha = 0.0015 * (10 + healTime % 60);
			if ( healTime % 60 == 0 ) {
				player.heal(1);
			}
			if ( healTime <= 0 ) {
				healOff();
			}
		}
		for ( p in particles ) {
			p.tick();
		}
		if ( explosionProgress > 0 ) {
			if ( framesPassed % 5 == 0 ) {
				explode();
			}
		}
	}
	
	public static function addUnit(unit:Unit,x:Int,y:Int) {
		field.addChild(unit);
		unit.x = x * tilesize;
		unit.y = y * tilesize;
		unit.draw();
		collidables.push(unit);
		if ( unit != player ) {
			enemies.push(unit);
		}
	}
	
	public static function bossDealDamage(dmg:Int) {
		bossHp -= dmg;		
		if ( bossHp > 0 ) {
			bossHpBar.scaleX = Math.pow(bossHp / bossHpMax, 1.5);
		} else {
			bossHpBar.scaleX = 0;
		}		
		trackProgress();
		chargeBossHand( -20 );
	}
	
	public static function getTileAt(x:Float, y:Float):Tile {
		if (( x < 0 ) || (x>=mapsizeX*tilesize) || (y<0) || (y>=mapsizeY*tilesize))		
			return tileAir;
		return tilemap[Math.floor(x / tilesize)][Math.floor(y / tilesize)];
	}
	
	static function resetGlobalFilter() {
		globalFilter.graphics.clear();
		globalFilter.graphics.beginFill(0x0000ff, 0.05);
		globalFilter.graphics.drawRect(0, 0, fullStageWidth, fullStageHeight);
		globalFilter.graphics.endFill();
		globalFilter.alpha = 1.0;
	}
	
	public static var lifesteal:Bool = false;
	public static var lifestealTime:Int = 0;
	public static function lifeStealOn() {
		lifesteal = true;
		lifestealTime = 60 * 20;
		globalFilter.graphics.clear();
		globalFilter.graphics.beginFill(0xff0000, 1.0);
		globalFilter.graphics.drawRect(0, 0, fullStageWidth, fullStageHeight);
		globalFilter.graphics.endFill();
		globalFilter.alpha = 0.1;
	}
	
	public static function lifeStealOff() {
		lifesteal = false;
		resetGlobalFilter();
	}
	
	public static var heal:Bool = false;
	public static var healTime:Int = 0;
	public static function healOn() {
		heal = true;
		healTime = 60 * 10;
		globalFilter.graphics.clear();
		globalFilter.graphics.beginFill(0x00ff00, 1.0);
		globalFilter.graphics.drawRect(0, 0, fullStageWidth, fullStageHeight);
		globalFilter.graphics.endFill();
		globalFilter.alpha = 0.1;
	}
	
	public static function healOff() {
		heal = false;
		resetGlobalFilter();
	}
	
	public static function positionBossHead() {
		bossHead.x = bossHeadXBase + bossHeadXD;
		bossHead.y = bossHeadYBase + bossHeadYD;
	}
	
	public static function shakeBossHead() {		
		if ( bossHeadStrike > 0 ) {
			if ( bossHeadStrike < 5 ) {
				bossHeadXD += Math.round(Math.cos(bossHeadStrikeAngle));
				bossHeadYD += Math.round(Math.sin(bossHeadStrikeAngle));				
			} else {
				bossHeadXD -= Math.round(Math.cos(bossHeadStrikeAngle));
				bossHeadYD -= Math.round(Math.sin(bossHeadStrikeAngle));
			}
			++bossHeadStrike;
			if ( bossHeadStrike > 8 ) {
				bossHeadStrike = 0;
			}
			positionBossHead();
		}
		if ( bossHeadShake >= 1 ) {
			if ( framesPassed % 15 != 0 ) {
				return;
			}
			if ( bossHeadShake == 3 ) {
				if ( framesPassed % 60 != 0 ) {
					return;
				}
			}
			if ( bossHeadShake < 3 ) {
				++bossHeadYD;
			} else {
				--bossHeadYD;
			}
			++bossHeadShake;
			if ( bossHeadShake > 4 ) {
				bossHeadShake = 0;
			}
			positionBossHead();
		}
	}
	
	public static function strikeBoss(angle:Float) {
		if ( bossHeadStrike <= 0 ) {
			bossHeadStrike = 1;
			bossHeadStrikeAngle = angle;
		}
	}
	
	static var pause:Bool = false;
	static var textManual:String = "<Space> to start the game\n<space> to control the Sword\n<R> to use collected bonus.";
	static var textWin:String = "No.";
	public static var textDefeat:String = "You lost";
	static var pauseScreen:Sprite;	
	
	public static function pauseGame(text:String) {
		pause = true;
		pauseScreen.visible = true;
		if ( pauseScreen.numChildren > 0 )	pauseScreen.removeChildAt(0);
		if ( text == textManual ) {
			if ( tutotalLessonCurrent == 0 ) {
				pauseScreen.addChild(new Bitmap(Assets.getBitmapData("img/T_START_WASD.png")));
			} else if ( tutotalLessonCurrent == 1 ) {
				pauseScreen.addChild(new Bitmap(Assets.getBitmapData("img/T_A_BOSS.png")));
			} else if ( tutotalLessonCurrent == 2 ) {
				pauseScreen.addChild(new Bitmap(Assets.getBitmapData("img/T_DESTROY_LAIR.png")));
			} else if ( tutotalLessonCurrent == 3 ) {
				pauseScreen.addChild(new Bitmap(Assets.getBitmapData("img/T_BONUS.png")));
			} else {
				pauseScreen.addChild(new Bitmap(Assets.getBitmapData("img/T_START.png")));
			}			
			pauseScreen.x = 214 - 90;
			pauseScreen.y = 183 - 140;			
			globalFilter.graphics.clear();
		globalFilter.graphics.beginFill(0x808080, 0.2);
		globalFilter.graphics.drawRect(0, 0, fullStageWidth, fullStageHeight);
		globalFilter.graphics.endFill();
		}
		if ( text == textWin ) {
			pauseScreen.addChild(new Bitmap(Assets.getBitmapData("img/T_WIN.png")));
			pauseScreen.x = 214 - 90;
			pauseScreen.y = 183 - 140;	
			globalFilter.graphics.clear();
		globalFilter.graphics.beginFill(0x808080, 0.2);
		globalFilter.graphics.drawRect(0, 0, fullStageWidth, fullStageHeight);
		globalFilter.graphics.endFill();
		tutotalBonus = false;
		}
		if ( text == textDefeat ) {
			pauseScreen.addChild(new Bitmap(Assets.getBitmapData("img/T_LOST.png")));
			pauseScreen.x = 214 - 90;
			pauseScreen.y = 183 - 140;	
			globalFilter.graphics.clear();
			globalFilter.graphics.beginFill(0xff0000, 0.3);
			globalFilter.graphics.drawRect(0, 0, fullStageWidth, fullStageHeight);
			globalFilter.graphics.endFill();
			var soundfx1 = Assets.getSound("audio/death.wav");
			soundfx1.play();
			tutotalBonus = false;
		}
		
	}
	public static function continueGame() {
		if ( pause ) {
			pause = false;
			pauseScreen.visible = false;
			resetGlobalFilter();
		}
	}
	
	public static function resetGame() {
		continueGame();
		healOff();
		lifeStealOff();
		healTime = 0;
		lifestealTime = 0;
		bossHp = bossHpMax;
		gameProgress = 100;
		bossDealDamage(0);
		swordCharges = 0;
		
		for ( e in enemies ) {
			e.kill();		
		}		
		for ( c in collidables ) {
			c.destroy();
		}
		framesPassed = 0;		
		
		Main.mainInstance.removeChild(field);
		field = new Sprite();
		Main.mainInstance.addChildAt(field, 1);
		Main.mainInstance.removeChild(globalFilter);		
		globalFilter = new Sprite();
		resetGlobalFilter();
		Main.mainInstance.addChild(globalFilter);
		field.x = 50;
		field.y = 72;
		player = null;
		enemies = null;
		tilemap = new Array<Array<Tile>>();
		for ( i in 0...mapsizeX ) {
			tilemap[i] = new Array<Tile>();
			for ( j in 0...mapsizeY ) {
				tilemap[i][j] = new Tile(i, j, true);
				field.addChild(tilemap[i][j]);	
				//tilemap[i][j].setGround();
			}
		}
		
		for ( i in 0...19 ) {
			for ( j in 0...9 ) {
				tilemap[i][j].setGround();
			}
		}
		for ( i in 20...40 ) {
			for ( j in 0...24 ) {
				tilemap[i][j].setGround();
			}
		}
		for ( i in 1...19 ) {
			for ( j in 11...24 ) {
				tilemap[i][j].setGround();
				//if ( Math.random() < 0.3)	tilemap[i][j].markForDestruction();
			}
		}
		tilemap[19][6].setGround();
		tilemap[19][7].setGround();
		tilemap[10][9].setGround();
		tilemap[10][10].setGround();
		
		//hand
		for ( i in 9...17 ) {
			for ( j in 0...4 ) {
				tilemap[i][j].setNo();
				tilemap[i][j].permanent = true;
			}
		}		
		for ( i in 17...19 ) {
			for ( j in 0...3 ) {
				tilemap[i][j].setNo();
				tilemap[i][j].permanent = true;
			}
		}
		
		//head
		for ( i in 20...35 ) {
			for ( j in 0...2 ) {
				tilemap[i][j].setNo();
				tilemap[i][j].permanent = true;
			}
		}
		for ( i in 20...30 ) {
			tilemap[i][2].setNo();
			tilemap[i][2].permanent = true;
		}
		for ( i in 20...29 ) {
			tilemap[i][3].setNo();
			tilemap[i][3].permanent = true;
		}
		
		//future lairs
		tilemap[25][10].permanent = true;
		tilemap[26][10].permanent = true;
		tilemap[25][15].permanent = true;
		tilemap[26][15].permanent = true;
		tilemap[8][16].permanent = true;
		tilemap[9][16].permanent = true;
		tilemap[5][18].permanent = true;
		tilemap[6][18].permanent = true;
		tilemap[11][11].permanent = true;
		tilemap[12][11].permanent = true;
		tilemap[17][15].permanent = true;
		tilemap[18][15].permanent = true;
		tilemap[22][15].permanent = true;
		tilemap[23][15].permanent = true;
		tilemap[30][19].permanent = true;
		tilemap[31][19].permanent = true;
		tilemap[33][13].permanent = true;
		tilemap[34][13].permanent = true;
		tilemap[31][3].permanent = true;
		tilemap[32][3].permanent = true;
		tilemap[42][5].permanent = true;
		tilemap[41][5].permanent = true;
		tilemap[37][11].permanent = true;
		tilemap[38][11].permanent = true;
		tilemap[6][4].permanent = true;
		tilemap[7][4].permanent = true;
		tilemap[7][5].permanent = true;
		tilemap[8][5].permanent = true;
		tilemap[15][8].permanent = true;
		tilemap[16][8].permanent = true;
		
		var testMap:Array<Int> = [0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0,
1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0,
1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 1, 1, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,
0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1];
		var tmI:Int = 0;
		var tmJ:Int = 0;
		for ( val in testMap ) {			
			if ( val == 0 ) {
				tilemap[tmI][tmJ].setNo();
			} else {
				tilemap[tmI][tmJ].setGround();
			}
			++tmI;
			if ( tmI >= mapsizeX ) {
				tmI = 0;
				++tmJ;
			}
		}
		
		collidables = new Array<Collidable>();
		enemies = new Array<Unit>();
		corpses = new List<Corpse>();
		
		
		player = new Unit();
		player.sizeX = 9;
		player.sizeY = 23;
		player.movespeed = 1.5;
		player.hpMax = 10;
		player.hp = player.hpMax;
		player.bmp = new Bitmap(Assets.getBitmapData("img/hero right00.png"));
		player.spriteDY = -39;
		player.spriteDX = -54;
		player.animationBmp.push(new Bitmap(Assets.getBitmapData("img/hero right00.png")));
		player.animationBmp.push(new Bitmap(Assets.getBitmapData("img/hero right01.png")));
		player.animationBmp.push(new Bitmap(Assets.getBitmapData("img/hero right02.png")));
		player.animationBmp.push(new Bitmap(Assets.getBitmapData("img/hero right03.png")));
		addUnit(player, 0, 0);
		
		player.tail = new Sprite();
		player.addChildAt(player.tail, 0);
		player.tail.x = -10;
		player.tail.y = 4;
		player.tailBmp[0] = new Bitmap(Assets.getBitmapData("img/tailr00.png"));
		player.tailBmp[1] = new Bitmap(Assets.getBitmapData("img/tailr01.png"));
		player.tailBmp[2] = new Bitmap(Assets.getBitmapData("img/tailr02.png"));
		player.tailBmp[3] = new Bitmap(Assets.getBitmapData("img/tailr03.png"));
		
		drawHearts();
		
		sword = new Sword();
		sword.setAngle(0);
		Main.field.addChild(sword);
		sword.x = player.x;
		sword.y = player.y;
		Main.collidables.push(sword);
		sword.source = player;
		
		Main.mainInstance.removeChild(bossHead);
		Main.mainInstance.addChildAt(bossHead, 1);
		Main.mainInstance.removeChild(bossHand);
		Main.mainInstance.addChild(bossHand);
		
		//placeLair("default", 25, 10);
		gameProgress = 200;		
		bossHpMax = 1000;
		bossHp = bossHpMax;		
		bonusIcon.visible = false;
		
		trackProgress();
		
		tutorial(0);
		Bonus.activeBonuses = 0;
		//bossHandOn();
	}
		
	public static var tutotalOn:Bool = true;
	public static var tutotalLessonCurrent:Int = 0;
	public static var tutotalBonus:Bool = false;
	public static function tutorial(lesson:Int) {
		if ( tutotalLessonCurrent > lesson ) {
			return;
		}
		if ( lesson == 0 ) {
			pauseGame(textManual);
		}
		if ( lesson == 1 ) {
			pauseGame(textManual);
		}
		if ( lesson == 2 ) {
			pauseGame(textManual);
		}
		if ( lesson == 3 ) {
			pauseGame(textManual);
			Bonus.placeBonus("build", 6, 12);
			tutotalOn = false;
			tutotalBonus = true;
		}
		if ( tutotalLessonCurrent <= lesson ) {
			tutotalLessonCurrent = lesson + 1;
		}
	}
	
	//Explosion
	public static var explosionX:Float;
	public static var explosionY:Float;
	public static var explosionProgress:Int = 0;
	
	public static function explode() {
		if ( explosionProgress <= 0 ) {
			return;
		}
		--explosionProgress;
		for ( c in enemies ) {
			if (( c != player)) {
				if ( c.distanceOuterTo(explosionX, explosionY) < ( 6 - explosionProgress) * tilesize ) {
					c.kill();
				}
			}
		}
		for ( c in collidables ) {
			if (( c != player) && (c != sword)) {
				if ( c.distanceOuterTo(explosionX, explosionY) < ( 6 - explosionProgress) * tilesize ) {
					if ( c.type == "bullet" ) {
						c.destroy();
					}
				}
			}
		}
	}
	
	public static var bossHandCharge:Int = 0;
	public static function chargeBossHand(val:Int) {
		bossHandCharge += val;
		if ( bossHandCharge < 0 )	bossHandCharge = 0;
	}
	public static var bossHandTimer:Int;
	public static function bossHandOn() {
		if ( bossHand.visible )	return;
		bossHandTimer = 0;
		bossHandCharge = 0;
		bossHandUpdate();
		bossHand.visible = true;
		bossHand.x = fullStageWidth + 5;
		bossHand.y = field.y + Math.random() * (mapsizeY * tilesize - 128);
		bossHand.y = field.y + player.y - 64;
	}
	
	public static function bossHandOff() {
		bossHand.visible = false;
		bossHandCharge = 0;
	}
	
	public static function bossHandUpdate() {
		if ( bossHandTimer % 15 == 0 ) {
			if ( bossHandYD == 0 ) {
				bossHandYD = 1;
				++bossHand.y;
			} else {
				bossHandYD = 0;
				--bossHand.y;
			}
			if ( bossHand.numChildren > 0 )	bossHand.removeChildAt(0);
			bossHand.addChild(bossHandBmp[bossHandYD]);
		}
		if ( bossHandTimer < 35 ) {
			bossHand.x -= 2;
		}
		if (( bossHandTimer % 30 == 0 ) && (bossHandTimer >=60 ) && (bossHandTimer <= 120)) {
			//shoot
			var projType:ProjectileType = projTypeBoss;
			var proj:Projectile = new Projectile(projType);
			proj.setAngle(Math.PI);
			Main.field.addChild(proj);
			proj.x = bossHand.x - field.x + 16;
			proj.y = bossHand.y - 32 - field.y + 32 * (bossHandTimer / 30) ;
			Main.collidables.push(proj);
			proj.source = null;
		}
		if ( bossHandTimer > 150 ) {
			++bossHand.x;
		}
		if ( bossHandTimer == 210 ) {
			bossHandOff();
		}
	}
	
	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
