// // // Enable Audio feature
// import 'dart:convert';
//
// import 'package:audio_manager/audio_manager.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../../models/audio/media_item.dart';
// import '../../../models/audio/player_controller_state.dart';
// import '../../../models/audio/playlist_audio.dart';
// import '../../../services/audio/audio_service.dart';
//
// const String storageKey = 'autoPlayAudio';
// const String listAudioQueueKey = 'listAudioQueueKey';
//
// class AudioServiceImpl extends AudioService {
//   late SharedPreferences _storage;
//   late ValueNotifier<PlaylistAudio> _data;
//   final _position = ValueNotifier(Duration.zero);
//   final _controllerState = ValueNotifier(PlayerControllerState());
//   final _isStickyAudioWidgetActive = ValueNotifier(false);
//   bool? _autoPlay;
//
//   AudioManager get _audioManager => AudioManager.instance;
//   @override
//   bool? get autoPlay => _autoPlay;
//   @override
//   PlayerControllerState get state => _controllerState.value;
//   @override
//   ValueNotifier<PlaylistAudio> get data => _data;
//   @override
//   ValueNotifier<PlayerControllerState> get controllerState => _controllerState;
//   @override
//   ValueNotifier<bool> get stateStickyAudioWidget => _isStickyAudioWidgetActive;
//   @override
//   List<MediaItem> get listData => _data.value.playlist ?? [];
//   @override
//   ValueNotifier<Duration> get position => _position;
//   @override
//   bool get isStickyAudioWidgetActive => _isStickyAudioWidgetActive.value;
//
//   AudioServiceImpl({required SharedPreferences sharedPreferences}) {
//     _storage = sharedPreferences;
//     timeCreate = '${DateTime.now()}';
//     registerOnEvent();
//     _autoPlay = sharedPreferences.getBool(storageKey);
//     _loadDataPlaylistFromStorage();
//   }
//
//   void _loadDataPlaylistFromStorage() {
//     final dataPlaylist = _storage.getString(listAudioQueueKey);
//     var playlist = PlaylistAudio(
//       name: 'Queue Audio',
//       createdAt: '${DateTime.now()}',
//       playlist: <MediaItem>[],
//     );
//
//     try {
//       if (dataPlaylist?.isNotEmpty ?? false) {
//         playlist = PlaylistAudio.fromJson(jsonDecode(dataPlaylist!));
//       }
//     } catch (e) {
//       debugPrint('--->Error load playlist: $e');
//     }
//
//     _data = ValueNotifier(playlist);
//   }
//
//   @override
//   void updateListAudio([List<MediaItem>? listMedia]) {
//     data.value = _data.value.copyWith(playlist: listMedia ?? <MediaItem>[]);
//     savePlaylist();
//   }
//
//   @override
//   void updatePlayListState() {
//     data.value = _data.value.copyWith();
//     savePlaylist();
//   }
//
//   @override
//   void registerOnEvent() {
//     _audioManager.onEvents((events, args) {
//       debugPrint('---> Event: $events $args');
//       switch (events) {
//         case AudioManagerEvents.start:
//           updatePlayerControllerState(state: PlayerState.loading);
//           return;
//         case AudioManagerEvents.ready:
//           updatePlayerControllerState(state: PlayerState.playing);
//           break;
//         case AudioManagerEvents.seekComplete:
//           updateTime();
//           break;
//         case AudioManagerEvents.buffering:
//           break;
//         case AudioManagerEvents.next:
//           next();
//           break;
//         case AudioManagerEvents.previous:
//           prev();
//           break;
//         case AudioManagerEvents.playstatus:
//           if (args is bool) {
//             updatePlayStatus(args);
//           }
//           break;
//         case AudioManagerEvents.timeupdate:
//           updateTime();
//           break;
//         case AudioManagerEvents.error:
//         case AudioManagerEvents.stop:
//           updatePlayerControllerState(state: PlayerState.stop);
//           break;
//         case AudioManagerEvents.ended:
//           updatePlayerControllerState(state: PlayerState.stop);
//           if (_controllerState.value.isRepeat) {
//             replay();
//           } else if (_controllerState.value.autoNextEnabled) {
//             next();
//           } else {
//             resetPlayerControllerState();
//           }
//           break;
//         case AudioManagerEvents.volumeChange:
//           break;
//         default:
//           break;
//       }
//     });
//   }
//
//   @override
//   void playMediaItem(MediaItem mediaItem, [bool isStart = false]) {
//     final compareItemNewAndCurrent = _controllerState.value.current != null &&
//         compareMediaItem(mediaItem, _controllerState.value.current!);
//
//     if (compareItemNewAndCurrent && !isStart) {
//       if (!_controllerState.value.isPlaying) {
//         //replay ended/paused
//         playOrPause();
//       }
//     } else {
//       //play new
//       _audioManager.start(
//         mediaItem.urlSource,
//         mediaItem.title,
//         desc: '',
//         cover: mediaItem.artUri ?? 'assets/images/app_icon.png',
//         auto: true,
//       );
//
//       if (state.index >= 0 && ((data.value.playlist?.length ?? 0) > 1)) {
//         data.value.playlist?.removeAt(state.index);
//       }
//       var indexMedia = listData
//           .indexWhere((element) => compareMediaItem(element, mediaItem));
//       if (indexMedia == -1) {
//         insertMediaItem(mediaItem);
//         indexMedia = 0;
//       }
//
//       updatePlayListState();
//       updatePlayerControllerState(
//         index: indexMedia,
//         current: mediaItem,
//       );
//     }
//   }
//
//   @override
//   void playOrPause() async {
//     if (_audioManager.isPlaying) {
//       await _audioManager.toPause();
//     } else {
//       if (_audioManager.position == Duration.zero &&
//           state.state == PlayerState.stop &&
//           state.current != null) {
//         playMediaItem(state.current!, true);
//       } else {
//         await _audioManager.toPlay();
//       }
//     }
//     updatePlayerControllerState(isPlaying: _audioManager.isPlaying);
//   }
//
//   @override
//   void next() {
//     var found = false;
//     for (final item in listData) {
//       if (found) {
//         playMediaItem(item);
//         return;
//       }
//       if (item.urlSource == _controllerState.value.current?.urlSource) {
//         found = true;
//       }
//     }
//     if (_controllerState.value.isRepeatList) {
//       playMediaItem(listData.first);
//     } else {
//       updatePlayerControllerState(isPlaying: false);
//     }
//   }
//
//   @override
//   void prev() {
//     final count = listData.length;
//     for (var i = 0; i < count; i++) {
//       if (listData[i].urlSource == _controllerState.value.current?.urlSource) {
//         if (i == 0) {
//           playMediaItem(listData.last);
//           return;
//         } else {
//           playMediaItem(listData[i - 1]);
//           return;
//         }
//       }
//     }
//   }
//
//   @override
//   void replay() {
//     _audioManager.seekTo(const Duration(seconds: 0));
//     _audioManager.playOrPause();
//     updatePlayerControllerState();
//   }
//
//   @override
//   void seek(Duration duration) {
//     _audioManager.seekTo(duration);
//     _controllerState.value.isSeeking = false;
//     updatePlayerControllerState();
//   }
//
//   @override
//   void setRepeat(bool isRepeat) {
//     _controllerState.value.isRepeat = isRepeat;
//     updatePlayerControllerState();
//   }
//
//   @override
//   void setAutoNext(bool autoNextEnabled) {
//     _controllerState.value.autoNextEnabled = autoNextEnabled;
//     updatePlayerControllerState();
//   }
//
//   @override
//   void updatePlayStatus(bool isPlaying) {
//     updatePlayerControllerState(isPlaying: isPlaying);
//     updatePlayListState();
//   }
//
//   @override
//   void updateTime() {
//     updatePlayerControllerState(
//       position: _audioManager.position.inMilliseconds,
//       duration: _audioManager.duration.inSeconds,
//       isPlaying: _audioManager.isPlaying,
//       state: PlayerState.playing,
//     );
//     updatePlayListState();
//   }
//
//   @override
//   void resetPlayerControllerState() {
//     _controllerState.value.position = 0;
//     _controllerState.value.duration = _audioManager.duration.inSeconds;
//     _controllerState.value.isPlaying = false;
//     updatePlayerControllerState();
//     updatePlayListState();
//   }
//
//   @override
//   void updatePlayerControllerState({
//     bool? isPlaying,
//     bool? isRepeat,
//     bool? isSeeking,
//     bool? autoNextEnabled,
//     int? duration,
//     int? index,
//     int? position,
//     MediaItem? current,
//     PlayerState? state,
//   }) {
//     _controllerState.value = _controllerState.value.copyWith(
//       isPlaying: isPlaying,
//       isRepeat: isRepeat,
//       isSeeking: isSeeking,
//       autoNextEnabled: autoNextEnabled,
//       duration: duration,
//       index: index,
//       position: position,
//       current: current,
//       state: state,
//     );
//   }
//
//   //utils
//   @override
//   bool isPlaying(MediaItem item) {
//     return isOnPlay(item) && _controllerState.value.isPlaying;
//   }
//
//   @override
//   bool isOnPlay(MediaItem item) {
//     return item.urlSource == _controllerState.value.current?.urlSource;
//   }
//
//   @override
//   void stop() {
//     _audioManager.stop();
//     _data.value.playlist?.clear();
//     _controllerState.value = PlayerControllerState();
//     updatePlayerControllerState();
//   }
//
//   @override
//   void pause() {
//     if (_controllerState.value.isPlaying) {
//       playOrPause();
//     }
//   }
//
//   @override
//   void dispose() {
//     stop();
//     _controllerState.dispose();
//     _data.dispose();
//   }
//
//   @override
//   void addList(List<MediaItem> listMedia) {
//     if (listMedia.isNotEmpty) {
//       data.value.playlist?.addAll(listMedia);
//       updatePlayListState();
//     }
//   }
//
//   @override
//   bool compareMediaItem(
//     MediaItem itemA,
//     MediaItem itemB,
//   ) {
//     return itemA.id == itemB.id &&
//         itemA.title == itemB.title &&
//         itemA.album == itemB.album &&
//         itemA.urlSource == itemB.urlSource;
//   }
//
//   Duration cachePosition = Duration.zero;
//   @override
//   void updateStateStickyAudioWidget(bool isActive) {
//     _isStickyAudioWidgetActive.value = isActive;
//   }
//
//   @override
//   void setAutoPlay(bool isAutoPlay) {
//     _autoPlay = isAutoPlay;
//     _storage.setBool(storageKey, isAutoPlay);
//   }
//
//   @override
//   void savePlaylist() {
//     _storage.setString(listAudioQueueKey, data.value.toString());
//   }
//
//   @override
//   void insertMediaItem(MediaItem mediaItem) {
//     data.value.playlist?.insert(0, mediaItem);
//     updatePlayListState();
//   }
//
//   @override
//   void addMediaItem(MediaItem mediaItem) {
//     data.value.playlist?.add(mediaItem);
//     updatePlayListState();
//   }
//
//   @override
//   void playList() {
//     if (listData.isNotEmpty) {
//       playMediaItem(listData.first);
//     }
//   }
//
//   @override
//   void removeMediaItem(MediaItem mediaItem) {
//     data.value.playlist
//         ?.removeWhere((element) => compareMediaItem(element, mediaItem));
//     updatePlayListState();
//   }
// }
