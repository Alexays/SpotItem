import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/interactor/utils.dart';

class LoginScreen extends StatefulWidget {
  final AuthManager _authManager;

  const LoginScreen(this._authManager);

  @override
  State createState() => new _LoginScreenState(_authManager);
}

class _LoginScreenState extends State<LoginScreen> {
  _LoginScreenState(this._authManager);

  final AuthManager _authManager;
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(
        title: const Text('Login'),
      ),
      body: new Builder(
          builder: (BuildContext context) => new SingleChildScrollView(
              child: new Container(
                  padding: const EdgeInsets.all(40.0),
                  child: new Card(
                      child: new Container(
                    margin: const EdgeInsets.all(20.0),
                    child: new Form(
                      key: _formKey,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new TextFormField(
                            key: const Key('email'),
                            decoration:
                                const InputDecoration(hintText: 'Email'),
                            autofocus: true,
                            controller: _usernameController,
                            validator: validateEmail,
                          ),
                          new TextFormField(
                            decoration:
                                const InputDecoration(hintText: 'Password'),
                            controller: _passwordController,
                            obscureText: true,
                            validator: validatePassword,
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new RaisedButton(
                                child: const Text('Don\'t have an account ?'),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/register');
                                },
                              ),
                              const Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                              ),
                              new RaisedButton(
                                  child: const Text('Login'),
                                  onPressed: () {
                                    final FormState form =
                                        _formKey.currentState;
                                    if (form.validate()) {
                                      _authManager
                                          .login(_usernameController.text,
                                              _passwordController.text)
                                          .then((bool success) {
                                        if (success) {
                                          Navigator.pushReplacementNamed(
                                              context, '/home');
                                        } else {
                                          Scaffold.of(context).showSnackBar(
                                              new SnackBar(
                                                  content: const Text(
                                                      'Invalid credentials !')));
                                        }
                                      });
                                    } else {
                                      Scaffold.of(context).showSnackBar(
                                          new SnackBar(
                                              content: const Text(
                                                  'Form must be valid !')));
                                    }
                                  })
                            ],
                          )
                        ],
                      ),
                    ),
                  ))))));
}
