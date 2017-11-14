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

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  static List<Group> _groups;
  static List<Group> _groupsInv;

  @override
  void initState() {
    super.initState();
    _groups = Services.groups.data;
    _groupsInv = Services.groups.invitation;
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

  //TO-DO MAYBE don't await it's better :)
  Future<Null> _loadGroups() async {
    final resGroup = await Services.groups.getAll();
    final resInv = await Services.groups.getInv();
    if (!mounted) {
      return;
    }
    setState(() {
      _groups = resGroup;
      _groupsInv = resInv;
    });
  }

  Future<Null> _joinGroup(int index) async {
    final response = await Services.groups.join(_groupsInv[index].id);
    if (resValid(context, response)) {
      await _loadGroups();
    }
  }

  Future<Null> _showGroup(int index) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          builder: (context) => new GroupPage(group: _groups[index - 1]),
        ));
  }

  Widget _createList() => _groupsInv != null && _groupsInv.isEmpty && _groups.isEmpty
      ? new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Center(child: new Text(SpotL.of(context).noGroups)),
            const Padding(padding: const EdgeInsets.all(10.0)),
            new RaisedButton(
              child: new Text(SpotL.of(context).addGroup),
              onPressed: () async {
                await Navigator.of(Services.context).pushNamed('/groups/add/');
              },
            ),
          ],
        )
      : new ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          itemCount: (_groups?.length ?? 0) + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              if (_groupsInv != null && _groupsInv.isNotEmpty) {
                return _buildInv();
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
                        leading:
                            new CircleAvatar(backgroundColor: Colors.grey, child: new Text(_groups[index - 1].name[0])),
                        title: new Text(_groups[index - 1].name),
                        subtitle: new Text(_groups[index - 1].about),
                        trailing: new Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Text(
                              (_groups[index - 1].users?.length ?? '?').toString(),
                              style: new TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
                            ),
                            const Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0)),
                            const Icon(Icons.people)
                          ],
                        ))
                  ],
                ),
              ),
            );
          });

  Widget _buildInv() {
    if (_groupsInv.isEmpty) {
      return new Container();
    }
    return new Container(
      child: new ExpansionTile(
        leading: const Icon(Icons.mail),
        title: new Text(SpotL.of(context).nbInv('${_groupsInv?.length.toString()}')),
        children: new List<Widget>.generate(
            _groupsInv?.length ?? 0,
            (index) => new GestureDetector(
                onTap: () {
                  showDialog<Null>(
                    context: context,
                    barrierDismissible: false,
                    child: new AlertDialog(
                      title: new Text(SpotL.of(context).confirm),
                      content: new SingleChildScrollView(
                        child: new ListBody(
                          children: <Widget>[
                            new Text(SpotL.of(context).joinGroup('${_groupsInv[index].name}')),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text(MaterialLocalizations.of(context).cancelButtonLabel),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: new Text(MaterialLocalizations.of(context).continueButtonLabel),
                          onPressed: () async {
                            await _joinGroup(index);
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
                          leading: new CircleAvatar(child: new Text(_groupsInv[index].name[0])),
                          title: new Text(_groupsInv[index]?.name),
                          subtitle: new Text(_groupsInv[index]?.about),
                          trailing: new Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                _groupsInv[index]
                                    .users
                                    .where((user) => user.groups.contains(_groupsInv[index].id))
                                    .length
                                    .toString(),
                                style: new TextStyle(fontWeight: FontWeight.w400, fontSize: 15.0),
                              ),
                              const Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0)),
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
  Widget build(BuildContext context) => new RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _loadGroups,
      child: _groups == null ? const Center(child: const CircularProgressIndicator()) : _createList());
}
