import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/user.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/ui/spot_strings.dart';

/// Edit user screen class
class EditUserScreen extends StatefulWidget {
  /// Edit user screen initializer
  const EditUserScreen();

  @override
  _EditUserScreenState createState() => new _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController _name;
  TextEditingController _lastname;
  TextEditingController _email;
  TextEditingController _password;

  User user;
  String password;
  String repeat;

  @override
  void initState() {
    final User tmp = Services.auth.user;
    user = new User.from(tmp);
    _name = new TextEditingController(text: user.firstname);
    _lastname = new TextEditingController(text: user.name);
    _email = new TextEditingController(text: user.email);
    super.initState();
  }

  Future<Null> editUser(BuildContext context) async {
    _formKey.currentState.save();
    if (password != repeat) {
      return showSnackBar(context, 'Password don\t match !');
    }
    if (!_formKey.currentState.validate()) {
      return showSnackBar(context, SpotL.of(context).correctError());
    }
    final dynamic res = await Services.users.updateUser(user, password);
    showSnackBar(context, res['msg']);
    if (res['success']) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).editProfile())),
        body: new Builder(builder: (context) {
          final ThemeData theme = Theme.of(context);
          return new Column(children: <Widget>[
            new Expanded(
                child: new SingleChildScrollView(
                    child: new Container(
                        margin: const EdgeInsets.all(20.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Form(
                                key: _formKey,
                                child: new Column(
                                  children: <Widget>[
                                    new TextFormField(
                                      key: const Key('name'),
                                      decoration: new InputDecoration(
                                          labelText: SpotL
                                              .of(Services.loc)
                                              .firstname(),
                                          hintText: SpotL
                                              .of(Services.loc)
                                              .firstnamePh()),
                                      onSaved: (value) {
                                        user.firstname = value.trim();
                                      },
                                      validator: validateString,
                                      controller: _name,
                                    ),
                                    new TextFormField(
                                      key: const Key('lastname'),
                                      decoration: new InputDecoration(
                                          labelText:
                                              SpotL.of(context).lastname(),
                                          hintText: SpotL
                                              .of(Services.loc)
                                              .lastnamePh()),
                                      onSaved: (value) {
                                        user.name = value.trim();
                                      },
                                      validator: validateString,
                                      controller: _lastname,
                                    ),
                                    new FocusScope(
                                      node: new FocusScopeNode(),
                                      child: new TextFormField(
                                        controller: _email,
                                        style: theme.textTheme.subhead.copyWith(
                                          color: theme.disabledColor,
                                        ),
                                        decoration: new InputDecoration(
                                          labelText: SpotL.of(context).email(),
                                          hintText: SpotL.of(context).emailPh(),
                                        ),
                                        validator: validateEmail,
                                      ),
                                    ),
                                    new TextFormField(
                                      key: const Key('password'),
                                      decoration: new InputDecoration(
                                          labelText:
                                              SpotL.of(context).password(),
                                          hintText:
                                              SpotL.of(context).passwordPh()),
                                      onSaved: (value) {
                                        password = value;
                                      },
                                      obscureText: true,
                                    ),
                                    new TextFormField(
                                      key: const Key('repeat'),
                                      decoration: new InputDecoration(
                                          labelText: SpotL
                                              .of(context)
                                              .passwordRepeat(),
                                          hintText: SpotL
                                              .of(context)
                                              .passwordRepeatPh()),
                                      onSaved: (value) {
                                        repeat = value;
                                      },
                                      controller: _password,
                                      obscureText: true,
                                    ),
                                  ],
                                )),
                          ],
                        )))),
            new Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: new ConstrainedBox(
                  constraints: new BoxConstraints.tightFor(
                      height: 48.0, width: MediaQuery.of(context).size.width),
                  child: new RaisedButton(
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      editUser(context);
                    },
                    child: new Text(
                      SpotL.of(context).save().toUpperCase(),
                      style:
                          new TextStyle(color: Theme.of(context).canvasColor),
                    ),
                  )),
            ),
          ]);
        }),
      );
}
