import 'package:flutter/services.dart';

class FlutterToAirplay {
  static const String name = 'flutter_to_airplay';

  static final FlutterToAirplay instance = FlutterToAirplay._internal();
  FlutterToAirplay._internal();

  final MethodChannel _platform = MethodChannel('com.junaidrehmat.flutterToAirplay.airplay_channel');
  final EventChannel _eventChannel = EventChannel('airplay_status_channel');

  Stream<AirPlay?> airplay() {
    return _eventChannel.receiveBroadcastStream().map((argument) => AirPlay.fromMap(
        argument == null ? null : Map<String, dynamic>.from(argument)));
  }

  void triggerAirPlay() {
    _platform.invokeMethod("trigger_airplay");
  }
}

class AirPlay {
  final String? uid;
  final String? name;

  AirPlay(this.uid, this.name);

  static AirPlay? fromMap(Map<String, dynamic>? json) {
    if(json != null) {
      final uid = json['uid'];
      final portName = json['portName'];
      return AirPlay(uid, portName);
    }else {
      return null;
    }
  }
}
