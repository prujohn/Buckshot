library text_box_tests_buckshot;

import 'dart:html';
import 'package:buckshot/buckshot_browser.dart';
import 'package:unittest/unittest.dart';

run(){
  group('TextBox', (){
    test('Throw on incorrect input type', (){
      TextBox t = new TextBox();

      Expect.throws(
          ()=> t.inputType.value = null,
          (e) => (e is BuckshotException)
      );
    });
    test('Accepts correct input types', (){
      TextBox t = new TextBox();

      //iterate through all the available types
      for(InputTypes s in InputTypes.validInputTypes){
        t.inputType.value = s;
      }
    });
  });
}
