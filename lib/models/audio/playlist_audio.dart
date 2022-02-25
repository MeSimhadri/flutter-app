import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:inspireui/utils.dart';

import 'media_item.dart';

class PlaylistAudio {
  late String name;
  late String createdAt;
  late List<MediaItem>? playlist;

  PlaylistAudio({
    required this.name,
    required this.createdAt,
    this.playlist,
  });

  PlaylistAudio copyWith({
    String? name,
    String? createdAt,
    List<MediaItem>? playlist,
  }) {
    return PlaylistAudio(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      playlist:
          List<MediaItem>.from(playlist ?? this.playlist ?? <MediaItem>[]),
    );
  }

  PlaylistAudio.fromJson(Map<String, dynamic> parsedJson) {
    try {
      name = parsedJson['name'];
      createdAt = parsedJson['createdAt'];
      playlist = <MediaItem>[];
      if (parsedJson['playlist'] is List) {
        for (var item in parsedJson['playlist']) {
          if ((item['urlSource']?.isNotEmpty ?? false) &&
              (item['title']?.isNotEmpty ?? false) &&
              (item['image']?.isNotEmpty ?? false)) {
            playlist?.add(MediaItem(
              id: item['id'] ?? '${UniqueKey()}',
              urlSource: item['urlSource'],
              album: item['album'],
              title: item['title'],
              artUri: item['image'],
            ));
          }
        }
      }
    } catch (e, trace) {
      printLog(trace);
      printLog('AudioItem $name error: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    final playlistJson = playlist?.map((e) => e.toJson()).toList() ?? [];
    return {
      'name': name,
      'createdAt': createdAt,
      'playlist': playlistJson,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}
