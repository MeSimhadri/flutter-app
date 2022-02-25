import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../menu/index.dart';
import '../../../models/audio/player_controller_state.dart';
import '../../../services/audio/audio_service.dart';
import '../../../widgets/common/index.dart' show FluxImage;
import '../../../widgets/overlay/custom_overlay_state.dart';
import '../mixins/audio_player_mixin.dart';
import 'widgets/audio_seek_bar.dart';

class AudioPlayerPage extends StatefulWidget {
  final AudioService audioService;
  const AudioPlayerPage({Key? key, required this.audioService})
      : super(key: key);

  @override
  _AudioPlayerPageState createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage>
    with AudioPlayerWidgetMixin {
  @override
  AudioService get audioPlayerService => widget.audioService;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlayerControllerState>(
      valueListenable: audioPlayerService.controllerState,
      builder: (_, state, __) {
        final mediaItem = state.current;
        return Container(
          color: Theme.of(context).backgroundColor,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          iconSize: 32,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context, true);
                          audioPlayerService
                            ..stop()
                            ..updateStateStickyAudioWidget(false);
                        },
                        child: Text(S.of(context).stop),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 6,
                      child: mediaItem?.artUri != null
                          ? Padding(
                              padding: const EdgeInsets.only(
                                left: 30,
                                right: 30,
                                bottom: 20,
                                top: 10,
                              ),
                              child: Card(
                                elevation: 20,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: FluxImage(
                                    imageUrl: mediaItem!.artUri.toString(),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.disc_full,
                              size: 60,
                            ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                mediaItem?.title ?? '',
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .headline6!
                                    .copyWith(fontWeight: FontWeight.w800),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SeekBar(
                              duration: Duration(seconds: state.duration),
                              position: Duration(milliseconds: state.position),
                              onChangeEnd: (Duration d) =>
                                  audioPlayerService.seek(d),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                openPlaylistButton(),
                                prevButton(),
                                // Play/pause/stop buttons.
                                if (state.isPlaying)
                                  pauseButton()
                                else
                                  playButton(),
                                nextButton(),
                                replayButton(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  IconButton openPlaylistButton() => IconButton(
        icon: const Icon(Icons.playlist_play),
        iconSize: 20,
        padding: const EdgeInsets.all(10.0),
        onPressed: () async {
          await Navigator.of(context).pushNamed(RouteList.audioPlaylist);

          OverlayControlDelegate().emitTab?.call(
                MainTabControlDelegate.getInstance().currentTabName(),
              );
        },
        constraints: const BoxConstraints(),
      );
}
