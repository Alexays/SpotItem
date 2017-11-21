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
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/ui/widgets/calendar.dart';

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

class _EditItemScreenState extends State<EditItemScreen>
    with TickerProviderStateMixin {
  _EditItemScreenState(this._itemId, this._item);

  final String _itemId;

  Item _item;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  /// Item name
  final TextEditingController _nameCtrl = new TextEditingController();

  /// Item Description
  final TextEditingController _aboutCtrl = new TextEditingController();

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

  /// Item calendar
  List<Event> _calendar = [];

  @override
  void initState() {
    super.initState();
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
    Services.groups.getAll().then((data) {
      if (!mounted) {
        return;
      }
      setState(() {
        _groups = data;
      });
    });
  }

  void _initForm() {
    if (_item != null) {
      setState(() {
        _nameCtrl.text = _item.name;
        _aboutCtrl.text = _item.about;
        _groupsId = _item.groups ?? [];
        _tracks = _item.tracks ?? [];
        _location = _item.location;
        _calendar = _item.calendar;
      });
    }
  }

  Future<Null> _getImage() async {
    final _fileName = await ImagePicker.pickImage(maxWidth: 720.0);
    if (mounted && _fileName != null) {
      setState(() {
        _imagesFile.add(_fileName);
        _fileName.readAsBytes().then((data) {
          if (!mounted) {
            return;
          }
          _images.add(
              'data:image/${_fileName.path.split('.').last};base64,${BASE64.encode(data)}');
        });
      });
    }
  }

  Widget _getImageGrid() {
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
            onPressed: _getImage,
          )
        ],
      );
    }
    return new GridView.count(
      primary: false,
      crossAxisCount: (_item.images.length + _imagesFile.length),
      crossAxisSpacing: 10.0,
      children: new List<Widget>.generate(
          (_item.images.length + _imagesFile.length), (index) {
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

  Future<Null> _editItem(BuildContext context) async {
    final finalImages = <String>[];
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      showSnackBar(context, SpotL.of(context).correctError);
      return;
    }
    showLoading(context);
    _item.images.forEach(finalImages.add);
    _images.forEach(finalImages.add);
    final location = Services.users.location ??
        await Services.users.getLocationByAddress(_location);
    if (location == null) {
      Navigator.of(context).pop();
      showSnackBar(context, SpotL.of(context).locationError);
      return;
    }
    if (!Services.auth.user.isValid()) {
      Navigator.of(context).pop();
      showSnackBar(context, SpotL.of(context).error);
      return;
    }
    final response = await Services.items.editItem({
      'id': _item.id,
      'name': _nameCtrl.text,
      'about': _aboutCtrl.text,
      'lat': Services.users.location['latitude'],
      'lng': Services.users.location['longitude'],
      'images': finalImages,
      'calendar': _calendar.map((f) => f.toJson()).toList(),
      'location': _location,
      'tracks': _tracks,
      'groups': _groupsId
    });
    Navigator.of(context).pop();
    if (!resValid(context, response)) {
      return;
    }
    showSnackBar(context, response.msg);
    await Services.items.getItems(force: true);
    await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Widget _getGroups() {
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
                  value
                      ? _groupsId.add(_groups[index].id)
                      : _groupsId.remove(_groups[index].id);
                });
              },
              secondary: const Icon(Icons.people),
            ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) => new Form(
        key: _formKey,
        child: new ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          children: <Widget>[
            new TextFormField(
              key: const Key('name'),
              decoration: new InputDecoration(
                  hintText: SpotL.of(context).namePh,
                  labelText: SpotL.of(context).name),
              validator: validateName,
              controller: _nameCtrl,
              initialValue: _nameCtrl.text,
            ),
            new TextFormField(
              key: const Key('about'),
              decoration: new InputDecoration(
                  hintText: SpotL.of(context).aboutPh,
                  labelText: SpotL.of(context).about),
              controller: _aboutCtrl,
              initialValue: _aboutCtrl.text,
            ),
            new Stack(
              children: <Widget>[
                new FocusScope(
                  node: new FocusScopeNode(),
                  child: new TextFormField(
                    decoration: new InputDecoration(
                        hintText: SpotL.of(context).locationPh,
                        labelText: SpotL.of(context).location),
                    initialValue: _location,
                  ),
                ),
                new GestureDetector(
                  onTap: () async {
                    final p = await Services.users.autocompleteCity(context);
                    if (mounted && p != null) {
                      setState(() {
                        _location = p;
                      });
                    }
                  },
                  child: new Container(
                    color: Colors.transparent,
                    height: 75.0,
                  ),
                ),
              ],
            ),
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
            new Container(
              height: 100.0,
              child: new ListView.builder(
                shrinkWrap: true,
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
            new Image.network('$apiUrl/items/${_item.id}/code')
          ],
        ),
      );

  Widget _buildImages(BuildContext context) => new Container(
        margin: const EdgeInsets.all(20.0),
        child: new Column(children: [
          (_item.images.length + _imagesFile.length) > 0
              ? new Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: new RaisedButton(
                    child: new Text(SpotL.of(context).addImage),
                    onPressed: _getImage,
                  ),
                )
              : new Container(),
          new Flexible(child: _getImageGrid())
        ]),
      );

  Widget _buildCalendar(BuildContext context) => new Container(
        height: MediaQuery.of(context).size.height,
        child: new Calendar(
          allowDisable: true,
          edit: true,
          selectedDates: _calendar,
          onChanged: (value) {
            setState(() {
              _calendar = value;
            });
          },
        ),
      );

  Widget _buildGroups(BuildContext context) => _groups != null
      ? new Container(
          margin: const EdgeInsets.all(20.0),
          child: _getGroups(),
        )
      : const Center(child: const CircularProgressIndicator());

  @override
  Widget build(BuildContext context) => new Scaffold(
        body: new Builder(
          builder: (context) {
            Services.context = context;
            return new DefaultTabController(
              length: 4,
              child: new NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
                      new SliverAppBar(
                        pinned: true,
                        floating: true,
                        snap: true,
                        title:
                            new Text(_item?.name ?? SpotL.of(context).loading),
                        bottom: new TabBar(
                          indicatorWeight: 4.0,
                          tabs: <Tab>[
                            new Tab(text: SpotL.of(context).about),
                            new Tab(text: SpotL.of(context).images),
                            new Tab(text: SpotL.of(context).calendar),
                            new Tab(text: SpotL.of(context).groups)
                          ],
                        ),
                      ),
                    ],
                body: _item == null
                    ? const Center(child: const CircularProgressIndicator())
                    : new TabBarView(
                        children: <Widget>[
                          _buildForm(context),
                          _buildImages(context),
                          _buildCalendar(context),
                          _buildGroups(context),
                        ],
                      ),
              ),
            );
          },
        ),
        bottomNavigationBar: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: new ConstrainedBox(
            constraints: new BoxConstraints.tightFor(
              height: 48.0,
              width: MediaQuery.of(context).size.width,
            ),
            child: new Builder(
              builder: (context) => new RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () => _editItem(context),
                    child: new Text(
                      SpotL.of(context).save.toUpperCase(),
                      style:
                          new TextStyle(color: Theme.of(context).canvasColor),
                    ),
                  ),
            ),
          ),
        ),
      );
}
