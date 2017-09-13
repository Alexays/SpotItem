import 'dart:async';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/ui/spot_strings.dart';

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

  Future<Null> _handleEmail() async {
    final String res = validateEmail(_email);
    if (res != null) {
      showSnackBar(Services.context, res);
    } else {
      Navigator.pop(context, _email);
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(title: new Text(SpotL.of(context).addSomeone())),
      body: new Builder(builder: (context) {
        Services.context = context;
        return new Column(children: <Widget>[
          new Container(
              margin: const EdgeInsets.all(15.0),
              decoration: new BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius:
                      const BorderRadius.all(const Radius.circular(3.0))),
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
                    _handleEmail();
                  },
                ),
              )),
          const Divider(),
          _contact.isNotEmpty
              ? new Expanded(
                  child: new ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: _contact?.length ?? 0,
                      itemBuilder: (context, index) => new ListTile(
                            title: new Text(
                                _contact[index]['names'][0]['displayName']),
                            leading: const Icon(Icons.people),
                            onTap: () {
                              _email =
                                  _contact[index]['emailAddresses'][0]['value'];
                              _handleEmail();
                            },
                          )))
              : new Text(SpotL.of(context).noContacts()),
        ]);
      }));
}
