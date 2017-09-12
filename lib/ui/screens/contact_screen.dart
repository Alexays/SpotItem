import 'dart:async';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';

/// Contact screen class
class ContactScreen extends StatefulWidget {
  /// Contact screen initalizer
  const ContactScreen();

  @override
  State createState() => new _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<dynamic> _contact;
  final GlobalKey<FormState> _formKeyEmail = new GlobalKey<FormState>();
  String _email;

  @override
  void initState() {
    _contact = Services.users.contact;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Services.context = context;
    return new Scaffold(
        appBar: new AppBar(title: const Text('Add Contacts')),
        body: new Builder(
            builder: (context) => new Column(children: <Widget>[
                  new Form(
                      key: _formKeyEmail,
                      autovalidate: true,
                      child: new ListBody(children: <Widget>[
                        const Text('Enter email of user.'),
                        new TextFormField(
                          key: const Key('email'),
                          decoration: const InputDecoration.collapsed(
                              hintText: 'ex: john.do@exemple.com'),
                          onSaved: (value) {
                            _email = value.trim();
                          },
                          validator: validateEmail,
                        )
                      ])),
                  new ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: _contact?.length ?? 0,
                      itemBuilder: (context, index) => new ListTile(
                            title: new Text(
                                _contact[index]['names'][0]['displayName']),
                            leading: const Icon(Icons.people),
                            onTap: () {
                              _email =
                                  _contact[index]['emailAddresses'][0]['value'];
                            },
                          ))
                ])));
  }
}
