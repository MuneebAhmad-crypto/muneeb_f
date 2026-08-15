import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';

import '../../../common/config.dart';
import '../../../models/index.dart' show Product;
import '../../../modules/dynamic_layout/config/product_config.dart';

class StockStatus extends StatelessWidget {
  final Product product;
  final ProductConfig config;

  const StockStatus({super.key, required this.product, required this.config});

  @override
  Widget build(BuildContext context) {
    if (!config.showStockStatus) {
      return const SizedBox();
    }

    var stockQuantity = '';
    if (config.showStockQuantity && product.stockQuantity != null) {
      stockQuantity = ' (${product.stockQuantity})';
    }

    var statusText = '';
    Color? statusColor;
    var showQuantity = true;

    if (product.inStock != null && !product.isEmptyProduct()) {
      final inStock = product.checkInStock() ?? false;
      // Only show Backorder when backorders are allowed AND stock is depleted.
      // If the product still has stock (inStock == true), show In Stock even
      // when the product configuration allows backorders.
      final isOnBackorder = product.backordersAllowed && !inStock;
      if (inStock) {
        statusText = S.of(context).inStock;
        statusColor = kStockColor.inStock;
      } else if (isOnBackorder) {
        statusText = S.of(context).backOrder;
        statusColor = kStockColor.backorder;
        showQuantity = false;
      } else {
        statusText = S.of(context).outOfStock;
        statusColor = kStockColor.outOfStock;
        showQuantity = false;
      }
    } else {
      return const SizedBox();
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: statusText,
            style: TextStyle(color: statusColor, fontSize: 12),
          ),
          if (stockQuantity.isNotEmpty && showQuantity)
            TextSpan(
              text: stockQuantity,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.apply(fontSizeFactor: 0.7),
            ),
        ],
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
