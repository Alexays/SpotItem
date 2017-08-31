import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/services.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({
    Key key,
    this.group,
  })
      : super(key: key);

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
    Services.authManager.getUser(group.owner).then((data) {
      owner = data;
    });
    group.users =
        group.users.where((user) => user.groups.contains(group.id)).toList();
    super.initState();
  }

  Future<Null> _leaveGroup() async {
    final dynamic response = await Services.authManager.leaveGroup(group.id);
    if (response['success']) {
      await Navigator
          .of(context)
          .pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  Widget _buildHeader() {
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
      return new Container(
        color: theme.primaryColor,
        padding: const EdgeInsets.all(28.0),
        child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.grey,
                  backgroundImage: owner?.avatar != 'null'
                      ? new NetworkImage(owner?.avatar)
                      : null,
                  child: new Text('${owner?.firstname[0]}${owner?.name[0]}')),
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
                Icons.star,
                color: theme.canvasColor,
              ),
              const Padding(
                padding: const EdgeInsets.all(1.0),
              ),
              new DefaultTextStyle(
                style: theme.primaryTextTheme.body1,
                child: const Text('Owner'),
              )
            ]),
      );
    } else {
      return new Container();
    }
  }

  List<Widget> _doButton() {
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
                    _leaveGroup();
                  },
                ),
              ],
            ),
          );
        },
      ));
    if (Services.authManager.loggedIn &&
        group != null &&
        group.owner == Services.authManager.user.id) {
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
                      Services.authManager.delGroup(group.id);
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
            //Navigator.of(context).pushNamed('/groups/${group.id}/edit');
          },
        ));
    }
    return top;
  }

  Widget _buildUsers() => new Flexible(
      child: new ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(20.0),
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
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            _buildUsers(),
            new Text(group.about)
          ],
        ),
      );
}
