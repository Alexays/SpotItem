import 'package:spotitem/services/services.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Settings screen class
class SettingsScreen extends StatefulWidget {
  /// Settings screen initalizer
  const SettingsScreen();

  @override
  State createState() => new _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) => new Scaffold(
      appBar: new AppBar(title: new Text(SpotL.of(context).settings)),
      body: new Builder(
          builder: (context) => new ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20.0),
                children: [
                  new Text(
                      '${SpotL.of(context).maxDistance}: ${Services.settings.value.maxDistance}km'),
                  new Slider(
                    value: Services.settings.value.maxDistance / 100,
                    onChanged: (value) {
                      setState(() {
                        Services.settings.value.maxDistance =
                            (value * 100).toInt();
                        Services.settings.saveSettings();
                      });
                    },
                  )
                ],
              )));
}
