import h2d.col.Point as Vec;
import h2d.Bitmap;
import Entity.SpriteEntity;
import motion.easing.*;
import motion.Actuate;

class Ball extends SpriteEntity
{
    public static var position(default, null):Vec = new Vec();
    public static var strokes(default, null):Int = 0;
    public static var respawn_pos(default, null):Vec = new Vec();
    public static var game_over(default, null):Bool = false;

    static final LEAVE_GROUND_SPEED_THRESHOLD = 32.0;

    var collider:Collider;
    var trail:BitmapTrail;

    var shoot_start:Vec = new Vec();
    var shooter:Shooter;
    var can_shoot:Bool = false;

    var velocity:Vec = new Vec();

    public var landed(default, null):Bool = true;
    var rolling:Bool = false;

    var invulnerable:Float = 0;

    public var spawn_x(default, null):Float;
    public var spawn_y(default, null):Float;

    public function new(x:Float, y:Float)
    {
        collider = new Collider(this, x, y, 3);
        collider.tag = "ball";
        collider.onCollide = onCollide;

        var tile = hxd.Res.tee.toTile();
        tile.dx = -32;
        tile.dy = -32;
        var tee = new Bitmap(tile, s2d);
        tee.x = x;
        tee.y = y;

        tile = hxd.Res.ball.toTile();
        tile.dx = -3;
        tile.dy = -3;
        var bmp = new Bitmap(tile, s2d);

        trail = new BitmapTrail(bmp);
        trail.enabled = false;

        s2d.over(bmp);

        super(bmp);
        spawn_x = this.x = x;
        spawn_y = this.y = y;
        respawn_pos.set(x, y);
        position.set(x, y);
        strokes = 0;
        game_over = false;

        shooter = new Shooter(s2d);
        shooter.hide();

        hxd.Stage.getInstance().addEventTarget(onEvent);
    }

    override public function destroy()
    {
        super.destroy();
        hxd.Stage.getInstance().removeEventTarget(onEvent);
        s2d.removeChild(shooter);
        trail.destroy();
        collider.destroy();
    }

    override public function update(dt:Float)
    {
        if(invulnerable > 0)
        {
            invulnerable -= dt / 60;
            sprite.alpha = invulnerable > 0 ? Math.abs(Math.cos(invulnerable * Math.PI * 2)) : 1.0;
        }

        x += velocity.x * dt / 60;
        y += velocity.y * dt / 60;
        velocity = velocity.scale(rolling ? 0.99 : 0.9);
        collider.x = x;
        collider.y = y;

        position.set(x, y);

        var v_len = velocity.length();
        if(v_len < 64.0 && sprite.scaleX > 1.0)
        {
            var scl = 1.0 + hxd.Math.max(v_len - LEAVE_GROUND_SPEED_THRESHOLD, 0) / 48.0;
            sprite.scaleX = scl;
            sprite.scaleY = scl;
        }

        if(v_len > LEAVE_GROUND_SPEED_THRESHOLD)
        {
            shooter.alpha = 0.1;
            //sprite.rotation = Math.atan2(velocity.y, velocity.x);
            //sprite.scaleX = (hxd.Math.clamp(velocity.lengthSq(), 0.5, 4) - 0.5) / 3.5 / 2 + 1;
            //sprite.scaleX = 1
            trail.enabled = true;
        }
        else
        {
            shooter.alpha = 1.0;
            if(v_len < 0.0025)
                velocity.set(0, 0);

            if(!landed)
            {
                landed = true;
                rolling = true;
                var terrain = Course.instance.get_terrain_type(x, y);
                if(terrain == Sky || terrain == Water)
                    kill(true);
                else if(terrain == Sand)
                    rolling = false;
            }
            else if(rolling)
            {
                var terrain = Course.instance.get_terrain_type(x, y);
                if(terrain == Sky || terrain == Water)
                    kill(true);
                else if(terrain == Sand)
                    velocity = velocity.scale(0.95);
                else if(terrain == Rough)
                    velocity = velocity.scale(0.98);
            }

            if(Course.instance.hole.distanceSq(new Vec(x, y)) < 3.5 * 3.5)
            {
                game_over = true;
                destroy();
            }

            trail.enabled = false;
        }
        shooter.x = (shoot_start.x / s2d.zoom - s2d.x);
        shooter.y = (shoot_start.y / s2d.zoom - s2d.y);
    }

