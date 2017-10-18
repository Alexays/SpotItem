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

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).messages)),
        body: new Builder(
            builder: (context) => Services.groups.groups.isNotEmpty
                ? new ListView.builder(
                    itemCount: Services.groups.groups?.length ?? 0,
                    itemBuilder: (context, index) => new ListTile(
                          title: new Text(Services.groups.groups[index].name),
                          onTap: () {
                            group = Services.groups.groups[index].id;
                            _addConv(context);
                          },
                        ),
                  )
                : new Center(
                    child: new Text(SpotL.of(context).noGroups),
                  )),
      );
}
