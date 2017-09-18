import 'dart:async';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';

/// Login screen class
class LoginScreen extends StatefulWidget {
  /// Login screen initalizer
  const LoginScreen();

  @override
  State createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameCtrl = new TextEditingController();
  final TextEditingController _passwordCtrl = new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  Future<Null> doLogin(BuildContext context) async {
    const errorText = 'Invalid credentials !';
    if (_formKey.currentState.validate()) {
      final bool success = await Services.auth.login(
          {'email': _usernameCtrl.text, 'password': _passwordCtrl.text},
          'local');
      if (success) {
        Navigator.pushReplacementNamed(context, '/');
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
                            decoration: const InputDecoration(
                              hintText: 'Enter email',
                              labelText: 'Email',
                            ),
                            autofocus: true,
                            controller: _usernameCtrl,
                            validator: validateEmail,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          new TextFormField(
                            key: const Key('password'),
                            decoration: const InputDecoration(
                              hintText: 'Enter password',
                              labelText: 'Password',
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
                                  child: const Text('Login'),
                                  onPressed: () {
                                    final FormState form =
                                        _formKey.currentState;
                                    if (form.validate()) {
                                      doLogin(context);
                                    } else {
                                      showSnackBar(
                                          context, 'Form must be valid !');
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
                                      showSnackBar(context, 'Error !');
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
                              const Text('Don\'t have an account ?'),
                              const Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0)),
                              new FlatButton(
                                child: const Text(
                                  'Register',
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
