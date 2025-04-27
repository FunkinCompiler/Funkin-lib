package funkin.api.newgrounds;

class NewgroundsCredentials
{
  public static var APP_ID:String = #if API_NG_APP_ID haxe.macro.Compiler.getDefine("API_NG_APP_ID") #else 'INSERT APP ID HERE' #end;
  public static var ENCRYPTION_KEY:String = #if API_NG_ENC_KEY haxe.macro.Compiler.getDefine("API_NG_ENC_KEY") #else 'INSERT ENCRYPTION KEY HERE' #end;
}