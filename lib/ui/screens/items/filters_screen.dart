import 'package:flutter/material.dart';
import 'package:spotitem/services/services.dart';
import 'package:spotitem/utils.dart';
import 'package:spotitem/i18n/spot_localization.dart';

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
            final spotL = SpotL.of(context);
            return new ListView(
              children: Services.items.filters.map((filter) {
                var widget;
                switch (filter['type']) {
                  case 'list':
                    widget = new Column(
                      children: filter['data']
                          .map((f) => new SwitchListTile(
                                title: new Text(spotL.custom('track$f')),
                                value: Services.items.tracks.value.contains(f),
                                onChanged: (value) {
                                  value
                                      ? Services.items.tracks.value.add(f)
                                      : Services.items.tracks.value.remove(f);
                                  setState(() {
                                    Services.items.tracks.value =
                                        new List<String>.from(
                                            Services.items.tracks.value);
                                  });
                                },
                                secondary: getIcon(f),
                              ))
                          .toList(),
                    );
                    break;
                  case 'select':
                    widget = new DropdownButton(
                      value: Services.items.tracks.value.firstWhere(
                              (f) => Services.items.sortMethod.contains(f),
                              orElse: () => 'none') ??
                          'none',
                      onChanged: (value) => setState(() {
                            if (value == 'none') {
                              Services.items.tracks.value = Services
                                  .items.tracks.value
                                  .where((f) => !Services.items.sortMethod
                                      .any((d) => d == f))
                                  .toList();
                              return;
                            }
                            Services.items.tracks.value = [
                              Services.items.tracks.value
                                  .where((f) => !Services.items.sortMethod
                                      .any((d) => d == f))
                                  .toList(),
                              [value]
                            ].expand((x) => x).toList();
                          }),
                      items: Services.items.sortMethod
                          .map((f) => new DropdownMenuItem<String>(
                                value: f,
                                child: new Text(spotL.custom(f)),
                              ))
                          .toList(),
                    );
                    break;
                  default:
                    assert(false);
                    widget = new Container();
                    break;
                }
                return new Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: new Flex(
                    direction: filter['dir'] ?? Axis.vertical,
                    crossAxisAlignment: filter['dir'] == Axis.horizontal
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        spotL.custom(filter['name']) ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 23.0,
                        ),
                      ),
                      const Padding(padding: const EdgeInsets.all(5.0)),
                      widget,
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      );
}
