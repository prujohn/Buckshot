part of core_buckshotui_org;

// Copyright (c) 2012, John Evans
// https://github.com/prujohn/Buckshot
// See LICENSE file for Apache 2.0 licensing information.


/**
* A control for displaying a list of items (and corresponding values) in a drop down pick list.
*/
class DropDownList extends Control
{
  FrameworkProperty<ObservableList<DropDownItem>> items;
  FrameworkProperty<List<String>> itemsSource;
  FrameworkProperty<DropDownItem> selectedItem;
  FrameworkProperty<num> selectedIndex; //TODO implement this property

  FrameworkEvent<SelectedItemChangedEventArgs<DropDownItem>> selectionChanged =
      new FrameworkEvent<SelectedItemChangedEventArgs<DropDownItem>>();

  DropDownList()
  {
    Browser.appendClass(rawElement, "dropdownlist");
    _initDropDownListProperties();

    registerEvent('selectionchanged', selectionChanged);
  }

  DropDownList.register() : super.register();
  makeMe() => new DropDownList();

  void _initDropDownListProperties(){
    items = new FrameworkProperty(this, "items",
        defaultValue:new ObservableList<DropDownItem>());

    itemsSource = new FrameworkProperty(this, "itemsSource",
        propertyChangedCallback: (List<String> v){
          _updateDDL();
        });

    selectedItem = new FrameworkProperty(this, "selectedItem",
        defaultValue:new DropDownItem());

    items.value.listChanged + (_, __) {
      if (!isLoaded) return;
      _updateDDL();
    };



    rawElement.on.change.add((e) => doNotify());
  }

  void doNotify(){
    DropDownItem selected;
    final el = rawElement as SelectElement;

    if (itemsSource.value != null && !itemsSource.value.isEmpty) {
      selectedItem.value.name.value = itemsSource.value[el.selectedIndex];
      selectedItem.value.item.value = itemsSource.value[el.selectedIndex];
      if (selectedItem.value.item.value is DropDownItem){
        selected = selectedItem.value.item.value;
      }else{
        selected = new DropDownItem()
          ..name.value = selectedItem.value.item.value;
      }
    }else if (!items.value.isEmpty){
      selected = items.value[el.selectedIndex];
      selectedItem.value.name.value = selected.name.value;
      selectedItem.value.item.value = selected.item.value;
    }

    if (selected != null){
      selectionChanged
      .invokeAsync(this,
          new SelectedItemChangedEventArgs<DropDownItem>(selected));
    }
  }

  void onLoaded(){
    _updateDDL();
    doNotify();
  }

  void _updateDDL(){
    rawElement.elements.clear();

    if (itemsSource.value != null){
      itemsSource.value.forEach((i){
        var option = new OptionElement();
        option.attributes['value'] = '$i';
        option.text = '$i';
        rawElement.elements.add(option);
      });

    }else{
      items.value.forEach((DropDownItem i){
        var option = new OptionElement();
        option.attributes['value'] = i.item.value;
        option.text = i.name.value;

        rawElement.elements.add(option);
      });
    }
  }

  /// Overridden [FrameworkObject] method for generating the html representation of the DDL.
  void createElement(){
    rawElement = new Element.tag('select');
  }

  get defaultControlTemplate => '';
}


class DropDownItem extends TemplateObject
{
  FrameworkProperty<String> name;
  FrameworkProperty<dynamic> item;

  DropDownItem(){
    _initDropDownListItemProperties();
  }

  DropDownItem.register() : super.register();
  makeMe() => new DropDownItem();

  void _initDropDownListItemProperties(){
    name = new FrameworkProperty(this, "name", defaultValue:'');

    item = new FrameworkProperty(this, "value");
  }
}