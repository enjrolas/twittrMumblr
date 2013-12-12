import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.json.*;
import twitter4j.internal.util.*;
import twitter4j.management.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;
import twitter4j.internal.json.*;
import java.net.HttpURLConnection;    // required for HTML download
import java.net.URL;                  // ditto, etc...
import java.net.URLConnection;
import java.net.URLEncoder;
import java.io.InputStreamReader;     // used to get our raw HTML source
import java.io.File;

float timing, startTime;
int lastReading=0;
int readingTime=10000;  //the time we wait to finish reading a tweet, in milliseconds
color currentColor, targetColor;
Twitter twitter;
ArrayList latestTweets;
ArrayList displayTweets;
int numberOfTweetsToDisplay=25;
boolean gettingTrendingTweets=false;
int woeid = 2487956;// yahoo's woeid (http://developer.yahoo.com/geo/geoplanet/guide/concepts.html) for the twitter location.

/* some sample WOEIDs.  You can look up more at http://woeid.rosselliot.co.nz/
 the world -- 1
 new york  -- 2459115
 san francisco -- 2487956
 manila    -- 1199477
 */

//Build an ArrayList to hold all of the words that we get from the imported tweets
ArrayList<String> words = new ArrayList();

void setup() {
  //Set the size of the stage, and the background to black.
  size(displayWidth, displayHeight);
  text("loading trending tweets...", width/2, height/2);
  currentColor = color(random(256), random(256), random(256));
  targetColor=currentColor;
  timing=frameCount+(int)random(500);
  startTime=0;
  smooth();

  displayTweets=new ArrayList();

  //Credentials
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setOAuthConsumerKey("Ap6CqNCdXJCN7BYTrrtZQ");
  cb.setOAuthConsumerSecret("ow5rK13ZbA7DoxDH2EoU3fjvsLDI7vh5ono4b9wDU");
  cb.setOAuthAccessToken("33208899-CSsFDf49w4RzL2h4bq2ZgAQxIxOXtwIEC0w0qfARF");
  cb.setOAuthAccessTokenSecret("nY8RAl69Dxpj8uVX8GCstoaSwpDJh20ihDoX4iRZ6WimZ");

  //Now we’ll make the main Twitter object that we can use to do pretty much anything you can do on the twitter website
  //– get status updates, run search queries, find follower information, etc. This Twitter object gets built by something
  //called the TwitterFactory, which needs our configuration information that we set above:
  twitter = new TwitterFactory(cb.build()).getInstance();
}

ArrayList getTrendingTweets()
{      
  ArrayList tweets=new ArrayList();
  Trends trends;
  //for each trending topic, get and sanitize the latest tweets on that topic, and add them to the arraylist of Strings
  try {
    //get list of trending topics
    trends = twitter.getPlaceTrends(woeid);
    for (int i = 0; i < trends.getTrends().length; i++) {
      Query query = new Query(trends.getTrends()[i].getName());
      QueryResult result = twitter.search(query);
      for (Status status : result.getTweets()) {
        String text=status.getText();
        String words[]=split(text, ' ');
        text="";
        for (int j=0;j<words.length;j++)
          if ((words[j].indexOf("/")==-1)&&(words[j].indexOf("@")==-1)&&(words[j].indexOf("#")==-1)&&(words[j].indexOf("RT")==-1))
            text+=words[j]+" ";
        if (text!="")
          tweets.add(text);
      }
    }
  }
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
  };
  gettingTrendingTweets=false;
  latestTweets=tweets;
  return tweets;
}



void draw() {
  colorFadingBackground();

  for (int i=0;i<displayTweets.size();i++)
    ((DisplayTweet)displayTweets.get(i)).display();
  if (latestTweets!=null)
  {
    if (millis()>(lastReading+readingTime))
    {
      lastReading=millis();
      if (latestTweets.size()>0)  //if we've still got some sweet tweets to talk about
      {

        println(latestTweets.size());
        int index=(int)random(latestTweets.size());
        println((String)latestTweets.get(index));
        TextToSpeech.say((String)latestTweets.get(index), TextToSpeech.voices[(int)random(TextToSpeech.voices.length)]);
        readingTime=split((String)latestTweets.get(index), ' ').length*400;  //wait 400ms/word for the reading to finish
        println(readingTime);
        displayTweets.add(new DisplayTweet((String)latestTweets.get(index)));
        if (displayTweets.size()>numberOfTweetsToDisplay)
          displayTweets.remove(0);
        latestTweets.remove(index);
      }
      else
        if (!gettingTrendingTweets)
        {
          fill(0);
          gettingTrendingTweets=true;
          thread("getTrendingTweets");
        }
    }
  }
  else
  {
    String msg="pulling in trending tweets";
    textSize(24);
    text(msg, width/2-textWidth(msg)/2, height/2-24/2);
    if (!gettingTrendingTweets)
    {
      fill(0);
      gettingTrendingTweets=true;
      thread("getTrendingTweets");
    }
  }
}

