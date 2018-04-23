import h2d.col.Point as Vec;

class Camera extends Entity
{
    public static var instance(default, null):Camera;

    public var target_x:Float = 0;
    public var target_y:Float = 0;
    public var follow:h2d.Sprite;

    public var x:Float = 0;
    public var y:Float = 0;

    var shake_offset:Vec = new Vec();
    var shake_amount:Float = 0;

    public function shake(amt:Float)
    {
        shake_amount = amt;
    }

    public function new()
    {
        super();
        instance = this;
    }

    override public function update(dt:Float)
    {
        if(follow != null)
        {
            target_x = follow.x;
            target_y = follow.y;
        }

        x = hxd.Math.lerp(x, target_x, 0.05);
        y = hxd.Math.lerp(y, target_y, 0.05);
        if(Math.abs(x - target_x) < 1)
            x = target_x;
        if(Math.abs(y - target_y) < 1)
            y = target_y;

        if(shake_amount > 0.1)
        {
            var a = Math.random() * Math.PI * 2;
            shake_offset.x = Math.cos(a) * shake_amount;
            shake_offset.y = Math.sin(a) * shake_amount;
            shake_amount *= 0.9;
        }
        else
            shake_offset.set(0, 0);

        s2d.x = -x - shake_offset.x + s2d.width / 2;
        s2d.y = -y - shake_offset.y + s2d.height / 2;
    }

    override public function destroy()
    {
        super.destroy();
        instance = null;
        follow = null;
    }
}