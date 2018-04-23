import Course.TerrainType;

class PlayScene extends h2d.Scene
{
	var app:hxd.App;
	var camera:Camera;
	var ball:Ball;
	var course:Course;
	var ui:Ui;

    public function new(app:hxd.App)
    {
        super();
		this.app = app;
	}

	override public function onAdd()
	{
		super.onAdd();

		ctx.engine.backgroundColor = Sky;
		zoom = 2;

		course = new Course();

		var ball_pos = course.hole.sub(course.center);
		ball_pos.rotate(Math.PI);
		var ball_to_center = ball_pos.clone();
		ball_to_center.normalizeFast();
		ball_to_center.scale(120);
		ball_pos = ball_to_center.add(course.center);
		var terrain = course.get_terrain_type(Math.round(ball_pos.x), Math.round(ball_pos.y));
		while(terrain == Water || terrain == Sand)
		{
			ball_to_center.rotate(Math.PI / 32);
			ball_pos = ball_to_center.add(course.center);
			terrain = course.get_terrain_type(Math.round(ball_pos.x), Math.round(ball_pos.y));
		}
		ball = new Ball(ball_pos.x, ball_pos.y);

		camera = new Camera();
		camera.x = ball_pos.x;
		camera.y = ball_pos.y;
		camera.follow = ball.sprite;

		for(i in 0...8)
		{
			var a = Math.random() * Math.PI * 2;
			var x = Math.cos(a) * course.radius * (Math.random() * 0.8 + 0.1);
			var y = Math.sin(a) * course.radius * (Math.random() * 0.8 + 0.1);
			(new Squid(course.center.x + x, course.center.y + y));
		}

		ui = new Ui();
    }

	override public function onRemove()
	{
		Entity.clear();
	}
}