import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/models/user.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';

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

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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

  Future<Null> _kickUser(String userId) async {
    final dynamic response =
        await Services.authManager.kickUser(group.id, userId);
    if (response['success']) {
      setState(() {
        group.users = group.users.where((user) => user.id == userId).toList();
      });
      Navigator.of(context).pop();
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
      final List<Widget> _toBuild = []..add(new Row(
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
                Icons.chevron_left,
                color: theme.canvasColor,
              ),
              const Padding(
                padding: const EdgeInsets.all(1.0),
              ),
              new DefaultTextStyle(
                style: theme.primaryTextTheme.body1,
                child: const Text('Owner'),
              )
            ]));
      if (group.about.isNotEmpty) {
        _toBuild
          ..add(const Padding(padding: const EdgeInsets.all(8.0)))
          ..add(new DefaultTextStyle(
            style: theme.primaryTextTheme.body2,
            child: const Text('About'),
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

  void _addPeople() {
    String _email;
    final GlobalKey<FormState> _formKeyEmail = new GlobalKey<FormState>();
    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        child: new AlertDialog(
            title: const Text('Add someone'),
            content: new SingleChildScrollView(
                child: new Form(
                    key: _formKeyEmail,
                    autovalidate: true,
                    child: new ListBody(children: <Widget>[
                      const Text('Enter email of user.'),
                      new TextFormField(
                        key: const Key('email'),
                        decoration: const InputDecoration.collapsed(
                            hintText: 'ex: john.do@exemple.com'),
                        onSaved: (value) {
                          _email = value.trim();
                        },
                        validator: validateEmail,
                      )
                    ]))),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              new FlatButton(
                  child: const Text('Add'),
                  onPressed: () {
                    _formKeyEmail.currentState.save();
                    if (_email != null && emailExp.hasMatch(_email)) {
                      Services.authManager
                          .addUserToGroup(group.id, _email)
                          .then((res) {
                        if (res['success']) {
                          Navigator.of(context).pop();
                        } else {
                          _scaffoldKey.currentState.showSnackBar(
                              new SnackBar(content: new Text(res['msg'])));
                        }
                      });
                    } else {
                      _scaffoldKey.currentState.showSnackBar(const SnackBar(
                          content: const Text('Enter valid email')));
                    }
                  }),
            ]));
  }

  Widget _buildUsers() => new Flexible(
      child: new ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: group.users.length,
          itemBuilder: (context, index) => new GestureDetector(
              onTap: () {},
              child: new Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: new Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new CircleAvatar(
                        radius: 30.0,
                        child: new Text(
                            '${group.users[index].firstname[0]}${group.users[index].name[0]}'),
                      ),
                      const Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0)),
                      new Text(
                          '${group.users[index].firstname} ${group.users[index].name}'),
                      new Expanded(child: new Container()),
                      group.owner == Services.authManager.user.id &&
                              group.users[index].id !=
                                  Services.authManager.user.id
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
                                          _kickUser(group.users[index].id);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                          : new Container()
                    ],
                  )))));

  @override
  Widget build(BuildContext context) => new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('Group: ${group.name}'),
          actions: _doButton(),
        ),
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new Center(
                    child: new RaisedButton(
                  onPressed: () {
                    _addPeople();
                  },
                  child: const Text('Add a user'),
                ))),
            _buildUsers(),
          ],
        ),
      );
}
