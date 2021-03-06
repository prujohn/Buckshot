part of core_buckshotui_org;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.


/**
 * Represents property of an element that participates in the framework
 * [Binding] model.
 *
 * ## Usage ##
 * ### Declare a FrameworkProperty as a field ###
 *     FrameworkProperty<num> foo;
 *
 * ### Initialize a FrameworkProperty (usually in constructor) ###
 *     foo = new FrameworkProperty(this, "foo",
 *             defaultValue: 123
 *             converter: const StringToNumericConverter());
 *     // Provide a string converter if the property type is not a String.
 *     // This provides better compatibility with Template parsing.
 *
 * ### Template usage ###
 *     <MyElement my="42"></MyElement>
 *
 * ## See Also ##
 * * [AttachedFrameworkProperty]
 */
class FrameworkProperty<T> extends FrameworkPropertyBase
{
  T _value;

  /**
   * Sets the stored value of the FrameworkProperty.
   */
   set value(T newValue){
     if (stringToValueConverter != null && newValue is String){
       newValue = stringToValueConverter.convert(newValue);
     }

     // don't rebind if the value is the same.
     if (newValue == _value) return;

     previousValue = _value;
     _value = newValue;

     // 1) callback
     propertyChangedCallback(_value);

     // 2) bindings
     Binding._executeBindingsFor(this);

     // 3) event
     propertyChanging
     .invokeAsync(sourceObject,
         new PropertyChangingEventArgs(previousValue, _value));

     if(_traceProperty.isEmpty) return;
     if (_traceProperty.indexOf(propertyName) == -1) return;
     log('***TRACE***: object $sourceObject property $propertyName assigned value: $_value');
   }

  /** Gets the stored value of the FrameworkProperty. */
  T get value => _value;

  /** Gets the previous value of the FrameworkProperty. */
  T previousValue;

  /**
   *  Declares a FrameworkProperty and initializes it to the framework.
   */
  FrameworkProperty(
      BuckshotObject sourceObject,
      String propertyName,
      {Function propertyChangedCallback : null,
      T defaultValue : null,
      converter : null})
  : super(
      sourceObject,
      propertyName,
      propertyChangedCallback,
      converter)
  {

    if (!reflectionEnabled && sourceObject != null){
      sourceObject._frameworkProperties.add(this);
    }

    if (defaultValue == null) return;
    value = defaultValue;
  }

  String toString() => 'FrameworkProperty (${propertyName}, value: ${_value})';
}

/// A [FrameworkProperty] that supports participation in transition/animation features.
class AnimatingFrameworkProperty<T> extends FrameworkProperty<T>
{
  final String cssPropertyPeer;

  AnimatingFrameworkProperty(FrameworkElement sourceObject, String propertyName, String this.cssPropertyPeer, {Function propertyChangedCallback, T defaultValue: null, converter: null})
  : super(sourceObject, propertyName, propertyChangedCallback:propertyChangedCallback, defaultValue:defaultValue, converter:converter)
  {
    if (sourceObject is! FrameworkElement) throw const BuckshotException('AnimatingFrameworkProperty can only be used with elements that derive from FrameworkElement.');
  }
}