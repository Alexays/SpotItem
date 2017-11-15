import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/conversation.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/ui/screens/social/conversation_screen.dart';

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
    super.initState();
    _conversations = Services.social.conversations;
    if (_conversations.isEmpty) {
      _conversations = null;
    }
    _checkConversation();
  }

  Future<Null> _checkConversation() async {
    if (_conversations != null) {
      return await _refreshIndicatorKey.currentState?.show();
    }
    await _loadConversation();
  }

  Future<Null> _loadConversation() async {
    final res = await Services.social.getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _conversations = res;
    });
  }

  Widget _createList() => new ListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      itemCount: _conversations?.length ?? 0,
      itemBuilder: (context, index) => new GestureDetector(
            onTap: () => Navigator.push(
                context,
                new MaterialPageRoute<Null>(
                  builder: (context) => new ConvScreen(_conversations[index]),
                )),
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
                          ? '${_conversations[index].conversation[0].sender.firstname}: ${_conversations[index].conversation[0].message}'
                          : SpotL.of(context).noMessages,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontStyle: FontStyle.italic),
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
          : _conversations.isNotEmpty
              ? _createList()
              : new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Center(child: new Text(SpotL.of(context).noMessages)),
                    const Padding(padding: const EdgeInsets.all(10.0)),
                    new RaisedButton(
                      child: new Text(SpotL.of(context).createConv),
                      onPressed: () async {
                        await Navigator
                            .of(Services.context)
                            .pushNamed('/messages/add/');
                      },
                    ),
                  ],
                ));
}
