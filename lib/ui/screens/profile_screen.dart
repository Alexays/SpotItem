import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(this._userId);

  final String _userId;

  @override
  _ProfileScreenState createState() => new _ProfileScreenState(_userId);
}

class _ProfileScreenState extends State<ProfileScreen> {
  _ProfileScreenState(this._userId);

  final String _userId;
  User _user;

  @override
  void initState() {
    Services.authManager.getUser(_userId).then((user) {
      _user = user;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
            title: _user != null
                ? new Text('${_user.firstname} ${_user.name}')
                : const Text('Loading...')),
        body: _user != null
            ? new Builder(
                builder: (context) => new SingleChildScrollView(
                    child: new Container(
                        margin: const EdgeInsets.all(20.0),
                        child: new Column(
                          children: <Widget>[
                            new Center(
                                child: new CircleAvatar(
                                    radius: 40.0,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: _user.avatar != null &&
                                            _user.avatar != 'null'
                                        ? new NetworkImage(_user.avatar)
                                        : null,
                                    child: new Text(
                                        '${_user.firstname[0]}${_user.name[0]}'))),
                            const Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0)),
                            new Text('${_user.firstname} ${_user.name}'),
                          ],
                        ))))
            : const Center(child: const CircularProgressIndicator()),
      );
}
