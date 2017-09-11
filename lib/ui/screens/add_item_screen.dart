import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/models/group.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class AddItemScreen extends StatefulWidget {
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
  List<Group> _groups;

  /// Check groups id
  final List<String> _groupsId = [];

  /// Stepper
  final int _stepLength = 3;
  int _currentStep = 0;

  @override
  void initState() {
    Services.groups.getGroups().then((data) {
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
          const Text('No images'),
          const Padding(
            padding: const EdgeInsets.all(10.0),
          ),
          new RaisedButton(
            child: const Text('Add image'),
            onPressed: getImage,
          )
        ],
      );
    }
    return new Column(children: <Widget>[
      new Center(
          child: new RaisedButton(
        child: const Text('Add image'),
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
      showSnackBar(context, 'Please correct error !');
      return;
    }
    showLoading(context);
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
      showSnackBar(context, response['msg']);
      if (response['success']) {
        await Services.items.getItems(force: true);
        await Navigator
            .of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } else {
      showSnackBar(context, 'Auth error !');
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: const Text('Add Item')),
        body: new Builder(
            builder: (context) => new Container(
                child: new Form(
                    key: _formKey,
                    child: new Stepper(
                      currentStep: _currentStep,
                      steps: [
                        new Step(
                            title: const Text('Informations'),
                            state: StepState.indexed,
                            content: new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Column(children: <Widget>[
                                    new TextFormField(
                                        key: const Key('name'),
                                        decoration: const InputDecoration(
                                            hintText: 'Name'),
                                        validator: validateName,
                                        onSaved: (value) {
                                          _name = value.trim();
                                        }),
                                    new TextFormField(
                                        key: const Key('about'),
                                        decoration: const InputDecoration(
                                            hintText: 'Description'),
                                        onSaved: (value) {
                                          _about = value.trim();
                                        }),
                                    new TextFormField(
                                        key: const Key('location'),
                                        decoration: const InputDecoration(
                                            hintText: 'Location'),
                                        validator: validateString,
                                        onSaved: (value) {
                                          _location = value.trim();
                                        }),
                                    const Divider(),
                                    new SwitchListTile(
                                        title: const Text('Donated Item'),
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
                                    new SwitchListTile(
                                        title: const Text('Private Item'),
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
                            title: const Text('Images'),
                            content: new Container(
                                height: 120 +
                                    320 *
                                        (_imagesFile.length / 3)
                                            .floorToDouble(),
                                child: getImageGrid()),
                            isActive: true),
                        new Step(
                            title: const Text('Groups'),
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
