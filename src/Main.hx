class Main extends hxd.App
{
	override function init()
	{
		hxd.Res.initEmbed();
		Entity.app = this;

		this.engine.resize(640, 360);
		setScene2D(new PlayScene(this));
	}
	
	override function update(dt:Float)
	{
		if(Time.freeze_frames > 0)
		{
			--Time.freeze_frames;
			return;
		}

		for(e in Entity.list)
		{
			if(!e.destroyed)
				e.update(dt);
		}
		for(i in 0...Collider.list.length)
		{
			if(Collider.list[i].destroyed)
				continue;

			for(j in i...Collider.list.length)
			{
				if(Collider.list[j].destroyed)
					continue;

				var ci = Collider.list[i];
				var cj = Collider.list[j];
				if(ci.collideCircle(cj))
				{
					if(ci.onCollide != null)
						ci.onCollide(cj);
					if(cj.onCollide != null)
						cj.onCollide(ci);
				}
			}
		}
		
		var i = -1;
		while(++i < Entity.list.length)
		{
			if(Entity.list[i].destroyed)
				Entity.list.splice(i--, 1);
		}
		i = -1;
		while(++i < Collider.list.length)
		{
			if(Collider.list[i].destroyed)
				Collider.list.splice(i--, 1);
		}
	}
	
	static function main()
	{
		new Main();
	}
}