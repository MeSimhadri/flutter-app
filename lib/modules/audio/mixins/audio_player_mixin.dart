import 'package:flutter/material.dart';

import '../../../services/audio/audio_service.dart';

mixin AudioPlayerWidgetMixin {
  AudioService get audioPlayerService;

  IconButton replayButton({double size = 20}) => IconButton(
        icon: const Icon(Icons.replay),
        iconSize: size,
        onPressed: () => audioPlayerService.seek(const Duration(seconds: 1)),
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints(),
      );

  IconButton playButton({double size = 70}) => IconButton(
        icon: const Icon(Icons.play_arrow),
        iconSize: size,
        onPressed: audioPlayerService.playOrPause,
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints(),
      );

  IconButton pauseButton({double size = 70}) => IconButton(
        icon: const Icon(Icons.pause),
        iconSize: size,
        onPressed: audioPlayerService.playOrPause,
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints(),
      );

  IconButton nextButton({double size = 40}) => IconButton(
        icon: const Icon(Icons.skip_next),
        iconSize: size,
        onPressed: audioPlayerService.listData.isNotEmpty &&
                audioPlayerService.state.index <
                    (audioPlayerService.listData.length - 1)
            ? audioPlayerService.next
            : null,
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints(),
      );

  IconButton prevButton({double size = 40}) => IconButton(
        icon: const Icon(Icons.skip_previous),
        iconSize: size,
        onPressed: audioPlayerService.listData.isNotEmpty &&
                audioPlayerService.state.index > 0
            ? audioPlayerService.prev
            : null,
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints(),
      );

  IconButton stopButton({double size = 40}) => IconButton(
        icon: const Icon(Icons.stop),
        iconSize: size,
        onPressed: () => audioPlayerService
          ..stop()
          ..updateStateStickyAudioWidget(false),
        padding: const EdgeInsets.all(10.0),
        constraints: const BoxConstraints(),
      );
}
