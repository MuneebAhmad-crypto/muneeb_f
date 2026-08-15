enum AjaxSearchPlugin {
  /// ref: https://ajaxsearchpro.com/
  ajaxSearchPro,

  /// ref: https://wordpress.org/plugins/ajax-search-for-woocommerce/
  fiboSearch;

  static AjaxSearchPlugin fromString(String? plugin) {
    return AjaxSearchPlugin.values.firstWhere(
      (e) => e.name == plugin,
      orElse: () => AjaxSearchPlugin.fiboSearch,
    );
  }
}

class SearchConfig {
  static const _defaultEmptyImage = 'assets/images/empty_search.png';
  static const _defaultBoxFit = 'contain';

  final AjaxSearchConfig ajaxSearch;
  final bool enableSkuSearch;

  /// The image to show when there is no search keyword or no search results
  final String? emptyImage;
  final String boxFit;

  bool get isFiboSearchEnabled =>
      ajaxSearch.plugin == AjaxSearchPlugin.fiboSearch && ajaxSearch.enable;
  bool get isAjaxSearchProEnabled =>
      ajaxSearch.plugin == AjaxSearchPlugin.ajaxSearchPro && ajaxSearch.enable;

  const SearchConfig({
    this.ajaxSearch = const AjaxSearchConfig(),
    this.enableSkuSearch = false,
    this.emptyImage = _defaultEmptyImage,
    this.boxFit = _defaultBoxFit,
  });

  Map<String, dynamic> toJson() => {
    'ajaxSearch': ajaxSearch.toJson(),
    'enableSkuSearch': enableSkuSearch,
    'emptyImage': emptyImage,
    'boxFit': boxFit,
  };

  factory SearchConfig.fromJson(Map<dynamic, dynamic> json) {
    return SearchConfig(
      ajaxSearch: AjaxSearchConfig(
        enable: bool.tryParse('${json['ajaxSearch']?['enable']}') ?? false,
        plugin: AjaxSearchPlugin.fromString(
          json['ajaxSearch']?['plugin']?.toString(),
        ),
      ),
      enableSkuSearch: bool.tryParse('${json['enableSkuSearch']}') ?? false,
      // Use containsKey for backward compatibility: missing key → default image,
      // key present but null/empty → hide image.
      emptyImage: json.containsKey('emptyImage')
          ? json['emptyImage']?.toString()
          : _defaultEmptyImage,
      boxFit: json['boxFit']?.toString() ?? _defaultBoxFit,
    );
  }

  factory SearchConfig.fromAdvanceConfigJson(Map<dynamic, dynamic> json) {
    return SearchConfig(
      ajaxSearch: AjaxSearchConfig(
        // Backward compatibility: enable Ajax search when AjaxSearchURL is set
        enable: json['AjaxSearchURL']?.toString().trim().isNotEmpty ?? false,
        plugin: AjaxSearchPlugin.ajaxSearchPro,
      ),
      enableSkuSearch: bool.tryParse('${json['EnableSkuSearch']}') ?? false,
    );
  }

  SearchConfig copyWith({
    AjaxSearchConfig? ajaxSearch,
    bool? enableSkuSearch,
    String? emptyImage,
    String? boxFit,
  }) {
    return SearchConfig(
      ajaxSearch: ajaxSearch ?? this.ajaxSearch,
      enableSkuSearch: enableSkuSearch ?? this.enableSkuSearch,
      emptyImage: emptyImage ?? this.emptyImage,
      boxFit: boxFit ?? this.boxFit,
    );
  }
}

class AjaxSearchConfig {
  final bool enable;
  final AjaxSearchPlugin plugin;

  const AjaxSearchConfig({
    this.enable = false,
    this.plugin = AjaxSearchPlugin.fiboSearch,
  });

  Map<String, dynamic> toJson() => {'enable': enable, 'plugin': plugin.name};
}
