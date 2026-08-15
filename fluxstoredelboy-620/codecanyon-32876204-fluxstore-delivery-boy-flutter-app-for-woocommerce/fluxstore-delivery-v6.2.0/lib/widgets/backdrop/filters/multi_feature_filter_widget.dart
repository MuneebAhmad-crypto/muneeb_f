import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:inspireui/extensions/color_extension.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:provider/provider.dart';

import '../../../models/index.dart';
import '../../../services/services.dart';
import 'widgets/filter_option_item.dart';
import 'widgets/menu_title_widget.dart';

class MultiFeatureFilterWidget extends StatefulWidget {
  const MultiFeatureFilterWidget({
    super.key,
    this.selectedFeature,
    this.onChanged,
    this.useExpansionStyle = true,
  });

  final bool useExpansionStyle;
  final Map<FilterFeature, List<SubFeature>>? selectedFeature;

  final Function(Map<FilterFeature, List<SubFeature>>)? onChanged;

  @override
  State<MultiFeatureFilterWidget> createState() =>
      MultiFeatureFilterWidgetState();
}

class MultiFeatureFilterWidgetState extends State<MultiFeatureFilterWidget> {
  Map<FilterFeature, List<SubFeature>> _listSelectedFeatures = {};

  FilterFeatureModel get filterFeatureModel =>
      context.read<FilterFeatureModel>();

  String get lang => context.read<AppModel>().langCode;

  @override
  void initState() {
    _listSelectedFeatures = Map<FilterFeature, List<SubFeature>>.from(
      widget.selectedFeature ?? {},
    );
    super.initState();
  }

  void _onTapFeature(FilterFeature feature, SubFeature subFeature) {
    var selectedSubFeature = List<SubFeature>.from(
      _listSelectedFeatures.entries
              .firstWhereOrNull((e) => e.key.id == feature.id)
              ?.value ??
          [],
    );

    final isExist =
        selectedSubFeature.indexWhere(
          (element) => element.id == subFeature.id,
        ) !=
        -1;

    setState(() {
      if (isExist) {
        selectedSubFeature.removeWhere(
          (element) => element.id == subFeature.id,
        );
      } else {
        selectedSubFeature.add(subFeature);
      }

      if (selectedSubFeature.isEmpty) {
        _listSelectedFeatures.removeWhere((key, value) => key.id == feature.id);
      } else {
        _listSelectedFeatures[feature] = selectedSubFeature;
      }
    });
    widget.onChanged?.call(_listSelectedFeatures);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterFeatureModel>(
      builder: (_, model, child) {
        final listFeature = model.listVisibleFeature ?? <FilterFeature>[];

        if (listFeature.isEmpty && !model.isLoading) {
          return const SizedBox();
        }

        var list = <Widget>[];

        for (var item in listFeature) {
          final featureName = model.getFeatureName(item.id, lang: lang);
          if (featureName == null) {
            continue;
          }
          list.add(
            MenuTitleWidget(
              title: featureName,
              useExpansionStyle: widget.useExpansionStyle,
              child: _renderSubFeatureList(context, model, item),
            ),
          );
        }

        return Column(children: list);
      },
    );
  }

  Widget _renderSubFeatureList(
    BuildContext context,
    FilterFeatureModel model,
    FilterFeature feature,
  ) {
    final listSubFeature = model.listSubFeature[feature.id] ?? [];
    final selectedSubFeatures =
        _listSelectedFeatures.entries
            .firstWhereOrNull((entry) => entry.key.id == feature.id)
            ?.value ??
        <SubFeature>[];

    final listVisibleSubFeature = listSubFeature
        .where((element) => element.isVisible)
        .toList();

    if (listVisibleSubFeature.isEmpty) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      height: listVisibleSubFeature.length > 4 ? 100 : 50,
      child: GridView.count(
        scrollDirection: Axis.horizontal,
        childAspectRatio: 0.4,
        shrinkWrap: true,
        crossAxisCount: listVisibleSubFeature.length > 4 ? 2 : 1,
        children: [
          for (var subFeature in listVisibleSubFeature)
            FilterOptionItem(
              title: subFeature.name ?? '',
              selected: selectedSubFeatures.any(
                (element) => element.id == subFeature.id,
              ),
              onTap: () => _onTapFeature(feature, subFeature),
            ),
          if (model.isLoadingSub[feature.id] == true)
            loadingMoreWidget()
          else if (model.isEndSub[feature.id] != true)
            FilterOptionItem(
              title: S.of(context).more,
              selected: false,
              onTap: () {
                model.getSubFeatures(featureId: feature.id!);
              },
            ),
        ],
      ),
    );
  }

  Widget loadingMoreWidget() {
    return SizedBox(
      width: 70,
      height: 50,
      child: Center(
        child: JumpingDots(
          innerPadding: 2,
          radius: 6,
          color: Services().widget.enableProductBackdrop
              ? Theme.of(context).colorScheme.secondary.withValueOpacity(0.8)
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
