import 'package:flutter/material.dart';
import 'package:inspireui/widgets/expandable/expansion_widget.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../models/index.dart' show ProductModel, TagModel;
import '../filter_option_item.dart';

class BackDropTagMenu extends StatefulWidget {
  const BackDropTagMenu({Key? key}) : super(key: key);

  @override
  State<BackDropTagMenu> createState() => _BackDropTagMenuState();
}

class _BackDropTagMenuState extends State<BackDropTagMenu> {
  String? get tagId =>
      Provider.of<ProductModel>(context, listen: false).tagId.toString();
  TagModel get tagModel => Provider.of<TagModel>(context, listen: false);
  String? _tagId;

  @override
  void initState() {
    _tagId = tagId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider.value(
      value: Provider.of<TagModel>(context),
      child: Consumer<TagModel>(
        builder: (context, TagModel tagModel, _) {
          var tagList = tagModel.tagList ?? [];

          if (tagList.isEmpty) {
            return const SizedBox();
          }

          return ExpansionWidget(
            initiallyExpanded: false,
            padding: const EdgeInsets.only(
              left: 15,
              right: 15,
              top: 25,
              bottom: 10,
            ),
            title: Text(
              S.of(context).byTag.toUpperCase(),
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                    ),
                    height: 130,
                    child: GridView.count(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 0.4,
                      children: List.generate(
                        tagList.length,
                        (index) {
                          final selected =
                              _tagId == tagList[index].id.toString();
                          return FilterOptionItem(
                            enabled: true,
                            selected: selected,
                            isValid: _tagId != '-1',
                            title: tagList[index].name!.toUpperCase(),
                            onTap: () {
                              setState(() {
                                _tagId = tagList[index].id.toString();
                              });
                              Provider.of<ProductModel>(context, listen: false)
                                  .updateTagId(tagId: tagList[index].id);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
