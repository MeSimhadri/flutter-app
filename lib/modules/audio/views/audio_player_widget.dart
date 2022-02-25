import 'package:flutter/material.dart';
import 'package:inspireui/inspireui.dart';

import '../../../models/audio/player_controller_state.dart';
import '../../../screens/index.dart';
import '../../../services/audio/audio_service.dart';
import '../../../widgets/common/index.dart' show FluxImage;
import '../mixins/audio_player_mixin.dart';
import 'widgets/audio_seek_bar.dart';

class AudioPlayerWidget extends StatefulWidget {
  final AudioService audioService;
  const AudioPlayerWidget({required this.audioService});

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends BaseScreen<AudioPlayerWidget>
    with AudioPlayerWidgetMixin {
  @override
  AudioService get audioPlayerService => widget.audioService;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: ValueListenableBuilder<PlayerControllerState>(
        valueListenable: audioPlayerService.controllerState,
        builder: (_, state, __) {
          final mediaItem = state.current;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: ClipRect(
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: Stack(
                                alignment: Alignment.center,
                                fit: StackFit.expand,
                                children: [
                                  if (mediaItem != null)
                                    FluxImage(
                                      imageUrl: mediaItem.artUri.toString(),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  else
                                    const SizedBox(width: 10),
                                  IgnorePointer(
                                    ignoring: true,
                                    child: AnimatedOpacity(
                                      opacity:
                                          state.state == PlayerState.loading
                                              ? 1
                                              : 0,
                                      duration:
                                          const Duration(milliseconds: 100),
                                      child: Container(
                                        color: Colors.black45,
                                        child: Container(
                                          margin: const EdgeInsets.all(8.0),
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (mediaItem?.title.isEmpty ?? true)
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Skeleton(
                                      width: 500,
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Skeleton(
                                      width: 80,
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Skeleton(
                                      width: 100,
                                      height: 10,
                                    ),
                                  ],
                                ),
                              )
                            else
                              Flexible(
                                child: Text(
                                  mediaItem!.title,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          prevButton(size: 20),
                          if (state.isPlaying)
                            pauseButton(size: 20)
                          else
                            playButton(size: 20),
                          nextButton(size: 20),
                          stopButton(size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              /* Seek Bar */
              SeekBar(
                duration: Duration(seconds: state.duration),
                position: Duration(milliseconds: state.position),
                onChangeEnd: (Duration d) => audioPlayerService.seek(d),
                isSmall: true,
              )
            ],
          );
        },
      ),
    );
  }
}
