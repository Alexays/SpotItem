import 'dart:async';
import 'dart:convert';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/conversation.dart';
import 'package:spotitem/utils.dart';
import 'package:flutter/material.dart';

import 'package:spotitem/ui/spot_strings.dart';

/// Chat message class
//TO-DO REMOVE THIS
@override
class ChatMessage extends StatelessWidget {
  /// Chat message initializer
  const ChatMessage({this.text, this.animation});

  /// Text message
  final Message text;

  /// Animation controller
  final AnimationController animation;

  @override
  Widget build(BuildContext context) => new SizeTransition(
        sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
        axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: getAvatar(text.sender),
              ),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(text.sender.firstname ?? '', style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: text.message != text.message
                        ? new Image.network(
                            text.message,
                            width: 250.0,
                          )
                        : new Text(text.message),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

/// Add Group screen class
class ConvScreen extends StatefulWidget {
  /// Add Group screen initalizer
  const ConvScreen(this._conv);

  final Conversation _conv;

  @override
  _ConvScreenState createState() => new _ConvScreenState(_conv);
}

class _ConvScreenState extends State<ConvScreen> with TickerProviderStateMixin {
  _ConvScreenState(this.conv);
  final Conversation conv;
  List<ChatMessage> _messages = [];
  String group;

  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    _loadConv();
    super.initState();
  }

  void newMessage(String res) {
    if (!mounted) {
      return;
    }
    final decoded = JSON.decode(res);
    if (decoded['type'] == 'MESSAGE') {
      final data = decoded['data'];
      if (data['room'] == conv.id) {
        final message = new ChatMessage(
          text: new Message({'sender': data['sender'], 'message': data['message']}),
          animation: new AnimationController(
            duration: new Duration(milliseconds: 700),
            vsync: this,
          ),
        );
        setState(() {
          _messages.insert(0, message);
        });
        message.animation.forward();
      }
    }
  }

  Future<Null> _loadConv() async {
    final res = await Services.social.getConversation(conv.id);
    if (res == null || !mounted) {
      return;
    }
    setState(() {
      _messages = res.conversation.map((f) {
        final chat = new ChatMessage(
            text: f,
            animation: new AnimationController(
              duration: new Duration(milliseconds: 500),
              vsync: this,
            ));
        chat.animation.forward();
        return chat;
      }).toList();
      Services.auth.ws.sink.add(JSON.encode({'type': 'CONVERSATION_CONNECT', 'room': conv.id}));
      Services.auth.addCallback('MESSAGE', newMessage);
    });
  }

  @override
  void dispose() {
    for (var message in _messages) {
      message.animation.dispose();
    }
    Services.auth.ws.sink.add(JSON.encode({'type': 'CONVERSATION_DISCONNECT', 'room': conv.id}));
    Services.auth.delCallback('MESSAGE');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(conv.group?.name ?? conv.users.join(', '))),
        body: new Builder(
            builder: (context) => new Column(children: <Widget>[
                  new Flexible(
                      child: new ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, index) => _messages[index],
                    itemCount: _messages.length,
                  )),
                  const Divider(height: 1.0),
                  new Container(
                    decoration: new BoxDecoration(color: Theme.of(context).cardColor),
                    child: _buildTextComposer(),
                  ),
                ])),
      );

  Widget _buildTextComposer() => new IconTheme(
        data: new IconThemeData(color: Theme.of(context).accentColor),
        child: new Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
            child: new Row(children: <Widget>[
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.isNotEmpty;
                    });
                  },
                  onSubmitted: _handleSubmitted,
                  decoration: new InputDecoration.collapsed(hintText: SpotL.of(context).send()),
                ),
              ),
              new Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: _isComposing ? () => _handleSubmitted(_textController.text) : null,
                  )),
            ]),
            decoration: Theme.of(context).platform == TargetPlatform.iOS
                ? new BoxDecoration(border: new Border(top: new BorderSide(color: Colors.grey[200])))
                : null),
      );

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    final message = new ChatMessage(
      text: new Message({'sender': Services.users.toString(), 'message': text}),
      animation: new AnimationController(
        duration: new Duration(milliseconds: 700),
        vsync: this,
      ),
    );
    Services.auth.ws.sink.add(JSON.encode({
      'type': 'CONVERSATION_MESSAGE',
      'data': {'room': conv.id, 'sender': Services.users.toString(), 'message': text}
    }));
    setState(() {
      _messages.insert(0, message);
    });
    message.animation.forward();
  }
}
