import 'package:flutter/material.dart';

import 'demos/events_demo.dart';
import 'demos/init_demo.dart';
import 'demos/list_view_demo.dart';
import 'demos/navigation_demo.dart';
import 'demos/options_demo.dart';

void main() => runApp(const StreetViewExampleApp());

class StreetViewExampleApp extends StatelessWidget {
  const StreetViewExampleApp({super.key});

  @override
  Widget build(BuildContext context) =>
      const MaterialApp(debugShowCheckedModeBanner: false, home: _DemoList());
}

class _DemoList extends StatelessWidget {
  const _DemoList();

  static const _demos = [
    (
      title: 'Initial options',
      description: 'Initial position, camera, gestures and iOS markers.',
      page: InitDemo(),
    ),
    (
      title: 'Events',
      description:
          'Camera, panorama and tap events, including a location '
          'without panorama.',
      page: EventsDemo(),
    ),
    (
      title: 'Navigation',
      description: 'Move the camera and jump between panoramas.',
      page: NavigationDemo(),
    ),
    (
      title: 'Options',
      description: 'Turn gestures and street names on and off.',
      page: OptionsDemo(),
    ),
    (
      title: 'Inside a ListView',
      description: 'Let the street view claim the gestures of a scrollable.',
      page: ListViewDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Street View Example')),
    body: ListView.separated(
      itemCount: _demos.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final demo = _demos[index];
        return ListTile(
          title: Text(demo.title),
          subtitle: Text(demo.description),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => demo.page)),
        );
      },
    ),
  );
}
