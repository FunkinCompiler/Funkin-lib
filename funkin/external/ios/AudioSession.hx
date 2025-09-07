package funkin.external.ios;

#if ios
/**
 * A Utility class to manage iOS audio.
 */
@:build(funkin.util.macro.LinkerMacro.xml('project/Build.xml'))
@:include('AudioSession.hpp')
@:unreflective
extern class AudioSession
{
  @:native('initialize')
  public static function initialize():Void;
  @:native('setActive')
  public static function setActive(active:Bool):Void;
}
#end
