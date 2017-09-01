import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/ui/views/group_view.dart';
import 'package:spotitem/models/group.dart';

class GroupsView extends StatefulWidget {
  const GroupsView();

  @override
  State<StatefulWidget> createState() => new _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  _GroupsViewState();

  static List<Group> _myGroups;
  static List<Group> _myGroupsInv;

  @override
  void initState() {
    _loadGroups();
    super.initState();
  }

  void _loadGroups() {
    if (Services.authManager.loggedIn) {
      Services.authManager.getGroups().then((data) {
        setState(() {
          _myGroups = data;
        });
      });
      Services.authManager
          .getGroupsInv(Services.authManager.user.id)
          .then((data) {
        setState(() {
          _myGroupsInv = data;
        });
      });
    }
  }

  Future<Null> _joinGroup(int index) async {
    final dynamic response =
        await Services.authManager.joinGroup(_myGroupsInv[index].id);
    if (response['success']) {
      _loadGroups();
    }
  }

  Future<Null> _showGroup(int index) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          builder: (context) => new GroupPage(group: _myGroups[index - 1]),
        ));
  }

  Widget getList() => new ListView.builder(
      padding: const EdgeInsets.all(20.0),
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
                    barrierDismissible: false,
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
                              const Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0)),
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
  Widget build(BuildContext context) =>
      _myGroups == null || _myGroupsInv == null
          ? const Center(child: const CircularProgressIndicator())
          : getList();
}
