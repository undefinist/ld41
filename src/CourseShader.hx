class CourseShader extends hxsl.Shader
{
    static var SRC = {
        @:import h3d.shader.Base2d;

        @param var stripe_color : Vec4;
        @param var water_color : Vec4;
        @param var fairway_color : Vec4;
        @param var water_surface_tex : Sampler2D;
        @param var distort_tex : Sampler2D;

        function color_equal(a:Vec4, b:Vec4):Int
        {
            return int(a.r == b.r && a.g == b.g && a.b == b.b);
        }

        function fragment()
        {
            var is_fairway = color_equal(fairway_color, pixelColor);
            var add = is_fairway * step(sin(calculatedUV.y * 1024 / 8), 0) * (stripe_color - fairway_color);

            var uv_mul = 1024 / 64;
            var is_water = color_equal(water_color, pixelColor);
            // var distort_min = step(vec4(0.5, 0.5, 0, 0), texture2D(distort_tex, calculatedUV));
            // var distort_max = step(texture2D(distort_tex, calculatedUV), vec4(0.75, 0.75, 0, 0));
            // var distort = texture2D(distort_tex, calculatedUV);
            var distort = texture2D(distort_tex, calculatedUV  + vec2(time / 25, 0)).xy / 16;
            add += is_water * (texture2D(water_surface_tex, calculatedUV * uv_mul + distort + vec2(time / 100, 0)) - water_color);

            pixelColor = (pixelColor + add);
        }
    }
}