package funkin.ui.charSelect;

#if html5
import funkin.graphics.video.FlxVideo;
#end
#if hxvlc
import funkin.graphics.video.FunkinVideoSprite;
#end
import funkin.ui.MusicBeatSubState;
import funkin.save.Save;

/**
 * When you first enter the character select state, it will play an introductory video opening up the lights
 */
class IntroSubState extends MusicBeatSubState
{
  #if html5
  public static var LIGHTS_VIDEO_PATH:String = Paths.stripLibrary(Paths.videos('introSelect'));
  #end

  #if hxvlc
  public static var LIGHTS_VIDEO_PATH:String = Paths.videos('introSelect');
  #end

  public override function create():Void
  {
    if (Save.instance.oldChar)
    {
      onLightsEnd();
      return;
    }
    // Pause existing music.
    if (FlxG.sound.music != null)
    {
      FlxG.sound.music.destroy();
      FlxG.sound.music = null;
    }

    #if html5
    trace('Playing web video ${LIGHTS_VIDEO_PATH}');
    playVideoHTML5(LIGHTS_VIDEO_PATH);
    #end

    #if hxvlc
    trace('Playing native video ${LIGHTS_VIDEO_PATH}');
    playVideoNative(LIGHTS_VIDEO_PATH);
    #end

    // // Im TOO lazy to even care, so uh, yep
    // FlxG.camera.zoom = 0.66666666666666666666666666666667;
    // vid.x = -(FlxG.width - (FlxG.width * FlxG.camera.zoom));
    // vid.y = -((FlxG.height - (FlxG.height * FlxG.camera.zoom)) * 0.75);
  }

  #if html5
  public var vid:FlxVideo;

  public function playVideoHTML5(filePath:String):Void
  {
    // Video displays OVER the FlxState.
    vid = new FlxVideo(filePath);

    vid.scrollFactor.set();
    if (vid != null)
    {
      vid.zIndex = 0;

      vid.finishCallback = onLightsEnd;

      add(vid);
    }
    else
    {
      trace('ALERT: Video is null! Could not play cutscene!');
    }
  }
  #end

  #if hxvlc
  public var vid:FunkinVideoSprite;

  public function playVideoNative(filePath:String):Void
  {
    // Video displays OVER the FlxState.
    vid = new FunkinVideoSprite(0, 0);

    vid.scrollFactor.set();

    if (vid != null)
    {
      vid.zIndex = 0;
      vid.bitmap.onEndReached.add(onLightsEnd);

      add(vid);
      if (vid.load(filePath)) vid.play();
    }
    else
    {
      trace('ALERT: Video is null! Could not play cutscene!');
    }
  }
  #end

  public override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    // if (!introSound.paused)
    // {
    //   #if html5
    //   @:privateAccess
    //   vid.netStream.seek(introSound.time);
    //   #elseif hxvlc
    //   vid.bitmap.time = Std.int(introSound.time);
    //   #end
    // }
  }

  /**
   * When the lights video finishes, it will close the substate
   */
  public function onLightsEnd():Void
  {
    if (vid != null)
    {
      #if hxvlc
      vid.stop();
      #end
      remove(vid);
      vid.destroy();
      vid = null;
    }

    FlxG.camera.zoom = 1;

    close();
  }
}
