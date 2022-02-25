import 'dart:convert';

import 'package:inspireui/inspireui.dart';

class MediaItem {
  late String id;
  late String title;
  late String urlSource;

  late Duration? duration;
  late String? artUri;
  late String? album;

  MediaItem({
    required this.id,
    required this.title,
    required this.urlSource,
    this.album,
    this.duration,
    this.artUri,
  });

  MediaItem copyWith({
    String? id,
    String? title,
    String? urlSource,
    String? album,
    String? artUri,
    Duration? duration,
  }) {
    return MediaItem(
      id: id ?? this.id,
      title: title ?? this.title,
      urlSource: urlSource ?? this.urlSource,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      artUri: artUri ?? this.artUri,
    );
  }

  MediaItem.fromJson(Map<String, dynamic> parsedJson) {
    try {
      id = parsedJson['id'];
      title = parsedJson['title'];
      urlSource = parsedJson['urlSource'];
      album = parsedJson['album'];
      artUri = parsedJson['artUri'];
      duration = parsedJson['duration'] != null
          ? _parseDuration(parsedJson['duration'])
          : const Duration(seconds: 0);
    } catch (e, trace) {
      printLog(trace);
      printLog('MediaItem $title error: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'urlSource': urlSource,
      'album': album,
      'artUri': artUri,
      'duration': duration.toString(),
    };
  }

  Duration _parseDuration(String s) {
    var hours = 0;
    var minutes = 0;
    int micros;
    var parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  @override
  String toString() => jsonEncode(toJson());
}
