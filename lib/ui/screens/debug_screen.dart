import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';

/// Debug screen class
class DebugScreen extends StatelessWidget {
  /// Debig screen initializer
  const DebugScreen();

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: const Text('Debug')),
        body: new Builder(
            builder: (context) => new SingleChildScrollView(
                child: new Container(
                    margin: const EdgeInsets.all(20.0),
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text('Logged => ${Services.auth.loggedIn}'),
                        new Text('Provider => ${Services.auth.provider}'),
                        new Text(
                            'Token expiration (ACCESS) => ${Services.auth.exp}'),
                        new Text('USER_ID => ${Services.auth.user.id}'),
                        const Divider(),
                        new Text('API_TOKEN => ${Services.auth.refreshToken}'),
                        const Divider(),
                        new Text(
                            'ACCESS_TOKEN => ${Services.auth.accessToken}'),
                        const Divider(),
                        new Text(
                            'Nb Items loaded => ${Services.items.items.length}'),
                        new Text(
                            'Nb User Items loaded => ${Services.items.myItems.length}'),
                      ],
                    )))),
      );
}
