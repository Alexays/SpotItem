import 'package:spotitems/interactor/manager/profile_manager.dart';
import 'package:spotitems/ui/profile_view.dart';
import 'package:flutter/material.dart';

class AddItemScreen extends StatelessWidget {
  final ProfileManager _profileManager;
  final String _username;
  final _usernameController = new TextEditingController();
  final _passwordController = new TextEditingController();

  AddItemScreen(this._profileManager, this._username);

  void _handleSubmit() {
    print("walou");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Add item"),
        ),
        body: new Container(
            margin: const EdgeInsets.all(20.0),
            child: new Form(
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    key: new Key('username'),
                    decoration: new InputDecoration.collapsed(
                        hintText: "Username or email"),
                    autofocus: true,
                    controller: _usernameController,
                  ),
                  new TextFormField(
                    decoration:
                        new InputDecoration.collapsed(hintText: 'Password'),
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  new RaisedButton(
                      child: new Text('Login'), onPressed: _handleSubmit)
                ],
              ),
            )));
  }
}
