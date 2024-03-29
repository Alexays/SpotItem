import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/ui/screens/groups/group_screen.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/utils.dart';

/// Groups view class
class GroupsView extends StatefulWidget {
  /// Groups view initializer
  const GroupsView();

  @override
  State<StatefulWidget> createState() => new _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  _GroupsViewState();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  List<Group> _groups;
  List<Group> _inv;

  @override
  void initState() {
    super.initState();
    _groups = Services.groups.data;
    _inv = Services.groups.invitation;
    if (_groups.isEmpty) {
      _groups = null;
    }
    _checkGroup();
  }

  Future<Null> _checkGroup() async {
    if (_groups != null) {
      return await _refreshIndicatorKey.currentState?.show();
    }
    await _loadGroups();
  }

  Future<Null> _loadGroups() async {
    await Services.groups.getAll().then((groups) {
      if (!mounted) {
        return;
      }
      setState(() {
        _groups = groups;
      });
    });
    await Services.groups.getInv().then((invitations) {
      if (!mounted) {
        return;
      }
      setState(() {
        _inv = invitations;
      });
    });
  }

  Future<Null> _joinGroup(String id) async {
    final response = await Services.groups.join(id);
    if (resValid(context, response)) {
      await _loadGroups();
    }
  }

  Future<Null> _showGroup(Group _group) async {
    await Navigator.push(
      context,
      new MaterialPageRoute<Null>(
        builder: (context) => new GroupPage(group: _group),
      ),
    );
  }

  Widget _createList(BuildContext context) {
    if (_inv.isEmpty && _groups.isEmpty) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Center(child: new Text(SpotL.of(context).noGroups)),
          const Padding(padding: const EdgeInsets.all(10.0)),
          new RaisedButton(
            child: new Text(SpotL.of(context).addGroup),
            onPressed: () => Navigator.of(context).pushNamed('/groups/add/'),
          ),
        ],
      );
    }
    return new ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        itemCount: (_groups?.length ?? 0) + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            if (_inv.isNotEmpty) {
              return _buildInv();
            }
            return new Container();
          }
          return new Card(
            child: new ListTile(
              onTap: () => _showGroup(_groups[index - 1]),
              leading: new CircleAvatar(
                backgroundColor: Colors.grey,
                child: new Text(_groups[index - 1].name[0]),
              ),
              title: new Text(_groups[index - 1].name),
              subtitle: new Text(_groups[index - 1].about),
              trailing: new Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Text(
                    (_groups[index - 1].users?.length ?? '?').toString(),
                    style: new TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15.0,
                    ),
                  ),
                  const Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2.0,
                    ),
                  ),
                  const Icon(Icons.people)
                ],
              ),
            ),
          );
        });
  }

  Widget _buildInv() => new Container(
        child: new ExpansionTile(
          leading: const Icon(Icons.mail),
          title: new Text(SpotL.of(context).nbInv(_inv?.length.toString())),
          children: _inv
              .map((f) => new Card(
                    child: new ListTile(
                      onTap: () {
                        showDialog<Null>(
                          context: context,
                          barrierDismissible: false,
                          child: new AlertDialog(
                            title: new Text(SpotL.of(context).confirm),
                            content: new SingleChildScrollView(
                              child: new ListBody(
                                children: <Widget>[
                                  new Text(SpotL.of(context).joinGroup(f.name)),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              new FlatButton(
                                child: new Text(MaterialLocalizations
                                    .of(context)
                                    .cancelButtonLabel),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              new FlatButton(
                                child: new Text(MaterialLocalizations
                                    .of(context)
                                    .continueButtonLabel),
                                onPressed: () async {
                                  await _joinGroup(f.id);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      leading: new CircleAvatar(
                        child: new Text(f.name[0]),
                      ),
                      title: new Text(f.name),
                      subtitle: new Text(f.about),
                      trailing: new Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            f.users
                                .where((user) => user.groups.contains(f.id))
                                .length
                                .toString(),
                            style: new TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15.0,
                            ),
                          ),
                          const Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2.0,
                            ),
                          ),
                          const Icon(Icons.people)
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      );

  @override
  Widget build(BuildContext context) => new RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _loadGroups,
      child: _groups == null
          ? const Center(child: const CircularProgressIndicator())
          : _createList(context));
}
