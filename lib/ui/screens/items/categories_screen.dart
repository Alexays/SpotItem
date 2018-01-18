import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/i18n/spot_localization.dart';

/// Edit item screen
class CategoriesScreen extends StatefulWidget {
  /// Edit item screen initializer
  const CategoriesScreen({Key key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => new _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  _CategoriesScreenState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        appBar: new AppBar(title: new Text(SpotL.of(context).categories)),
        body: new Builder(
          builder: (context) {
            Services.context = context;
            return new GridView.count(
              padding: const EdgeInsets.all(15.0),
              crossAxisCount: 3,
              crossAxisSpacing: 10.0,
              children: Services.items.categories.map((f) {
                if (Services.items.tracks.value.contains(f)) {
                  return new RaisedButton(
                    child: new Image.asset('assets/$f.png'),
                    onPressed: () => setState(() =>
                        Services.items.tracks.value = Services
                            .items.tracks.value
                            .where((d) => d != f)
                            .toList()),
                  );
                }
                return new FlatButton(
                  child: new Image.asset('assets/$f.png'),
                  onPressed: () => setState(() =>
                      Services.items.tracks.value = Services.items.tracks.value
                          .where((f) =>
                              !Services.items.categories.any((d) => d == f))
                          .toList()
                            ..add(f)),
                );
              }).toList(),
            );
          },
        ),
      );
}
