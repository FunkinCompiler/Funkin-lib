package;

import sys.io.File;

using StringTools;

// Patcher
// !! make sure to put "polymodExecFunc" in Module.hx
// !! THIS IS NOT AUTOMATIC
class CodePatcher
{
  static var blacklist:Array<String> = ["../funkin/ui/debug", "../funkin/play/notes/notekind/NoteKind.hx"];

  static var regex:Map<EReg, String> = [
    ~/@:hscriptClass\nclass +(.*) +extends +(.*) +implements .* +{}/g => "class $1 extends $2 {
  //! mock calls
  //* real implementations are handled by polymod

  /**
   * Initializes a scripted class instance using the given scripted class name and constructor arguments.
   * @param className Name of the target class extending $1 type
   * @param args List of argument of a scripted constructor. olny the first one seems to work?
   * @return $1
   */
  public static function init(className:String,...args:Any):$1 {
    return null;
  }
  /**
   * Polymod function: Calls a requested function from this scripted class using given arguments
   *
   * You must enable `mockPolymodCalls` to use this function
   * @param funcName Name of the target function
   * @param args Arguments for that function
   */
  public function polymodExecFunc(funcName:String, args:Array<Dynamic> = null):Dynamic {
    //* mock call. Once build it should be replaced with
    //* 'scriptCall'
    return null;
  }
	/**
	 * Returns the value of a custom field of the scripted class, by the given name.
	 	 *
	 	 * @param fieldName The name of the field to return.
	 	 * @return The value of the field, if any.
	 */
	 public function scriptGet(fieldName:String):Dynamic{return null;};
	/**
	 * Sets the value of a custom field of the scripted class, by the given name.
	 *
	 * @param fieldName The name of the field to set.
	 * @param value The value to set.
	 * @return The newly set value.
	 */
	 public function scriptSet(fieldName:String, value:Dynamic):Dynamic{return null; }
   /**
    * Returns a list of all the scripted classes which extend $1.
    * @return Array<String> THE list
    */
   public static function listScriptClasses():Array<String> {return null; }
}",
    ~/^  var (.*):(.*)/gm => "  public var $1:$2",
    ~/^  static var (.*):(.*)/gm => "  public static var $1:$2",
    ~/^  static final (.*):(.*)/gm => "  public static var $1:$2",
    ~/^  var (.*)/gm => "  public var $1",
    ~/^  static var (.*)/gm => "  public static var $1",
    ~/^  static final (.*)/gm => "  public static var $1",
    ~/^  public static final (.*):(.*)/gm => "  public static var $1:$2",
    ~/^  function (.*)\((.*)\)/gm => "  public function $1($2)",
    ~/^  private function (.*)\((.*)\):/gm => "  public function $1($2):",
    ~/^  static function (.*)\((.*)\):/gm => "  public static function $1($2):"
  ];

  public static function main()
  {
    scanForFiles("../funkin");
  }

  private static function scanForFiles(path:String):Void
  {
    if (sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path))
    {
      var entries = sys.FileSystem.readDirectory(path);
      for (entry in entries)
      {
        if (sys.FileSystem.isDirectory(path + '/' + entry))
        {
          scanForFiles(path + '/' + entry);
        }
        else
        {
          inspectFile(path + '/' + entry);
        }
      }
    }
  }

  private static function inspectFile(path:String)
  {
    for (x in blacklist)
    {
      if (path.startsWith(x)) return;
    }
    var content = File.getContent(path);
    trace(path);

    if (path == "../funkin/modding/module/ScriptedModule.hx")
    {
      // the only known exception
      File.saveContent(path, File.getContent("scriptModule.txt"));
      return;
    }

    for (x in regex.keys())
    {
      content = x.replace(content, regex[x]);
    }
    File.saveContent(path, content);
  }
}
