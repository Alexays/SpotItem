import 'package:spotitems/model/user.dart';
import 'package:spotitems/interactor/manager/profile_manager.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  final ProfileManager _profileManager;
  final User _user;

  ProfileView(this._profileManager, this._user);

  @override
  State<StatefulWidget> createState() =>
      new _ProfileViewState(_profileManager, _user);
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileManager _profileManager;
  final User _user;

  _ProfileViewState(this._profileManager, this._user);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(children: <Widget>[
      _buildProfileHeader(_user),
      new Flexible(child: new Text(""))
    ]);
  }

  Widget _buildProfileHeader(User user) {
    user = user != null ? user : new User(null, null, null, null, null);

    return new Container(
      margin: new EdgeInsets.only(top: 16.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[_buildUserIdentity(user), new Divider()],
      ),
    );
  }

  Widget _buildUserIdentity(User user) {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Padding(
            child: new CircleAvatar(
              radius: 40.0,
              backgroundColor: Colors.grey,
              backgroundImage:
                  user.avatar != null ? new NetworkImage(user.avatar) : null,
            ),
            padding: const EdgeInsets.only(right: 16.0),
          ),
          new Column(
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: new Text(user.name != null ? user.name : '',
                    style: new TextStyle(fontWeight: FontWeight.bold)),
              ),
              new Text(user.firstname != null ? user.firstname : '')
            ],
          )
        ]);
  }
}
