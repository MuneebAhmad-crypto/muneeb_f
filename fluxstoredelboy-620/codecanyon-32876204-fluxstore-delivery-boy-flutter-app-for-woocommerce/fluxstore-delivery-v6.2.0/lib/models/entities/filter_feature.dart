import '../../common/tools.dart';

class FilterFeature {
  int? id;
  String? name;
  bool isVisible = true;
  List<SubFeature>? subFeatures;

  FilterFeature.fromJson(Map parsedJson) {
    id = int.tryParse('${parsedJson['id']}');
    name = parsedJson['name']?.toString().unescape().trim();
    isVisible = parsedJson['is_visible'] ?? true;

    final optionValues = parsedJson['associations']?['feature_values'];
    if (optionValues is List) {
      subFeatures = [];
      for (var subFeature in optionValues) {
        subFeatures?.add(SubFeature.fromJson(subFeature));
      }
    }
  }
}

class SubFeature {
  int? id;
  String? name;
  int? count;

  SubFeature.fromJson(Map parsedJson) {
    id = int.tryParse('${parsedJson['id']}');
    name = parsedJson['value']?.toString().unescape().trim();
    count = int.tryParse('${parsedJson['count']}');
  }

  @override
  String toString() {
    return '[id: $id ===== name: $name]';
  }
}

extension SubFeatureExt on SubFeature {
  /// Show sub feature if count is null due to the old API or unsupported
  /// frameworks
  bool get isVisible => count == null || count! > 0;

  bool get isNotVisible => !isVisible;
}
