import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/index.dart';
import '../../../../widgets/common/index.dart' show FluxImage;

class AudioBlogCard extends StatefulWidget {
  final Blog blog;
  final ValueChanged<Blog>? addAll;
  final ValueChanged<MediaItem>? addItem;
  final ValueChanged<MediaItem>? playItem;
  const AudioBlogCard({
    Key? key,
    required this.blog,
    this.addAll,
    this.addItem,
    this.playItem,
  }) : super(key: key);

  @override
  _AudioBlogCardState createState() => _AudioBlogCardState();
}

class _AudioBlogCardState extends State<AudioBlogCard> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.addAll != null)
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => widget.addAll!.call(widget.blog),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  S.of(context).playAll,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          )
        else
          const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              ...List.generate(
                widget.blog.audioUrls.length,
                (index) => cardAudio(index, widget.blog.audioUrls[index],
                    index == (widget.blog.audioUrls.length - 1)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget cardAudio(int index, String urlAudio, [bool isLast = false]) {
    final mediaItem = MediaItem(
      id: '${UniqueKey()}',
      album: 'Playlist Queue',
      title:
          '${widget.blog.title}${widget.blog.audioUrls.length > 1 ? '(P${index + 1})' : ''}',
      artUri: widget.blog.imageFeature,
      urlSource: urlAudio,
    );

    return Container(
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        width: 4,
        color:
            isLast ? Colors.transparent : Theme.of(context).primaryColorLight,
      ))),
      child: Row(
        children: [
          if (widget.playItem != null)
            IconButton(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              onPressed: () => widget.playItem!.call(mediaItem),
              icon: const Icon(Icons.play_arrow),
            ),
          Padding(
            padding: const EdgeInsets.only(
              right: 10,
              top: 12,
              bottom: 12,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: FluxImage(
                imageUrl: widget.blog.imageFeature,
                width: 42,
                height: 42,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${widget.blog.title} (P${index + 1})',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.caption,
            ),
          ),
          if (widget.addItem != null)
            IconButton(
              onPressed: () => widget.addItem!.call(mediaItem),
              icon: Icon(
                CupertinoIcons.plus_circled,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            )
        ],
      ),
    );
  }
}
