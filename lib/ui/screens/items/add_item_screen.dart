import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/ui/widgets/calendar.dart';
import 'package:spotitem/models/item.dart';
import 'package:spotitem/keys.dart';

/// Add item screen class
class AddItemScreen extends StatefulWidget {
  /// Add item screen initializer
  const AddItemScreen();

  @override
  _AddItemScreenState createState() => new _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  _AddItemScreenState();

  /// Item name
  String _name;

  /// Item description
  String _about;

  /// Item location
  final TextEditingController _location = new TextEditingController();

  /// Tracks of item
  List<String> _tracks = [];

  /// Images taken from gallery
  List<File> _imagesFile = [];

  /// Base64 images
  final List<String> _images = [];

  /// Groups of user
  List<Group> _groups = [];

  /// Check groups id
  final List<String> _groupsId = [];

  List<Event> _calendar = [];

  /// Stepper
  final int _stepLength = 4;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    Services.groups.getAll().then((data) {
      if (!mounted) {
        return;
      }
      setState(() {
        _groups = data;
      });
    });
    if (Services.users.location != null) {
      Services.users.getCity().then((cityName) {
        if (!mounted) {
          return;
        }
        setState(() {
          _location.text = cityName;
        });
      });
    }
  }

  /// Get image from gallery.
  ///
  Future<Null> _getImage() async {
    final _fileName = await ImagePicker.pickImage(maxWidth: 720.0);
    if (!mounted) {
      return;
    }
    setState(() {
      _imagesFile.add(_fileName);
    });
  }

  Widget _getImageGrid() => new GridView.count(
        primary: false,
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        children: new List<Widget>.generate(
          _imagesFile.length + 1,
          (i) {
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
            return new GridTile(
              child: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new Image.file(
                    _imagesFile[index],
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
                            _imagesFile = _imagesFile
                                .where((f) => f != _imagesFile[index])
                                .toList();
                          }),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

  Widget _getGroups() {
    if (_groups == null) {
      return const Center(child: const CircularProgressIndicator());
    }
    if (_groups.isEmpty) {
      return new Center(child: new Text(SpotL.of(context).noGroups));
    }
    return new Column(
      children: _groups
          .map((f) => new CheckboxListTile(
                title: new Text(f.name),
                value: _groupsId.contains(f.id),
                onChanged: (value) => setState(() {
                      value ? _groupsId.add(f.id) : _groupsId.remove(f.id);
                    }),
                secondary: const Icon(Icons.people),
              ))
          .toList(),
    );
  }

  Future<Null> _addItem(BuildContext context) async {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      setState(() {
        _currentStep = 0;
      });
      showSnackBar(context, SpotL.of(context).correctError);
      return;
    }
    showLoading(context);
    await Services.users.getLocation(force: true);
    _images.clear();
    for (var f in _imagesFile) {
      final imageBytes = f.readAsBytesSync();
      _images.add(
          'data:image/${f.path.split('.').last};base64,${BASE64.encode(imageBytes)}');
    }
    if (_location == null || validateString(_location.text) != null) {
      Navigator.of(context).pop();
      showSnackBar(context, SpotL.of(context).locationError);
      return;
    }
    final location = Services.users.location ??
        await Services.users.locationByAddress(_location.text);
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
    final response = await Services.items.addItem({
      'name': _name,
      'about': _about,
      'owner': Services.auth.user.id,
      'lat': location['latitude'],
      'lng': location['longitude'],
      'images': _images,
      'location': _location.text,
      'calendar': _calendar,
      'tracks': _tracks,
      'groups': _groupsId
    });
    Navigator.of(context).pop();
    if (!resValid(context, response)) {
      return;
    }
    showSnackBar(context, response.msg);
    await Services.items
        .getItems(force: true); // UNTIL WE HIDE USER ITEM FROM GENERAL LIST
    await showDialog<Null>(
      context: context,
      child: new SimpleDialog(children: [
        new Container(
          child: new Image.network(
            '$apiUrl/items/${response.data}/code',
            headers: getHeaders(
              key: Services.auth.accessToken,
              type: contentType.image,
            ),
          ),
        ),
      ]),
    );
    await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Widget _buildForm(BuildContext context) => new Column(
        children: <Widget>[
          new TextFormField(
            key: const Key('name'),
            decoration: new InputDecoration(
              hintText: SpotL.of(context).namePh,
              labelText: SpotL.of(context).name,
            ),
            validator: validateName,
            onSaved: (value) {
              _name = value.trim();
            },
          ),
          new TextFormField(
            key: const Key('about'),
            decoration: new InputDecoration(
              hintText: SpotL.of(context).aboutPh,
              labelText: SpotL.of(context).about,
            ),
            validator: validateString,
            onSaved: (value) {
              _about = value.trim();
            },
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
                  controller: _location,
                  initialValue: _location.text ?? SpotL.of(context).loading,
                ),
              ),
              new GestureDetector(
                onTap: () async {
                  final p = await Services.users.autocompleteCity(context);
                  if (mounted && p != null) {
                    setState(() {
                      _location.text = p;
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
          const Divider(),
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
                itemBuilder: (context, index) {
                  final image = new Image.asset(
                      'assets/${Services.items.categories[index]}.png');
                  if (_tracks.contains(Services.items.categories[index])) {
                    return new RaisedButton(
                      child: image,
                      onPressed: () => setState(() {
                            _tracks.remove(Services.items.categories[index]);
                          }),
                    );
                  }
                  return new FlatButton(
                    child: image,
                    onPressed: () => setState(() {
                          _tracks = _tracks
                              .where((f) =>
                                  !Services.items.categories.any((d) => d == f))
                              .toList()
                                ..add(Services.items.categories[index]);
                        }),
                  );
                }),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).addItem)),
        body: new Form(
          key: _formKey,
          child: new Builder(builder: (context) {
            Services.context = context;
            return new Container(
              child: new Stepper(
                currentStep: _currentStep,
                steps: [
                  new Step(
                    title: new Text(SpotL.of(context).about),
                    content: _buildForm(context),
                    state: _name != null && _name.isNotEmpty
                        ? StepState.complete
                        : StepState.indexed,
                    isActive: true,
                  ),
                  new Step(
                    title: new Text(SpotL.of(context).images),
                    content: new Container(
                      height: (120 + 320 * (_imagesFile.length / 3))
                          .floorToDouble(),
                      child: _getImageGrid(),
                    ),
                    // TO-DO setState name when it changed
                    state: _name != null && _name.isNotEmpty
                        ? _imagesFile.isNotEmpty
                            ? StepState.complete
                            : StepState.indexed
                        : StepState.disabled,
                    isActive: _name != null && _name.isNotEmpty,
                  ),
                  new Step(
                    title: new Text(SpotL.of(context).calendar),
                    content: new Container(
                      height: 320.0,
                      child: new Calendar(
                        allowDisable: true,
                        edit: true,
                        selectedDates: _calendar,
                        onChanged: (value) => setState(() {
                              _calendar = value;
                            }),
                      ),
                    ),
                    state: _imagesFile.isNotEmpty
                        ? _calendar.isNotEmpty
                            ? StepState.complete
                            : StepState.indexed
                        : StepState.disabled,
                    isActive: _imagesFile.isNotEmpty,
                  ),
                  new Step(
                    title: new Text(SpotL.of(context).groups),
                    content: _getGroups(),
                    state: _calendar.isNotEmpty
                        ? _groups.isNotEmpty
                            ? StepState.complete
                            : StepState.indexed
                        : StepState.disabled,
                    isActive: _calendar.isNotEmpty,
                  ),
                ],
                type: StepperType.vertical,
                onStepTapped: (step) => setState(() {
                      _currentStep = step;
                    }),
                onStepCancel: () => setState(() {
                      _currentStep = _currentStep > 0 ? _currentStep - 1 : 0;
                    }),
                onStepContinue: () => setState(() {
                      if (_currentStep < _stepLength - 1) {
                        _currentStep = _currentStep + 1;
                      } else {
                        _addItem(context);
                      }
                    }),
              ),
            );
          }),
        ),
      );
}
