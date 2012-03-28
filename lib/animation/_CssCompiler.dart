//   Copyright (c) 2012, John Evans & LUCA Studios LLC
//
//   http://www.lucastudios.com/contact
//   John: https://plus.google.com/u/0/115427174005651655317/about
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.


//intermediate data structure used during animation css compilation
class _CssAnimationObject{
  final StringBuffer css;
  final HashMap<String, Dynamic> carryOverTransforms;
  final HashMap<String, Dynamic> standardPropertyCarryOver;
  
  FrameworkElement concreteElement;
  
  _CssAnimationObject() 
  : 
    css = new StringBuffer(),
    carryOverTransforms = new HashMap<String, Dynamic>(),
    standardPropertyCarryOver = new HashMap<String, Dynamic>();
}

class _CssCompiler
{
  static final List<String> transformProperties = const ['translateX','translateY','translateZ','scaleX','scaleY','scaleZ','rotateX','rotateY','rotateZ'];
  
  static bool isTransformProperty(String property) => transformProperties.indexOf(property) > -1;
  
  static void compileAnimation(AnimationResource anim){
    
    if (anim._cachedAnimation != null || anim.keyFrames == null || anim.keyFrames.length == 0) return;

    //sort keyframe by time    
    sortKeyFrames(anim.keyFrames);
       
    if (anim.keyFrames[0].time < 0)
      throw const AnimationException('keyframe start time is < 0');
           
    //convert keyframe times to percentages
    computeKeyFramePercentages(anim.keyFrames);
     
    final HashMap<String, _CssAnimationObject> animHash = new HashMap<String, _CssAnimationObject>();
    
    AnimationKeyFrame previous;
    anim.keyFrames.forEach((AnimationKeyFrame k){
      
      //initialize any new elements
      k.states.forEach((AnimationState s){
        if (!animHash.containsKey(s.target)){
          animHash[s.target] = new _CssAnimationObject();
          animHash[s.target].concreteElement = BuckshotSystem.namedElements[s.target].makeMe();
          animHash[s.target].css.add('@keyframes ${anim.key}${s.target} { ');
          if (animHash[s.target].concreteElement == null) throw const AnimationException('Unable to find target name in object registry.');
        }
      });
      

      animHash.forEach((_, s){
        s.css.add(' ${k._percentage}% {');
      });
      
      //write the properties
      //TODO handle value conversion from complex properties, like gradient brushes
      
      k.states.forEach((AnimationState s){        
          _CssAnimationObject ao = animHash[s.target];
        AnimatingFrameworkProperty prop = ao.concreteElement._getPropertyByName(s.property);
        if (prop == null) throw new AnimationException('Unable to find specified property: ${s.property}');
        if (prop is! AnimatingFrameworkProperty) throw new AnimationException('Attempted to animate property ${s.property} that is not type AnimatingFrameworkProperty.');

        if (isTransformProperty(prop.cssPropertyPeerAndUnit.first)){
          ao.carryOverTransforms[prop.cssPropertyPeerAndUnit.first] = '${s.value}${prop.cssPropertyPeerAndUnit.second}';
        }else{
          ao.standardPropertyCarryOver[prop.cssPropertyPeerAndUnit.first] = '${s.value}${prop.cssPropertyPeerAndUnit.second}';
        }
        
      });


            
      //merge previous keyframe transforms
      animHash.forEach((t, ah){
        if (ah.standardPropertyCarryOver.length > 0){
          ah.standardPropertyCarryOver.forEach((kk, v){
            ah.css.add('${kk}: ${v};');
          });
        }
        
        if (ah.carryOverTransforms.length > 0 != null){
          ah.css.add('transform:');
          ah.carryOverTransforms.forEach((kk, v){
            ah.css.add(' ${kk}($v)');
          });
          ah.css.add(';}');
        }
      });      
    });
    
    //wrap in animation declaration and convert to multi browser
    StringBuffer compiledCSS = new StringBuffer();
    
    animHash.forEach((t, ah){
      ah.css.add(' } ');

      //now create the animation declarations

      StringBuffer sb = new StringBuffer();
      
      //create x-browser version of each animation
      _Dom.prefixes.forEach((String p){
        String temp = ah.css.toString();
        temp = temp.replaceAll('@keyframes', '@${p}keyframes');
        temp = temp.replaceAll('transform', '${p}transform');
        sb.add(temp);
      });       

      sb.add('#${t} { ${_Dom.generateXPCSS("animation", "${anim.key}${t} ${anim.keyFrames.last().time}s linear forwards")} }');
      
      compiledCSS.add(sb.toString());
    });

    BuckshotSystem._buckshotCSS.innerHTML = compiledCSS.toString();
    anim._cachedAnimation = compiledCSS.toString();
  }
  
  
  
  static void computeKeyFramePercentages(List<AnimationKeyFrame> keyFrames){
    var span = keyFrames.last().time;
            
    for(int i = 0; i < keyFrames.length; i++){
      keyFrames[i]._percentage = (keyFrames[i].time / span) * 100;
    }
  }
  
  static void sortKeyFrames(List<AnimationKeyFrame> keyFrames){
    keyFrames.sort((a, b){
      if (a.time < b.time) return -1;
      if (a.time > b.time) return 1;
      return 0;
    });
  }
}