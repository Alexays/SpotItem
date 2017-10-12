import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/models/group.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/keys.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:flutter_google_places_autocomplete/flutter_google_places_autocomplete.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Edit item screen
class EditItemScreen extends StatefulWidget {
  /// Edit item screen initializer
  const EditItemScreen({Key key, this.itemId, this.item})
      : assert(itemId != null || item != null),
        super(key: key);

  /// Item id
  final String itemId;

  /// Item data
  final Item item;

  @override
  _EditItemScreenState createState() => new _EditItemScreenState(itemId, item);
}

class _EditItemScreenState extends State<EditItemScreen> with TickerProviderStateMixin {
  _EditItemScreenState(this._itemId, this._item);

  final String _itemId;

  Item _item;

  AnimationController _controller;
  Animation<Size> _bottomSize;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  /// Item name
  String _name;
  TextEditingController _nameCtrl;

  /// Item Description
  String _about;
  TextEditingController _aboutCtrl;

  /// Item location
  String _location;

  /// Images file
  final List<File> _imagesFile = [];

  /// Item tracks
  List<String> _tracks = [];

  /// Base64 images
  final List<String> _images = [];

  /// User groups
  List<Group> _groups = [];

  /// Item groups
  List<String> _groupsId = [];

  /// Geocoding class
  final GoogleMapsGeocoding geocoding = new GoogleMapsGeocoding(geoApiKey);

