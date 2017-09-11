import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Error screen class
class ErrorScreen extends StatelessWidget {
  /// Error screen initializer
  const ErrorScreen();

  @override
  Widget build(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.clear();
    });
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Error :('),
        centerTitle: true,
      ),
      body: new Builder(
          builder: (context) => new SingleChildScrollView(
              child: new Container(
                  margin: const EdgeInsets.all(20.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                          'Error while loading Spotitem, to try fix this problem we disconnect you from our server, so close app and relaunch it :)'),
                    ],
                  )))),
    );
  }
}
