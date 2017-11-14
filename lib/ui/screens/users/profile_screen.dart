import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Profile screen class
class ProfileScreen extends StatefulWidget {
  /// Profile screen initializer
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
    super.initState();
    Services.users.get(_userId).then((user) {
      if (!mounted) {
        return;
      }
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
            title: _user != null ? new Text('${_user.firstname} ${_user.name}') : new Text(SpotL.of(context).loading)),
        body: new Builder(
            builder: (context) => _user != null
                ? new SingleChildScrollView(
                    child: new Container(
                        margin: const EdgeInsets.all(20.0),
                        child: new Column(
                          children: <Widget>[
                            new Center(child: getAvatar(_user)),
                            const Padding(padding: const EdgeInsets.symmetric(vertical: 10.0)),
                            new Text('${_user.firstname} ${_user.name}'),
                          ],
                        )))
                : const Center(child: const CircularProgressIndicator())),
      );
}