  @override
  void initState() {
    if (_item == null) {
      Services.items.getItem(_itemId).then((data) {
        if (!mounted) {
          return;
        }
        setState(() {
          _item = data;
          _initForm();
        });
      });
    } else {
      _initForm();
    }
    Services.groups.getGroups().then((data) {
      if (!mounted) {
        return;
      }
      setState(() {
        _groups = data;
      });
    });
    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bottomSize = new SizeTween(
      begin: new Size.fromHeight(kTextTabBarHeight + 40.0),
      end: new Size.fromHeight(kTextTabBarHeight + 280.0),
    )
        .animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.ease,
    ));
    super.initState();
  }

  void _initForm() {
    if (_item != null) {
      setState(() {
        _nameCtrl = new TextEditingController(text: _item.name);
        _aboutCtrl = new TextEditingController(text: _item.about);
        _groupsId = _item.groups ?? [];
        _tracks = _item.tracks ?? [];
      });
    }
  }

  Future<Null> getImage() async {
    final _fileName = await ImagePicker.pickImage();
    if (_fileName != null) {
      setState(() {
        _imagesFile.add(_fileName);
        _fileName.readAsBytes().then((data) {
          if (!mounted) {
            return;
          }
          _images.add('data:image/${_fileName.path.split('.').last};base64,${BASE64.encode(data)}');
        });
      });
    }
  }

  Widget getImageGrid() {
    if ((_item.images.length + _imagesFile.length) < 1) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(SpotL.of(context).noImages),
          const Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
          ),
          new RaisedButton(
            child: new Text(SpotL.of(context).addImage),
            onPressed: getImage,
          )
        ],
      );
    }
    return new GridView.count(
      primary: false,
      crossAxisCount: (_item.images.length + _imagesFile.length),
      crossAxisSpacing: 10.0,
      children: new List<Widget>.generate((_item.images.length + _imagesFile.length), (index) {
        if (index < _item.images.length) {
          return new GridTile(
              child: new Stack(
            children: <Widget>[
              new Image.network('$apiImgUrl${_item.images[index]}'),
              new Positioned(
                top: 2.5,
                left: 2.5,
                child: new IconButton(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete this image',
                  onPressed: () {
                    setState(() {
                      _item.images.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          ));
        } else {
          return new GridTile(
              child: new Stack(
            children: <Widget>[
              new Image.file(_imagesFile[index - _item.images.length]),
              new Positioned(
                top: 2.5,
                left: 2.5,
                child: new IconButton(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete this image',
                  onPressed: () {
                    setState(() {
                      _imagesFile.removeAt(index);
                      _images.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          ));
        }
      }),
    );
  }

  Future<Null> editItem(BuildContext context) async {
    final finalImages = <String>[];
    final groups = <String>[];
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      return showSnackBar(context, SpotL.of(context).correctError);
    }
    showLoading(context);
    _item.images.forEach(finalImages.add);
    _images.forEach(finalImages.add);
    var location = Services.users.location;
    if (location == null) {
      final geoRes = await geocoding.searchByAddress(_location);
      location = <String, double>{
        'latitude': geoRes.results[0].geometry.location.lat,
        'longitude': geoRes.results[0].geometry.location.lng
      };
    }
    if (location == null) {
      Navigator.of(context).pop();
      return showSnackBar(context, 'Please enable location or choose location !');
    }
    if (!Services.auth.user.isValid()) {
      Navigator.of(context).pop();
      return showSnackBar(context, SpotL.of(context).error);
    }
    final response = await Services.items.editItem({
      'id': _item.id,
      'name': _name,
      'about': _about,
      'lat': Services.users.location['latitude'].toString(),
      'lng': Services.users.location['longitude'].toString(),
      'images': JSON.encode(finalImages),
      'location': _location,
      'tracks': JSON.encode(_tracks),
      'groups': JSON.encode(groups)
    });
    Navigator.of(context).pop();
    if (resValid(context, response)) {
      showSnackBar(context, response.msg);
      await Services.items.getItems(force: true);
      await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Widget getGroups() {
    if (_groups == null) {
      return const Center(child: const CircularProgressIndicator());
    }
    if (_groups.isEmpty) {
      return new Center(child: new Text(SpotL.of(context).noGroups));
    }
    return new Column(
      children: new List<Widget>.generate(
          _groups.length,
          (index) => new CheckboxListTile(
                title: new Text(_groups[index].name),
                value: _groupsId.contains(_groups[index].id),
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _groupsId.add(_groups[index].id);
                    } else {
                      _groupsId.remove(_groups[index].id);
                    }
                  });
                },
                secondary: const Icon(Icons.people),
              )),
    );
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      body: new Builder(
          builder: (context) => new Column(
                children: <Widget>[
                  new Expanded(
                      child: new DefaultTabController(
                          length: 3,
                          child: new NestedScrollView(
                              headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
                                    new AnimatedBuilder(
                                        animation: _bottomSize,
                                        builder: (context, child) => new SliverAppBar(
                                            pinned: true,
                                            title:
                                                new Text(_item != null ? '${_item.name}' : SpotL.of(context).loading),
                                            bottom: new TabBar(indicatorWeight: 4.0, tabs: <Tab>[
                                              new Tab(text: SpotL.of(context).about),
                                              new Tab(text: SpotL.of(context).images),
                                              new Tab(text: SpotL.of(context).groups)
                                            ])))
                                  ],
                              body: _item == null
                                  ? const Center(child: const CircularProgressIndicator())
                                  : new Form(
                                      key: _formKey,
                                      child: new TabBarView(children: <Widget>[
                                        new Container(
                                            margin: const EdgeInsets.all(20.0),
                                            child: new Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  new TextFormField(
                                                    key: const Key('name'),
                                                    decoration: new InputDecoration(
                                                        hintText: SpotL.of(context).namePh,
                                                        labelText: SpotL.of(context).name),
                                                    validator: validateName,
                                                    controller: _nameCtrl,
                                                    onSaved: (data) {
                                                      _name = data;
                                                    },
                                                  ),
                                                  new TextFormField(
                                                    key: const Key('about'),
                                                    decoration: new InputDecoration(
                                                        hintText: SpotL.of(context).aboutPh,
                                                        labelText: SpotL.of(context).about),
                                                    controller: _aboutCtrl,
                                                    onSaved: (data) {
                                                      _about = data;
                                                    },
                                                  ),
                                                  new FlatButton(
                                                      onPressed: () async {
                                                        final p = await showGooglePlacesAutocomplete(
                                                            context: context,
                                                            apiKey: placeApiKey,
                                                            mode: Mode.overlay, // Mode.fullscreen
                                                            language: 'fr',
                                                            components: [new Component(Component.country, 'fr')]);
                                                        if (p?.description != null) {
                                                          setState(() {
                                                            _location = p.description;
                                                          });
                                                        }
                                                      },
                                                      child: new Text(_location ?? SpotL.of(context).location)),
                                                  new CheckboxListTile(
                                                    title: new Text(SpotL.of(context).gift),
                                                    value: _tracks.contains('gift'),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        if (value) {
                                                          _tracks.add('gift');
                                                        } else {
                                                          _tracks.remove('gift');
                                                        }
                                                      });
                                                    },
                                                    secondary: const Icon(Icons.card_giftcard),
                                                  ),
                                                  new CheckboxListTile(
                                                    title: new Text(SpotL.of(context).private),
                                                    value: _tracks.contains('private'),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        if (value) {
                                                          _tracks.add('private');
                                                        } else {
                                                          _tracks.remove('private');
                                                        }
                                                      });
                                                    },
                                                    secondary: const Icon(Icons.lock),
                                                  ),
                                                  new Flexible(
                                                    child: new ListView.builder(
                                                      scrollDirection: Axis.horizontal,
                                                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                                                      itemCount: Services.items.categories.length,
                                                      itemExtent: 75.0,
                                                      itemBuilder: (context, index) => !_tracks
                                                              .contains(Services.items.categories[index])
                                                          ? new FlatButton(
                                                              child: new Image.asset(
                                                                  'assets/${Services.items.categories[index]}.png'),
                                                              onPressed: () {
                                                                _tracks = _tracks
                                                                    .where((f) =>
                                                                        !Services.items.categories.any((d) => d == f))
                                                                    .toList()
                                                                      ..add(Services.items.categories[index]);
                                                                setState(() {
                                                                  _tracks = new List<String>.from(_tracks);
                                                                });
                                                              },
                                                            )
                                                          : new RaisedButton(
                                                              child: new Image.asset(
                                                                  'assets/${Services.items.categories[index]}.png'),
                                                              onPressed: () {
                                                                _tracks.remove(Services.items.categories[index]);
                                                                setState(() {
                                                                  _tracks = new List<String>.from(_tracks);
                                                                });
                                                              },
                                                            ),
                                                    ),
                                                  ),
                                                ])),
                                        new Container(
                                            margin: const EdgeInsets.all(20.0),
                                            child: new Column(children: [
                                              (_item.images.length + _imagesFile.length) > 0
                                                  ? new Padding(
                                                      padding: const EdgeInsets.only(bottom: 15.0),
                                                      child: new RaisedButton(
                                                        child: new Text(SpotL.of(context).addImage),
                                                        onPressed: getImage,
                                                      ))
                                                  : new Container(),
                                              new Flexible(
                                                child: getImageGrid(),
                                              )
                                            ])),
                                        _groups != null
                                            ? new Container(margin: const EdgeInsets.all(20.0), child: getGroups())
                                            : const Center(child: const CircularProgressIndicator()),
                                      ]))))),
                  new Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: new ConstrainedBox(
                        constraints:
                            new BoxConstraints.tightFor(height: 48.0, width: MediaQuery.of(context).size.width),
                        child: new RaisedButton(
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            editItem(context);
                          },
                          child: new Text(
                            SpotL.of(context).save.toUpperCase(),
                            style: new TextStyle(color: Theme.of(context).canvasColor),
                          ),
                        )),
                  ),
                ],
              )));
}
