import 'package:flutter/services.dart';

class FlutterToAirplay {
  static const String name = 'flutter_to_airplay';

  static Map<String, dynamic> colorToParams(Color color) {
    return {
      'red': color.red,
      'green': color.green,
      'blue': color.blue,
      'alpha': color.alpha,
    };
  }

  static const MethodChannel _platform = MethodChannel('com.junaidrehmat.flutterToAirplay.airplay_channel');
  static const EventChannel _eventChannel = EventChannel('airplay_status_channel');

  static Stream<bool> airplayStatus() {
    return _eventChannel.receiveBroadcastStream().map((e) => e as bool);
  }

  static void triggerAirPlay() {
    _platform.invokeMethod("trigger_airplay");
  }
}
