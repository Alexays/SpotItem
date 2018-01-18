import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/utils.dart';

/// Login screen class
class LoginScreen extends StatefulWidget {
  /// Contact screen initalizer
  const LoginScreen();

  @override
  State createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _LoginScreenState();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final TextEditingController _usernameCtrl = new TextEditingController();
  final TextEditingController _passwordCtrl = new TextEditingController();

  Future<Null> _localLogin(BuildContext context) async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      showSnackBar(context, SpotL.of(context).correctError);
      return;
    }
    final errorText = SpotL.of(context).loginError;
    if (_formKey.currentState.validate()) {
      final success = await Services.auth.login(
          {'email': _usernameCtrl.text, 'password': _passwordCtrl.text},
          'local');
      if (success) {
        await Navigator.pushReplacementNamed(context, '/');
        return;
      }
    }
    showSnackBar(context, errorText);
  }

  Future<Null> _googleLogin(BuildContext context) async {
    final success = await Services.auth.handleGoogleSignIn();
    if (!success) {
      return showSnackBar(context, SpotL.of(context).error);
    }
    await Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        body: new Builder(
          builder: (context) {
            Services.context = context;
            return new ListView(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: new Image.asset(
                    'assets/logo.png',
                    height: MediaQuery.of(context).size.height * 0.25,
                  ),
                ),
                new Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: new Form(
                    key: _formKey,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new TextFormField(
                          key: const Key('email'),
                          decoration: new InputDecoration(
                            hintText: SpotL.of(context).emailPh,
                            labelText: SpotL.of(context).email,
                          ),
                          autofocus: true,
                          controller: _usernameCtrl,
                          validator: validateEmail,
                          initialValue: Services.auth.lastEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        new TextFormField(
                          key: const Key('password'),
                          decoration: new InputDecoration(
                            hintText: SpotL.of(context).passwordPh,
                            labelText: SpotL.of(context).password,
                          ),
                          controller: _passwordCtrl,
                          obscureText: true,
                          validator: validatePassword,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        persistentFooterButtons: [
          new FlatButton(
            child: new Text(SpotL.of(context).noAccount),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/register'),
          ),
        ],
        bottomNavigationBar: new Builder(
          builder: (context) => new Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Expanded(
                    child: new Container(
                      height: 48.0,
                      child: new RaisedButton(
                        onPressed: () => _localLogin(context),
                        child: new Text(SpotL.of(context).login.toUpperCase()),
                      ),
                    ),
                  ),
                  new Expanded(
                    child: new Container(
                      height: 48.0,
                      child: new RaisedButton(
                        color: Theme.of(context).accentColor,
                        onPressed: () => _googleLogin(context),
                        child: new Text(
                          'GOOGLE',
                          style: new TextStyle(
                            color: Theme.of(context).canvasColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        ),
      );
}
