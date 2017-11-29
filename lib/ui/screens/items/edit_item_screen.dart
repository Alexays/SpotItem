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
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _EditItemScreenState(this._itemId, this._item);

  final String _itemId;

  Item _item;

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
      _item = new Item.from(_item);
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
    if (_item == null) {
      return;
    }
    setState(() {
      _nameCtrl.text = _item.name;
      _aboutCtrl.text = _item.about;
      _groupsId = _item.groups ?? [];
      _tracks = _item.tracks ?? [];
      _location = _item.location;
      _calendar = _item.calendar;
    });
  }

  Future<Null> _getImage() async {
    final _fileName = await ImagePicker.pickImage(maxWidth: 720.0);
    final imageData = await _fileName.readAsBytes();
    if (!mounted) {
      return;
    }
    setState(() {
      _imagesFile.add(_fileName);
      _images.add(
        'data:image/${_fileName.path.split('.').last};base64,${BASE64.encode(imageData)}',
      );
    });
  }

  Widget _buildImages(BuildContext context) {
    final length = _item.images.length + _imagesFile.length;
    return new GridView.count(
      primary: false,
      padding: const EdgeInsets.all(15.0),
      crossAxisCount: 3,
      crossAxisSpacing: 10.0,
      children: new List<Widget>.generate(length + 1, (i) {
        final index = i - 1;
        if (i == 0) {
          return new GridTile(
            child: new GestureDetector(
              onTap: _getImage,
              child: new Card(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.add),
                    new Text(SpotL.of(context).addImage),
                  ],
                ),
              ),
            ),
          );
        }
        if (index < _item.images.length) {
          return new GridTile(
            child: new Card(
              child: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new Image.network(
                    '$imgUrl${_item.images[index]}',
                    headers: getHeaders(
                      key: Services.auth.accessToken,
                      type: contentType.image,
                    ),
                    fit: BoxFit.cover,
                  ),
                  new Positioned(
                    top: 2.5,
                    left: 2.5,
                    child: new IconButton(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete this image',
                      onPressed: () => setState(() {
                            _item.images.removeAt(index);
                          }),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return new GridTile(
          child: new Card(
            child: new Stack(
              fit: StackFit.expand,
              children: <Widget>[
                new Image.file(
                  _imagesFile[index - _item.images.length],
                  fit: BoxFit.cover,
                ),
                new Positioned(
                  top: 2.5,
                  left: 2.5,
                  child: new IconButton(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete this image',
                    onPressed: () => setState(() {
                          _imagesFile.removeAt(index);
                          _images.removeAt(index);
                        }),
                  ),
                ),
              ],
            ),
          ),
        );
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
        await Services.users.locationByAddress(_location);
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
    return new ListView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: _groups.length,
      itemBuilder: (context, index) => new CheckboxListTile(
            title: new Text(_groups[index].name),
            value: _groupsId.contains(_groups[index].id),
            onChanged: (value) => setState(() {
                  value
                      ? _groupsId.add(_groups[index].id)
                      : _groupsId.remove(_groups[index].id);
                }),
            secondary: const Icon(Icons.people),
          ),
    );
  }

  Widget _buildForm(BuildContext context) => new ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: <Widget>[
          new TextFormField(
            key: const Key('name'),
            decoration: new InputDecoration(
              hintText: SpotL.of(context).namePh,
              labelText: SpotL.of(context).name,
            ),
            validator: validateName,
            controller: _nameCtrl,
            initialValue: _nameCtrl.text,
          ),
          new TextFormField(
            key: const Key('about'),
            decoration: new InputDecoration(
              hintText: SpotL.of(context).aboutPh,
              labelText: SpotL.of(context).about,
            ),
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
                    labelText: SpotL.of(context).location,
                  ),
                  initialValue: _location,
                ),
              ),
              new GestureDetector(
                onTap: () async {
                  final p = await Services.users.autocompleteCity(context);
                  if (!mounted || p == null) {
                    return;
                  }
                  setState(() {
                    _location = p;
                  });
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
            onChanged: (value) => setState(() {
                  value ? _tracks.add('gift') : _tracks.remove('gift');
                }),
            secondary: const Icon(Icons.card_giftcard),
          ),
          new CheckboxListTile(
            title: new Text(SpotL.of(context).private),
            value: _tracks.contains('private'),
            onChanged: (value) => setState(() {
                  value ? _tracks.add('private') : _tracks.remove('private');
                }),
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
                        'assets/${Services.items.categories[index]}.png',
                      ),
                      onPressed: () => setState(() {
                            _tracks = _tracks
                                .where((f) => !Services.items.categories
                                    .any((d) => d == f))
                                .toList()
                                  ..add(Services.items.categories[index]);
                          }),
                    )
                  : new RaisedButton(
                      child: new Image.asset(
                          'assets/${Services.items.categories[index]}.png'),
                      onPressed: () => setState(() {
                            _tracks.remove(Services.items.categories[index]);
                          }),
                    ),
            ),
          ),
          new Image.network(
            '$apiUrl/items/${_item.id}/code',
            headers: getHeaders(
              key: Services.auth.accessToken,
              type: contentType.image,
            ),
          )
        ],
      );

  Widget _buildCalendar(BuildContext context) => new Container(
        height: MediaQuery.of(context).size.height,
        child: new Calendar(
          allowDisable: true,
          edit: true,
          selectedDates: _calendar,
          onChanged: (value) => setState(() {
                _calendar = value;
              }),
        ),
      );

  Widget _buildGroups(BuildContext context) => _groups != null
      ? _getGroups()
      : const Center(child: const CircularProgressIndicator());

  @override
  Widget build(BuildContext context) => new Scaffold(
        body: new Form(
          key: _formKey,
          child: new Builder(
            builder: (context) {
              Services.context = context;
              return new DefaultTabController(
                length: 4,
                child: new NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) =>
                      <Widget>[
                        new SliverAppBar(
                          pinned: true,
                          floating: true,
                          snap: true,
                          title: new Text(
                            _item?.name ?? SpotL.of(context).loading,
                          ),
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
        ),
        bottomNavigationBar: new ConstrainedBox(
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
                    style: new TextStyle(
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                ),
          ),
        ),
      );
}
