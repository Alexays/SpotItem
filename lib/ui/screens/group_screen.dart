import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/ui/spot_strings.dart';

/// Group page class
class GroupPage extends StatefulWidget {
  /// Group page initializer
  const GroupPage({
    Key key,
    this.group,
  })
      : super(key: key);

  /// Group data
  final Group group;

  @override
  _GroupPageState createState() => new _GroupPageState(group);
}

class _GroupPageState extends State<GroupPage>
    with SingleTickerProviderStateMixin {
  _GroupPageState(this.group);

  Group group;

  User owner;

  bool dragStopped = true;

  @override
  void initState() {
    Services.users.getUser(group.owner).then((data) {
      setState(() {
        owner = data;
      });
    });
    group.users =
        group.users.where((user) => user.groups.contains(group.id)).toList();
    super.initState();
  }

  Future<Null> _leaveGroup(BuildContext context) async {
    final dynamic response = await Services.groups.leaveGroup(group.id);
    if (response['success']) {
      await Navigator
          .of(context)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  Future<Null> _kickUser(BuildContext context, String userId) async {
    final dynamic response = await Services.groups.kickUser(group.id, userId);
    if (response['success']) {
      setState(() {
        group.users = group.users.where((user) => user.id == userId).toList();
      });
      Navigator.of(context).pop();
    }
  }

  Future<Null> _addPeople(BuildContext context) async {
    final String _email = await Navigator.pushNamed(context, '/contacts');
    if (_email == null) {
      return;
    }
    final res = await Services.groups.addUserToGroup(group.id, _email);
    if (res['success']) {
      Navigator.of(context).pop();
    } else {
      showSnackBar(context, res['msg']);
    }
  }

  Widget _buildHeader(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Widget accountNameLine = new DefaultTextStyle(
      style: theme.primaryTextTheme.body2,
      child: new Text('${owner?.firstname} ${owner?.name}'),
    );
    final Widget accountEmailLine = new DefaultTextStyle(
      style: theme.primaryTextTheme.body1,
      child: new Text('${owner?.email}'),
    );
    if (owner != null) {
      final List<Widget> _toBuild = []..add(new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              getAvatar(owner),
              new Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        (accountEmailLine != null && accountNameLine != null)
                            ? <Widget>[accountNameLine, accountEmailLine]
                            : <Widget>[accountNameLine ?? accountEmailLine]),
              ),
              new Expanded(
                child: new Container(),
              ),
              new Icon(
                Icons.chevron_left,
                color: theme.canvasColor,
              ),
              const Padding(
                padding: const EdgeInsets.all(1.0),
              ),
              new DefaultTextStyle(
                style: theme.primaryTextTheme.body1,
                child: new Text(SpotL.of(context).owner()),
              )
            ]));
      if (group.about.isNotEmpty) {
        _toBuild
          ..add(const Padding(padding: const EdgeInsets.all(8.0)))
          ..add(new DefaultTextStyle(
            style: theme.primaryTextTheme.body2,
            child: new Text(SpotL.of(context).about()),
          ))
          ..add(new DefaultTextStyle(
            style: theme.primaryTextTheme.body1,
            child: new Text('${group.about}'),
          ));
      }
      return new Container(
          color: theme.primaryColor,
          padding: const EdgeInsets.all(28.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _toBuild,
          ));
    } else {
      return new Container();
    }
  }

  List<Widget> _doButton(BuildContext context) {
    final List<Widget> top = <Widget>[]..add(new IconButton(
        icon: const Icon(Icons.exit_to_app),
        tooltip: 'Leave group',
        onPressed: () {
          showDialog<Null>(
            context: context,
            barrierDismissible: false,
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
                    _leaveGroup(context);
                  },
                ),
              ],
            ),
          );
        },
      ));
    if (Services.auth.loggedIn &&
        group != null &&
        group.owner == Services.auth.user.id) {
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
                      Services.groups.delGroup(group.id);
                      Navigator
                          .of(context)
                          .pushNamedAndRemoveUntil('/home', (route) => false);
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
            Navigator.of(context).pushNamed('/groups/${group.id}/edit');
          },
        ));
    }
    return top;
  }

  Widget _buildUsers(BuildContext context) => new Flexible(
      child: new ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: group.users.length,
          itemBuilder: (context, index) => new GestureDetector(
              onTap: () {},
              child: new GestureDetector(
                  onTap: () {
                    Navigator
                        .of(context)
                        .pushNamed('/profile/${group.users[index].id}');
                  },
                  child: new Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          getAvatar(group.users[index]),
                          const Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0)),
                          new Text(
                              '${group.users[index].firstname} ${group.users[index].name}'),
                          new Expanded(child: new Container()),
                          group.owner == Services.auth.user.id &&
                                  group.users[index].id != Services.auth.user.id
                              ? new IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    showDialog<Null>(
                                      context: context,
                                      barrierDismissible: false,
                                      child: new AlertDialog(
                                        title: const Text('Kick confirmation'),
                                        content: new SingleChildScrollView(
                                          child: new ListBody(
                                            children: <Widget>[
                                              new Text(
                                                  'Are you sure to kick ${group.users[index].firstname} ${group.users[index].name} ?'),
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
                                            child: const Text('Kick'),
                                            onPressed: () {
                                              _kickUser(context,
                                                  group.users[index].id);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : new Container()
                        ],
                      ))))));

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(
        title: new Text('${group.name}'),
        actions: _doButton(context),
      ),
      body: new Builder(
          builder: (context) => new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(context),
                  new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Center(
                          child: new RaisedButton(
                        onPressed: () {
                          _addPeople(context);
                        },
                        child: new Text(SpotL.of(context).addSomeone()),
                      ))),
                  _buildUsers(context),
                ],
              )));
}
