class Collider extends h2d.col.Circle
{
    @:allow(Main)
    private static var list:Array<Collider> = [];
    
    public var onCollide:(Collider)->Void;
    public var destroyed(default, null):Bool = false;
    public var entity(default, null):Entity;
    public var tag:String = "default";

    public function new(entity:Entity, x:Float, y:Float, rad:Float)
    {
        super(x, y, rad);
        list.push(this);
        this.entity = entity;
    }

    public function destroy()
    {
        destroyed = true;
    }
}