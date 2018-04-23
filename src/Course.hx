import h2d.col.Point as Vec;
import hxd.BitmapData;
import h2d.Bitmap;

class Course extends Entity
{
    static final MAX_INT = 0x7FFFFFF;
    public static var instance(default, null):Course;

    var data:BitmapData;
    var bitmap:Bitmap;
    public var hole(default, null):Vec;
    public var center(default, null):Vec;
    public var radius(default, null):Float;

    public function new()
    {
        super();

        instance = this;

        var w = 1024;
		var h = 1024;
        radius = 512;
        var half_rad = radius * 0.5;
		data = new hxd.BitmapData(w, h);

        var seed = Math.round(Math.random() * MAX_INT);
		var perlin = new hxd.Perlin();
        center = new Vec(w / 2, h / 2);
        hole = center.clone();
        var hole_dist_sq:Float = 0;

        data.lock();
        while(hole.x == center.x && hole.y == center.y)
        {
            hole_dist_sq = 0;
            seed = Math.round(Math.random() * MAX_INT);
            for(i in 0...h)
            {
                for(j in 0...w)
                {
                    var col;
                    var f = perlin.perlin(seed, i / 128, j / 128, 4, 1.5, 0.75);
                    var dist_from_center = new Vec(j - w / 2, i - h / 2).length();
                    if(dist_from_center > radius)
                    {
                        f = -10;
                    }
                    else if(dist_from_center > half_rad)
                    {
                        //f = 0;
                        var outside = dist_from_center - half_rad;
                        f *= hxd.Math.clamp(half_rad - outside, 0, half_rad) / half_rad;
                        //trace((w / 4 - (dist_from_center - w / 4)) / (w / 4));
                    }

                    if(f > 2.0) col = Green;
                    else if(f > 0.5) col = Fairway;
                    else if(f <= -10) col = Sky;
                    else if(f < -2.0) col = Water;
                    else if(f < -1.5) col = Sand;
                    else col = Rough;

                    if(f > 3.0)
                    {
                        var p = new Vec(j, i);
                        var dist_sqr = p.distanceSq(center);
                        if(dist_sqr > hole_dist_sq)
                        {
                            hole = p;
                            hole_dist_sq = dist_sqr;
                        }
                    }

                    data.setPixel(j, i, col);
                }
            }
        }

        // var resized = new BitmapData(w * 4, h * 4);
        // for(i in 0...w*4)
        // {
        //     for(j in 0...h*4)
        //     {
        //         var x = j / 4;
        //         var y = i / 4;
        //         var ratio_x = x - Math.floor(x);
        //         var ratio_y = y - Math.floor(y);
        //         hxd.Math.colorLerp(data.getPixel(j, i), data.getPixel())
        //     }
        // }
        
        data.unlock();

		var tile = h2d.Tile.fromBitmap(data);

        bitmap = new Bitmap(tile, s2d);
        var shader = new CourseShader();
        shader.stripe_color.setColor(0xff3d961d);
        shader.fairway_color.setColor(Fairway);
        shader.water_color.setColor(Water);
        shader.distort_tex = hxd.Res.water_distort.toTexture();
        shader.distort_tex.wrap = Repeat;
        shader.water_surface_tex = hxd.Res.water_surface.toTexture();
        shader.water_surface_tex.wrap = Repeat;
        shader.water_surface_tex.filter = Nearest;
        bitmap.addShader(shader);

        var hole_tile = hxd.Res.hole.toTile();
        hole_tile.dx = -5;
        hole_tile.dy = -35;
        var hole_bmp = new h2d.Bitmap(hole_tile, bitmap);
        hole_bmp.x = hole.x;
        hole_bmp.y = hole.y;
    }

    public function get_terrain_type(x:Float, y:Float):TerrainType
    {
        var x_to_c = x - center.x;
        var y_to_c = y - center.x;
        if(x_to_c * x_to_c + y_to_c * y_to_c > radius * radius)
            return Sky;
        else
            return data.getPixel(Std.int(x), Std.int(y));
    }
}

@:enum
abstract TerrainType(Color) from Color to Color
{
    var Green = 0xff99e550;
    var Fairway = 0xff6abe30;
    var Rough = 0xff37946e;
    var Sand = 0xffd9a066;
    var Water = 0xff639bff;
    var Sky = 0xff5fcde4;
}