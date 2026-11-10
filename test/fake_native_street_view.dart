import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeNativeStreetView {
  FakeNativeStreetView(this._tester);

  static const _codec = StandardMethodCodec();

  final WidgetTester _tester;
  final List<MethodCall> calls = [];
  Map<Object?, Object?>? creationParams;
  int? viewId;
  Completer<Map<String, Object?>?> readyState = Completer()
    ..complete(readyStateWith());
  Map<String, Object?>? location;

  TestDefaultBinaryMessenger get _messenger =>
      _tester.binding.defaultBinaryMessenger;

  String get _channelName => 'flutter_google_street_view_$viewId';

  static Map<String, Object?> readyStateWith({
    bool zoomGesturesEnabled = true,
    int streetViewCount = 1,
  }) => {
    'panningGesturesEnabled': true,
    'streetNamesEnabled': true,
    'userNavigationEnabled': true,
    'zoomGesturesEnabled': zoomGesturesEnabled,
    'streetViewCount': streetViewCount,
  };

  void install() {
    _messenger.setMockMethodCallHandler(
      SystemChannels.platform_views,
      _handlePlatformViewsCall,
    );
    _tester.view.physicalSize = const Size(400, 800);
    addTearDown(() {
      _messenger.setMockMethodCallHandler(SystemChannels.platform_views, null);
      if (viewId != null) {
        _messenger.setMockMethodCallHandler(MethodChannel(_channelName), null);
      }
      _tester.view.resetPhysicalSize();
    });
  }

  Iterable<MethodCall> callsTo(String method) =>
      calls.where((call) => call.method == method);

  Future<void> sendEvent(String method, Map<String, Object?> arguments) =>
      _messenger.handlePlatformMessage(
        _channelName,
        _codec.encodeMethodCall(MethodCall(method, arguments)),
        (_) {},
      );

  Future<Object?> _handlePlatformViewsCall(MethodCall call) async {
    final arguments = call.arguments;
    return switch (call.method) {
      'create' => _createPlatformView(arguments! as Map<Object?, Object?>),
      'resize' => arguments,
      _ => null,
    };
  }

  int _createPlatformView(Map<Object?, Object?> arguments) {
    viewId = arguments['id']! as int;
    final params = arguments['params']! as Uint8List;
    creationParams =
        const StandardMessageCodec().decodeMessage(ByteData.sublistView(params))
            as Map<Object?, Object?>?;
    _messenger.setMockMethodCallHandler(
      MethodChannel(_channelName),
      _handleStreetViewCall,
    );
    return 1;
  }

  Future<Object?> _handleStreetViewCall(MethodCall call) async {
    calls.add(call);
    return switch (call.method) {
      'streetView#waitForStreetView' => readyState.future,
      'streetView#getLocation' => location,
      'streetView#getPanoramaCamera' => {'bearing': 10.0, 'tilt': 5.0},
      'streetView#orientationToPoint' => {'x': 12, 'y': 34},
      'streetView#pointToOrientation' => {'bearing': 90.0, 'tilt': -10.0},
      _ => null,
    };
  }
}