    private function shoot(v:Vec)
    {
        velocity = v.scale(5);
        var v_len_sq = velocity.lengthSq();
        if(v_len_sq > LEAVE_GROUND_SPEED_THRESHOLD * LEAVE_GROUND_SPEED_THRESHOLD)
        {
            landed = false;
            rolling = false;
            Actuate.tween(sprite, 0.5, {scaleX:2.0, scaleY:2.0});
        }
        else
        {
            rolling = true;
            landed = true;
        }

        ++strokes;
    }

    public function kill(force:Bool=false)
    {
        if(!force && invulnerable > 0)
            return;

        Time.freeze(10);
        Camera.instance.shake(4);

        var tile = hxd.Res.ring.toTile();
        tile.dx = -8;
        tile.dy = -8;
        var bmp = new Bitmap(tile, s2d);
        bmp.x = x;
        bmp.y = y;
        Actuate.tween(bmp, 0.25, {scaleX:0.5, scaleY:0.5}).onComplete(function() {
            Actuate.tween(bmp, 0.5, {scaleX:2.0, scaleY:2.0, alpha: 0.0}).ease(Sine.easeOut).onComplete(function() {
                s2d.removeChild(bmp);
            });
        });
        ++strokes;
        respawn();
    }

    private function respawn()
    {
        landed = true;
        rolling = false;
        x = spawn_x;
        y = spawn_y;
        invulnerable = 3;
        velocity.set(0, 0);
    }

    private function onCollide(other:Collider)
    {
        if(other.tag == "squid")
        {
            if(landed)
                return;

            var squid:Squid = cast other.entity;
            var dmg = Math.round(velocity.length());
            squid.damage(dmg);

            var normal:Vec = new Vec(x - other.x, y - other.y);
            normal.normalize();
            velocity = velocity.add(normal.scale(-velocity.dot(normal) * 2)).scale(0.75);

            Time.freeze(Math.round(dmg / 50));
            Camera.instance.shake(4);
        }
    }

    private function onEvent(e:hxd.Event)
    {
        if(e.kind == hxd.Event.EventKind.EPush)
        {
            var x = e.relX;
            var y = e.relY;
            if(x < 0 || y < 0 || x > hxd.Stage.getInstance().width || y > hxd.Stage.getInstance().height)
                return;

            if(e.button == 1)
            {
                shooter.hide();
                can_shoot = false;
                return;
            }
            
            shoot_start.x = x;
            shoot_start.y = y;
            can_shoot = true;
        }
        else if(e.kind == hxd.Event.EventKind.ERelease)
        {
            if(e.button == 0)
            {
                if(can_shoot && shooter.alpha == 1)
                {
                    var x = e.relX;
                    var y = e.relY;
                    var v = shoot_start.sub(new Vec(x, y));
                    if(v.lengthSq() > 128 * 128)
                    {
                        v.normalize();
                        v = v.scale(128);
                    }
                    shoot(v);
                }
                shooter.hide();
                can_shoot = false;
            }
        }
        else if(e.kind == hxd.Event.EventKind.EMove)
        {
            if(!can_shoot)
                return;

            var x = e.relX;
            var y = e.relY;
            // if(x < 0 || y < 0 || x > hxd.Stage.getInstance().width || y > hxd.Stage.getInstance().height)
            // {
            //     return;
            // }

            var v = shoot_start.sub(new Vec(x, y));
            var d_sqr = v.lengthSq();
            if(d_sqr > 16.0)
            {
                shooter.x = (shoot_start.x / s2d.zoom - s2d.x);
                shooter.y = (shoot_start.y / s2d.zoom - s2d.y);
                if(d_sqr > 128 * 128)
                {
                    v.normalize();
                    v = v.scale(128);
                }
                shooter.show(v.scale(0.3333333333 / s2d.zoom));
            }
            else
                shooter.hide();
        }
    }
}