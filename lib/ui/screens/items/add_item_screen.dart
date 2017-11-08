import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/models/group.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/ui/widgets/calendar.dart';
import 'package:spotitem/models/item.dart';

/// Add item screen class
class AddItemScreen extends StatefulWidget {
  /// Add item screen initializer
  const AddItemScreen();

  @override
  _AddItemScreenState createState() => new _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  /// Add form
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  /// Item name
  String _name;

  /// Item description
  String _about;

  /// Item location
  final TextEditingController _location = new TextEditingController();

  /// Tracks of item
  List<String> _tracks = [];

  /// Images taken from gallery
  final List<File> _imagesFile = [];

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
    Services.groups.getGroups().then((data) {
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
    super.initState();
  }

  /// Get image from gallery.
  ///
  Future<Null> getImage() async {
    final _fileName = await ImagePicker.pickImage(maxWidth: 720.0);
    if (!mounted) {
      return;
    }
    setState(() {
      _imagesFile.add(_fileName);
    });
  }

  Widget getImageGrid() {
    if (_imagesFile.isEmpty) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text(SpotL.of(context).noImages),
          const Padding(
            padding: const EdgeInsets.all(10.0),
          ),
          new RaisedButton(
            child: new Text(SpotL.of(context).addImage),
            onPressed: getImage,
          )
        ],
      );
    }
    return new Column(children: <Widget>[
      new Center(
          child: new RaisedButton(
        child: new Text(SpotL.of(context).addImage),
        onPressed: getImage,
      )),
      const Divider(),
      new Flexible(
          child: new GridView.count(
        primary: false,
        crossAxisCount: 3,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        children: new List<Widget>.generate(
          _imagesFile.length,
          (index) => new GridTile(
                child: new Stack(
                  children: <Widget>[
                    new Image.file(_imagesFile[index]),
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
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
        ),
      ))
    ]);
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

  Future<Null> addItem(BuildContext context) async {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      setState(() {
        _currentStep = 0;
      });
      return showSnackBar(context, SpotL.of(context).correctError);
    }
    showLoading(context);
    await Services.users.getLocation(force: true);
    _images.clear();
    for (var f in _imagesFile) {
      final imageBytes = f.readAsBytesSync();
      _images.add('data:image/${f.path.split('.').last};base64,${BASE64.encode(imageBytes)}');
    }
    if (_location == null || validateString(_location.text) != null) {
      Navigator.of(context).pop();
      return showSnackBar(context, 'Please enable location or choose location !');
    }
    final location = Services.users.location ?? await Services.users.getLocationByAddress(_location.text);
    if (location == null) {
      Navigator.of(context).pop();
      return showSnackBar(context, 'Please enable location or choose location !');
    }
    if (!Services.auth.user.isValid()) {
      Navigator.of(context).pop();
      return showSnackBar(context, SpotL.of(context).error);
    }
    final response = await Services.items.addItem({
      'name': _name,
      'about': _about,
      'owner': Services.auth.user.id,
      'lat': location['latitude'],
      'lng': location['longitude'],
      'images': _images,
      'location': _location.text,
      'calendar': _calendar.toString(),
      'tracks': _tracks,
      'groups': _groupsId
    });
    Navigator.of(context).pop();
    if (resValid(context, response)) {
      showSnackBar(context, response.msg);
      await Services.items.getItems(force: true);
      await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).addItem)),
        body: new Builder(
            builder: (context) => new Container(
                child: new Form(
                    key: _formKey,
                    child: new Stepper(
                      currentStep: _currentStep,
                      steps: [
                        new Step(
                            title: new Text(SpotL.of(context).about),
                            content: new Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                              new Column(children: <Widget>[
                                new TextFormField(
                                    key: const Key('name'),
                                    decoration: new InputDecoration(
                                        hintText: SpotL.of(context).namePh, labelText: SpotL.of(context).name),
                                    validator: validateName,
                                    onSaved: (value) {
                                      _name = value.trim();
                                    }),
                                new TextFormField(
                                    key: const Key('about'),
                                    decoration: new InputDecoration(
                                        hintText: SpotL.of(Services.loc).aboutPh, labelText: SpotL.of(context).about),
                                    validator: validateString,
                                    onSaved: (value) {
                                      _about = value.trim();
                                    }),
                                new Stack(
                                  children: <Widget>[
                                    new FocusScope(
                                      node: new FocusScopeNode(),
                                      child: new TextFormField(
                                        decoration: new InputDecoration(
                                            hintText: SpotL.of(context).locationPh,
                                            labelText: SpotL.of(context).location),
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
                                    onChanged: (value) {
                                      setState(() {
                                        if (value) {
                                          _tracks.add('gift');
                                        } else {
                                          _tracks.remove('gift');
                                        }
                                      });
                                    },
                                    secondary: const Icon(Icons.card_giftcard)),
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
                                    secondary: const Icon(Icons.lock)),
                                new Container(
                                  height: 100.0,
                                  child: new ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                                      itemCount: Services.items.categories.length,
                                      itemExtent: 75.0,
                                      itemBuilder: (context, index) => !_tracks
                                              .contains(Services.items.categories[index])
                                          ? new FlatButton(
                                              child: new Image.asset('assets/${Services.items.categories[index]}.png'),
                                              onPressed: () {
                                                _tracks = _tracks
                                                    .where((f) => !Services.items.categories.any((d) => d == f))
                                                    .toList()
                                                      ..add(Services.items.categories[index]);
                                                setState(() {
                                                  _tracks = new List<String>.from(_tracks);
                                                });
                                              },
                                            )
                                          : new RaisedButton(
                                              child: new Image.asset('assets/${Services.items.categories[index]}.png'),
                                              onPressed: () {
                                                _tracks.remove(Services.items.categories[index]);
                                                setState(() {
                                                  _tracks = new List<String>.from(_tracks);
                                                });
                                              },
                                            )),
                                ),
                              ])
                            ]),
                            state: _name != null && _name.isNotEmpty ? StepState.complete : StepState.indexed,
                            isActive: true),
                        new Step(
                            title: new Text(SpotL.of(context).images),
                            content: new Container(
                                height: 120 + 320 * (_imagesFile.length / 3).floorToDouble(), child: getImageGrid()),
                            state: _name != null && _name.isNotEmpty
                                ? _imagesFile.isNotEmpty ? StepState.complete : StepState.indexed
                                : StepState.disabled,
                            isActive: _name != null && _name.isNotEmpty),
                        new Step(
                            title: new Text(SpotL.of(context).calendar),
                            content: new Container(
                                height: 320.0,
                                child: new Calendar(
                                  allowDisable: true,
                                  edit: true,
                                  selectedDates: _calendar,
                                  onChanged: (value) {
                                    setState(() {
                                      _calendar = value;
                                    });
                                  },
                                )),
                            state: _imagesFile.isNotEmpty
                                ? _calendar.isNotEmpty ? StepState.complete : StepState.indexed
                                : StepState.disabled,
                            isActive: _imagesFile.isNotEmpty),
                        new Step(
                            title: new Text(SpotL.of(context).groups),
                            content: getGroups(),
                            state: _calendar.isNotEmpty
                                ? _groups.isNotEmpty ? StepState.complete : StepState.indexed
                                : StepState.disabled,
                            isActive: _calendar.isNotEmpty),
                      ],
                      type: StepperType.vertical,
                      onStepTapped: (step) {
                        setState(() {
                          _currentStep = step;
                        });
                      },
                      onStepCancel: () {
                        setState(() {
                          _currentStep = _currentStep > 0 ? _currentStep - 1 : 0;
                        });
                      },
                      onStepContinue: () {
                        setState(() {
                          if (_currentStep < _stepLength - 1) {
                            _currentStep = _currentStep + 1;
                          } else {
                            addItem(context);
                          }
                        });
                      },
                    )))),
      );
}
