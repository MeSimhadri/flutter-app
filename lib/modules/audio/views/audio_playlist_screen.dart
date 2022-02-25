import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inspireui/widgets/header_view/header_view.dart';
import 'package:provider/provider.dart';

import '../../../models/audio/media_item.dart';
import '../../../models/audio/player_controller_state.dart';
import '../../../models/index.dart';
import '../../../services/audio/audio_service.dart';
import '../../../widgets/common/index.dart' show FluxImage;
import '../mixins/audio_player_mixin.dart';
import 'widgets/audio_seek_bar.dart';

class AudioPlaylistScreen extends StatefulWidget {
  final AudioService audioService;
  const AudioPlaylistScreen({Key? key, required this.audioService})
      : super(key: key);

  @override
  _AudioPlaylistScreenState createState() => _AudioPlaylistScreenState();
}

class _AudioPlaylistScreenState extends State<AudioPlaylistScreen>
    with TickerProviderStateMixin, AudioPlayerWidgetMixin {
  @override
  AudioService get audioPlayerService => widget.audioService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(Icons.close),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        title: FluxImage(
          imageUrl:
              Provider.of<AppModel>(context, listen: false).themeConfig.logo,
          height: 40,
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<PlayerControllerState>(
        valueListenable: audioPlayerService.controllerState,
        builder: (context, state, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (state.current != null) ...[
                        const HeaderView(headerText: 'Now playing'),
                        _renderItemNowPlaying(state.current!)
                      ],
                      if ((audioPlayerService.listData.isNotEmpty) &&
                          audioPlayerService.listData.length > 1) ...[
                        const HeaderView(headerText: 'Next In Queue'),
                        ...List.generate(audioPlayerService.listData.length,
                            (index) {
                          final item = audioPlayerService.listData[index];
                          if (audioPlayerService.compareMediaItem(
                              item, state.current!)) {
                            return const SizedBox();
                          }
                          return _renderItem(item);
                        })
                      ]
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 5),
                height: 160,
                child: Card(
                  margin: EdgeInsets.zero,
                  child: _renderControl(state),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _renderItemNowPlaying(MediaItem item) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: FluxImage(
              imageUrl: item.artUri.toString(),
              width: 55,
              height: 55,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _renderControl(PlayerControllerState state) {
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
      ),
      child: Column(
        children: [
          SeekBar(
            duration: Duration(seconds: state.duration),
            position: Duration(milliseconds: state.position),
            onChangeEnd: (Duration d) => audioPlayerService.seek(d),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              prevButton(),
              if (state.isPlaying) pauseButton() else playButton(),
              nextButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _renderItem(MediaItem media, {bool remove = true}) {
    return Container(
      color: Theme.of(context).backgroundColor,
      height: 80,
      padding: EdgeInsets.only(left: remove ? 0 : 10, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (remove)
            Center(
              child: IconButton(
                onPressed: () {
                  audioPlayerService.removeMediaItem(media);
                  if (mounted) {
                    setState(() {});
                  }
                },
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 22,
              ),
            ),
          if (media.artUri != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: FluxImage(
                  imageUrl: media.artUri.toString(),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Expanded(
            child: Text(
              media.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
