import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:flutter/material.dart';

class AddItemScreen extends StatelessWidget {
  final AuthManager _authManager;
  final _usernameController = new TextEditingController();
  final _passwordController = new TextEditingController();

  AddItemScreen(this._authManager);

  void _handleSubmit() {
    print(this._authManager.user.name);
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
                    key: new Key('name'),
                    decoration: new InputDecoration.collapsed(hintText: "name"),
                    autofocus: true,
                    controller: _usernameController,
                  ),
                  new TextFormField(
                    decoration:
                        new InputDecoration.collapsed(hintText: 'Description'),
                    controller: _passwordController,
                  ),
                  new RaisedButton(
                      child: new Text('Add'), onPressed: _handleSubmit)
                ],
              ),
            )));
  }
}
