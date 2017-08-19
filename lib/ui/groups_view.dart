import 'package:flutter/material.dart';
import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/ui/group_view.dart';
import 'package:spotitems/model/group.dart';

class GroupsView extends StatefulWidget {
  final ItemsManager _itemsManager;
  final AuthManager _authManager;

  GroupsView(this._itemsManager, this._authManager);

  @override
  State<StatefulWidget> createState() =>
      new _GroupsViewState(_itemsManager, _authManager);
}

class _GroupsViewState extends State<GroupsView> {
  _GroupsViewState(this._itemsManager, this._authManager);

  final AuthManager _authManager;
  final ItemsManager _itemsManager;

  bool _loading = true;

  List<Group> _myGroups = [];

  List<Group> _myGroupsInv = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  _loadGroups() {
    _loading = true;
    var loading = true;
    if (_authManager.loggedIn) {
      _authManager.getGroups(_authManager.user.id).then((data) {
        setState(() {
          _myGroups = data;
          if (loading == false) {
            _loading = false;
          }
          loading = false;
        });
      });
      _authManager.getGroupsInv(_authManager.user.id).then((data) {
        setState(() {
          _myGroupsInv = data;
          if (loading == false) {
            _loading = false;
          }
          loading = false;
        });
      });
    }
  }

  _joinGroup(int index) async {
    var response = await _authManager.joinGroup(_myGroupsInv[index].id);
    if (response['success']) {
      _loadGroups();
    }
  }

  Widget getList() {
    if (_myGroups.length == 0) {
      return new Center(
        child: new Text("No groups"),
      );
    }
    return new Container(
        padding: const EdgeInsets.all(20.0),
        child: new ListView.builder(
            padding: new EdgeInsets.symmetric(vertical: 8.0),
            itemCount: _myGroups.length,
            itemBuilder: (BuildContext context, int index) {
              return new GestureDetector(
                onTap: () {
                  Navigator.push(context, new MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return new GroupPage(
                        group: _myGroups[index],
                        authManager: _authManager,
                        itemsManager: _itemsManager,
                      );
                    },
                  ));
                },
                child: new Card(
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new ListTile(
                          leading: new CircleAvatar(
                              backgroundColor: Colors.grey,
                              child: new Text(_myGroups[index].name[0])),
                          title: new Text(_myGroups[index].name),
                          subtitle: new Text(_myGroups[index].about),
                          trailing: new Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                _myGroups[index].users.length.toString(),
                                style: new TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15.0),
                              ),
                              const Icon(Icons.people)
                            ],
                          ))
                    ],
                  ),
                ),
              );
            }));
  }

  _buildInv() {
    if (_myGroupsInv.length == 0) return new Container();
    return new Container(
      child: new ExpansionTile(
        leading: const Icon(Icons.mail),
        title: new Text(
            "You have " + _myGroupsInv.length.toString() + " invitation(s)"),
        children: new List<Widget>.generate(_myGroupsInv.length, (int index) {
          return new GestureDetector(
              onTap: () {
                showDialog<Null>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  child: new AlertDialog(
                    title: new Text('Join $_myGroupsInv[index].name ?'),
                    content: new SingleChildScrollView(
                      child: new ListBody(
                        children: <Widget>[
                          new Text('Are you sure to join ?'),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      new FlatButton(
                        child: new Text('Join !'),
                        onPressed: _joinGroup(index),
                      ),
                    ],
                  ),
                );
              },
              child: new Card(
                child: new Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new ListTile(
                        leading: new CircleAvatar(
                            child: new Text(_myGroupsInv[index].name[0])),
                        title: new Text(_myGroupsInv[index]?.name),
                        subtitle: new Text(_myGroupsInv[index]?.about),
                        trailing: new Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              _myGroupsInv[index].users.length.toString(),
                              style: new TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 15.0),
                            ),
                            const Icon(Icons.people)
                          ],
                        ))
                  ],
                ),
              ));
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.all(20.0),
      child: _loading
          ? new Center(child: new CircularProgressIndicator())
          : new SingleChildScrollView(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildInv(),
                  new Container(
                    height: MediaQuery.of(context).size.height,
                    child: getList(),
                  )
                ],
              ),
            ),
    );
  }
}
