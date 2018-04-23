import h2d.Bitmap;
import de.polygonal.ds.ArrayedQueue;

class BitmapTrail extends Entity.SpriteEntity
{
    var trail:ArrayedQueue<Bitmap> = new ArrayedQueue(16);
    var target:Bitmap;
    public var enabled:Bool = true;

    public function new(bitmap:Bitmap)
    {
        super(new h2d.Sprite(s2d));
        target = bitmap;
    }

    override public function update(dt:Float)
    {
        if(enabled)
        {
            var bmp = new Bitmap(target.tile, sprite);
            bmp.x = target.x;
            bmp.y = target.y;
            if(trail.size >= 16)
                trail.dequeue().remove();
            trail.enqueue(bmp);
        }
        
        for(bmp in trail)
            bmp.alpha -= 1 / 16;
    }

    override public function destroy()
    {
        super.destroy();
        trail.free();
    }

}