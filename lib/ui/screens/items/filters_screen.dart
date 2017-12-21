import 'dart:async';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/models/item.dart';
import 'package:flutter/material.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';
import 'package:spotitem/ui/widgets/calendar.dart';

/// Edit item screen
class FiltersScreen extends StatefulWidget {
  /// Edit item screen initializer
  const FiltersScreen({Key key}) : super(key: key);

  @override
  _FiltersScreenState createState() => new _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen> {
  _FiltersScreenState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).filters)),
        body: new Builder(
          builder: (context) {
            Services.context = context;
            return new Container();
          },
        ),
      );
}
