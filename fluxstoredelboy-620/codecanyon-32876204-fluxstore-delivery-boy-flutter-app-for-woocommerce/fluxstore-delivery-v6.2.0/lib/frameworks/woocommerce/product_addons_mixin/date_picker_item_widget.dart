import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:intl/intl.dart';

import '../../../models/index.dart';
import 'expansion_tile_widget.dart';

class DatePickerItemWidget extends StatefulWidget {
  final ProductAddons item;
  final Map<String, AddonsOption> selected;
  final void Function(Map<String, AddonsOption>)? onSelectProductAddons;
  final String? durationUnit;
  const DatePickerItemWidget({
    required this.item,
    required this.selected,
    this.onSelectProductAddons,
    this.durationUnit,
    super.key,
  });

  @override
  StateDatePickerItemWidget createState() => StateDatePickerItemWidget();
}

class StateDatePickerItemWidget extends State<DatePickerItemWidget> {
  static const _maxYearsInFuture = 10;

  DateTime? selectedDate;

  ProductAddons get item => widget.item;
  AddonsOption? get option =>
      (item.options?.isNotEmpty ?? false) ? item.options?.first : null;
  AddonsOption? get current =>
      option != null ? widget.selected['${item.name}'] : null;

  @override
  void initState() {
    super.initState();
    if (current?.label != null && current!.label!.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(current!.label!);
      } catch (e) {
        selectedDate = null;
      }
    }
  }

  void onDateSelected(DateTime? date) {
    setState(() {
      selectedDate = date;
    });

    final selected = Map<String, AddonsOption>.from(widget.selected);
    final addons = AddonsOption(
      parent: item.name,
      type: option?.type,
      label: date != null ? DateFormat('yyyy-MM-dd').format(date) : null,
      price: item.price,
      display: item.display,
      fieldName: item.fieldName,
      priceType: item.priceType,
    );

    if (date == null) {
      selected.remove(item.name);
    } else {
      selected['${item.name}'] = addons;
    }
    widget.onSelectProductAddons?.call(selected);
  }

  Future<void> showDatePickerDialog() async {
    final now = DateTime.now();
    final initialDate = selectedDate ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + _maxYearsInFuture),
    );

    if (date != null) {
      onDateSelected(date);
    }
  }

  String get displayDate {
    if (selectedDate == null) return '';
    return DateFormat('MMM dd, yyyy').format(selectedDate!);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTileWidget(
      item: item,
      selected: widget.selected,
      subtitle: displayDate,
      durationUnit: widget.durationUnit,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: InkWell(
            onTap: showDatePickerDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      displayDate.isEmpty
                          ? S.of(context).selectDate
                          : displayDate,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: displayDate.isEmpty
                            ? Theme.of(context).hintColor
                            : null,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedDate != null)
                        GestureDetector(
                          onTap: () => onDateSelected(null),
                          child: Icon(
                            Icons.clear,
                            size: 20,
                            color: Theme.of(context).iconTheme.color,
                          ),
                        ),
                      if (selectedDate != null) const SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
