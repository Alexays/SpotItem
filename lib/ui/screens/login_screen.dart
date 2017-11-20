import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/utils.dart';

/// Login screen class
class LoginScreen extends StatelessWidget {
  /// It's constructor
  LoginScreen();

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
            return new SingleChildScrollView(
              primary: true,
              child: new Container(
                constraints: new BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                hintText: SpotL.of(Services.context).emailPh,
                                labelText: SpotL.of(Services.context).email,
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
                            const Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                            ),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new RaisedButton(
                                    key: const Key('login'),
                                    child: new Text(
                                        SpotL.of(Services.context).login),
                                    onPressed: () => _localLogin(context)),
                                const Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                ),
                                new RaisedButton(
                                  child: const Text(
                                    'Google',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  color: Colors.blue,
                                  onPressed: () => _googleLogin(context),
                                )
                              ],
                            ),
                            const Padding(padding: const EdgeInsets.all(5.0)),
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Text(SpotL.of(context).noAccount),
                                const Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                ),
                                new FlatButton(
                                  child: new Text(
                                    SpotL.of(Services.context).register,
                                    textAlign: TextAlign.center,
                                  ),
                                  onPressed: () =>
                                      Navigator.pushReplacementNamed(
                                          context, '/register'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
}
