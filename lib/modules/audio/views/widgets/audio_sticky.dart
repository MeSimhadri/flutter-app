import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../../services/audio/audio_service.dart';
import '../audio_player_page.dart';
import '../audio_player_widget.dart';

class AudioStickyWidget extends StatefulWidget {
  final AudioService audioService;
  const AudioStickyWidget({Key? key, required this.audioService})
      : super(key: key);

  @override
  _AudioStickyWidgetWidgetState createState() =>
      _AudioStickyWidgetWidgetState();
}

class _AudioStickyWidgetWidgetState extends State<AudioStickyWidget> {
  AudioService get audioPlayerService => widget.audioService;
  final _transitionType = ContainerTransitionType.fadeThrough;
  var blockAudioWidget = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: audioPlayerService.stateStickyAudioWidget,
      builder: (context, active, child) {
        if (!active) {
          audioPlayerService.stop();
          return const SizedBox();
        }

        return OpenContainer<bool>(
          transitionType: _transitionType,
          openBuilder: (BuildContext _, VoidCallback openContainer) {
            return VisibilityDetector(
              onVisibilityChanged: (info) {
                if (info.visibleFraction == 1) {
                  blockAudioWidget.value = true;
                }
              },
              key: const ValueKey('AudioPlayerPageKey'),
              child: AudioPlayerPage(audioService: audioPlayerService),
            );
          },
          closedShape: const RoundedRectangleBorder(),
          closedElevation: 0.0,
          onClosed: (data) {
            blockAudioWidget.value = false;
          },
          closedBuilder: (BuildContext _, VoidCallback openContainer) {
            return ValueListenableBuilder<bool>(
              valueListenable: blockAudioWidget,
              builder: (context, blockWidget, child) {
                return SizedBox(
                  height: 63,
                  child: Visibility(
                    key: const ValueKey('AudioPlayerWidgetKey'),
                    visible: !blockWidget,
                    child: AudioPlayerWidget(audioService: audioPlayerService),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
