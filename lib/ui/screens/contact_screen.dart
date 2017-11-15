import 'dart:async';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Contact screen class
class ContactScreen extends StatefulWidget {
  /// Contact screen initalizer
  const ContactScreen();

  @override
  State createState() => new _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<dynamic> _contacts = [];
  String _email;

  @override
  void initState() {
    super.initState();
    Services.users.getContact().then((data) {
      if (!mounted) {
        return;
      }
      setState(() {
        _contacts = data ?? [];
      });
    });
  }

  Future<Null> _handleEmail(BuildContext context) async {
    final res = validateEmail(_email);
    if (res != null) {
      showSnackBar(context, res);
    } else {
      Navigator.pop(context, _email);
    }
  }

  Future<Null> _getMail(int index) async {
    final res = await showDialog<Null>(
      context: context,
      child: new SimpleDialog(
          title: new Text(SpotL.of(Services.loc).confirm),
          children: new List<Widget>.generate(
              _contacts[index]['emailAddresses'].length,
              (i) => new ListTile(
                    title: new Text(_contacts[index]['emailAddresses'][i]['value']),
                    onTap: () {
                      _email = _contacts[index]['emailAddresses'][i]['value'];
                      _handleEmail(context);
                    },
                  ))),
    );
    if (res != null) {
      Navigator.pop(context, _email);
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(title: new Text(SpotL.of(context).addSomeone)),
      body: new Builder(
          builder: (context) => new Column(children: <Widget>[
                new Container(
                    margin: const EdgeInsets.all(15.0),
                    decoration: new BoxDecoration(
                        color: Theme.of(context).accentColor,
                        borderRadius: const BorderRadius.all(const Radius.circular(3.0))),
                    child: new Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: new TextField(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: new InputDecoration(
                          hideDivider: true,
                          hintText: SpotL.of(context).searchContact,
                          errorText: _contacts == null || _contacts.isEmpty ? validateEmail(_email) : null,
                          hintStyle: const TextStyle(
                            color: const Color.fromARGB(150, 255, 255, 255),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _email = value;
                          });
                          Services.users.getContact().then((data) {
                            if (!mounted || data == null) {
                              return;
                            }
                            setState(() {
                              _contacts = data
                                  .where((contact) =>
                                      contact['names'][0]['displayName'].toString().contains(value) ||
                                      contact['emailAddresses'][0]['value'].toString().contains(value))
                                  .toList();
                            });
                          });
                        },
                      ),
                    )),
                const Padding(padding: const EdgeInsets.all(10.0)),
                _contacts.isNotEmpty || (_email != null && _email.isNotEmpty)
                    ? _contacts.isNotEmpty
                        ? new Expanded(
                            child: new ListView.builder(
                                shrinkWrap: true,
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                itemCount: _contacts?.length ?? 0,
                                itemBuilder: (context, index) => new ListTile(
                                      title: new Text(_contacts[index]['names'][0]['displayName']),
                                      leading: const Icon(Icons.people),
                                      onTap: () {
                                        _getMail(index);
                                      },
                                    )))
                        : new RaisedButton(
                            child: new Text(SpotL.of(context).addSomeone),
                            onPressed: () {
                              _handleEmail(context);
                            },
                          )
                    : new Text(SpotL.of(context).noContacts),
              ])));
}
