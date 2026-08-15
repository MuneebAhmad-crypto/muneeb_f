import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../services/index.dart';
import 'entities/filter_feature.dart';
import 'mixins/language_mixin.dart';

class FilterFeatureModel with ChangeNotifier, LanguageMixin {
  final Services _service = Services();
  static const int _maxAutoLoadInvisiblePages = 3;

  /// List all features
  List<FilterFeature>? listFeature;

  Iterable<FilterFeature>? get listVisibleFeature =>
      listFeature?.where((element) => element.isVisible);

  /// List all sub features of each feature by id
  Map<int, List<SubFeature>> listSubFeature = {};

  /// Current status of each feature by id
  Map<int, bool> isEndSub = {};

  /// Current loading status of each feature by id
  Map<int, bool> isLoadingSub = {};

  /// Current pages of each feature by id
  Map<int, int> currentPages = {};

  /// Loading status of all features
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? getFeatureName(int? featureId, {String? lang}) {
    final feature = listFeature?.firstWhereOrNull(
      (element) => element.id == featureId,
    );

    if (feature == null) {
      return null;
    }

    if (lang == null || lang.isEmpty) {
      return feature.name;
    }

    final overridedName =
        kProductVariantLanguage[lang]?[feature.name?.toLowerCase()]?.toString();
    return overridedName ?? feature.name;
  }

  Future<void> getFilterFeatures({
    String? categoryIds,
    String? tagIds,
    String? brandIds,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      listFeature = await _service.api.getFilterFeatures(
        categoryIds: categoryIds,
        tagIds: tagIds,
        brandIds: brandIds,
      );

      listSubFeature.clear();
      isEndSub.clear();
      isLoadingSub.clear();
      currentPages.clear();

      for (var item in listFeature ?? <FilterFeature>[]) {
        if (item.id != null && item.subFeatures != null) {
          listSubFeature[item.id!] = item.subFeatures ?? [];
        }
      }
    } catch (e, trace) {
      printError(e, trace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<SubFeature>?> getSubFeatures({required int featureId}) async {
    if (isEndSub[featureId] == true) {
      return listSubFeature[featureId];
    }

    try {
      isLoadingSub[featureId] = true;
      notifyListeners();
      var autoLoadCount = 0;

      do {
        autoLoadCount++;

        /// If the same id, load the next page. Otherwise, load the first page
        final page = currentPages[featureId] =
            (currentPages[featureId] ?? 0) + 1;
        final data =
            (await _service.api.getSubFeatures(
              id: featureId,
              page: page,
              perPage: apiPageSize,
            )) ??
            <SubFeature>[];

        var subFeatures = listSubFeature[featureId] ?? [];
        if (subFeatures.isEmpty) {
          subFeatures = data;
        } else {
          subFeatures.addAll(data);
        }

        listSubFeature.update(
          featureId,
          (value) => subFeatures,
          ifAbsent: () => subFeatures,
        );

        if (data.isEmpty || data.length < apiPageSize) {
          isEndSub[featureId] = true;
        }

        // Remove duplicates item
        subFeatures = listSubFeature[featureId] ?? [];

        final subFeatureIds = subFeatures
            .map((e) => e.id)
            .toSet()
            .toList()
            .where((e) => e != null)
            .toList(); // Get distinct list id and remove null id

        listSubFeature[featureId]?.retainWhere(
          (element) => subFeatureIds.remove(element.id),
        );

        // Keep loading more pages while all loaded items are invisible
      } while (isEndSub[featureId] != true &&
          autoLoadCount < _maxAutoLoadInvisiblePages &&
          (listSubFeature[featureId] ?? []).isNotEmpty &&
          (listSubFeature[featureId] ?? []).every(
            (element) => element.isNotVisible,
          ));
    } catch (e, trace) {
      printError(e, trace);
    } finally {
      isLoadingSub[featureId] = false;
      notifyListeners();
    }

    return listSubFeature[featureId];
  }
}
