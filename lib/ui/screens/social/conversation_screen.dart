import 'dart:async';

import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/conversation.dart';
import 'package:spotitem/utils.dart';
import 'package:flutter/material.dart';

import 'package:spotitem/ui/spot_strings.dart';

//TO-DO REMOVE THIS
@override
class ChatMessage extends StatelessWidget {
  ChatMessage({this.text, this.animation});
  final Message text;
  final AnimationController animation;

  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: new CircleAvatar(backgroundImage: new NetworkImage(text.sender.avatar)),
            ),
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text(text.sender.name, style: Theme.of(context).textTheme.subhead),
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
}

/// Add Group screen class
class ConvScreen extends StatefulWidget {
  /// Add Group screen initalizer
  const ConvScreen();

  @override
  _ConvScreenState createState() => new _ConvScreenState();
}

class _ConvScreenState extends State<ConvScreen> with TickerProviderStateMixin {
  Conversation conv;
  final List<ChatMessage> _messages = [];
  String group;

  final TextEditingController _textController = new TextEditingController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var message in _messages) {
      message.animation.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).addGroup())),
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

  Widget _buildTextComposer() {
    return new IconTheme(
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
                decoration: const InputDecoration.collapsed(hintText: 'Send a message'),
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
  }

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
    setState(() {
      _messages.insert(0, message);
    });
    message.animation.forward();
  }
}
