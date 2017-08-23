import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/model/group.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/interactor/manager/auth_manager.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({
    @required this.itemsManager,
    @required this.authManager,
    Key key,
    this.group,
  })
      : super(key: key);

  final AuthManager authManager;
  final ItemsManager itemsManager;
  final Group group;

  @override
  _GroupPageState createState() => new _GroupPageState(group);
}

class _GroupPageState extends State<GroupPage>
    with SingleTickerProviderStateMixin {
  _GroupPageState(this.group);

  Group group;

  bool dragStopped = true;

  @override
  void initState() {
    super.initState();
    group.users =
        group.users.where((user) => user.groups.contains(group.id)).toList();
  }

  Future<Null> _leaveGroup() async {
    final dynamic reponse = await widget.authManager.leaveGroup(group.id);
    if (reponse['success']) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  List<Widget> _doButton() {
    final List<Widget> top = <Widget>[]..add(new IconButton(
        icon: const Icon(Icons.exit_to_app),
        tooltip: 'Leave group',
        onPressed: () {
          showDialog<Null>(
            context: context,
            barrierDismissible: false, // user must tap button!
            child: new AlertDialog(
              title: const Text('Leave confirmation'),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    const Text('Are you sure to leave this group ?'),
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
                  child: const Text('Leave'),
                  onPressed: () {
                    _leaveGroup;
                  },
                ),
              ],
            ),
          );
        },
      ));
    if (widget.authManager.loggedIn &&
        group != null &&
        group.owner == widget.authManager.user.id) {
      top
        ..add(new IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Delete',
          onPressed: () {
            showDialog<Null>(
              context: context,
              barrierDismissible: false, // user must tap button!
              child: new AlertDialog(
                title: const Text('Delete confirmation'),
                content: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      const Text('Are you sure to delete this group ?'),
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
                    child: const Text('Delete'),
                    onPressed: () {
                      widget.authManager.delGroup(group.id);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                ],
              ),
            );
          },
        ))
        ..add(new IconButton(
          icon: const Icon(Icons.create),
          tooltip: 'Edit',
          onPressed: () {
            //Navigator.of(context).pushNamed('/groups/${group.id}/edit');
          },
        ));
    }
    return top;
  }

  Widget _buildUsers() => new Flexible(
      child: new ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          itemCount: group.users.length,
          itemBuilder: (context, index) => new GestureDetector(
              onTap: () {},
              child: new Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new CircleAvatar(
                        radius: 30.0,
                        child: new Text(
                            '${group.users[index].firstname[0]}${group.users[index].name[0]}'),
                      ),
                      const Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                      ),
                      new Text(
                          '${group.users[index].firstname}.${group.users[index].name[0]}')
                    ],
                  )))));

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(
        title: new Text('Group: ${group.name}'),
        actions: _doButton(),
      ),
      body: new Container(
        margin: const EdgeInsets.all(20.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[_buildUsers(), new Text(group.about)],
        ),
      ));
}
