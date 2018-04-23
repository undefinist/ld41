import h2d.Bitmap;
import h2d.col.Point as Vec;

class Shooter extends h2d.Sprite
{
    var base:Bitmap;
    var extend:Bitmap;
    var arrow:Bitmap;

    public function new(parent:h2d.Sprite)
    {
        super(parent);

        var arrow_tile = hxd.Res.arrow.toTile();
        base = new Bitmap(arrow_tile.sub(0, 6, 5, 3, -2, -1), this);
        extend = new Bitmap(arrow_tile.sub(0, 3, 5, 3, -2, -3), this);
        arrow = new Bitmap(arrow_tile.sub(0, 0, 5, 3, -2, -1), this);

        extend.y = -1;
    }

    public function show(v:Vec)
    {
        var a = Math.atan2(v.y, v.x);
        rotation = a + Math.PI / 2;
        
        extend.scaleY = v.length();
        arrow.y = -extend.scaleY * extend.tile.height - 1;

        visible = true;
    }

    public function hide()
    {
        visible = false;
    }

}