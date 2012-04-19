#import('../lib/Buckshot.dart');
#import('dart:html');

//#import('dart:json');

#source('ViewModel.dart');
#source('View.dart');
#source('MainUIView.dart');
#source('GridDemoView.dart');
#source('BorderDemoView.dart');
#source('StackPanelDebug.dart');

// This project is used for development of the buckshot project.
// Anything here may or may not be working properly, or may look strange.

class Debug {
  ViewModel _vm;
  
  Debug():
  _vm = new ViewModel(){}
   
  void run() {
    if (_vm == null) br("is null");

    _vm.title = "Demo"; //view can bind to this property   
           
   
    IPresentationFormatProvider p = new BuckshotTemplateProvider();
     
//    FrameworkObject o = p.deserialize('''
//      <textblock>Hello World.</textblock>
//      ''');
    
    String test =
'''
<stackpanel grid.column="2">

  <textblock text="Before Border TextBlock"></textblock>

  <border cursor="Crosshair" margin="10" width="300" height="300" background="Green" borderThickness="3" cornerradius="5" borderColor="Blue">

    <textblock horizontalalignment="center" text="In-Border TextBlock" foreground="White" fontSize="20">

      <!-- properties can be declared inside the element like so... -->
      <verticalAlignment>center</verticalAlignment>
    </textblock>

  </border>

  <textblock text="After Border TextBlock"></textblock>

</stackpanel>
''';
    
    FrameworkObject o = p.deserialize(test);
        
    //buckshot.renderRaw(o);
    
    
    //passing the view, which triggers rendering on the page. 
    //buckshot.rootView = new MainUIView();
    buckshot.rootView = new GridDemoView.with(_vm);
    //buckshot.rootView = new BorderDemoView();
    //buckshot.rootView = new StackPanelDebug();
        
  }
}

void main() {
  try{
    }catch(FrameworkException e){
      print("buckshot Framework initialization failed: ${e}");
    }
    catch(Exception e){
      print("*SYSTEM EXCEPTION* buckshot Framework initialization failed: ${e.toString()}");
      return;
    }

    
//  if (DEBUG){
//    try{
//      new Debug().run();
//      db("***end***");
//    }catch(FrameworkException e){
//      print("Unhandled Framework Exception: ${e.message}");
//      //window.alert("Unhandled Framework Exception: ${e.message}");
//    }
//    catch(Exception e){
//      print("Unhandled Exception: ${e.toString()}");
//      //window.alert("Unhandled Exception: ${e.toString()}");
//    }
//  }else{
    new Debug().run();
//  }
}
