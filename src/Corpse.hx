package ;
import flash.display.BlendMode;
import flash.display.Sprite;

/**
 * ...
 * @author Al
 */
class Corpse extends Sprite
{
	var ttlMax:Int;
	var ttlRem:Int;
	public function new(source:Unit) 
	{
		super();
		if ( source!=null) {
			if ( source.bmp != null )	{
				//source.removeChild(source.bmp);
				this.addChild(source.bmp);
			}
			this.x = source.x;
			this.y = source.y;
		}
		Main.field.addChild(this);
		Main.corpses.add(this);
		ttlMax = 180;
		ttlRem = ttlMax;
		this.blendMode = BlendMode.DARKEN;
	}
	
	public function decay() {
		--ttlRem;
		if ( ttlRem <= 0 ) {
			Main.field.removeChild(this);
			Main.corpses.remove(this);
			return;
		}
		this.alpha = 0.1 + 0.9 * ttlRem / ttlMax;		
	}
	
}