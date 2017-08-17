import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/model/user.dart';

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
    user = new User(null, null, null, null, null);
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
    _authManager.register(user, password).then((success) {
      if (success) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("Invalid credentials !")));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Register"),
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Container(
              decoration: new BoxDecoration(
                color: const Color.fromARGB(55, 52, 152, 219),
              ),
              padding: const EdgeInsets.all(40.0),
              child: new Card(
                  child: new Container(
                margin: const EdgeInsets.all(20.0),
                child: new Form(
                    key: _formKey,
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
                        ),
                        new FocusScope(
                          node: new FocusScopeNode(),
                          child: new TextFormField(
                            controller: _email,
                            style: theme.textTheme.subhead.copyWith(
                              color: theme.disabledColor,
                            ),
                            decoration: new InputDecoration(
                              labelText: "Email",
                              hintText: "Enter your email",
                            ),
                          ),
                        ),
                        new TextFormField(
                          key: new Key('password'),
                          decoration: new InputDecoration(
                              labelText: "Password", hintText: "***********"),
                          onSaved: (String value) {
                            password = value;
                          },
                          obscureText: true,
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
                        new RaisedButton(
                            child: new Text('Login'),
                            onPressed: addUser(user, password)),
                      ],
                    )),
              )));
        }));
  }
}
