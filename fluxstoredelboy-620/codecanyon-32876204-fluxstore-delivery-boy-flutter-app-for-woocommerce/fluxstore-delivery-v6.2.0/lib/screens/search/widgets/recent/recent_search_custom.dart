import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:provider/provider.dart';

import '../../../../common/config.dart';
import '../../../../common/tools/image_tools.dart';
import '../../../../models/product_model.dart';
import '../../../../models/search_model.dart';
import 'recent_products_custom.dart';

class RecentSearchesCustom extends StatelessWidget {
  final Function? onTap;

  const RecentSearchesCustom({this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final widthContent = (screenSize.width / 2) - 4;
    final productType = context.read<ProductModel>().productType;

    return Consumer<SearchModel>(
      builder: (context, model, child) {
        final keywords = model.getKeywordsByType(productType);
        return (keywords.isEmpty)
            ? renderEmpty(context)
            : renderKeywords(
                model,
                widthContent,
                context,
                keywords,
                productType,
              );
      },
    );
  }

  Widget renderEmpty(context) {
    final emptyImage = kSearchConfig.emptyImage;

    return Column(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (emptyImage != null)
          FluxImage(
            imageUrl: emptyImage,
            fit: ImageTools.boxFit(kSearchConfig.boxFit),
            width: 120,
            height: 120,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60.0),
          child: Text(
            S.of(context).emptySearch,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget renderKeywords(
    SearchModel model,
    double widthContent,
    BuildContext context,
    List<String> keywords,
    bool productType,
  ) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                S.of(context).history,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (keywords.isNotEmpty)
                InkWell(
                  onTap: () => model.clearKeywords(productType: productType),
                  child: Text(
                    S.of(context).clear,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          color: Theme.of(context).primaryColorLight,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: keywords
                .take(5)
                .map(
                  (e) => ListTile(
                    title: Text(e),
                    onTap: () {
                      onTap?.call(e);
                    },
                  ),
                )
                .toList(),
          ),
        ),
        RecentProductsCustom(),
      ],
    );
  }
}
