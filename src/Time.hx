@:allow(Main)
class Time
{
    private static var freeze_frames:Int = 0;

    public static function freeze(frames:Int)
    {
        if(frames > freeze_frames)
            freeze_frames = frames;
    }
}