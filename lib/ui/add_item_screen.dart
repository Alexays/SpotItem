import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:flutter/material.dart';

class AddItemScreen extends StatelessWidget {
  final AuthManager _authManager;
  final _usernameController = new TextEditingController();
  final _passwordController = new TextEditingController();

  AddItemScreen(this._authManager);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Add Item')),
      body: new Builder(
        builder: (BuildContext context) {
          return new Container(
              margin: const EdgeInsets.all(20.0),
              child: new Form(
                child: new Column(
                  children: <Widget>[
                    new TextFormField(
                      key: new Key('name'),
                      decoration:
                          new InputDecoration.collapsed(hintText: "name"),
                      autofocus: true,
                      controller: _usernameController,
                    ),
                    new TextFormField(
                      decoration: new InputDecoration.collapsed(
                          hintText: 'Description'),
                      controller: _passwordController,
                    ),
                    new RaisedButton(
                        child: new Text('Add'),
                        onPressed: () {
                          Scaffold.of(context).showSnackBar(
                              new SnackBar(content: new Text("test")));
                        })
                  ],
                ),
              ));
        },
      ),
    );
  }
}
