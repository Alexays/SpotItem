import 'dart:async';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/models/conversation.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/ui/screens/social/conversation_screen.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Add Conv screen class
class AddConvScreen extends StatefulWidget {
  /// Add Conv screen initalizer
  const AddConvScreen();

  @override
  _AddConvScreenState createState() => new _AddConvScreenState();
}

class _AddConvScreenState extends State<AddConvScreen> {
  String group;
  String groupName;

  @override
  void initState() {
    super.initState();
  }

  Future<Null> _addConv(BuildContext context) async {
    if (group == null) {
      return showSnackBar(context, SpotL.of(context).selectGroup);
    }
    final response = await Services.social.addConversation({
      'group': group,
    });
    if (resValid(context, response)) {
      showSnackBar(context, response.msg);
      await Navigator.of(context).pushReplacement(new MaterialPageRoute<Null>(
            builder: (context) => new ConvScreen(new Conversation(response.data)),
          ));
    }
  }

  Future<Null> _selectGroup(BuildContext context) async {
    await showDialog<Null>(
      context: context,
      child: new SimpleDialog(
          children: Services.groups.groups
              .map((f) => new ListTile(
                    title: new Text(f.name),
                    onTap: () {
                      group = f.id;
                      setState(() {
                        groupName = f.name;
                      });
                      Navigator.of(context).pop();
                    },
                  ))
              .toList()),
    );
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).messages)),
        body: new Builder(
            builder: (context) => new Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
                  new Expanded(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Center(
                            child: new Text(
                          groupName ?? SpotL.of(context).noGroups,
                        )),
                        const Padding(padding: const EdgeInsets.all(10.0)),
                        new RaisedButton(
                          child: new Text(SpotL.of(context).selectGroup),
                          onPressed: () {
                            _selectGroup(context);
                          },
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: new ConstrainedBox(
                        constraints:
                            new BoxConstraints.tightFor(height: 48.0, width: MediaQuery.of(context).size.width),
                        child: new RaisedButton(
                          color: Theme.of(context).accentColor,
                          onPressed: () {
                            _addConv(context);
                          },
                          child: new Text(
                            MaterialLocalizations.of(context).continueButtonLabel.toUpperCase(),
                            style: new TextStyle(color: Theme.of(context).canvasColor),
                          ),
                        )),
                  ),
                ])),
      );
}
