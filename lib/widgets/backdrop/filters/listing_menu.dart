import 'package:flutter/material.dart';
import 'package:inspireui/widgets/expandable/expansion_widget.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../models/entities/listing_location.dart';
import '../../../models/index.dart' show ListingLocationModel, ProductModel;
import 'location_item.dart';

class BackDropListingMenu extends StatefulWidget {
  final Function onFilter;

  const BackDropListingMenu({Key? key, required this.onFilter})
      : super(key: key);

  @override
  State<BackDropListingMenu> createState() => _BackDropTagMenuState();
}

class _BackDropTagMenuState extends State<BackDropListingMenu> {
  List<ListingLocation> get locations =>
      Provider.of<ListingLocationModel>(context, listen: false).locations;
  String? get listingLocationId =>
      Provider.of<ProductModel>(context, listen: false).listingLocationId;
  String? get categoryId =>
      Provider.of<ProductModel>(context, listen: false).categoryId;

  @override
  Widget build(BuildContext context) {
    return ExpansionWidget(
      padding: const EdgeInsets.only(
        left: 15,
        right: 15,
        top: 20,
        bottom: 10,
      ),
      title: Text(
        S.of(context).location.toUpperCase(),
        style: Theme.of(context).textTheme.subtitle1!.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
      ),
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
          decoration: const BoxDecoration(
            color: Colors.white12,
          ),
          child: Column(
            children: List.generate(
              locations.length,
              (index) => LocationItem(
                locations[index],
                isSelected: locations[index].id == listingLocationId,
                onTap: () {
                  widget.onFilter(
                    categoryId: categoryId,
                    listingLocationId: locations[index].id,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
