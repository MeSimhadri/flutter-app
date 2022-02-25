import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../../../common/tools/tools.dart';
import '../config/header_config.dart';

class HeaderType extends StatelessWidget {
  final HeaderConfig config;

  const HeaderType({required this.config});

  @override
  Widget build(BuildContext context) {
    var _fontSize = config.fontSize;
    var _textOpacity = config.textOpacity;
    var _fontWeight = config.fontWeight;
    var _textColor = config.textColor != null
        ? HexColor(config.textColor)
        : Theme.of(context).colorScheme.secondary;

    var _textStyle = TextStyle(
      fontSize: _fontSize.toDouble(),
      fontWeight: Tools.getFontWeight(_fontWeight.toString()),
      color: _textColor.withOpacity(_textOpacity.toDouble()),
    );

    switch (config.type) {
      case 'rotate':
        return AnimatedTextItem(
          title: config.title,
          textStyle: _textStyle,
          animatedTexts: [
            for (var name in config.rotate)
              RotateAnimatedText(
                name,
                textStyle: _textStyle,
              ),
          ],
        );
      case 'fade':
        return AnimatedTextItem(
          title: config.title,
          textStyle: _textStyle,
          animatedTexts: [
            for (var name in config.rotate)
              FadeAnimatedText(
                name,
                textStyle: _textStyle,
              ),
          ],
        );
      case 'typer':
        return AnimatedTextItem(
          title: config.title,
          textStyle: _textStyle,
          animatedTexts: [
            for (var name in config.rotate)
              TyperAnimatedText(
                name,
                textStyle: _textStyle,
              ),
          ],
        );
      case 'typewriter':
        return AnimatedTextItem(
          title: config.title,
          textStyle: _textStyle,
          animatedTexts: [
            for (var name in config.rotate)
              TypewriterAnimatedText(
                name,
                textStyle: _textStyle,
              ),
          ],
        );
      case 'scale':
        return AnimatedTextItem(
          title: config.title,
          textStyle: _textStyle,
          animatedTexts: [
            for (var name in config.rotate)
              ScaleAnimatedText(
                name,
                textStyle: _textStyle,
              ),
          ],
        );
      case 'color':
        return AnimatedTextItem(
          title: config.title,
          textStyle: _textStyle,
          animatedTexts: [
            for (var name in config.rotate)
              ColorizeAnimatedText(
                name,
                textStyle: _textStyle,
                colors: [
                  Colors.purple,
                  Colors.blue,
                  Colors.yellow,
                  Colors.red,
                ],
              ),
          ],
        );
      case 'static':
      default:
        return config.title != null && config.title.toString().isNotEmpty
            ? FittedBox(
                alignment: Alignment.centerLeft,
                child: Text(
                  config.title ?? '',
                  style: _textStyle,
                  maxLines: 3,
                ),
              )
            : const SizedBox();
    }
  }
}

class AnimatedTextItem extends StatelessWidget {
  final String? title;
  final TextStyle? textStyle;
  final List<AnimatedText> animatedTexts;

  const AnimatedTextItem({
    this.title,
    this.textStyle,
    required this.animatedTexts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (title?.isNotEmpty ?? false) ...[
          Text(
            title!,
            style: textStyle ?? const TextStyle(fontSize: 16.0),
          ),
          const SizedBox(width: 10.0),
        ],
        Expanded(
          child: AnimatedTextKit(
            isRepeatingAnimation: true,
            animatedTexts: animatedTexts,
            repeatForever: true,
          ),
        )
      ],
    );
  }
}
