import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/conversation.dart';
import 'package:spotitem/ui/spot_strings.dart';
import 'package:spotitem/utils.dart';

/// Social view class
class SocialView extends StatefulWidget {
  /// Social view initializer
  const SocialView();

  @override
  State<StatefulWidget> createState() => new _SocialViewState();
}

class _SocialViewState extends State<SocialView> {
  _SocialViewState();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  static List<Conversation> _conversations;

  @override
  void initState() {
    _conversations = Services.social.conversations;
    if (_conversations.isEmpty) {
      _conversations = null;
    }
    _checkConversation();
    super.initState();
  }

  Future<Null> _checkConversation() async {
    if (_conversations != null) {
      await _refreshIndicatorKey.currentState?.show();
    } else {
      await _loadConversation();
    }
  }

  Future<Null> _loadConversation() async {
    final res = await Services.social.getConversations();
    if (!mounted) {
      return;
    }
    setState(() {
      _conversations = res;
    });
  }

  Widget _createList() => new ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      itemCount: _conversations?.length ?? 0,
      itemBuilder: (context, index) => new GestureDetector(
            onTap: () {
              //showItemPage(_myItems[index], 'items', context);
            },
            child: new Card(
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new ListTile(
                    leading: const Icon(Icons.people),
                    title: new Text(
                      _conversations[index].group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: new Text(
                      _conversations[index].conversation.isNotEmpty
                          ? _conversations[index].conversation[0].message
                          : SpotL.of(context).noMessage(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
            ),
          ));

  @override
  Widget build(BuildContext context) => new RefreshIndicator(
      key: _refreshIndicatorKey,
      onRefresh: _loadConversation,
      child: _conversations == null
          ? const Center(child: const CircularProgressIndicator())
          : _createList());
}
