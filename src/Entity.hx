class Entity
{
    @:allow(Main)
    private static var list:Array<Entity> = [];
    @:allow(Main)
    private static var app:hxd.App;
    public static function clear()
    {
        for(e in list)
        {
            if(e != null && !e.destroyed)
                e.destroy();
        }
        list = [];
    }

    private var s2d(get, never):h2d.Scene;
    private function get_s2d() { return app.s2d; }

    public var destroyed(default, null):Bool = false;

    public function new()
    {
        list.push(this);
    }

    public function update(dt:Float)
    {
        
    }

    public function destroy()
    {
        destroyed = true;
    }
}

class SpriteEntity extends Entity
{
    public var sprite(default, null):h2d.Sprite;

    public var x(get, set):Float;
    public var y(get, set):Float;

    public function new(sprite : h2d.Sprite)
    {
        super();
        this.sprite = sprite;
    }

    override public function destroy()
    {
        super.destroy();
        if(sprite.parent == null)
            s2d.removeChild(sprite);
        else
            sprite.remove();
        sprite = null;
    }

    private function get_x() { return sprite.x; }
    private function set_x(v:Float) { return sprite.x = v; }

    private function get_y() { return sprite.y; }
    private function set_y(v:Float) { return sprite.y = v; }
}