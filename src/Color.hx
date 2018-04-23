abstract Color(Int) from Int to Int
{
    public var r(get, set):Float;
    public var g(get, set):Float;
    public var b(get, set):Float;
    public var a(get, set):Float;

    inline function set_r(val:Float):Float
    {
        this &= 0xff00ffff;
        this |= Math.round(val * 255) << 16;
        return val;
    }
    inline function get_r():Float
    {
        return ((this & 0x00ff0000) >> 16) / 255.0;
    }

    inline function set_g(val:Float):Float
    {
        this &= 0xffff00ff;
        this |= Math.round(val * 255) << 8;
        return val;
    }
    inline function get_g():Float
    {
        return ((this & 0x0000ff00) >> 8) / 255.0;
    }

    inline function set_b(val:Float):Float
    {
        this &= 0xffffff00;
        this |= Math.round(val * 255);
        return val;
    }
    inline function get_b():Float
    {
        return (this & 0x000000ff) / 255.0;
    }

    inline function set_a(val:Float):Float
    {
        this &= 0x00ffffff;
        this |= Math.round(val * 255) << 24;
        return val;
    }
    inline function get_a():Float
    {
        return ((this & 0xff000000) >> 24) / 255.0;
    }

    public static inline function rgba(r:Float, g:Float, b:Float, a:Float=1.0):Color
    {
        return new Color(
            Math.round(a * 255) << 24 |
            Math.round(r * 255) << 16 |
            Math.round(g * 255) << 8 |
            Math.round(b * 255)
        );
    }

    public inline function new(val:Int=0)
    {
        this = val;
    }
}