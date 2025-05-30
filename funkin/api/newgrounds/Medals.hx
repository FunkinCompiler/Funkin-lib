package funkin.api.newgrounds;

#if FEATURE_NEWGROUNDS
import io.newgrounds.objects.Medal as MedalData;
import funkin.util.plugins.NewgroundsMedalPlugin;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.Json;

class Medals
{
  public static var medalJSON:Array<MedalJSON>;

  public static function listMedalData():Map<Medal, MedalData>
  {
    if (NewgroundsClient.instance.medals == null)
    {
      trace('[NEWGROUNDS] Not logged in, cannot fetch medal data!');
      return [];
    }

    var result:Map<Medal, MedalData> = [];

    for (medalId in NewgroundsClient.instance.medals.keys())
    {
      var medalData = NewgroundsClient.instance.medals.get(medalId);
      if (medalData == null) continue;

      // A little hacky, but it works.
      result.set(cast medalId, medalData);
    }

    return result;
  }

  public static function isValid(medalData:MedalData):Bool
  {
    // IDK why medalData can exist but _data can be null...
    // TODO: Move checks to the NG library.
    @:privateAccess
    return (medalData != null && medalData._data != null);
  }

  public static function award(medal:Medal):Void
  {
    if (NewgroundsClient.instance.isLoggedIn())
    {
      var medalData = NewgroundsClient.instance.medals.get(medal.getId());
      if (!isValid(medalData))
      {
        trace('[NEWGROUNDS] Could not retrieve data for medal: ${medal}');
        return;
      }

      if (!medalData.unlocked)
      {
        trace('[NEWGROUNDS] Awarding medal (${medal}).');
        medalData.sendUnlock();

        // Play the medal unlock animation, but only if the user has not already unlocked it.
        #if html5
        // Web builds support parsing the bitmap data from the URL directly.
        BitmapData.loadFromFile("https:" + medalData.icon).onComplete(function(bmp:BitmapData) {
          var medalGraphic = FlxGraphic.fromBitmapData(bmp);
          medalGraphic.persist = true;
          NewgroundsMedalPlugin.play(medalData.value, medalData.name, medalGraphic);
        });
        #else
        if (medalJSON == null) loadMedalJSON();
        // We have to use a medal image from the game files. We use a Base64 encoded image that NG spits out.
        // TODO: Wait, don't they give us the medal icon?

        var g:FlxGraphic = null;

        var localMedalData:Null<MedalJSON> = medalJSON.filter(function(jsonMedal) {
          #if FEATURE_NEWGROUNDS_TESTING_MEDALS
          return medal == jsonMedal.idTest;
          #else
          return medal == jsonMedal.id;
          #end
        })[0];

        if (localMedalData == null) throw "You forgot to encode a Base64 image for medal: " + medal;

        var str:String = localMedalData.icon;
        // Lime/OpenFL parses it without the included prefix stuff, so we remove it.
        str = str.replace("data:image/png;base64,", "").trim();
        var bitmapData = BitmapData.fromBase64(str, "image/png");
        if (str != null) g = FlxGraphic.fromBitmapData(bitmapData);
        g.persist = true;

        NewgroundsMedalPlugin.play(medalData.value, medalData.name, g);
        #end
      }
      else
      {
        trace('[NEWGROUNDS] User already has medal (${medal}).');
      }
    }
    else
    {
      trace('[NEWGROUNDS] Attempted to award medal (${medal}), but not logged into Newgrounds.');
    }
  }

  public static function loadMedalJSON():Void
  {
    var jsonPath = Paths.json('medals');

    var jsonString = Assets.getText(jsonPath);

    var parser = new json2object.JsonParser<Array<MedalJSON>>();
    parser.ignoreUnknownVariables = false;
    trace('[NEWGROUNDS] Parsing local medal data...');
    parser.fromJson(jsonString, jsonPath);

    if (parser.errors.length > 0)
    {
      trace('[NEWGROUNDS] Failed to parse local medal data!');
      for (error in parser.errors)
        funkin.data.DataError.printError(error);
      medalJSON = null;
    }
    else
    {
      medalJSON = parser.value;
    }
  }

  public static function awardStoryLevel(id:String):Void
  {
    switch (id)
    {
      case 'tutorial':
        Medals.award(Medal.StoryTutorial);
      case 'week1':
        Medals.award(Medal.StoryWeek1);
      case 'week2':
        Medals.award(Medal.StoryWeek2);
      case 'week3':
        Medals.award(Medal.StoryWeek3);
      case 'week4':
        Medals.award(Medal.StoryWeek4);
      case 'week5':
        Medals.award(Medal.StoryWeek5);
      case 'week6':
        Medals.award(Medal.StoryWeek6);
      case 'week7':
        Medals.award(Medal.StoryWeek7);
      case 'weekend1':
        Medals.award(Medal.StoryWeekend1);
      default:
        trace('[NEWGROUNDS] Story level does not have a medal! (${id}).');
    }
  }
}
#end

