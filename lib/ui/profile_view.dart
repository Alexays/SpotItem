import 'package:spot_items/model/item.dart';
import 'package:spot_items/model/user.dart';
import 'package:spot_items/interactor/manager/profile_manager.dart';
import 'package:flutter/material.dart';

class ProfileView extends StatefulWidget {
  final ProfileManager _profileManager;
  final String _username;

  ProfileView(this._profileManager, this._username);

  @override
  State<StatefulWidget> createState() =>
      new _ProfileViewState(_profileManager, _username);
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileManager _profileManager;
  final String _username;

  _ProfileViewState(this._profileManager, this._username);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(children: <Widget>[
      _buildProfileView(),
      new Flexible(child: new Text("test"))
    ]);
  }

  Widget _buildProfileView() {
    return new FutureBuilder<User>(
      future: _profileManager.loadUser(),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          default:
            return _buildProfileHeader(snapshot.data);
        }
      },
    );
  }

  Widget _buildProfileHeader(User user) {
    user = user != null ? user : new User(-1, null, null, null, null);

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
