import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/models/group.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/ui/spot_strings.dart';

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
  String _location;

  /// Tracks of item
  final List<String> _tracks = [];

  /// Images taken from gallery
  final List<File> _imagesFile = [];

  /// Base64 images
  final List<String> _images = [];

  /// Groups of user
  List<Group> _groups = [];

  /// Check groups id
  final List<String> _groupsId = [];

  /// Stepper
  final int _stepLength = 3;
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
    super.initState();
  }

  /// Get image from gallery.
  ///
  Future<Null> getImage() async {
    final File _fileName = await ImagePicker.pickImage();
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
          new Text(SpotL.of(context).noImages()),
          const Padding(
            padding: const EdgeInsets.all(10.0),
          ),
          new RaisedButton(
            child: new Text(SpotL.of(context).addImage()),
            onPressed: getImage,
          )
        ],
      );
    }
    return new Column(children: <Widget>[
      new Center(
          child: new RaisedButton(
        child: new Text(SpotL.of(context).addImage()),
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
      showSnackBar(context, SpotL.of(context).correctError());
      return;
    }
    showLoading(context);
    await Services.users.getLocation(true);
    _images.clear();
    _imagesFile.forEach((f) {
      final List<int> imageBytes = f.readAsBytesSync();
      _images.add(
          'data:image/${f.path.split('.').last};base64,${BASE64.encode(imageBytes)}');
    });
    if (Services.auth.user != null &&
        Services.auth.user.id != null &&
        Services.users.location != null) {
      final dynamic response = await Services.items.addItem({
        'name': _name,
        'about': _about,
        'owner': Services.auth.user.id,
        'holder': Services.auth.user.id,
        'lat': Services.users.location['latitude'].toString(),
        'lng': Services.users.location['longitude'].toString(),
        'images': JSON.encode(_images),
        'location': _location,
        'tracks': JSON.encode(_tracks),
        'groups': JSON.encode(_groupsId)
      });
      Navigator.of(context).pop();
      if (resValid(response)) {
        showSnackBar(context, response['msg']);
        await Services.items.getItems(force: true);
        await Navigator
            .of(context)
            .pushNamedAndRemoveUntil('/', (route) => false);
      }
    } else {
      showSnackBar(context, 'Auth error !');
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).addItem())),
        body: new Builder(
            builder: (context) => new Container(
                child: new Form(
                    key: _formKey,
                    child: new Stepper(
                      currentStep: _currentStep,
                      steps: [
                        new Step(
                            title: new Text(SpotL.of(context).about()),
                            state: StepState.indexed,
                            content: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Column(children: <Widget>[
                                    new TextFormField(
                                        key: const Key('name'),
                                        decoration: new InputDecoration(
                                            hintText:
                                                SpotL.of(context).namePh(),
                                            labelText:
                                                SpotL.of(context).name()),
                                        validator: validateName,
                                        onSaved: (value) {
                                          _name = value.trim();
                                        }),
                                    new TextFormField(
                                        key: const Key('about'),
                                        decoration: new InputDecoration(
                                            hintText: SpotL
                                                .of(Services.loc)
                                                .aboutPh(),
                                            labelText:
                                                SpotL.of(context).about()),
                                        validator: validateString,
                                        onSaved: (value) {
                                          _about = value.trim();
                                        }),
                                    new TextFormField(
                                        key: const Key('location'),
                                        decoration: new InputDecoration(
                                            hintText: SpotL
                                                .of(Services.loc)
                                                .locationPh(),
                                            labelText: SpotL
                                                .of(Services.loc)
                                                .location()),
                                        validator: validateString,
                                        onSaved: (value) {
                                          _location = value.trim();
                                        }),
                                    const Divider(),
                                    new CheckboxListTile(
                                        title:
                                            new Text(SpotL.of(context).gift()),
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
                                        secondary:
                                            const Icon(Icons.card_giftcard)),
                                    new CheckboxListTile(
                                        title: new Text(
                                            SpotL.of(context).private()),
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
                                        secondary: const Icon(Icons.lock))
                                  ])
                                ]),
                            isActive: true),
                        new Step(
                            title: new Text(SpotL.of(context).images()),
                            content: new Container(
                                height: 120 +
                                    320 *
                                        (_imagesFile.length / 3)
                                            .floorToDouble(),
                                child: getImageGrid()),
                            isActive: true),
                        new Step(
                            title: new Text(SpotL.of(context).groups()),
                            content: getGroups(),
                            isActive: true),
                      ],
                      type: StepperType.vertical,
                      onStepTapped: (step) {
                        setState(() {
                          _currentStep = step;
                        });
                      },
                      onStepCancel: () {
                        setState(() {
                          if (_currentStep > 0) {
                            _currentStep = _currentStep - 1;
                          } else {
                            _currentStep = 0;
                          }
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
