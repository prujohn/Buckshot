
class VarResourceTests extends TestGroupBase
{
 
  registerTests(){
    
    this.testGroupName = "VarResource Tests";
    
    testList["String values work"] = stringValuesWork;
    testList["Object values work"] = objectValuesWork;
  }
  
  void objectValuesWork(){
    var t = '''
<resourcecollection>
  <var key="contenttest">
    <textblock text="hello world!"></textblock>
  </var>
</resourcecollection>
''';
    
    Template
    .deserialize(t)
    .then(expectAsync1((_){
      final result = FrameworkResource.retrieveResource("contenttest");
      
      Expect.isTrue(result is TextBlock);      
    }));
  }
  
  void stringValuesWork(){
    var t = '''
  <resourcecollection>
<var key="test" value="hello world!"></var>
<var key="colortest" value="#007777"></var>
<var key="numtest" value="150"></var>
<var key="urltest" value="http://www.lucastudios.com/img/lucaui_logo_candidate2.png"></var>
</resourcecollection>
''';
    Template.deserialize(t)
      .then(expectAsync1((_){
        Expect.equals("hello world!", FrameworkResource.retrieveResource("test"));
        Expect.equals("#007777", FrameworkResource.retrieveResource("colortest"));
        Expect.equals("150", FrameworkResource.retrieveResource("numtest"));
        Expect.equals("http://www.lucastudios.com/img/lucaui_logo_candidate2.png", FrameworkResource.retrieveResource("urltest"));        
      }));
    
  }
}
