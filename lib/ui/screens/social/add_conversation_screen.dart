import 'dart:async';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/models/conversation.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/ui/screens/social/conversation_screen.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Add conversation screen class
class AddConvScreen extends StatelessWidget {
  /// Add conversation screen constructor
  const AddConvScreen();
  Future<Null> _addConv(BuildContext context, String group) async {
    if (group == null) {
      showSnackBar(context, SpotL.of(context).selectGroup);
      return;
    }
    final response = await Services.social.add({'group': group});
    if (!resValid(context, response)) {
      return;
    }
    showSnackBar(context, response.msg);
    await Navigator.of(context).pushReplacement(
          new MaterialPageRoute<Null>(
            builder: (context) => new ConvScreen(
                  new Conversation(response.data),
                ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).messages)),
        body: new Builder(
          builder: (context) {
            Services.context = context;
            return Services.groups.data.isNotEmpty
                ? new ListView.builder(
                    itemCount: Services.groups.data?.length ?? 0,
                    itemBuilder: (context, index) => new ListTile(
                          title: new Text(Services.groups.data[index].name),
                          onTap: () =>
                              _addConv(context, Services.groups.data[index].id),
                        ),
                  )
                : new Center(child: new Text(SpotL.of(context).noGroups));
          },
        ),
      );
}
