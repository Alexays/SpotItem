import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/interactor/utils.dart';

class LoginScreen extends StatefulWidget {
  final AuthManager _authManager;

  LoginScreen(this._authManager);

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
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Login"),
        ),
        body: new Builder(builder: (BuildContext context) {
          return new SingleChildScrollView(
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
                            key: new Key('email'),
                            decoration: new InputDecoration(hintText: "Email"),
                            autofocus: true,
                            controller: _usernameController,
                            validator: validateEmail,
                          ),
                          new TextFormField(
                            decoration:
                                new InputDecoration(hintText: 'Password'),
                            controller: _passwordController,
                            obscureText: true,
                            validator: validatePassword,
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new RaisedButton(
                                child: new Text('Don\'t have an account ?'),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, "/register");
                                },
                              ),
                              new Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                              ),
                              new RaisedButton(
                                  child: new Text('Login'),
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
                                              context, "/home");
                                        } else {
                                          Scaffold.of(context).showSnackBar(
                                              new SnackBar(
                                                  content: new Text(
                                                      "Invalid credentials !")));
                                        }
                                      });
                                    } else {
                                      Scaffold.of(context).showSnackBar(
                                          new SnackBar(
                                              content: new Text(
                                                  "Form must be valid !")));
                                    }
                                  })
                            ],
                          )
                        ],
                      ),
                    ),
                  ))));
        }));
  }
}
