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
  List<dynamic> _contact = [];
  String _email;

  @override
  void initState() {
    _contact = Services.users.contact ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Services.context = context;
    return new Scaffold(
        appBar: new AppBar(title: const Text('Add Contacts')),
        body: new Builder(
            builder: (context) => new Column(children: <Widget>[
                  new Container(
                      margin: const EdgeInsets.all(15.0),
                      decoration: new BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: const BorderRadius.all(
                              const Radius.circular(3.0))),
                      child: new Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: new TextField(
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Enter email of non listed user...',
                            hintStyle: const TextStyle(
                              color: const Color.fromARGB(150, 255, 255, 255),
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onSubmitted: (value) {
                            _email = value.trim();
                            final String res = validateEmail(_email);
                            if (res != null) {
                              showSnackBar(context, res);
                            } else {
                              Navigator.of(context).pop(_email);
                            }
                          },
                        ),
                      )),
                  const Divider(),
                  _contact.isNotEmpty
                      ? new Expanded(
                          child: new ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              itemCount: _contact?.length ?? 0,
                              itemBuilder: (context, index) => new ListTile(
                                    title: new Text(_contact[index]['names'][0]
                                        ['displayName']),
                                    leading: const Icon(Icons.people),
                                    onTap: () {
                                      _email = _contact[index]['emailAddresses']
                                          [0]['value'];
                                      Navigator.of(context).pop(_email);
                                    },
                                  )))
                      : const Text('No contacts'),
                ])));
  }
}
