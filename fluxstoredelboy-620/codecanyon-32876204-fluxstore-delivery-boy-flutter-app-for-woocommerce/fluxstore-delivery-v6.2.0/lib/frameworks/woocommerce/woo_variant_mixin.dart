import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../models/index.dart'
    show Product, ProductAttribute, ProductVariation;
import '../../widgets/product/product_variant/product_variant_widget.dart';
import '../product_variant_mixin.dart';

mixin WooVariantMixin on ProductVariantMixin {
  @override
  Future<void> getProductVariations({
    BuildContext? context,
    Product? product,
    void Function({
      Product? productInfo,
      List<ProductVariation>? variations,
      Map<String?, String?> mapAttribute,
      ProductVariation? variation,
    })?
    onLoad,
  }) async {
    if (product == null) {
      return;
    }

    final productAttributes = product.attributes ?? [];
    var mapAttribute = <String?, String?>{};
    var variations = product.variationProducts ?? [];
    Product? productInfo = product;
    ProductVariation? variation;

    if (variations.isEmpty) {
      for (var attr in productAttributes) {
        if (attr.options?.isNotEmpty ?? false) {
          mapAttribute.update(
            attr.keyAttr,
            (value) => attr.options![0]['name'],
            ifAbsent: () => attr.options![0]['name'],
          );
        }
      }
    } else {
      /// If [autoSelectFirstAttribute] is true then search for a suitable
      /// variant (in stock) and set it as initial value. If `defaultAttributes`
      /// exists then use default value to override the initial value.
      ///
      /// If [autoSelectFirstAttribute] is false then set all inital value of
      /// attributes as null. If `defaultAttributes` exists then use default value
      /// to override the initial value.
      final autoSelectFirstAttribute =
          productInfo.defaultAttributes.isEmpty &&
          kProductDetail.autoSelectFirstAttribute;

      if (autoSelectFirstAttribute) {
        for (var variant in variations) {
          final isInStock = product.checkProductVariationInStock(variant);

          if (!isInStock) {
            continue;
          }

          // Let's return it to double so we can compare accurately.
          // There was a case of wrong comparison due to
          // different String: "6530" vs "6530.0"
          final priceProduct = num.tryParse(product.price ?? '0')?.toDouble();
          final priceVariant = num.tryParse(variant.price ?? '0')?.toDouble();

          if (priceVariant == priceProduct) {
            for (var attribute in variant.attributes) {
              for (var attr in productAttributes) {
                if (attr.keyAttr == attribute.keyAttr) {
                  mapAttribute.update(
                    attr.keyAttr,
                    (value) => attr.options![0]['name'],
                    ifAbsent: () => attr.options![0]['name'],
                  );
                }
              }

              mapAttribute.update(
                attribute.keyAttr,
                (value) => attribute.option,
                ifAbsent: () => attribute.option,
              );
            }

            /// Although this variant has the same price as the product,
            /// no attribute was found. So this object will be ignored
            /// and the search for a suitable variant will continue.
            if (mapAttribute.isNotEmpty) {
              break;
            }
          }

          /// If after find there is still no suitable variant,
          /// select the first variant to set.
          if (mapAttribute.isEmpty) {
            /// Requires variant to have attribute
            var firstItem = variations.firstWhereOrNull((e) {
              return e.attributes.isNotEmpty;
            });

            if (firstItem != null) {
              for (var attribute in firstItem.attributes) {
                mapAttribute.update(
                  attribute.keyAttr,
                  (value) => value,
                  ifAbsent: () {
                    return attribute.option;
                  },
                );
              }
            }
          }
        }
      } else {
        if (productAttributes.isNotEmpty) {
          /// Load attributes but not selected yet
          for (var element in productAttributes) {
            mapAttribute.update(
              element.keyAttr,
              (value) => null,
              ifAbsent: () => null,
            );
          }
        }
      }

      if (productInfo.defaultAttributes.isNotEmpty) {
        /// Load default attributes from Woo.
        final validAttributeKeys = productAttributes
            .map((attribute) => attribute.keyAttr)
            .whereType<String>()
            .toSet();
        for (var attribute in productInfo.defaultAttributes) {
          final keyAttr = attribute.keyAttr;
          if (keyAttr == null || !validAttributeKeys.contains(keyAttr)) {
            continue;
          }

          /// Convert slug to name.
          final option =
              productInfo.attributeSlugMap[attribute.option] ??
              attribute.option;
          if (option != null && option.isNotEmpty) {
            mapAttribute[keyAttr] = option;
          }
        }
      }

      String getDataUpdateAttribute(List options, String valueCompare) {
        for (var productOptionAttr in options) {
          if (productOptionAttr['slug'] != null &&
              productOptionAttr['slug'] == valueCompare) {
            return productOptionAttr['name'];
          }
        }
        return valueCompare;
      }

      /// Update name for attribute if its value is from slug
      if (productAttributes.isNotEmpty) {
        /// update with product option
        for (var attr in productAttributes) {
          if (attr.options == null) {
            break;
          }

          /// update variations
          for (var item in variations) {
            /// update attributes(1) and attributeMap(2) of variations

            /// (1) update attributes of variations
            for (var itemAttr in item.attributes) {
              if ((attr.keyAttr == itemAttr.keyAttr ||
                      attr.name == itemAttr.name ||
                      attr.label == itemAttr.name) &&
                  itemAttr.option != null) {
                itemAttr.option = getDataUpdateAttribute(
                  attr.options!,
                  itemAttr.option!,
                );
              }
            }

            /// (2) update attributes of attributeMap
            item.attributeMap.forEach((key, value) {
              if (item.attributeMap[key] != null) {
                item.attributeMap[key]!.option = getDataUpdateAttribute(
                  attr.options!,
                  item.attributeMap[key]!.option!,
                );
              }
            });
          }

          /// update for product mapAttribute
          mapAttribute.forEach((key, value) {
            if (attr.options != null && value != null) {
              mapAttribute[key] = getDataUpdateAttribute(attr.options!, value);
            }
          });
        }
      }

      /// Check default attributes
      for (var item in variations) {
        if (item.hasSameAttributes(mapAttribute)) {
          variation = item;
          break;
        }
      }

      if (variation == null) {
        /// Clear default attributes if it's invalid.
        // mapAttribute.clear();
      }
    }

    // if there is any default attribute is any, we need to set first option for that attribute
    if ((productAttributes.isNotEmpty) &&
        mapAttribute.isNotEmpty &&
        productAttributes.length > mapAttribute.keys.length) {
      for (var attr in productAttributes) {
        if (mapAttribute[attr.keyAttr] == null &&
            (attr.options?.isNotEmpty ?? false)) {
          mapAttribute[attr.keyAttr] = attr.options![0]['name'];
        }
      }
    }

    onLoad?.call(
      productInfo: productInfo,
      variations: variations,
      variation: variation,
      mapAttribute: mapAttribute,
    );
    return;
  }

  bool couldBePurchased(
    List<ProductVariation>? variations,
    ProductVariation? productVariation,
    Product product,
    Map<String?, String?>? mapAttribute,
  ) {
    final isAvailable = productVariation != null
        ? productVariation.id != null
        : true;

    final isValidProductVariant = productVariation != null
        ? isValidProductVariation(variations!, mapAttribute)
        : true;

    return isValidProductVariant &&
        isPurchased(productVariation, product, mapAttribute, isAvailable);
  }

  /// Return true if mapAttribute match with any of variations.
  bool isValidProductVariation(
    List<ProductVariation> variations,
    Map<String?, String?>? mapAttribute,
  ) {
    for (var variation in variations) {
      if (variation.hasSameAttributes(mapAttribute)) {
        /// Hide out of stock variation
        if ((kAdvanceConfig.hideOutOfStock) &&
            !variation.inStock! &&
            !(variation.backordersAllowed ?? false)) {
          return false;
        }
        return true;
      }
    }
    return false;
  }

  Map<String?, String?> _filterSelectedAttributesForValidation(
    List<ProductVariation> variations,
    Map<String?, String?>? mapAttribute,
  ) {
    if (mapAttribute == null || mapAttribute.isEmpty || variations.isEmpty) {
      return {};
    }

    final variationKeys = variations
        .expand((variation) => variation.attributes)
        .map((attribute) => attribute.keyAttr)
        .whereType<String>()
        .toSet();

    final filtered = <String?, String?>{};
    mapAttribute.forEach((key, value) {
      if (key != null &&
          value != null &&
          value.isNotEmpty &&
          variationKeys.contains(key)) {
        filtered[key] = value;
      }
    });
    return filtered;
  }

  @override
  void onSelectProductVariant({
    ProductAttribute? attr,
    String? val,
    List<ProductVariation>? variations,
    Map<String?, String?>? mapAttribute,
    Function? onFinish,
  }) {
    if (kProductDetail.hideInvalidAttributes) {
      final previousVal = mapAttribute![attr!.keyAttr];

      /// Unselect if option is selected.
      if (val.toString() == previousVal) {
        mapAttribute[attr.keyAttr] = null;
        final productVariation = updateVariation(variations!, mapAttribute);
        onFinish!(mapAttribute, productVariation);
        return;
      }
    }

    mapAttribute!.update(
      attr!.keyAttr,
      (value) => val.toString(),
      ifAbsent: () => val.toString(),
    );

    final mapForValidation = _filterSelectedAttributesForValidation(
      variations!,
      mapAttribute,
    );
    if (mapForValidation.isNotEmpty &&
        !isValidProductVariation(variations, mapForValidation)) {
      /// Reset other choices
      mapAttribute.clear();
      mapAttribute[attr.keyAttr] = val.toString();
    }

    final productVariation = updateVariation(variations, mapAttribute);
    onFinish!(mapAttribute, productVariation);
  }

  Map getPWOptionsName(List<ProductVariation> variations) {
    var optionsName = {};
    for (var item in variations) {
      var attributes = item.attributes;
      var key = attributes.isNotEmpty ? attributes.first.option : null;
      if ((key?.isNotEmpty ?? false) && (item.price?.isNotEmpty ?? false)) {
        optionsName[key] = item.price;
      }
    }
    return optionsName;
  }

  @override
  List<Widget> getProductAttributeWidget(
    String lang,
    Product product,
    Map<String?, String?>? mapAttribute,
    Function onSelectProductVariant,
    List<ProductVariation> variations,
  ) {
    var listWidget = <Widget>[];

    Map? optionsName;
    if (product.isPWGiftCardProduct) {
      optionsName = getPWOptionsName(variations);
    }
    final productAttributes = product.attributes ?? [];

    // TODO(tri): add attribute widget
    if (productAttributes.isNotEmpty) {
      for (var attr in productAttributes) {
        ///  - Use `attrClone` clone because there are cases where it is necessary
        /// to update the name of `attr` to identify the product variant.
        ///  - Depending on `mapAttribute` whose key is the mapAttribute's name
        /// or label, it will determine the updated value.
        var attrClone = attr.copyWith();

        if (attrClone.name?.isNotEmpty ?? false) {
          var options = _getValidAttributeOptions(
            attrClone,
            mapAttribute,
            variations,
          );

          /// Deselect invalid option.
          if (options.isEmpty) {
            mapAttribute?[attrClone.keyAttr] = null;
            options = _getValidAttributeOptions(
              attrClone,
              mapAttribute,
              variations,
            );
          }

          var selectedValue = mapAttribute?[attrClone.keyAttr] ?? '';
          var attrType =
              kProductVariantLayout[attr.cleanSlug ?? attr.name] ??
              kProductVariantLayout[attr.name?.toLowerCase()] ??
              'box';
          if (product.isPWGiftCardProduct) {
            attrType = 'price';
          }
          if (attr.isImageType == true) {
            attrType = 'image';
          }

          /// Only products that are "Variable" can select the attribute.
          if (product.isVariableProduct) {
            listWidget.addAll([
              BasicSelection(
                imageUrls: attrClone.imageUrls,
                colorValues: attrClone.colorValues,
                options: options,
                optionsName: optionsName,
                title: kProductVariantLanguage[lang] != null
                    ? kProductVariantLanguage[lang][attr.cleanSlug ??
                              attr.name] ??
                          kProductVariantLanguage[lang][attr.name
                              ?.toLowerCase()] ??
                          attr.label?.toLowerCase()
                    : attr.label?.toLowerCase(),
                type: attrType,
                value: selectedValue,
                productId: product.id,
                onChanged: (val) => onSelectProductVariant(
                  attr: attrClone,
                  val: val,
                  mapAttribute: mapAttribute,
                  variations: variations,
                ),
              ),
            ]);
          }
        }
      }
    }
    return listWidget;
  }

  @override
  List<Widget> getProductTitleWidget(
    BuildContext context,
    ProductVariation? productVariation,
    Product product,
  ) {
    final isAvailable =
        // ignore: unnecessary_null_comparison
        productVariation != null ? productVariation.id != null : true;
    return makeProductTitleWidget(
      context,
      productVariation,
      product,
      isAvailable,
    );
  }

  @override
  List<Widget> getBuyButtonWidget({
    required BuildContext context,
    ProductVariation? productVariation,
    required Product product,
    Map<String?, String?>? mapAttribute,
    required int maxQuantity,
    required int quantity,
    required Function({bool buyNow, bool inStock}) addToCart,
    required Function(int quantity) onChangeQuantity,
    List<ProductVariation>? variations,
    required bool isInAppPurchaseChecking,
    bool showQuantity = true,
    Widget Function(bool Function(int) onChanged, int maxQuantity)?
    builderQuantitySelection,
    bool disableBuyButton = false,
  }) {
    final isAvailable = couldBePurchased(
      variations,
      productVariation,
      product,
      mapAttribute,
    );

    return makeBuyButtonWidget(
      context: context,
      productVariation: productVariation,
      product: product,
      mapAttribute: mapAttribute,
      maxQuantity: maxQuantity,
      quantity: quantity,
      addToCart: addToCart,
      onChangeQuantity: onChangeQuantity,
      isAvailable: isAvailable,
      isInAppPurchaseChecking: isInAppPurchaseChecking,
      showQuantity: showQuantity,
      builderQuantitySelection: builderQuantitySelection,
      disableBuyButton: disableBuyButton,
    );
  }

  List<String> _getValidAttributeOptions(
    ProductAttribute attr,
    Map<String?, String?>? mapAttribute,
    List<ProductVariation> variations,
  ) {
    return List<String>.from(
      attr.options!
          .map((e) {
            final copy = Map<String?, String?>.from(mapAttribute ?? {});
            copy[attr.keyAttr] = e['name'];

            final mapForValidation = _filterSelectedAttributesForValidation(
              variations,
              copy,
            );
            if (kProductDetail.hideInvalidAttributes) {
              if (mapForValidation.isEmpty ||
                  isValidProductVariation(variations, mapForValidation)) {
                return e['name'];
              }
              return null;
            } else {
              return e['name'];
            }
          })
          .toList()
          /// To filter null value.
          .whereType<String>(),
    );
  }
}
