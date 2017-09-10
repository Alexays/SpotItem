import 'dart:async';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen();

  @override
  State createState() => new _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  Map<String, dynamic> _contact;

  @override
  void initState() {
    _contact = Services.users.contact;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(title: const Text('Add Contacts')),
      body: new Builder(
          builder: (context) => new ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: _contact?.length ?? 0,
              itemExtent: 250.0,
              itemBuilder: (context, index) => new CheckboxListTile(
                    title: new Text(_contact[index].name),
                    value: _contact[index] == true,
                    onChanged: (value) {},
                    secondary: const Icon(Icons.people),
                  ))));
}
