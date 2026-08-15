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
import 'widgets/sub_attribute_item.dart';

/// Only used for Prestashop
class FeatureFilterWidget extends StatefulWidget {
  const FeatureFilterWidget({
    super.key,
    this.selectedFeature,
    this.onChanged,
    this.useExpansionStyle = true,
  });

  final bool useExpansionStyle;
  final Map<FilterFeature, List<SubFeature>>? selectedFeature;

  final Function(Map<FilterFeature, List<SubFeature>>)? onChanged;

  @override
  State<FeatureFilterWidget> createState() => FeatureFilterWidgetState();
}

class FeatureFilterWidgetState extends State<FeatureFilterWidget> {
  FilterFeature? currentFeature;

  Map<FilterFeature, List<SubFeature>> _listSelectedFeature = {};

  FilterFeatureModel get filterFeatureModel =>
      context.read<FilterFeatureModel>();

  String get lang => context.read<AppModel>().langCode;

  @override
  void initState() {
    _listSelectedFeature = Map<FilterFeature, List<SubFeature>>.from(
      widget.selectedFeature ?? {},
    );
    currentFeature =
        _listSelectedFeature.entries.firstOrNull?.key ??
        filterFeatureModel.listVisibleFeature?.firstOrNull;
    super.initState();
  }

  void _onTapFeature(int? id) {
    if (id == null || filterFeatureModel.isLoading) {
      return;
    }

    setState(() {
      currentFeature = filterFeatureModel.listFeature?.firstWhereOrNull(
        (element) => element.id == id,
      );
    });
    filterFeatureModel.getSubFeatures(featureId: id);
  }

  void _onTapSubFeature(int featureId, SubFeature subFeature) {
    final currentFeature = filterFeatureModel.listFeature?.firstWhereOrNull(
      (item) => item.id == featureId,
    );

    if (currentFeature == null) {
      return;
    }

    var selectedSubFeature = List<SubFeature>.from(
      _listSelectedFeature.entries
              .firstWhereOrNull((sub) => sub.key.id == currentFeature.id)
              ?.value ??
          [],
    );

    final isExist =
        selectedSubFeature.firstWhereOrNull(
          (element) => element.id == subFeature.id,
        ) !=
        null;

    setState(() {
      if (isExist) {
        selectedSubFeature.removeWhere(
          (element) => element.id == subFeature.id,
        );
      } else {
        selectedSubFeature.add(subFeature);
      }
      _listSelectedFeature.clear();
      _listSelectedFeature[currentFeature] = selectedSubFeature;
    });
    widget.onChanged?.call(_listSelectedFeature);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FilterFeatureModel>(
      builder: (_, model, child) {
        final listFeature = model.listVisibleFeature ?? [];

        if (listFeature.isEmpty) {
          return const SizedBox();
        }

        var list = <Widget>[];

        for (var item in listFeature) {
          final featureName = model.getFeatureName(item.id, lang: lang);
          if (featureName == null) {
            continue;
          }
          list.add(
            FilterOptionItem(
              enabled: !model.isLoading,
              onTap: () => _onTapFeature(item.id),
              title: featureName,
              selected: currentFeature?.id == item.id,
            ),
          );
        }

        final featureWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: list.length > 4 ? 100 : 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              constraints: const BoxConstraints(maxHeight: 100),
              child: GridView.count(
                scrollDirection: Axis.horizontal,
                childAspectRatio: 0.4,
                shrinkWrap: true,
                crossAxisCount: list.length > 4 ? 2 : 1,
                children: list,
              ),
            ),
            _renderSubFeatureList(context, model),
          ],
        );

        return MenuTitleWidget(
          title: S.of(context).feature,
          useExpansionStyle: widget.useExpansionStyle,
          child: featureWidget,
        );
      },
    );
  }

  Widget _renderSubFeatureList(BuildContext context, FilterFeatureModel model) {
    if (model.isLoading && currentFeature?.id == null) {
      return loadingMoreWidget();
    }

    if (currentFeature == null ||
        (model.listSubFeature[currentFeature?.id]?.isEmpty ?? true)) {
      return const SizedBox();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Wrap(
        children: [
          for (var subFeature
              in model.listSubFeature[currentFeature?.id] ?? <SubFeature>[])
            if (subFeature.isVisible)
              SubAttributeItem(
                name: subFeature.name ?? '',
                isSelected:
                    _listSelectedFeature.entries.firstWhereOrNull(
                      (sub) =>
                          sub.key.id == currentFeature?.id &&
                          sub.value.any(
                            (element) => element.id == subFeature.id,
                          ),
                    ) !=
                    null,
                onSelected: (val) =>
                    _onTapSubFeature(currentFeature!.id!, subFeature),
              ),
          if (model.isLoadingSub[currentFeature?.id] == true)
            loadingMoreWidget()
          else if (model.isEndSub[currentFeature?.id] != true)
            SubAttributeItem(
              name: S.of(context).more,
              isSelected: false,
              onSelected: (val) {
                model.getSubFeatures(featureId: currentFeature!.id!);
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
