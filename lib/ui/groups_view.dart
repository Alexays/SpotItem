import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotitems/interactor/manager/auth_manager.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/ui/group_view.dart';
import 'package:spotitems/model/group.dart';

class GroupsView extends StatefulWidget {
  final ItemsManager _itemsManager;
  final AuthManager _authManager;

  const GroupsView(this._itemsManager, this._authManager);

  @override
  State<StatefulWidget> createState() => new _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  _GroupsViewState();

  bool _loading = true;

  List<Group> _myGroups = <Group>[];

  List<Group> _myGroupsInv = <Group>[];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    setState(() {
      _loading = true;
    });
    bool loading = true;
    if (widget._authManager.loggedIn) {
      widget._authManager.getGroups(widget._authManager.user.id).then((data) {
        setState(() {
          _myGroups = data;
          if (loading == false) {
            _loading = false;
          }
          loading = false;
        });
      });
      widget._authManager
          .getGroupsInv(widget._authManager.user.id)
          .then((data) {
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

  Future<Null> _joinGroup(int index) async {
    final dynamic response =
        await widget._authManager.joinGroup(_myGroupsInv[index].id);
    if (response['success']) {
      _loadGroups();
    }
  }

  Future<Null> _showGroup(int index) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          builder: (context) => new GroupPage(
                group: _myGroups[index - 1],
                authManager: widget._authManager,
                itemsManager: widget._itemsManager,
              ),
        ));
  }

  Widget getList() => new ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: _myGroups.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          if (_myGroupsInv.isNotEmpty) {
            return _buildInv();
          } else if (_myGroups.isEmpty) {
            return const Center(child: const Text('No groups'));
          }
          return new Container();
        }
        return new GestureDetector(
          onTap: () {
            _showGroup(index);
          },
          child: new Card(
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new ListTile(
                    leading: new CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: new Text(_myGroups[index - 1].name[0])),
                    title: new Text(_myGroups[index - 1].name),
                    subtitle: new Text(_myGroups[index - 1].about),
                    trailing: new Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          _myGroups[index - 1]
                              .users
                              .where((user) =>
                                  user.groups.contains(_myGroups[index - 1].id))
                              .length
                              .toString(),
                          style: new TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15.0),
                        ),
                        const Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0)),
                        const Icon(Icons.people)
                      ],
                    ))
              ],
            ),
          ),
        );
      });

  Widget _buildInv() {
    if (_myGroupsInv.isEmpty) {
      return new Container();
    }
    return new Container(
      child: new ExpansionTile(
        leading: const Icon(Icons.mail),
        title: new Text(
            'You have ${_myGroupsInv.length.toString()} invitation(s)'),
        children: new List<Widget>.generate(
            _myGroupsInv.length,
            (index) => new GestureDetector(
                onTap: () {
                  showDialog<Null>(
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    child: new AlertDialog(
                      title: new Text('Join ${_myGroupsInv[index].name} ?'),
                      content: new SingleChildScrollView(
                        child: new ListBody(
                          children: <Widget>[
                            const Text('Are you sure to join ?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: const Text('Join !'),
                          onPressed: () {
                            _joinGroup(index);
                            Navigator.of(context).pop();
                          },
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
                                _myGroupsInv[index]
                                    .users
                                    .where((user) => user.groups
                                        .contains(_myGroupsInv[index].id))
                                    .length
                                    .toString(),
                                style: new TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15.0),
                              ),
                              const Icon(Icons.people)
                            ],
                          ))
                    ],
                  ),
                ))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => new Container(
        margin: const EdgeInsets.all(20.0),
        child: _loading
            ? const Center(child: const CircularProgressIndicator())
            : getList(),
      );
}
