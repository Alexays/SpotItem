import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen();

  @override
  State createState() => new _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) => new Scaffold(
      body: new Builder(
          builder: (context) => new SingleChildScrollView(
              child: new Container(
                  padding: const EdgeInsets.all(40.0),
                  child: new Column(
                    children: <Widget>[
                      new Image.asset(
                        'assets/logo.png',
                        width: 200.0,
                      ),
                      const Divider(),
                      new Card(
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
                                keyboardType: TextInputType.emailAddress,
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
                                    child: const Text(
                                        'Don\'t have\n an account ?'),
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, '/register');
                                    },
                                  ),
                                  const Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                  ),
                                  new RaisedButton(
                                      child: const Text('Login'),
                                      onPressed: () {
                                        final FormState form =
                                            _formKey.currentState;
                                        if (form.validate()) {
                                          Services.auth
                                              .login(_usernameController.text,
                                                  _passwordController.text)
                                              .then((success) {
                                            if (success) {
                                              Navigator.pushReplacementNamed(
                                                  context, '/home');
                                            } else {
                                              showSnackBar(context,
                                                  'Invalid credentials !');
                                            }
                                          });
                                        } else {
                                          showSnackBar(
                                              context, 'Form must be valid !');
                                        }
                                      })
                                ],
                              )
                            ],
                          ),
                        ),
                      ))
                    ],
                  )))));
}
