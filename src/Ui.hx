class Ui extends Entity
{
    var tf:h2d.Text;

    public function new()
    {
        super();

        var fnt = hxd.Res.font.toFont();
        tf = new h2d.Text(fnt, s2d);
        tf.text = "strokes: 0";
        tf.letterSpacing = 2;
        tf.textAlign = Right;
        tf.scaleX = 0.5;
        tf.scaleY = 0.5;
    }

    override public function destroy()
    {
        super.destroy();
        s2d.removeChild(tf);
    }

    override public function update(dt:Float)
    {
        if(Ball.game_over)
        {
            tf.text = 'you   took   ${Ball.strokes}   strokes!';
            tf.scaleX = 1;
            tf.scaleY = 1;
            tf.x = (s2d.width / 2) - s2d.x;
            tf.y = (s2d.height / 2) - s2d.y;
            tf.textAlign = Center;

            if(hxd.Key.isPressed(hxd.Key.R))
            {
                Entity.app.setScene(new PlayScene(Entity.app));
            }
            return;
        }

        tf.text = 'strokes:   ${Ball.strokes}';
        tf.x = (s2d.width - 16) - s2d.x;
        tf.y = (s2d.height - 16) - s2d.y;
    }
}