void colorFadingBackground()
{
  background(lerpColor(currentColor, targetColor, (frameCount-startTime)/(timing-startTime)));
  if (frameCount==timing)
  {
    targetColor= color(random(256), random(256), random(256));
    timing=frameCount+random(500);   
    startTime=frameCount;
  }
}

//Thanks to Frontier Nerds' awesome code -- http://frontiernerds.com/text-to-speech-in-processing
// the text to speech class
import java.io.IOException;

static class TextToSpeech extends Object {

  // Store the voices, makes for nice auto-complete in Eclipse

  // male voices
  static final String ALEX = "Alex";
  static final String BRUCE = "Bruce";
  static final String FRED = "Fred";
  static final String JUNIOR = "Junior";
  static final String RALPH = "Ralph";

  // female voices
  static final String AGNES = "Agnes";
  static final String KATHY = "Kathy";
  static final String PRINCESS = "Princess";
  static final String VICKI = "Vicki";
  static final String VICTORIA = "Victoria";

  // novelty voices
  static final String ALBERT = "Albert";
  static final String BAD_NEWS = "Bad News";
  static final String BAHH = "Bahh";
  static final String BELLS = "Bells";
  static final String BOING = "Boing";
  static final String BUBBLES = "Bubbles";
  static final String CELLOS = "Cellos";
  static final String DERANGED = "Deranged";
  static final String GOOD_NEWS = "Good News";
  static final String HYSTERICAL = "Hysterical";
  static final String PIPE_ORGAN = "Pipe Organ";
  static final String TRINOIDS = "Trinoids";
  static final String WHISPER = "Whisper";
  static final String ZARVOX = "Zarvox";

  // throw them in an array so we can iterate over them / pick at random
  static String[] voices = {
    ALEX, BRUCE, FRED, JUNIOR, RALPH, AGNES, KATHY, 
    PRINCESS, VICKI, VICTORIA, ALBERT, BAD_NEWS, BAHH, 
    BELLS, BOING, BUBBLES, CELLOS, DERANGED, GOOD_NEWS, 
    HYSTERICAL, PIPE_ORGAN, TRINOIDS, WHISPER, ZARVOX
  };

  // this sends the "say" command to the terminal with the appropriate args
  static void say(String script, String voice, int speed) {
    try {
      Runtime.getRuntime().exec(new String[] {
        "say", "-v", voice, "[[rate " + speed + "]]" + script
      }
      );
    }
    catch (IOException e) {
      System.err.println("IOException");
    }
  }

  // Overload the say method so we can call it with fewer arguments and basic defaults
  static void say(String script) {
    // 200 seems like a resonable default speed
    say(script, ALEX, 200);
  }

  // Overload the say method so we can call it with fewer arguments and basic defaults
  static void say(String script, String voice) {
    // 200 seems like a resonable default speed
    say(script, voice, 200);
  }
}

class DisplayTweet {
  String tweet;
  int x, y;
  color tweetColor;
  float angle;
  PFont font;
  DisplayTweet(String _tweet)
  {
    tweet=_tweet;
    x=(int)random(width);
    y=(int)random(height);
    tweetColor=color(random(256), random(256), random(256));
    angle=random(2*PI);
    font=createFont(PFont.list()[(int)random(PFont.list().length)], 48);
  }
  void display()
  {
    textFont(font);
    pushMatrix();
    translate(width/2, height/2);
    rotate(angle+(float)frameCount*.001);
    noStroke();
    fill(tweetColor);
    textSize(48);
    textSize(48*(width-x)/textWidth(tweet));
    text(tweet, x-width/2, y-height/2);
    popMatrix();
  }
}

