import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/ui/spot_strings.dart';
import 'package:spotitem/ui/screens/groups/edit_group_screen.dart';

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

  bool isOwner = false;

  @override
  void initState() {
    isOwner = group.owners.any((owner) => owner.id == Services.auth.user.id);
    super.initState();
  }

  Future<Null> _leaveGroup(BuildContext context) async {
    final response = await Services.groups.leaveGroup(group.id);
    if (resValid(context, response)) {
      await Navigator
          .of(context)
          .pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  Future<Null> _kickUser(BuildContext context, String userId) async {
    final response = await Services.groups.kickUser(group.id, userId);
    if (resValid(context, response)) {
      setState(() {
        group.users = group.users.where((user) => user.id == userId).toList();
      });
      Navigator.of(context).pop();
    }
  }

  Future<Null> _removeOwner(BuildContext context, String userId) async {
    final response = await Services.groups.removeOwner(group.id, userId);
    if (resValid(context, response)) {
      if (!mounted) {
        return;
      }
      setState(() {
        group.owners =
            group.owners.where((owner) => owner.id != userId).toList();
      });
      Navigator.of(context).pop();
    }
  }

  Future<Null> _addOwner(BuildContext context, String userId) async {
    final response = await Services.groups.addOwner(group.id, userId);
    if (resValid(context, response)) {
      if (!mounted) {
        return;
      }
      setState(() {
        if (response.data != null) {
          group = new Group(JSON.decode(response.data));
        }
      });
      Navigator.of(context).pop();
    }
  }

  Future<Null> _addPeople(BuildContext context) async {
    final String _email = await Navigator.pushNamed(context, '/contacts');
    if (_email == null) {
      return;
    }
    final res = await Services.groups.addUser(group.id, _email);
    if (!res.success) {
      showSnackBar(context, res.msg);
    }
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final Widget accountNameLine = new DefaultTextStyle(
      style: theme.primaryTextTheme.body2,
      child: new Text('${group.owners[0]?.firstname} ${group.owners[0]?.name}'),
    );
    final Widget accountEmailLine = new DefaultTextStyle(
      style: theme.primaryTextTheme.body1,
      child: new Text('${group.owners[0]?.email}'),
    );
    final _toBuild = <Widget>[
      new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            getAvatar(group.owners[0]),
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
            new Text(
              '${(group?.users?.length ?? 0 + 1).toString()} member(s)',
              style: const TextStyle(color: Colors.white),
            )
          ])
    ];
    if (group.about.isNotEmpty) {
      _toBuild.addAll([
        const Padding(padding: const EdgeInsets.all(8.0)),
        new DefaultTextStyle(
          style: theme.primaryTextTheme.body2,
          child: new Text(SpotL.of(context).about()),
        ),
        new DefaultTextStyle(
          style: theme.primaryTextTheme.body1,
          child: new Text(group.about),
        )
      ]);
    }
    return new Container(
        color: theme.primaryColor,
        padding: const EdgeInsets.all(28.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _toBuild,
        ));
  }

  List<Widget> _doButton(BuildContext context) {
    final top = <Widget>[
      new IconButton(
        icon: const Icon(Icons.exit_to_app),
        tooltip: 'Leave group',
        onPressed: () {
          showDialog<Null>(
            context: context,
            barrierDismissible: false,
            child: new AlertDialog(
              title: new Text(SpotL.of(context).confirm()),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    const Text('Are you sure to leave this group ?'),
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                      MaterialLocalizations.of(context).cancelButtonLabel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text(
                      MaterialLocalizations.of(context).continueButtonLabel),
                  onPressed: () {
                    _leaveGroup(context);
                  },
                ),
              ],
            ),
          );
        },
      )
    ];
    if (Services.auth.loggedIn &&
        group != null &&
        group.owners[0].id == Services.auth.user.id) {
      top.addAll([
        new IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Delete',
          onPressed: () {
            showDialog<Null>(
              context: context,
              barrierDismissible: false,
              child: new AlertDialog(
                title: new Text(SpotL.of(context).confirm()),
                content: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      const Text('Are you sure to delete this group ?'),
                    ],
                  ),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text(
                        MaterialLocalizations.of(context).cancelButtonLabel),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    child: const Text('Delete'),
                    onPressed: () async {
                      await Services.groups.delGroup(group.id);
                      await Navigator
                          .of(context)
                          .pushNamedAndRemoveUntil('/', (route) => false);
                    },
                  ),
                ],
              ),
            );
          },
        ),
        new IconButton(
          icon: const Icon(Icons.create),
          tooltip: 'Edit',
          onPressed: () async {
            await Navigator.push(
                context,
                new MaterialPageRoute<Null>(
                  builder: (context) => new EditGroupScreen(group: group),
                ));
          },
        )
      ]);
    }
    return top;
  }

  Widget _buildUsers(BuildContext context) => new Flexible(
      child: new ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: group?.users?.length ?? 0,
          itemBuilder: (context, index) {
            final buttons = <Widget>[
              getAvatar(group.users[index]),
              const Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0)),
              new Text(
                  '${group.users[index].firstname} ${group.users[index].name}'),
              new Expanded(child: new Container()),
            ];
            if (group.owners
                .any((owner) => owner.id == group.users[index].id)) {
              buttons.add(const Icon(
                Icons.star,
              ));
            }
            if (!group.owners
                    .any((owner) => owner.id == group.users[index].id) &&
                group.users[index].id != Services.auth.user.id &&
                isOwner) {
              buttons.add(new IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () {
                  showDialog<Null>(
                    context: context,
                    child: new AlertDialog(
                      title: new Text(SpotL.of(context).confirm()),
                      content: new SingleChildScrollView(
                        child: new ListBody(
                          children: <Widget>[
                            new Text(
                                'Are you sure to add ${group.users[index].firstname} ${group.users[index].name} as a owner ?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text(MaterialLocalizations
                              .of(context)
                              .cancelButtonLabel),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: const Text('Add'),
                          onPressed: () {
                            _addOwner(context, group.users[index].id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ));
            }
            if (group.owners
                    .any((owner) => owner.id == group.users[index].id) &&
                group.users[index].id != Services.auth.user.id &&
                isOwner &&
                group.owners[0].id != group.users[index].id) {
              buttons.add(new IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: () {
                  showDialog<Null>(
                    context: context,
                    child: new AlertDialog(
                      title: new Text(SpotL.of(context).confirm()),
                      content: new SingleChildScrollView(
                        child: new ListBody(
                          children: <Widget>[
                            new Text(
                                'Are you sure to remove ${group.users[index].firstname} ${group.users[index].name} from owners ?'),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text(MaterialLocalizations
                              .of(context)
                              .cancelButtonLabel),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: new Text(MaterialLocalizations
                              .of(context)
                              .continueButtonLabel),
                          onPressed: () {
                            _removeOwner(context, group.users[index].id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ));
            }
            if (isOwner &&
                group.users[index].id != Services.auth.user.id &&
                !group.owners
                    .any((owner) => owner.id == group.users[index].id)) {
              buttons.add(new IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  showDialog<Null>(
                    context: context,
                    child: new AlertDialog(
                      title: new Text(SpotL.of(context).confirm()),
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
                          child: new Text(MaterialLocalizations
                              .of(context)
                              .cancelButtonLabel),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: new Text(MaterialLocalizations
                              .of(context)
                              .continueButtonLabel),
                          onPressed: () {
                            _kickUser(context, group.users[index].id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ));
            }
            return new GestureDetector(
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
                          children: buttons,
                        ))));
          }));

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(
        title: new Text(group.name),
        actions: _doButton(context),
      ),
      body: new Builder(
          builder: (context) => new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(context),
                  isOwner
                      ? new Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: new Center(
                              child: new RaisedButton(
                            onPressed: () {
                              _addPeople(context);
                            },
                            child: new Text(SpotL.of(context).addSomeone()),
                          )))
                      : new Container(),
                  _buildUsers(context),
                ],
              )));
}
