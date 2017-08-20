import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/model/user.dart';
import 'package:spotitems/interactor/utils.dart';

class RegisterScreen extends StatefulWidget {
  final AuthManager _authManager;

  RegisterScreen(this._authManager);

  @override
  State createState() => new _RegisterScreenState(_authManager);
}

class _RegisterScreenState extends State<RegisterScreen> {
  _RegisterScreenState(this._authManager);
  final AuthManager _authManager;
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
    super.initState();
    user = new User(null, null, null, null, null, null);
    _name = new TextEditingController(text: user.firstname);
    _lastname = new TextEditingController(text: user.name);
    _email = new TextEditingController(text: user.email);
  }

  addUser(BuildContext context) async {
    final FormState form = _formKey.currentState;
    form.save();
    if (password != repeat) {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text("Password don't match !")));
      return;
    }
    if (form.validate()) {
      _authManager.register(user, password).then((data) {
        if (data['success']) {
          Navigator.pushReplacementNamed(context, "/login");
        } else {
          Scaffold
              .of(context)
              .showSnackBar(new SnackBar(content: new Text(data['msg'])));
        }
      });
    } else {
      Scaffold.of(context).showSnackBar(
          new SnackBar(content: new Text('Form must be valid !')));
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Register"),
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
                      autovalidate: true,
                      child: new Column(
                        children: <Widget>[
                          new TextFormField(
                            key: new Key('name'),
                            decoration: new InputDecoration(
                                labelText: "Firstname",
                                hintText: "Enter your firstname"),
                            onSaved: (String value) {
                              user.firstname = value;
                            },
                            controller: _name,
                            validator: validateName,
                          ),
                          new TextFormField(
                            key: new Key('lastname'),
                            decoration: new InputDecoration(
                                labelText: "Lastname",
                                hintText: "Enter your lastname"),
                            onSaved: (String value) {
                              user.name = value;
                            },
                            controller: _lastname,
                            validator: validateName,
                          ),
                          new TextFormField(
                            controller: _email,
                            decoration: new InputDecoration(
                              labelText: "Email",
                              hintText: "Enter your email",
                            ),
                            onSaved: (String value) {
                              user.email = value;
                            },
                            validator: validateEmail,
                          ),
                          new TextFormField(
                            key: new Key('password'),
                            decoration: new InputDecoration(
                                labelText: "Password", hintText: "***********"),
                            onSaved: (String value) {
                              password = value;
                            },
                            obscureText: true,
                            validator: validatePassword,
                          ),
                          new TextFormField(
                            key: new Key('repeat'),
                            decoration: new InputDecoration(
                                labelText: "Confirm password",
                                hintText: "***********"),
                            onSaved: (String value) {
                              repeat = value;
                            },
                            controller: _password,
                            obscureText: true,
                          ),
                          new Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new RaisedButton(
                                  child: new Text('Have an account ?'),
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                        context, "/login");
                                  },
                                ),
                                new Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                ),
                                new RaisedButton(
                                    child: new Text('Register'),
                                    onPressed: () {
                                      addUser(context);
                                    })
                              ]),
                        ],
                      )),
                ))),
          );
        }));
  }
}
