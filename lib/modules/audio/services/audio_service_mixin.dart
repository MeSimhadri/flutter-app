import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/utils/logs.dart';

// import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/config.dart';
import '../../../models/audio/media_item.dart';
import '../../../models/entities/blog.dart';
import '../../../services/audio/audio_service.dart';
import '../../../services/index.dart';
import '../views/audio_playlist_screen.dart';
import '../views/widgets/audio_blog_card.dart';
import '../views/widgets/audio_dialog.dart';
import '../views/widgets/audio_sticky.dart';
// // Enable Audio feature
// import 'audio_service_impl.dart';

mixin AudioServiceMixin {
  AudioService get audioPlayerService => injector<AudioService>();

  // // Enable Audio feature
  // AudioService getAudioService() {
  //   if (!(kBlogDetail['enableAudioSupport'] ?? false)) {
  //     return AudioServiceEmpty();
  //   }
  //   final sharedPreferences = injector<SharedPreferences>();
  //   return AudioServiceImpl(sharedPreferences: sharedPreferences);
  // }

  Widget getAudioWidget() =>
      AudioStickyWidget(audioService: audioPlayerService);

  Widget renderAudioPlaylistScreen() =>
      AudioPlaylistScreen(audioService: audioPlayerService);

  Widget getAudioBlogCard(
    Blog blog, {
    ValueChanged<Blog>? addAll,
    ValueChanged<MediaItem>? addItem,
    ValueChanged<MediaItem>? playItem,
  }) =>
      AudioBlogCard(
        blog: blog,
        addAll: addAll,
        addItem: addItem,
        playItem: playItem,
      );

  void playMediaItem(BuildContext context, MediaItem mediaItem) async {
    if (!audioPlayerService.isStickyAudioWidgetActive) {
      await _requestOpenStickyAudio(context);
    }
    audioPlayerService.playMediaItem(mediaItem);
  }

  void addMediaItemToPlaylist(BuildContext context, MediaItem mediaItem) async {
    if (!audioPlayerService.isStickyAudioWidgetActive) {
      await _requestOpenStickyAudio(context);
    }
    audioPlayerService.addMediaItem(mediaItem);
    if (audioPlayerService.listData.length == 1) {
      audioPlayerService.playMediaItem(mediaItem);
    }
    _showFlashMessage(context, 'Add media to playlist success.');
  }

  Future<void> addBlogAudioToPlaylist(BuildContext context, Blog blog) async {
    var audioUrls = blog.audioUrls;
    if (audioUrls.isNotEmpty) {
      try {
        var mediaList = <MediaItem>[];
        for (var i = 0; i < audioUrls.length; i++) {
          final item = audioUrls[i];
          var mediaItem = MediaItem(
            id: '${UniqueKey()}',
            album: '',
            title: '${blog.title}${audioUrls.length > 1 ? ' (P${i + 1})' : ''}',
            artUri: blog.imageFeature,
            urlSource: item,
            // duration: duration,
          );
          mediaList.add(mediaItem);
        }

        audioPlayerService.addList(mediaList);
        _showFlashMessage(context,
            'Add media to playlist success. Add new ${mediaList.length} item');

        if (!audioPlayerService.isStickyAudioWidgetActive) {
          await _requestOpenStickyAudio(context);
        }
        if (audioPlayerService.state.isPlaying == false) {
          audioPlayerService.playList();
        }
      } catch (e) {
        printLog('[audio_components] Fail to load audio');
        _showFlashMessage(context, 'Add media to playlist fail',
            isSuccess: false);
      }
    }
  }

  void _showFlashMessage(context, String message, {bool isSuccess = true}) {
    showFlash(
      context: context,
      duration: const Duration(seconds: 3),
      persistent: !Config().isBuilder,
      builder: (context, controller) {
        return Flash(
          borderRadius: BorderRadius.circular(3.0),
          backgroundColor: isSuccess
              ? Theme.of(context).primaryColor
              : Theme.of(context).errorColor,
          controller: controller,
          behavior: FlashBehavior.floating,
          position: FlashPosition.top,
          horizontalDismissDirection: HorizontalDismissDirection.horizontal,
          child: FlashBar(
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ),
            title: const Text(
              'ADD MEDIA TO PLAYLIST',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15.0,
              ),
            ),
            content: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15.0,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestOpenStickyAudio(BuildContext context) async {
    if (kBlogDetail['enableAudioSupport']) {
      var isAccept = audioPlayerService.autoPlay;
      if (isAccept == null) {
        isAccept = await showDialog(
          context: context,
          builder: (context) => const AudioDialog(),
        );
        audioPlayerService.setAutoPlay(isAccept!);
      }
      if (isAccept) {
        audioPlayerService.updateStateStickyAudioWidget(true);
      }
    } else {
      audioPlayerService.updateStateStickyAudioWidget(false);
    }
  }
}
