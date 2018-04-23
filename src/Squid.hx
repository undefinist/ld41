import h2d.Bitmap;
import h2d.col.Point as Vec;

class Squid extends Entity.SpriteEntity
{
    private static final ATTACK_DELAY = 2.5;
    private static final ATTACK_CYCLE = 1;

    var collider:Collider;

    var health:Int = 500;
    var elapsed:Float = 0;
    var state:Int = 0;
    var attack_cycle_count:Int = 0;
    var attack_angle_offset:Float = 0;

    public function new(x:Float, y:Float)
    {
        collider = new Collider(this, 0, 0, 16);
        collider.tag = "squid";
        collider.onCollide = onCollide;
        elapsed = Math.random();

        var tile = hxd.Res.goomsquid.toTile();
        tile.dx = -15;
        tile.dy = -20;
        var bmp = new Bitmap(tile, s2d);
        super(bmp);
        this.x = x;
        this.y = y;
    }

    override public function destroy()
    {
        super.destroy();
        collider.destroy();
    }

    override public function update(dt:Float)
    {
        dt /= 60;
        elapsed += dt;

        if(state == 0) // moving
        {
            var d_to_ball = Ball.position.sub(new Vec(x, y));
            d_to_ball.normalize();
            var new_x = x + d_to_ball.x * 16 * dt;
            var new_y = y + d_to_ball.y * 16 * dt;
            if(Ball.respawn_pos.distanceSq(new Vec(new_x, new_y)) > 40 * 40)
            {
                x = new_x;
                y = new_y;
            }

            if(elapsed > ATTACK_DELAY)
            {
                elapsed -= ATTACK_DELAY;
                state = 1;
                attack_cycle_count = 0;
                attack_angle_offset = Math.random();
            }
        }
        else if(state == 1)
        {
            if(elapsed > ATTACK_CYCLE)
            {
                elapsed -= ATTACK_CYCLE;
                do_attack(attack_angle_offset);
                attack_angle_offset += 0.1;
                if(++attack_cycle_count == 8)
                    state = 0;
            }
        }

        collider.x = x;
        collider.y = y;
    }

    public function do_attack(angle_offset:Float)
    {
        var num_bullets = 8;
        for(i in 0...num_bullets)
        {
            var a = angle_offset + Math.PI * 2 / num_bullets * i;
            new SquidBullet(x, y, a);
        }
    }

    public function damage(amt:Int)
    {
        health -= amt;
        if(health <= 0)
        {
            destroy();
        }
    }

    private function onCollide(other:Collider)
    {
        if(other.tag == "ball")
        {
            var ball:Ball = cast other.entity;
            if(ball.landed)
                ball.kill(true);
        }
    }
}

class SquidBullet extends Entity.SpriteEntity
{
    var collider:Collider;
    var velocity:Vec;
    var elapsed:Float = 0;

    public function new(x:Float, y:Float, rot:Float)
    {
        collider = new Collider(this, 0, 0, 2.5);
        collider.tag = "squidbullet";
        collider.onCollide = onCollide;

        var tile = hxd.Res.squid_bullet.toTile();
        tile.dx = -6;
        tile.dy = -2;
        var bmp = new Bitmap(tile, s2d);
        super(bmp);
        this.x = x;
        this.y = y;
        bmp.rotation = rot;

        velocity = new Vec(Math.cos(rot) * 128, Math.sin(rot) * 128);
    }

    override public function destroy()
    {
        super.destroy();
        collider.destroy();
    }

    override public function update(dt:Float)
    {
        x += velocity.x * dt / 60;
        y += velocity.y * dt / 60;
        collider.x = x + 0.5;
        collider.y = y + 0.5;

        elapsed += dt / 60;
        if(elapsed > 2.5)
            destroy();
    }

    private function onCollide(other:Collider)
    {
        if(other.tag == "ball")
        {
            var ball:Ball = cast other.entity;
            ball.kill();
        }
    }
}