/**
 * Represents NG Medal data in a JSON format.
 */
typedef MedalJSON =
{
  /**
   * Medal ID to use for release builds
   */
  public var id:Int;

  /**
   * Medal ID to use for testing builds
   */
  public var idTest:Int;

  /**
   * The English name for the medal
   */
  public var name:String;

  /**
   * The English name for the medal
   */
  public var icon:String;
}

enum abstract Medal(Int) from Int to Int
{
  /**
   * Represents an undefined or invalid medal.
   */
  public var Unknown = -1;

  /**
   * I Said Funkin'!
   * Start the game for the first time.
   */
  public var StartGame = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80894 #else 60960 #end;

  /**
   * That's How You Do It!
   * Beat Tutoria l in Story Mode (on any difficulty).
   */
  public var StoryTutorial = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80906 #else 83647 #end;

  /**
   * More Like Daddy Queerest
   * Beat Week 1 in Story Mode (on any difficulty).
   */
  public var StoryWeek1 = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80899 #else 60961 #end;

  /**
   * IT IS THE SPOOKY MONTH
   * Beat Week 2 in Story Mode (on any difficulty).
   */
  public var StoryWeek2 = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80900 #else 83648 #end;

  /**
   * Pico Funny
   * Beat Week 3 in Story Mode (on any difficulty).
   */
  public var StoryWeek3 = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80901 #else 83649 #end;

  /**
   * Mommy Must Murder
   * Beat Week 4 in Story Mode (on any difficulty).
   */
  public var StoryWeek4 = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80902 #else 83650 #end;

  /**
   * Yule Tide Joy
   * Beat Week 5 in Story Mode (on any difficulty).
   */
  public var StoryWeek5 = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80903 #else 83651 #end;

  /**
   * A Visual Novelty
   * Beat Week 6 in Story Mode (on any difficulty).
   */
  public var StoryWeek6 = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80904 #else 83652 #end;

  /**
   * I <3 JohnnyUtah
   * Beat Week 7 in Story Mode (on any difficulty).
   */
  public var StoryWeek7 = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80905 #else 83653 #end;

  /**
   * Yo, Really Think So?
   * Beat Weekend 1 in Story Mode (on any difficulty).
   */
  public var StoryWeekend1 = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80907 #else 83654 #end;

  /**
   * Stay Funky
   * Press TAB in Freeplay and unlock your first character.
   */
  public var CharSelect = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 83633 #else 83655 #end;

  /**
   * A Challenger Appears
   * Beat any Pico remix in Freeplay (on any difficulty).
   */
  public var FreeplayPicoMix = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80910 #else 83656 #end;

  /**
   * De-Stressing
   * Beat Stress (Pico Mix) in Freeplay (on Normal difficulty or higher).
   */
  public var FreeplayStressPico = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 83629 #else 83657 #end;

  /**
   * L
   * Earn a Loss rating on any song (on any difficulty).
   */
  public var LossRating = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80915 #else 83658 #end;

  /**
   * Getting Freaky
   * Earn a Perfect rating on any song on Hard difficulty or higher.
   * NOTE: Should also be awarded for a Gold Perfect because otherwise that would be annoying.
   */
  public var PerfectRatingHard = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80908 #else 83659 #end;

  /**
   * You Should Drink More Water
   * Earn a Golden Perfect rating on any song on Hard difficulty or higher.
   */
  public var GoldPerfectRatingHard = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80909 #else 83660 #end;

  /**
   * Harder Than Hard
   * Beat any Erect remix in Freeplay on Erect or Nightmare difficulty.
   */
  public var ErectDifficulty = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80911 #else 83661 #end;

  /**
   * The Rap God
   * Earn a Gold Perfect rating on any song on Nightmare difficulty.
   */
  public var GoldPerfectRatingNightmare = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80912 #else 83662 #end;

  /**
   * Just like the game!
   * Get freaky on a Friday.
   * NOTE: You must beat at least one song on any difficulty.
   */
  public var FridayNight = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80913 #else 61034 #end;

  /**
   * Nice
   * Earn a rating of EXACTLY 69% (good luck).
   */
  public var Nice = #if FEATURE_NEWGROUNDS_TESTING_MEDALS 80914 #else 83646 #end;

  public function getId():Int
  {
    return this;
  }

  public static function getMedalByStoryLevel(levelId:String):Medal
  {
    switch (levelId)
    {
      case "week1":
        return StoryWeek1;
      case "week2":
        return StoryWeek2;
      case "week3":
        return StoryWeek3;
      case "week4":
        return StoryWeek4;
      case "week5":
        return StoryWeek5;
      case "week6":
        return StoryWeek6;
      case "week7":
        return StoryWeek7;
      case "weekend1":
        return StoryWeekend1;
      default:
        return Unknown;
    }
  }
}
