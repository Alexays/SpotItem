import 'dart:async';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/ui/spot_strings.dart';

/// Login screen class
class LoginScreen extends StatefulWidget {
  /// Login screen initalizer
  const LoginScreen();

  @override
  State createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameCtrl =
      new TextEditingController(text: Services.auth.lastEmail);
  final TextEditingController _passwordCtrl = new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Future<Null> doLogin(BuildContext context) async {
    final errorText = SpotL.of(context).loginError();
    if (_formKey.currentState.validate()) {
      final success = await Services.auth.login(
          {'email': _usernameCtrl.text, 'password': _passwordCtrl.text},
          'local');
      if (success) {
        await Navigator.pushReplacementNamed(context, '/');
      } else {
        showSnackBar(context, errorText);
      }
    } else {
      showSnackBar(context, errorText);
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      body: new Builder(
          builder: (context) => new Container(
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
                              hintText: SpotL.of(Services.loc).emailPh(),
                              labelText: SpotL.of(Services.loc).email(),
                            ),
                            autofocus: true,
                            controller: _usernameCtrl,
                            validator: validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          new TextFormField(
                            key: const Key('password'),
                            decoration: new InputDecoration(
                              hintText: SpotL.of(context).passwordPh(),
                              labelText: SpotL.of(context).password(),
                            ),
                            controller: _passwordCtrl,
                            obscureText: true,
                            validator: validatePassword,
                          ),
                          const Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0)),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new RaisedButton(
                                  key: const Key('login'),
                                  child:
                                      new Text(SpotL.of(Services.loc).login()),
                                  onPressed: () {
                                    final form = _formKey.currentState;
                                    if (form.validate()) {
                                      doLogin(context);
                                    } else {
                                      showSnackBar(
                                          context,
                                          SpotL
                                              .of(Services.loc)
                                              .correctError());
                                    }
                                  }),
                              const Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0)),
                              new RaisedButton(
                                child: const Text(
                                  'Google',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                color: Colors.blue,
                                onPressed: () {
                                  Services.auth
                                      .handleGoogleSignIn()
                                      .then((success) {
                                    if (success) {
                                      Navigator.pushReplacementNamed(
                                          context, '/');
                                    } else {
                                      showSnackBar(
                                          context, SpotL.of(context).error());
                                    }
                                  });
                                },
                              )
                            ],
                          ),
                          const Padding(padding: const EdgeInsets.all(5.0)),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text(SpotL.of(context).noAccount()),
                              const Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0)),
                              new FlatButton(
                                child: new Text(
                                  SpotL.of(Services.loc).register(),
                                  textAlign: TextAlign.center,
                                ),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/register');
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ))));
}
