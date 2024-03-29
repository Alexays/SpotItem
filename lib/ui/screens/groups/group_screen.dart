import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';
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
    final response = await Services.groups.leave(group.id);
    if (!mounted) {
      return;
    }
    if (!resValid(context, response)) {
      showSnackBar(context, SpotL.of(context).error);
      return;
    }
    await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<Null> _kickUser(BuildContext context, String userId) async {
    final response = await Services.groups.kickUser(group.id, userId);
    if (!mounted) {
      return;
    }
    if (!resValid(context, response)) {
      showSnackBar(context, SpotL.of(context).error);
      return;
    }
    setState(() {
      group.users = group.users.where((user) => user.id == userId).toList();
    });
    Navigator.of(context).pop();
  }

  Future<Null> _removeOwner(BuildContext context, String userId) async {
    final response = await Services.groups.removeOwner(group.id, userId);
    if (!mounted) {
      return;
    }
    if (!resValid(context, response)) {
      showSnackBar(context, SpotL.of(context).error);
      return;
    }
    setState(() {
      group.owners = group.owners.where((owner) => owner.id != userId).toList();
    });
    Navigator.of(context).pop();
  }

  Future<Null> _addOwner(BuildContext context, String userId) async {
    final response = await Services.groups.addOwner(group.id, userId);
    if (!mounted) {
      return;
    }
    if (!resValid(context, response)) {
      showSnackBar(context, SpotL.of(context).error);
      return;
    }
    setState(() {
      if (response.data != null) {
        group = new Group(JSON.decode(response.data));
      }
    });
    Navigator.of(context).pop();
  }

  Future<Null> _addPeople(BuildContext context) async {
    final String _email = await Navigator.pushNamed(context, '/contacts');
    if (!mounted || _email == null) {
      return;
    }
    final res = await Services.groups.addUser(group.id, _email);
    if (!resValid(context, res)) {
      return;
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
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 20.0,
              ),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: (accountEmailLine != null && accountNameLine != null)
                    ? <Widget>[accountNameLine, accountEmailLine]
                    : <Widget>[accountNameLine ?? accountEmailLine],
              ),
            ),
            new Expanded(child: new Container()),
            new Text(
              '${(group?.users?.length ?? 0 + 1).toString()} ${SpotL.of(context).members}',
              style: const TextStyle(color: Colors.white),
            )
          ])
    ];
    if (group.about.isNotEmpty) {
      _toBuild.addAll([
        const Padding(padding: const EdgeInsets.all(8.0)),
        new DefaultTextStyle(
          style: theme.primaryTextTheme.body2,
          child: new Text(SpotL.of(context).about),
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
              title: new Text(SpotL.of(context).confirm),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(SpotL.of(context).leaveGroup),
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                    MaterialLocalizations.of(context).cancelButtonLabel,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                new FlatButton(
                  child: new Text(
                    MaterialLocalizations.of(context).continueButtonLabel,
                  ),
                  onPressed: () => _leaveGroup(context),
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
                title: new Text(SpotL.of(context).confirm),
                content: new SingleChildScrollView(
                  child: new ListBody(
                    children: <Widget>[
                      new Text(SpotL.of(context).deleteGroup),
                    ],
                  ),
                ),
                actions: <Widget>[
                  new FlatButton(
                    child: new Text(
                        MaterialLocalizations.of(context).cancelButtonLabel),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  new FlatButton(
                    child: new Text(SpotL.of(context).delete.toUpperCase()),
                    onPressed: () async {
                      await Services.groups.delete(group.id);
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
              ),
            );
          },
        )
      ]);
    }
    return top;
  }

  Widget _buildSetOwnerButton(BuildContext context, int index) =>
      new IconButton(
        icon: const Icon(Icons.arrow_upward),
        onPressed: () {
          showDialog<Null>(
            context: context,
            child: new AlertDialog(
              title: new Text(SpotL.of(context).confirm),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(SpotL.of(context).addOwner(
                        '${group.users[index].firstname} ${group.users[index].name}')),
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(MaterialLocalizations
                      .of(context)
                      .cancelButtonLabel
                      .toUpperCase()),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                new FlatButton(
                  child: new Text(
                    SpotL.of(context).add.toUpperCase(),
                  ),
                  onPressed: () => _addOwner(context, group.users[index].id),
                ),
              ],
            ),
          );
        },
      );

  Widget _buildUnsetOwnerButton(BuildContext context, int index) =>
      new IconButton(
        icon: const Icon(Icons.arrow_downward),
        onPressed: () {
          showDialog<Null>(
            context: context,
            child: new AlertDialog(
              title: new Text(SpotL.of(context).confirm),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(SpotL.of(context).delOwner(
                        '${group.users[index].firstname} ${group.users[index].name}')),
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                      MaterialLocalizations.of(context).cancelButtonLabel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                new FlatButton(
                  child: new Text(
                      MaterialLocalizations.of(context).continueButtonLabel),
                  onPressed: () => _removeOwner(context, group.users[index].id),
                ),
              ],
            ),
          );
        },
      );

  Widget _buildKickUser(BuildContext context, int index) => new IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: () {
          showDialog<Null>(
            context: context,
            child: new AlertDialog(
              title: new Text(SpotL.of(context).confirm),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text(SpotL.of(context).kickUser(
                        '${group.users[index].firstname} ${group.users[index].name}')),
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text(
                      MaterialLocalizations.of(context).cancelButtonLabel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                new FlatButton(
                  child: new Text(
                      MaterialLocalizations.of(context).continueButtonLabel),
                  onPressed: () => _kickUser(context, group.users[index].id),
                ),
              ],
            ),
          );
        },
      );

  Widget _buildUsers(BuildContext context) => new Flexible(
        child: new ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemCount: group?.users?.length ?? 0,
          itemBuilder: (context, index) {
            final user = group.users[index];
            final buttons = <Widget>[
              getAvatar(user),
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
              ),
              new Text('${user.firstname} ${user.name}'),
              new Expanded(child: new Container()),
            ];
            if (group.owners.any((owner) => owner.id == user.id)) {
              buttons.add(const Icon(Icons.star));
            }
            if (!group.owners.any((owner) => owner.id == user.id) &&
                user.id != Services.auth.user.id &&
                isOwner) {
              buttons.add(_buildSetOwnerButton(context, index));
            }
            if (group.owners.any((owner) => owner.id == user.id) &&
                user.id != Services.auth.user.id &&
                isOwner &&
                group.owners[0].id != user.id) {
              buttons.add(_buildUnsetOwnerButton(context, index));
            }
            if (isOwner &&
                user.id != Services.auth.user.id &&
                !group.owners.any((owner) => owner.id == user.id)) {
              buttons.add(_buildKickUser(context, index));
            }
            return new GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed('/profile/:${user.id}'),
              child: new Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: buttons,
                ),
              ),
            );
          },
        ),
      );

  Widget _buildGroup(BuildContext context) => new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildUsers(context),
        ],
      );

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(
          title: new Text(group.name),
          actions: _doButton(context),
        ),
        body: new Builder(
          builder: (context) {
            Services.context = context;
            return _buildGroup(context);
          },
        ),
        bottomNavigationBar: isOwner
            ? new ConstrainedBox(
                constraints: new BoxConstraints.tightFor(
                  height: 48.0,
                  width: MediaQuery.of(context).size.width,
                ),
                child: new Builder(
                  builder: (context) => new RaisedButton(
                        color: Theme.of(context).accentColor,
                        onPressed: () => _addPeople(context),
                        child: new Text(
                          SpotL.of(context).addSomeone.toUpperCase(),
                          style: new TextStyle(
                            color: Theme.of(context).canvasColor,
                          ),
                        ),
                      ),
                ),
              )
            : null,
      );
}
