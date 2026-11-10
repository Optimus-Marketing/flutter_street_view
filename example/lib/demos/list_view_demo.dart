import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_street_view/flutter_google_street_view.dart';

import '../places.dart';

class ListViewDemo extends StatelessWidget {
  const ListViewDemo({super.key});

  static const _streetViewIndex = 2;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Inside a ListView')),
    body: ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => index == _streetViewIndex
          ? SizedBox(
              height: 300,
              child: FlutterGoogleStreetView(
                initPos: sydney,
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    EagerGestureRecognizer.new,
                  ),
                },
              ),
            )
          : Container(
              height: 150,
              color: Colors.primaries[index % Colors.primaries.length],
            ),
    ),
  );
}
