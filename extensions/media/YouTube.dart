// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.

#library('extensions_media_youtube');
#import('../../lib/Buckshot.dart');

class YouTube extends FrameworkElement
{
  FrameworkProperty videoIDProperty;
  
  FrameworkObject makeMe() => new YouTube();
  
  YouTube(){
    Dom.appendClass(rawElement, "buckshot_youtube");
    
    _initializeYouTubeProperties();
    
  }
  
  
  void _initializeYouTubeProperties(){
    videoIDProperty = new FrameworkProperty(this, "videoID", (String value){
      rawElement.attributes["src"] = 'http://www.youtube.com/embed/${value.toString()}';
    });
  }
  
  String get videoID() => getValue(videoIDProperty);
  set videoID(String value) => setValue(videoIDProperty, value);
  
  
  void createElement(){
    rawElement = Dom.createByTag("iframe");
    Dom.appendClass(rawElement, 'youtube-player');
    rawElement.attributes["type"] = "text/html";
    rawElement.attributes["frameborder"] = "0";
  }
  
  String get type() => "YouTube";
}
