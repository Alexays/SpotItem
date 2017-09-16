import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/ui/screens/group_screen.dart';
import 'package:spotitem/models/group.dart';
import 'package:spotitem/ui/spot_strings.dart';

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

  static List<Group> _groups;
  static List<Group> _groupsInv;

  @override
  void initState() {
    _getGroups();
    super.initState();
  }

  Future<Null> _getGroups() async {
    setState(() {
      _groups = Services.groups.groups;
      _groupsInv = Services.groups.groupsInv;
      if (_groups.isEmpty) {
        _groups = null;
      }
    });
    if (_groups != null) {
      _refreshIndicatorKey.currentState?.show();
    } else {
      _loadGroups();
    }
  }

  //TO-DO MAYBE don't await it's better :)
  Future<Null> _loadGroups() async {
    final List<Group> resGroup = await Services.groups.getGroups();
    final List<Group> resInv = await Services.groups.getGroupsInv();
    setState(() {
      _groups = resGroup;
      _groupsInv = resInv;
    });
  }

  Future<Null> _joinGroup(int index) async {
    final dynamic response =
        await Services.groups.joinGroup(_groupsInv[index].id);
    if (response['success']) {
      _loadGroups();
    }
  }

  Future<Null> _showGroup(int index) async {
    await Navigator.push(
        context,
        new MaterialPageRoute<Null>(
          builder: (context) => new GroupPage(group: _groups[index - 1]),
        ));
  }

  Widget getList() => new ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: _groups.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          if (_groupsInv != null && _groupsInv.isNotEmpty) {
            return _buildInv();
          } else if (_groups.isEmpty) {
            return new Center(child: new Text(SpotL.of(context).noGroups()));
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
                        child: new Text(_groups[index - 1].name[0])),
                    title: new Text(_groups[index - 1].name),
                    subtitle: new Text(_groups[index - 1].about),
                    trailing: new Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text(
                          _groups[index - 1]
                              .users
                              .where((user) =>
                                  user.groups.contains(_groups[index - 1].id))
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
    if (_groupsInv.isEmpty) {
      return new Container();
    }
    return new Container(
      child: new ExpansionTile(
        leading: const Icon(Icons.mail),
        title:
            new Text('You have ${_groupsInv.length.toString()} invitation(s)'),
        children: new List<Widget>.generate(
            _groupsInv.length,
            (index) => new GestureDetector(
                onTap: () {
                  showDialog<Null>(
                    context: context,
                    barrierDismissible: false,
                    child: new AlertDialog(
                      title: new Text('Join ${_groupsInv[index].name} ?'),
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
                              child: new Text(_groupsInv[index].name[0])),
                          title: new Text(_groupsInv[index]?.name),
                          subtitle: new Text(_groupsInv[index]?.about),
                          trailing: new Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                _groupsInv[index]
                                    .users
                                    .where((user) => user.groups
                                        .contains(_groupsInv[index].id))
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
  Widget build(BuildContext context) => new RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: () => _loadGroups(),
      child: _groups == null
          ? const Center(child: const CircularProgressIndicator())
          : getList());
}
