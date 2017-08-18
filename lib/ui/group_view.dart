import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotitems/model/group.dart';
import 'package:spotitems/interactor/manager/items_manager.dart';
import 'package:spotitems/interactor/manager/auth_manager.dart';

class GroupPage extends StatefulWidget {
  GroupPage({
    Key key,
    @required this.itemsManager,
    @required this.authManager,
    this.group,
  })
      : super(key: key);

  final AuthManager authManager;
  final ItemsManager itemsManager;
  final Group group;

  @override
  _GroupPageState createState() =>
      new _GroupPageState(authManager, itemsManager, group);
}

class _GroupPageState extends State<GroupPage>
    with SingleTickerProviderStateMixin {
  _GroupPageState(this.authManager, this.itemsManager, this.group);

  final AuthManager authManager;
  final ItemsManager itemsManager;

  Group group;

  bool dragStopped = true;

  @override
  void initState() {
    super.initState();
  }

  doButton() {
    List<Widget> top = [];
    if (authManager.loggedIn &&
        group != null &&
        group.owner == authManager.user.id) {
      top.add(new IconButton(
        icon: const Icon(Icons.delete),
        tooltip: 'Delete',
        onPressed: () {
          showDialog<Null>(
            context: context,
            barrierDismissible: false, // user must tap button!
            child: new AlertDialog(
              title: new Text('Delete confirmation'),
              content: new SingleChildScrollView(
                child: new ListBody(
                  children: <Widget>[
                    new Text('Are you sure to delete this group ?'),
                  ],
                ),
              ),
              actions: <Widget>[
                new FlatButton(
                  child: new Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text('Delete'),
                  onPressed: () {
                    authManager.delGroup(group.id);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
              ],
            ),
          );
        },
      ));
      top.add(new IconButton(
        icon: const Icon(Icons.create),
        tooltip: 'Edit',
        onPressed: () {
          //Navigator.of(context).pushNamed('/groups/${group.id}/edit');
        },
      ));
    }
    return top;
  }

  _buildUsers() {
    return new Flexible(
        child: new ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: new EdgeInsets.symmetric(vertical: 8.0),
            itemCount: group.users.length,
            itemBuilder: (BuildContext context, int index) {
              return new GestureDetector(
                  onTap: () {},
                  child: new Container(
                      padding: new EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new CircleAvatar(
                            radius: 30.0,
                            child: new Text(group.users[index].firstname[0] +
                                group.users[index].name[0]),
                          ),
                          new Padding(
                            padding: new EdgeInsets.symmetric(vertical: 4.0),
                          ),
                          new Text(group.users[index].firstname +
                              '.' +
                              group.users[index].name[0])
                        ],
                      )));
            }));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('Group: ' + group.name),
          actions: doButton(),
        ),
        body: new Container(
          margin: const EdgeInsets.all(20.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[new Text(group.about), _buildUsers()],
          ),
        ));
  }
}
