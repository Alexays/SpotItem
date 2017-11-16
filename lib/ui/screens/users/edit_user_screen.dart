import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Edit user screen class
class EditUserScreen extends StatefulWidget {
  /// Edit user screen initializer
  const EditUserScreen();

  @override
  _EditUserScreenState createState() => new _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  final TextEditingController _firstname = new TextEditingController();
  final TextEditingController _lastname = new TextEditingController();
  final TextEditingController _password = new TextEditingController();

  String password;

  @override
  void initState() {
    super.initState();
    _firstname.text = Services.auth.user.firstname;
    _lastname.text = Services.auth.user.name;
  }

  Future<Null> editUser(BuildContext context) async {
    _formKey.currentState.save();
    if (!_formKey.currentState.validate()) {
      showSnackBar(context, SpotL.of(context).correctError);
      return;
    }
    if (password != _password.text) {
      showSnackBar(context, SpotL.of(context).passwordError);
      return;
    }
    final res = await Services.users.edit({
      'firstname': _firstname.text,
      'name': _lastname.text,
    }, password);
    if (!resValid(context, res)) {
      return;
    }
    showSnackBar(context, res.msg);
    Navigator.pop(context);
  }

  Widget _buildForm(BuildContext context, ThemeData theme) => new Container(
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
                      labelText: SpotL.of(Services.loc).firstname,
                      hintText: SpotL.of(Services.loc).firstnamePh,
                    ),
                    validator: validateString,
                    controller: _firstname,
                    initialValue: _firstname.text,
                  ),
                  new TextFormField(
                    key: const Key('lastname'),
                    decoration: new InputDecoration(
                      labelText: SpotL.of(context).lastname,
                      hintText: SpotL.of(Services.loc).lastnamePh,
                    ),
                    controller: _lastname,
                    initialValue: _lastname.text,
                  ),
                  new FocusScope(
                    node: new FocusScopeNode(),
                    child: new TextFormField(
                      style: theme.textTheme.subhead.copyWith(
                        color: theme.disabledColor,
                      ),
                      decoration: new InputDecoration(
                        labelText: SpotL.of(context).email,
                        hintText: SpotL.of(context).emailPh,
                      ),
                      initialValue: Services.auth.user?.email,
                    ),
                  ),
                  new TextFormField(
                    key: const Key('password'),
                    decoration: new InputDecoration(
                      labelText: SpotL.of(context).password,
                      hintText: SpotL.of(context).passwordPh,
                    ),
                    onSaved: (value) {
                      password = value;
                    },
                    obscureText: true,
                  ),
                  new TextFormField(
                    key: const Key('repeat'),
                    decoration: new InputDecoration(
                      labelText: SpotL.of(context).passwordRepeat,
                      hintText: SpotL.of(context).passwordRepeatPh,
                    ),
                    controller: _password,
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(title: new Text(SpotL.of(context).editProfile)),
      body: new Builder(
        builder: (context) => new SingleChildScrollView(
              child: _buildForm(context, theme),
            ),
      ),
      bottomNavigationBar: new Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: new ConstrainedBox(
          constraints: new BoxConstraints.tightFor(
            height: 48.0,
            width: MediaQuery.of(context).size.width,
          ),
          child: new RaisedButton(
            color: theme.accentColor,
            onPressed: () => editUser(context),
            child: new Text(
              SpotL.of(context).save.toUpperCase(),
              style: new TextStyle(color: theme.canvasColor),
            ),
          ),
        ),
      ),
    );
  }
}
