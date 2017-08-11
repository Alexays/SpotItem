import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:flutter/material.dart';

class EditItemScreen extends StatelessWidget {
  final AuthManager _authManager;
  final String _itemId;
  final _usernameController = new TextEditingController();
  final _passwordController = new TextEditingController();

  EditItemScreen(this._authManager, this._itemId);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('Edit: ' + this._itemId)),
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
                        child: new Text('Edit'),
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
