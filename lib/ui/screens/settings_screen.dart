import 'dart:async';
import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/ui/spot_strings.dart';

/// Settings screen class
class SettingsScreen extends StatefulWidget {
  /// Settings screen initalizer
  const SettingsScreen();

  @override
  State createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    print(Services.settings.settings.maxDistance);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(title: new Text(SpotL.of(context).settings())),
      body: new Builder(
          builder: (context) => new ListView(
                padding: const EdgeInsets.all(20.0),
                children: [
                  new Text(
                      '${SpotL.of(context).maxDistance()}: ${Services.settings.settings.maxDistance}km'),
                  new Slider(
                    value: Services.settings.settings.maxDistance / 100,
                    onChanged: (value) {
                      setState(() {
                        Services.settings.settings.maxDistance =
                            (value * 100).toInt();
                      });
                    },
                  )
                ],
              )));
}
