import 'package:flutter/material.dart';

import '../../models/audio/media_item.dart';
import '../../models/audio/player_controller_state.dart';
import '../../models/audio/playlist_audio.dart';

abstract class AudioService {
  ValueNotifier<PlaylistAudio> get data;
  ValueNotifier<PlayerControllerState> get controllerState;
  ValueNotifier<Duration> get position;
  ValueNotifier<bool> get stateStickyAudioWidget;
  List<MediaItem> get listData;
  PlayerControllerState get state;
  bool get isStickyAudioWidgetActive;
  bool? get autoPlay;
  String timeCreate = 'NULL';

  void dispose();
  void registerOnEvent();

  void savePlaylist();
  void updateListAudio([List<MediaItem>? listMedia]);
  void addList(List<MediaItem> listMedia);
  void insertMediaItem(MediaItem mediaItem);
  void addMediaItem(MediaItem mediaItem);
  void updatePlayListState();

  void stop();
  void next();
  void prev();
  void replay();
  void pause();
  void playList();
  void playOrPause();
  void seek(Duration duration);
  void setRepeat(bool isRepeat);
  void playMediaItem(MediaItem mediaItem, [bool isStart = false]);
  void removeMediaItem(MediaItem mediaItem);
  void setAutoNext(bool autoNextEnabled);
  void updatePlayStatus(bool isPlaying);
  void updateTime();
  void setAutoPlay(bool isAutoPlay);
  void resetPlayerControllerState();
  void updatePlayerControllerState();
  void updateStateStickyAudioWidget(bool isActive);
  bool isPlaying(MediaItem item);
  bool isOnPlay(MediaItem item);
  bool compareMediaItem(MediaItem itemA, MediaItem itemB);
}

class AudioServiceEmpty extends AudioService {
  AudioServiceEmpty();

  @override
  void addList(List<MediaItem> listMedia) {}

  @override
  void addMediaItem(MediaItem mediaItem) {}

  @override
  bool? get autoPlay => false;

  @override
  bool compareMediaItem(MediaItem itemA, MediaItem itemB) {
    return false;
  }

  @override
  ValueNotifier<PlayerControllerState> get controllerState =>
      ValueNotifier(PlayerControllerState());

  @override
  ValueNotifier<PlaylistAudio> get data =>
      ValueNotifier(PlaylistAudio(name: '', playlist: [], createdAt: ''));

  @override
  void dispose() {}

  @override
  void insertMediaItem(MediaItem mediaItem) {}

  @override
  bool isOnPlay(MediaItem item) => false;

  @override
  bool isPlaying(MediaItem item) => false;
  @override
  bool get isStickyAudioWidgetActive => false;

  @override
  List<MediaItem> get listData => [];

  @override
  void next() {}

  @override
  void pause() {}

  @override
  void playList() {}

  @override
  void playMediaItem(MediaItem mediaItem, [bool isStart = false]) {}

  @override
  void playOrPause() {}

  @override
  ValueNotifier<Duration> get position => ValueNotifier(Duration.zero);

  @override
  void prev() {}

  @override
  void registerOnEvent() {}

  @override
  void removeMediaItem(MediaItem mediaItem) {}

  @override
  void replay() {}

  @override
  void resetPlayerControllerState() {}

  @override
  void savePlaylist() {}

  @override
  void seek(Duration duration) {}

  @override
  void setAutoNext(bool autoNextEnabled) {}

  @override
  void setAutoPlay(bool isAutoPlay) {}

  @override
  void setRepeat(bool isRepeat) {}

  @override
  PlayerControllerState get state => PlayerControllerState();

  @override
  ValueNotifier<bool> get stateStickyAudioWidget => ValueNotifier(false);

  @override
  void stop() {}

  @override
  void updateListAudio([List<MediaItem>? listMedia]) {}

  @override
  void updatePlayListState() {}

  @override
  void updatePlayStatus(bool isPlaying) {}

  @override
  void updatePlayerControllerState() {}

  @override
  void updateStateStickyAudioWidget(bool isActive) {}

  @override
  void updateTime() {}
}
