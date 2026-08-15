import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:core';

import 'package:collection/collection.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:http/http.dart';
import 'package:quiver/strings.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/events.dart';
import '../../../common/extensions/extensions.dart';
import '../../../data/boxes.dart';
import '../../../models/booking/staff_booking_model.dart';
import '../../../models/entities/branch.dart';
import '../../../models/entities/brand.dart';
import '../../../models/entities/order_delivery_date.dart';
import '../../../models/entities/product_component.dart';
import '../../../models/entities/stripe_payment_intent.dart';
import '../../../models/index.dart';
import '../../../services/base_services.dart';
import '../../../services/elastic/elastic_client.dart';
import '../../../services/elastic/elastic_query.dart';
import '../../../services/elastic/elastic_service.dart';
import '../../../services/index.dart';
import '../../../services/wordpress/wordpress_blog_service.dart';
import 'branch_ext.dart';
import 'woo_connector.dart';
import 'woo_query.dart';
import 'woocommerce_api.dart';

const _rootCategoryId = 0;

final String kDefaultCurrency =
    kCurrencyConfig.defaultCurrency?.currencyCode ?? 'USD';

void checkExpiredCookie(Response response) {
  final body = convert.jsonDecode(response.body);
  if (response.statusCode == 401 && body['code'] == 'expired_cookie') {
    eventBus.fire(
      EventExpiredCookie(isRequiredLogin: true, errMsg: body['message']),
    );
  }
}

class WooCommerceService extends BaseServices {
  final WooComerceConnector wcConnector;

  final String isSecure;
  List<Category> categories = [];
  Map<String, Tag> tags = {};
  String? currentLanguage;
  bool? currentHideEmptyCategories;
  String? currentExcludedCategoryIDs;
  Map<String, List<Product>> categoryCache = <String, List<Product>>{};
  bool? _useAjaxSearchProGetMethod;
  FiboSearchConfig? _fiboSearchConfig;

  WooCommerceService({
    required super.domain,
    String? blogDomain,
    required String consumerKey,
    required String consumerSecret,
  }) : wcConnector = WooComerceConnector(
         WooCommerceAPI(domain, consumerKey, consumerSecret),
       ),
       isSecure = domain.contains('https') ? '' : '&insecure=cool',
       super(
         blogService: WordpressBlogService(
           domain: blogDomain ?? domain,
           useCrossBlog: blogDomain != domain,
         ),
       ) {
    categories = [];
    currentLanguage = null;
    currentHideEmptyCategories = null;
    categoryCache = <String, List<Product>>{};
  }

  String buildUrlToGetProducts(String endPoint) {
    if (kCurrencyConfig.enableWOOCSCurrencySwitcher) {
      endPoint = endPoint.addUrlQuery('currency=$kDefaultCurrency');
    }
    return endPoint.addUrlQuery(
      'is_all_data=${kAdvanceConfig.enableIsAllData == true}',
    );
  }

  String buildUrlByLang(String endPoint, {bool isForceUseLang = false}) {
    if (isForceUseLang || kAdvanceConfig.isMultiLanguages) {
      return endPoint.addUrlQuery('lang=$languageCode');
    }
    return endPoint;
  }

  /// Returns `{'User-Cookie': <encoded>}` when any feature that requires
  /// server-side per-user pricing is enabled and a user is logged in.
  /// Add new feature flags here as they are introduced.
  Map<String, String>? get wooHeaders {
    final needsCookie = isWholesaleEnabled;
    if (!needsCookie) return null;
    final cookie = UserBox().userInfo?.cookie;
    if (cookie == null) return null;
    return {'User-Cookie': EncodeUtils.encodeCookie(cookie)};
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      if (categories.isNotEmpty &&
          currentLanguage == languageCode &&
          currentHideEmptyCategories == kAdvanceConfig.hideEmptyCategories &&
          currentExcludedCategoryIDs == kExcludedCategoryIDs &&
          !isWholesaleEnabled) {
        return categories;
      }
      currentLanguage = languageCode;
      currentHideEmptyCategories = kAdvanceConfig.hideEmptyCategories;
      currentExcludedCategoryIDs = kExcludedCategoryIDs;
      var list = <Category>[];
      var isEnd = false;
      var page = 1;
      var limit = 100;

      while (!isEnd) {
        var categories = await getCategoriesByPage(page: page, limit: limit);
        if (categories.isEmpty || categories.length < limit - 1) {
          isEnd = true;
        }
        page = page + 1;
        list = [...list, ...categories];
      }
      categories = list;
      return list;
    } catch (e) {
      return [];
      //rethrow;
    }
  }

  @override
  Future<List<Category>> getCategoriesByPage({
    page,
    limit,
    storeId,
    String? searchTerm,
    int? parent,
    bool useCompute = true,
    dynamic nextCursor,
  }) async {
    try {
      var url =
          'products/categories?per_page=$limit&page=$page&hide_empty=${kAdvanceConfig.hideEmptyCategories}';

      if (kExcludedCategoryIDs?.isNotEmpty ?? false) {
        url = url.addUrlQuery('exclude=$kExcludedCategoryIDs');
      }
      url = buildUrlByLang(url);
      if (searchTerm != null && searchTerm.isNotEmpty) {
        url += '&search=$searchTerm';
      }
      if (parent != null) {
        url += '&parent=$parent';
      }
      var response = await wcConnector.getAsync(url, headers: wooHeaders);
      if (!useCompute) {
        return Category.parseCategoryList(response);
      }

      return Category.parseCategoryList(response);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts({userId}) async {
    var list = <Product>[];
    try {
      var endpoint = 'products';
      if (userId != null) {
        endpoint += '?user_id=$userId';
      }
      var response = await wcConnector.getAsync(endpoint);
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        for (var item in response) {
          list.add(Product.jsonParser(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
    return list;
  }

  Future<List<Product>> boostProducts({
    dynamic category,
    String? tag,
    bool? featured,
    bool? onSale,
    num? maxPrice,
    num? minPrice,
    String? orderBy,
    String? order,
    int? limit,
    int? offset,
    String? include,
    String? search,
    List<String>? brandIds,
    Map? attributes,
    String? stockStatus,
    List<String>? exclude,
  }) async {
    final mustList = ElasticActionList();
    final mustNotList = ElasticActionList();
    final sortList = <Map<String, dynamic>>[];
    var catIds = [];
    if (category is List) {
      catIds = category;
    } else if (category != null) {
      /// need to remove '' when empty
      catIds = '$category'.split(',');
    }
    catIds.removeWhere((e) => ['0', kEmptyCategoryID, ''].contains('$e'));
    if (catIds.isNotEmpty) {
      mustList.addFilter(
        keyFilter: 'terms',
        key: 'categories.id',
        value: catIds,
      );
    }

    if (brandIds != null && brandIds.isNotEmpty) {
      mustList.addFilter(keyFilter: 'terms', key: 'brands.id', value: brandIds);
    }
    if (tag?.isNotEmpty ?? false) {
      mustList.addFilter(
        keyFilter: 'terms',
        key: 'tags.id',
        value: '$tag'.split(','),
      );
    }

    /// Add featured filter
    if (featured ?? false) {
      mustList.addMatch(key: 'featured', value: true);
    }

    /// Add onSale filter
    if (onSale ?? false) {
      mustList.addMatch(key: 'on_sale', value: true);
    }
    if (maxPrice != null && maxPrice > 0) {
      mustList.addRange(key: 'price', gteValue: minPrice, lteValue: maxPrice);
    }

    /// ignore the hidden catalog
    mustNotList.addMatch(key: 'catalog_visibility', value: 'hidden');

    if (attributes?.isNotEmpty ?? false) {
      // As the old logic, only support single attribute
      final attribute = attributes!.entries.first;
      final attributeId = attribute.value;

      if (attributeId != null) {
        var termId = [];
        if (attributeId is List) {
          termId = List.from(attributeId);
        }
        if (attributeId is String) {
          var convertAttribute = attributeId.replaceAll(']', '');
          convertAttribute = convertAttribute.replaceAll('[', '');
          convertAttribute = convertAttribute.replaceAll(' ', '');
          if (convertAttribute.isNotEmpty) {
            termId = convertAttribute.split(',');
          }
        }
        if (termId.isNotEmpty) {
          mustList.addFilter(
            keyFilter: 'terms',
            key: 'attributesData.options.term_id',
            value: termId,
          );
        }
      }
    }

    /// sort by
    if (orderBy is String) {
      orderBy = ElasticClient.convertProductOrderBy(orderBy);
      sortList.add({orderBy: order ?? 'desc'});
    }
    var stock = kAdvanceConfig.hideOutOfStock ? 'instock' : null;
    stock = stockStatus ?? stock;
    if (stock != null) {
      switch (stock) {
        case 'instock':
          mustList.addMatch(key: 'in_stock', value: true);
          break;
        case 'outofstock':
          mustList.addMatch(key: 'in_stock', value: false);
          break;
        case 'onbackorder':
          mustList.addMatch(key: 'backordered', value: true);
          break;
        default:
      }
    }
    if (include?.isNotEmpty ?? false) {
      mustList.addFilter(
        keyFilter: 'terms',
        key: 'id',
        value: include?.split(','),
      );
    }
    List<String>? excludeIds;
    if (kExcludedProductIDs?.isNotEmpty ?? false) {
      excludeIds = kExcludedProductIDs?.split(',');
    }
    excludeIds = exclude ?? excludeIds;
    if (excludeIds?.isNotEmpty ?? false) {
      mustNotList.addFilter(keyFilter: 'terms', key: 'id', value: excludeIds);
    }
    if (search?.isNotEmpty ?? false) {
      var fields = ['name'];
      if (kSearchConfig.enableSkuSearch) {
        fields = ['name', 'sku'];
      }
      mustList.addQuery(
        query: '$search'.splitMapJoin(
          RegExp(r' |-'),
          onNonMatch: (n) => '*$n*',
          onMatch: (m) => ' ',
        ),
        queryOperator: ElasticQueryOperator.and,
        fields: fields,
      );
    }
    final result = await ElasticService.search(
      uri: Uri.parse(domain),
      languageCode: languageCode,
      limit: limit ?? apiPageSize,
      offset: offset,
      mustList: mustList,
      mustNotList: mustNotList,
      sortList: sortList,
    );

    return ProductModel.parseWooProductList(result, {
      'category': category,
      'include': include,
    });
  }

  Future<List<Product>?> boostProductsLayout({required Map config}) {
    return boostProducts(
      category: config['category'],
      tag: config['tag'],
      featured: bool.tryParse('${config['featured']}'),
      onSale: bool.tryParse('${config['onSale']}'),
      maxPrice: double.tryParse('${config['maxPrice']}'),
      minPrice: double.tryParse('${config['minPrice']}'),
      attributes:
          config['attributes'] ??
              (config['attribute'] != null && config['attributeId'] != null)
          ? {config['attribute']: config['attributeId']}
          : null,
      orderBy: config['orderby'] is String ? config['orderby'] : null,
      order: config['order'] is String ? config['order'] : null,
      limit: int.tryParse('${config['limit']}'),
      offset: int.tryParse('${config['page']}'),
      include: config['include'] is List
          ? (config['include'] as List).join(',')
          : config['include'] is String
          ? config['include']
          : null,
      stockStatus: config['stockStatus'] is String
          ? config['stockStatus']
          : null,
      exclude: config['exclude'] is List<String> ? config['exclude'] : null,
    );
  }

  Future<dynamic> getWooProductsResponse({
    String params = '',
    int version = 2,
    bool refreshCache = false,
  }) async {
    var endPoint = 'products$params';
    var response = await wcConnector.getAsync(
      endPoint,
      refreshCache: refreshCache,
      version: version,
      headers: wooHeaders,
    );
    return response;
  }

  @override
  Future<List<Product>?> fetchProductsLayout({
    config,
    userId,
    bool refreshCache = false,
  }) async {
    try {
      if (config is! Map) {
        return [];
      }

      final dataConfig = Map<String, dynamic>.from(config);
      final enableBoostEngine =
          bool.tryParse('${dataConfig['boostEngine']}') ??
          kBoostEngineConfig.isOptimizeEnable;
      if (enableBoostEngine) {
        try {
          // Add await here to cache exception if boost engine does not work
          final values = await boostProductsLayout(config: dataConfig);

          // If values exist, just return them
          // Otherwise, fall back to calling the API.
          if (values?.isNotEmpty ?? false) {
            return values;
          }
        } catch (e, trace) {
          // If the boost engine does not work, just print error and go to call the API
          printError(e, trace);
        }
      }

      var params = '?status=publish';
      params = buildUrlByLang(params);
      params += ProductQuery.fromJson(config).toParams(apiVersion: 3);
      params = buildUrlToGetProducts(params);

      var response = await getWooProductsResponse(
        params: params,
        refreshCache: refreshCache,
        version: 3,
      );

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      }

      return ProductModel.parseWooProductList(response, dataConfig);
    } catch (e, trace) {
      printLog(trace.toString());
      printLog(e.toString());
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      return [];
    }
  }

  /// get all attribute_term for selected attribute for filter menu
  @override
  Future<List<SubAttribute>> getSubAttributes({
    required int id,
    int page = 1,
    int perPage = 10,
  }) async {
    var listAttributes = <SubAttribute>[];
    try {
      var url = 'products/attributes/$id/terms?page=$page&per_page=$perPage';
      url = buildUrlByLang(url);

      var response = await wcConnector.getAsync(url);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        for (var item in response) {
          if (item['count'] > 0) {
            listAttributes.add(SubAttribute.fromJson(item));
          }
        }
        return listAttributes;
      }
    } catch (e) {
      rethrow;
    }

    return listAttributes;
  }

  //get all attributes for filter menu
  @override
  Future<List<FilterAttribute>>? getFilterAttributes({
    String? categoryIds,
    String? tagIds,
    String? brandIds,
  }) async {
    var list = <FilterAttribute>[];
    try {
      var endPoint = 'products/attributes';
      endPoint = buildUrlByLang(endPoint);

      if (categoryIds != null) {
        endPoint = endPoint.addUrlQuery('category=$categoryIds');
      }
      if (tagIds != null) {
        endPoint = endPoint.addUrlQuery('tag=$tagIds');
      }
      if (brandIds != null) {
        endPoint = endPoint.addUrlQuery('brand=$brandIds');
      }

      var response = await wcConnector.getAsync(endPoint);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        for (var item in response) {
          list.add(FilterAttribute.fromJson(item));
        }
      }

      return list;
    } catch (err, trace) {
      printError(err, trace);
    }
    return list;
  }

  @override
  Future<List<Product>?> fetchProductsByCategory({
    String? categoryId,
    String? tagId,
    int? page = 1,
    int? limit,
    minPrice,
    maxPrice,
    orderBy,
    order,
    featured,
    onSale,
    listingLocation,
    userId,
    String? include,
    String? search,
    bool? productType,
    nextCursor,
    bool? boostEngine,
    List<String>? brandIds,
    Map? attributes,
    Map? features,
    String? stockStatus,
    List<String>? exclude,
    bool? refreshCache,
  }) async {
    try {
      final enableBoostEngine =
          boostEngine ?? kBoostEngineConfig.isOptimizeEnable;
      if (enableBoostEngine) {
        try {
          final values = await boostProductsByCategory(
            categoryId: categoryId,
            tagId: tagId,
            minPrice: minPrice,
            maxPrice: maxPrice,
            orderBy: orderBy,
            order: order,
            page: page,
            featured: featured,
            onSale: onSale,
            attributes: attributes,
            include: include,
            search: search,
            brandIds: brandIds,
            stockStatus: stockStatus,
            exclude: exclude,
          );

          // If values exist, just return them
          // Otherwise, fall back to calling the API.
          if (values?.isNotEmpty ?? false) {
            return values;
          }
        } catch (e, trace) {
          printError(e, trace);
        }
      }
      // If user use ajax search, it can't apply filter when loading product
      if (kSearchConfig.isAjaxSearchProEnabled &&
          search != null &&
          search.isNotEmpty) {
        var result = await ajaxSearch(
          search,
          useGetMethod: _useAjaxSearchProGetMethod,
        );
        return result.data;
      }
      var list = <Product>[];

      /// this cause a bug on Profile List
      /// we just allow cache if the totalItem = perPageItem otherwise, should reload
      if ((page == 0 || page == 1) &&
          categoryCache['$categoryId'] != null &&
          categoryCache['$categoryId']!.isNotEmpty &&
          featured == null &&
          onSale == null &&
          attributes == null &&
          refreshCache != true) {
        if (categoryCache['$categoryId']!.length == (limit ?? apiPageSize)) {
          return categoryCache['$categoryId'];
        }
      }

      var query = ProductQuery.parse(
        category: categoryId,
        tag: tagId,
        page: page,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        order: order,
        attributes: attributes,
        featured: featured,
        onSale: onSale,
        userId: userId,
        include: include,
        search: search,
        perPage: limit ?? apiPageSize,
        brandIds: brandIds,
        stockStatus: stockStatus,
        exclude: exclude,
      );
      var params = '?status=publish&skip_cache=1';
      params += query.toParams(apiVersion: 3);
      params = buildUrlByLang(params);

      params = buildUrlToGetProducts(params);
      printLog('-- fetchProductsByCategory --');
      printLog(params);
      var response = await getWooProductsResponse(
        params: params,
        version: 3,
        refreshCache: refreshCache ?? false,
      );

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        if (response is List) {
          for (var item in response) {
            /// ignore the hidden catalog
            if (item['catalog_visibility'] == 'hidden') {
              continue;
            }

            final product = Product.jsonParser(item);

            /// hideOutOfStock product
            if ((kAdvanceConfig.hideOutOfStock) &&
                !(product.inStock ?? false) &&
                !product.backordersAllowed) {
              continue;
            }

            /// ignore the listing type
            if (product.isListingType) {
              continue;
            }

            if (categoryId != null) {
              product.categoryId = categoryId;
            }

            list.add(product);
          }
        }

        /// Search by SKU.
        final isFiboSearch = kSearchConfig.isFiboSearchEnabled;

        if (kSearchConfig.enableSkuSearch &&
            search != null &&
            search.isNotEmpty &&
            !isFiboSearch) {
          final skuList = await _searchBySku(
            categoryId: categoryId,
            tagId: tagId,
            minPrice: minPrice,
            maxPrice: maxPrice,
            orderBy: orderBy,
            order: order,
            page: page,
            featured: featured,
            onSale: onSale,
            attributes: attributes,
            include: include,
            sku: search,
            brandIds: brandIds,
            userId: userId,
          );

          if (skuList.isNotEmpty) {
            /// Merge results. Let SKU results on top.
            skuList.addAll(list);
            return skuList;
          }
        }
        return list;
      }
    } catch (e, trace) {
      printError(e, trace);
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  Future<List<Product>> _searchBySku({
    String? categoryId,
    String? tagId,
    page = 1,
    minPrice,
    maxPrice,
    orderBy,
    order,
    featured,
    onSale,
    userId,
    String? include,
    String? sku,
    List<String>? brandIds,
    Map? attributes,
    String? stockStatus,
    List<String>? exclude,
  }) async {
    var skuList = <Product>[];
    var query = ProductQuery.parse(
      category: categoryId,
      tag: tagId,
      page: page,
      minPrice: minPrice,
      maxPrice: maxPrice,
      orderBy: orderBy,
      order: order,
      attributes: attributes,
      featured: featured,
      onSale: onSale,
      userId: userId,
      include: include,
      sku: sku,
      perPage: apiPageSize,
      brandIds: brandIds,
      stockStatus: stockStatus,
      exclude: exclude,
    );
    var params = '?status=publish&skip_cache=1';
    params += query.toParams(apiVersion: 3);
    params = buildUrlByLang(params);
    params = buildUrlToGetProducts(params);
    final response = await getWooProductsResponse(params: params, version: 3);
    if (response is List) {
      for (var item in response) {
        /// ignore the hidden catalog
        if (item['catalog_visibility'] == 'hidden') {
          continue;
        }

        final product = Product.jsonParser(item);

        /// hideOutOfStock product
        if ((kAdvanceConfig.hideOutOfStock) &&
            !(product.inStock ?? false) &&
            !product.backordersAllowed) {
          continue;
        }

        /// ignore the listing type
        if (product.isListingType) {
          continue;
        }

        skuList.add(product);
      }
    }
    return skuList;
  }

  Future<List<Product>?> boostProductsByCategory({
    categoryId,
    tagId,
    page = 1,
    minPrice,
    maxPrice,
    orderBy,
    order,
    featured,
    onSale,
    String? include,
    String? search,
    List<String>? brandIds,
    Map? attributes,
    String? stockStatus,
    List<String>? exclude,
  }) async {
    return boostProducts(
      category: categoryId,
      tag: tagId,
      featured: featured is bool ? featured : null,
      onSale: onSale is bool ? onSale : null,
      maxPrice: double.tryParse('$maxPrice'),
      minPrice: double.tryParse('$minPrice'),
      attributes: attributes,
      orderBy: orderBy is String ? orderBy : null,
      order: order is String ? order : null,
      offset: page,
      include: include,
      search: search,
      brandIds: brandIds,
      stockStatus: stockStatus,
      exclude: exclude,
    );
  }

  @override
  Future<User?> loginFacebook({String? token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          '$domain/wp-json/api/flutter_user/fb_connect/?second=$cookieLifeTime'
          // ignore: prefer_single_quotes
          "&access_token=$token$isSecure";

      var response = await wcConnector.httpGet(endPoint.toUri()!);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null ||
          jsonDecode['cookie'] == null ||
          jsonDecode['user'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(
        jsonDecode['user'],
        jsonDecode['cookie'],
        isSocial: true,
      );
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<User> loginSMS({String? token}) async {
    try {
      var idToken = await Services().firebase.getIdToken();
      var endPoint = '$domain/wp-json/api/flutter_user/firebase_sms';
      if (kAuthConfig.enableNewSMSLogin) {
        endPoint = '$domain/wp-json/api/flutter_user/firebase_sms_v2';
      }

      var response = await wcConnector.httpPost(
        endPoint.toUri()!,
        body: convert.jsonEncode({'id_token': idToken}),
        headers: {'Content-Type': 'application/json'},
      );

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null ||
          jsonDecode['cookie'] == null ||
          jsonDecode['user'] == null) {
        throw Exception(jsonDecode['message']);
      }

      return User.fromWooJson(
        jsonDecode['user'],
        jsonDecode['cookie'],
        isSocial: true,
      );
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<User?> loginApple({
    String? token,
    String? firstName,
    String? lastName,
  }) async {
    try {
      var endPoint = '$domain/wp-json/api/flutter_user/apple_login_2';

      var response = await wcConnector.httpPost(
        endPoint.toUri()!,
        body: convert.jsonEncode({
          'authorization_code': token,
          'first_name': firstName,
          'last_name': lastName,
          'team_id': kAuthConfig.providers.apple.teamId,
          'bundle_id': kAuthConfig.providers.apple.iOSBundleId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null ||
          jsonDecode['cookie'] == null ||
          jsonDecode['user'] == null) {
        throw Exception(
          isNotBlank(jsonDecode['message'])
              ? jsonDecode['message']
              : jsonDecode['code'],
        );
      }

      return User.fromWooJson(
        jsonDecode['user'],
        jsonDecode['cookie'],
        isSocial: true,
      );
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Review>> getReviews(
    productId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      var response = await wcConnector.getAsync(
        'products/reviews?per_page=$perPage&page=$page&product=$productId',
        version: 3,
      );
      var list = <Review>[];
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        for (var item in response) {
          list.add(Review.fromJson(item));
        }
        return PagingResponse(data: list);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future createReview(ReviewPayload payload) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      final token = payload.token;
      if (token != null) {
        headers['User-Cookie'] = EncodeUtils.encodeCookie(token);
      }

      final response = await wcConnector.httpPost(
        '${wcConnector.url}/wp-json/api/flutter_woo/products/reviews'.toUri()!,
        body: jsonEncode(payload.toWooJson()),
        headers: headers,
      );
      var body = jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body['message'] == null) {
        return;
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<List<ProductVariation>> getProductVariations(
    Product product, {
    String? lang = 'en',
  }) async {
    const perPage = 100;
    try {
      final list = <ProductVariation>[];
      var page = 1;

      while (true) {
        var endPoint =
            'products/${product.id}/variations?per_page=$perPage&page=$page';
        endPoint = buildUrlByLang(endPoint);
        endPoint = buildUrlToGetProducts(endPoint);
        var response = await wcConnector.getAsync(
          endPoint,
          headers: wooHeaders,
        );
        if (response is Map && isNotBlank(response['message'])) {
          throw Exception(response['message']);
        } else if (response is List) {
          for (var item in response) {
            if (item['visible']) {
              list.add(ProductVariation.fromJson(item));
            }
          }

          if (response.length < perPage) {
            /// No more data.
            break;
          }

          /// Fetch next page.
          page++;
        }
      }

      return list;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods({
    required CartModel cartModel,
    String? token,
    String? checkoutId,
    Store? store,
  }) async {
    try {
      // if (!isBookingProduct(cartModel!)) {
      //   return getShippingMethodsByWooApi();
      // }
      var params = Order().toJson(cartModel, cartModel.user?.id, false);
      if (!kVendorConfig.disableVendorShipping &&
          ServerConfig().isVendorType()) {
        final lineItemsByStore = [];
        for (var element in params['line_items']) {
          final product = cartModel.getProductById(element['product_id']);

          if (product == null) continue;

          // The old logic is to use non-store products and the same store's
          // product to calculate shipping fees. But not sure if that is the
          // right way, need to check the logic again on the web
          if ((store == null && product.store == null)) {
            lineItemsByStore.add(element);
          }

          if (store != null &&
              product.store != null &&
              product.store?.id == store.id) {
            lineItemsByStore.add(element);
          }
        }

        // Get all products from the same store to calculate shipping fees
        params['line_items'] = lineItemsByStore;
      }
      var list = <ShippingMethod>[];
      final response = await wcConnector.httpPost(
        buildUrlByLang(
          '$domain/wp-json/api/flutter_woo/shipping_methods',
        ).toUri()!,
        body: convert.jsonEncode(params),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 502) {
        return getShippingMethodsByWooApi();
      }

      final body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (response.statusCode == 200) {
        for (var item in body) {
          list.add(ShippingMethod.fromJson(item));
        }
      } else if (body['data'] != null &&
          body['data']['required_shipping'] != null) {
        if (body['data']['required_shipping'] == false) {
          return list;
        } else {
          throw Exception(S.current.emptyShippingMsg);
        }
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      if (list.isEmpty) {
        throw Exception(S.current.emptyShippingMsg);
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  bool isBookingProduct(CartModel cartModel) {
    var isBooking = false;
    for (var key in cartModel.productsInCart.keys) {
      var productId = Product.cleanProductID(key);
      var product = cartModel.item[productId]!;
      if (product.bookingInfo != null) {
        isBooking = true;
      }
    }
    return isBooking;
  }

  Future<List<ShippingMethod>> getShippingMethodsByWooApi() async {
    try {
      var list = <ShippingMethod>[];
      var res = await wcConnector.getAsync('shipping/zones');
      if (res is Map && isNotBlank(res['message'])) {
        throw Exception(res['message']);
      } else if (res is List && res.isNotEmpty) {
        await Future.forEach(res, (zone) async {
          final zoneId = zone is Map ? zone['id'] : 0;
          var response = await wcConnector.getAsync(
            'shipping/zones/$zoneId/methods',
          );
          if (response is Map && isNotBlank(response['message'])) {
            throw Exception(response['message']);
          } else if (response is List) {
            for (var item in response) {
              var methodItem = {
                'id': item['instance_id'],
                'method_id': item['method_id'],
                'instance_id': item['instance_id'],
                'label': item['title'],
                'cost':
                    item['settings']['cost'] != null &&
                        item['settings']['cost']['value'] != null
                    ? item['settings']['cost']['value']
                    : 0,
                'shipping_tax': 0,
              };
              list.add(ShippingMethod.fromJson(methodItem));
            }
          }
        });
      }

      if (list.isEmpty) {
        throw Exception(S.current.emptyShippingMsg);
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods({
    CartModel? cartModel,
    ShippingMethod? shippingMethod,
    String? token,
  }) async {
    try {
      // if (isBookingProduct(cartModel!)) {
      //   return getPaymentMethodsByWooApi();
      // }
      final params = Order().toJson(cartModel!, null, false);

      var list = <PaymentMethod>[];
      final response = await wcConnector.httpPost(
        buildUrlByLang(
          '$domain/wp-json/api/flutter_woo/payment_methods',
        ).toUri()!,
        body: convert.jsonEncode(params),
        headers: {
          'Content-Type': 'application/json',
          'User-Cookie': EncodeUtils.encodeCookie(token ?? ''),
        },
      );

      if (response.statusCode == 502) {
        return getPaymentMethodsByWooApi();
      }

      final body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (response.statusCode == 200) {
        for (var item in body) {
          list.add(PaymentMethod.fromJson(item));
          final availableExpressPay =
              kExpressPayConfig
                  .getValueList('paymentMethodIds')
                  .contains(item['id']) &&
              kExpressPayConfig['enabled'] == true;
          if (availableExpressPay && isIos) {
            list.add(
              PaymentMethod(
                id: 'expresspay_apple_pay',
                title: 'ExpressPay Apple Pay',
                enabled: true,
              ),
            );
          }
        }
        if (kFIBConfig['enabled'] ?? false) {
          list.add(
            PaymentMethod(id: 'fib', title: 'FIRST IRAQI BANK', enabled: true),
          );
        }
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  Future<List<PaymentMethod>> getPaymentMethodsByWooApi() async {
    try {
      var list = <PaymentMethod>[];
      var response = await wcConnector.getAsync('payment_gateways');
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        for (var item in response) {
          if (item['enabled'] == true &&
              item['id'] != 'wc-appointment-gateway') {
            var methodItem = {
              'id': item['id'],
              'title': item['method_title'],
              'method_title': item['instance_id'],
              'description': item['description'],
            };
            list.add(PaymentMethod.fromJson(methodItem));
          }
        }
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Order>> getMyOrders({
    User? user,
    dynamic cursor,
    String? cartId,
    String? orderStatus,
  }) async {
    var list = <Order>[];
    try {
      var endPoint =
          'orders?&customer=${user!.id}&per_page=20&page=$cursor&order=desc&orderby=id&dummy=${DateTime.now().millisecondsSinceEpoch}';
      if (orderStatus?.isNotEmpty ?? false) {
        endPoint += '&status=$orderStatus';
      }
      var response = await wcConnector.getAsync(endPoint, version: 3);
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        for (var item in response) {
          list.add(Order.fromJson(item));
        }
        return PagingResponse(data: list);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
    return PagingResponse(data: list);
  }

  @override
  Future<List<OrderNote>> getOrderNote({
    String? userId,
    String? orderId,
  }) async {
    var list = <OrderNote>[];
    try {
      var response = await wcConnector.getAsync(
        'orders/$orderId/notes?customer=$userId&per_page=20&type=${kAdvanceConfig.orderNotesWithPrivateNote == true ? 'any' : 'customer'}',
      );
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        for (var item in response) {
          //          if (item.type == 'any') {
          /// it is possible to update to `any` note
          /// ref: https://woocommerce.github.io/woocommerce-rest-api-docs/#list-all-order-notes
          list.add(OrderNote.fromJson(item));
          //          }
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
    return list;
  }

  @override
  Future<Order> createOrder({
    CartModel? cartModel,
    UserModel? user,
    bool? paid,
    AdditionalPaymentInfo? additionalPaymentInfo,
  }) async {
    try {
      final params = Order().toJson(
        cartModel!,
        user!.user != null ? user.user!.id : null,
        paid,
      );
      if (additionalPaymentInfo?.transactionId != null) {
        params['transaction_id'] = additionalPaymentInfo?.transactionId;
      }

      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_order/create'.toUri()!,
        body: convert.jsonEncode(params),
        headers: {
          'User-Cookie': EncodeUtils.encodeCookie(
            user.user != null ? user.user!.cookie! : '',
          ),
          'Content-Type': 'application/json',
        },
      );
      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if ((response.statusCode == 201 || response.statusCode == 200) &&
          body['message'] == null) {
        if (cartModel.shippingMethod == null &&
            kPaymentConfig.enableShipping &&
            body['shipping_lines'].length > 0) {
          body['shipping_lines'][0]['method_title'] = null;
        }
        return Order.fromJson(body);
      } else {
        final params = body['data']?['params'];
        if (params is Map && params.isNotEmpty) {
          throw Exception(params.values.join(' '));
        }
        throw Exception(body['message']);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> processDokanPayPalPayment({
    required String orderId,
    String? token,
  }) async {
    try {
      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_paypal/process_payment'
            .addUrlQuery('order_id=$orderId')
            .toUri()!,
        headers: {
          if (token != null && token.isNotEmpty)
            'User-Cookie': EncodeUtils.encodeCookie(token),
          'Content-Type': 'application/json',
        },
      );

      final body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);

      if (body is Map) {
        if (body['message'] != null) {
          throw Exception(body['message']);
        }
        return Map<String, dynamic>.from(body);
      }

      throw Exception('Invalid response from PayPal process payment API');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future updateOrder(
    orderId, {
    status,
    token,
    PaymentMethod? paymentMethod,
  }) async {
    try {
      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_order/update/$orderId'.toUri()!,
        body: convert.jsonEncode({'status': status}),
        headers: {
          if (token != null) 'User-Cookie': EncodeUtils.encodeCookie(token),
          'Content-Type': 'application/json',
        },
      );

      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body['message'] != null) {
        throw Exception(body['message']);
      } else {
        return Order.fromJson(body);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future? deleteOrder(orderId, {required token}) async {
    try {
      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_order/delete/$orderId'.toUri()!,
        headers: {
          if (token != null) 'User-Cookie': EncodeUtils.encodeCookie(token),
          'Content-Type': 'application/json',
        },
      );

      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body['message'] != null) {
        throw Exception(body['message']);
      } else {
        return true;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<Order?> cancelOrder({Order? order, String? userCookie}) async {
    final newOrder = await Services().api.updateOrder(
      order!.id,
      status: 'cancelled',
      token: userCookie,
    );
    return newOrder;
  }

  @override
  Future<FiboSearchConfig> getFiboSearchConfig() async {
    try {
      final uri = '$domain/wp-json/api/flutter_fibo_search/settings'.toUri();
      if (uri == null) return FiboSearchConfig();

      final response = await wcConnector.httpGet(uri);
      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);
        return FiboSearchConfig.fromJson(body);
      }
    } catch (e) {
      printLog('[FiboSearch] Error loading config: $e');
    }
    return FiboSearchConfig();
  }

  @override
  Future<FiboSearchResponse> fiboSearch(
    String name, {
    FiboSearchConfig? config,
  }) async {
    final searchConfig =
        config ?? _fiboSearchConfig ?? await getFiboSearchConfig();
    _fiboSearchConfig ??= searchConfig;

    if (name.length < searchConfig.minChars) {
      return FiboSearchResponse(searchQuery: name);
    }

    try {
      final encodedQuery = Uri.encodeQueryComponent(name);
      final uri =
          '$domain/wp-json/api/flutter_fibo_search/search?s=$encodedQuery'
              .toUri();
      if (uri == null) return FiboSearchResponse(searchQuery: name);

      final response = await wcConnector.httpGet(uri);
      if (response.statusCode != 200) {
        return FiboSearchResponse(searchQuery: name);
      }

      final body = convert.jsonDecode(response.body);

      if (body is Map && isNotBlank(body['message'])) {
        return FiboSearchResponse(
          searchQuery: name,
          errorMessage: body['message'],
        );
      }

      return FiboSearchResponse.fromJson(body as Map<String, dynamic>)
        ..searchQuery = name;
    } catch (e) {
      printLog('[FiboSearch] Error: $e');
      return FiboSearchResponse(searchQuery: name, errorMessage: e.toString());
    }
  }

  Future<PagingResponse<Product>> ajaxSearch(
    String name, {
    bool? useGetMethod,
  }) async {
    final uri = '$domain/wp-json/ajax-search-pro/v0/woo_search?s=$name'.toUri();
    final useGet = useGetMethod == true;

    if (uri == null || uri.toString().isEmpty) {
      return const PagingResponse(data: []);
    }
    try {
      printLog('[ajaxSearch] Using ${useGet ? "GET" : "POST"} method');
      final response = await (useGet
          ? wcConnector.httpGet(uri)
          : wcConnector.httpPost(uri));

      if (response.statusCode == 200) {
        final body = convert.jsonDecode(response.body);

        if (body is Map && isNotBlank(body['message'])) {
          throw Exception(body['message']);
        }

        _useAjaxSearchProGetMethod = useGet;
        final list = (body is List)
            ? body
                  .map((item) => Product.fromAjaxSearch(item['asp_data']))
                  .toList()
            : <Product>[];

        return PagingResponse(data: list);
      }
      return const PagingResponse(data: []);
    } catch (e) {
      printLog(e);
      if (_useAjaxSearchProGetMethod == null && useGet == false) {
        printLog('[ajaxSearch] Switching to GET method');
        return ajaxSearch(name, useGetMethod: true);
      }

      return const PagingResponse(data: []);
    }
  }

  /// Auth
  @override
  Future<User?> getUserInfo(cookie) async {
    try {
      var base64Str = EncodeUtils.encodeCookie(cookie);
      final response = await wcConnector.httpGet(
        '$domain/wp-json/api/flutter_user/get_currentuserinfo?token=$base64Str&$isSecure'
            .toUri()!,
        refreshCache: true,
      );
      final body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body['user'] != null) {
        var user = body['user'];
        return User.fromWooJson(user, cookie);
      } else {
        if (body['message'] != 'Invalid cookie') {
          throw Exception(body['message']);
        }
        return null;

        /// we may handle if Invalid cookie here
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
    Map<String, dynamic> json,
    String? token,
  ) async {
    try {
      final body = convert.jsonEncode({...json, 'cookie': token});

      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_user/update_user_profile'.toUri()!,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      final data = jsonDecode(response.body);
      checkExpiredCookie(response);

      if (response.statusCode == 200) {
        data['cookie'] = token;
        return data;
      } else if (data['message'] != null) {
        throw Exception(data['message']);
      } else {
        throw Exception(S.current.canNotUpdateInfo);
      }
    } catch (err) {
      rethrow;
    }
  }

  /// Create a New User
  @override
  Future<User?> createUser({
    String? firstName,
    String? lastName,
    String? username,
    String? email,
    String? password,
    String? phoneNumber,
    bool isVendor = false,
    bool isDelivery = false,
    bool isOwner = false,
  }) async {
    try {
      final displayName = [firstName ?? '', lastName ?? ''].join(' ').trim();
      final endpoint =
          '$domain/wp-json/api/flutter_user/sign_up/?insecure=cool&$isSecure'
              .toUri()!;
      final response = await wcConnector.httpPost(
        endpoint,
        body: convert.jsonEncode({
          'user_email': email ?? username,
          'user_login': username ?? email,
          'username': username ?? email,
          'user_pass': password,
          'email': email ?? username,
          'display_name': displayName,
          'phone': phoneNumber,
          'first_name': firstName,
          'last_name': lastName,

          /// Woo single app doesn't have vendor role but has delivery boy role.
          if (isDelivery) 'role': 'driver',
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body['message'] == null) {
        final cookie = body['cookie'];
        return await getUserInfo(cookie);
      }
      if (body is Map && isNotBlank(body['message'])) {
        if (body['code'] == 'invalid_username') {
          throw Exception(S.current.usernameInvalid);
        }
        if (body['code'] == 'existed_username') {
          throw Exception(S.current.usernameAlreadyInUse);
        }
        if (body['code'] == 'invalid_email') {
          throw Exception(S.current.emailAddressInvalid);
        }
        if (body['code'] == 'existed_email') {
          throw Exception(S.current.emailAlreadyInUse);
        }
        throw Exception(body['message']);
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      printLog(err);
      rethrow;
    }
    return null;
  }

  /// login
  @override
  Future<User?> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_user/generate_auth_cookie/?insecure=cool&$isSecure'
            .toUri()!,
        body: convert.jsonEncode({
          'seconds': cookieLifeTime.toString(),
          'username': username,
          'password': password,
        }),
        headers: {'Content-Type': 'application/json'},
        useCache: false,
      );

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && isNotBlank(body['cookie'])) {
        return await getUserInfo(body['cookie']);
      } else if (body['code'] == 'pending_approval') {
        throw (S.current.accountIsPendingApproval);
      } else if (body['code'] == 'too_many_retries') {
        // For plugin https://wordpress.org/plugins/limit-login-attempts-reloaded/
        throw (S.current.tooManyFailedLogin);
      } else if (body['message'] != null) {
        throw body['message'];
      } else {
        throw (S.current.userNameInCorrect);
      }
    } catch (err, trace) {
      printError(err, trace, '🔥 Integration error:');
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  Future<Stream<Product>> streamProductsLayout({required config}) async {
    try {
      var endPoint = 'products?per_page=$apiPageSize';
      if (config['category'] != null &&
          config['category'].toString().isNotEmpty &&
          config['category'] != kEmptyCategoryID) {
        endPoint += "&category=${config["category"]}";
      }
      if (config['tag'] != null && config['tag'].toString().isNotEmpty) {
        endPoint += "&tag=${config["tag"]}";
      }
      endPoint = buildUrlToGetProducts(endPoint);
      var response = await wcConnector.getStream(endPoint);

      return response.stream
          .transform(utf8.decoder)
          .transform(json.decoder)
          .expand((data) => (data as List))
          .map(Product.jsonParser);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<Product?> getProduct(id) async {
    try {
      var endpoint = 'products/$id';
      endpoint = buildUrlByLang(endpoint);
      endpoint = buildUrlToGetProducts(endpoint);
      var response = await wcConnector.getAsync(
        endpoint,
        refreshCache: true,
        headers: wooHeaders,
      );

      if (response is Map && isNotBlank(response['message'])) {
        printLog('GetProduct Error: ${response['message']}');
        return null;
      }

      if (response == null || response is! Map) {
        return null;
      }

      var product = Product.jsonParser(response);
      if (product.isCompositeProduct) {
        var components = await Services().api.getProductComponents(product.id);
        product.components = components;
      }
      return product;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<ProductVariation?> getVariationProduct(
    String productId,
    variationId,
  ) async {
    try {
      var endpoint = 'products/$productId/variations/$variationId';
      endpoint = buildUrlByLang(endpoint);
      endpoint = buildUrlToGetProducts(endpoint);
      var response = await wcConnector.getAsync(endpoint, headers: wooHeaders);

      if (response is Map) {
        if (isNotBlank(response['message'])) {
          printLog('GetProduct Error: ${response['message']}');
          return null;
        }

        return ProductVariation.fromJson(response);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
    return null;
  }

  @override
  Future<Coupons> getCoupons({int page = 1, String search = ''}) async {
    try {
      var response = await wcConnector.getAsync(
        'coupons?page=$page${search.isNotEmpty ? '&search=$search' : ''}',
      );
      if (response is List) {
        return Coupons.getListCoupons(response);
      }
      return Coupons.getListCoupons([]);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getHomeCache(String? lang) async {
    try {
      var endpoint = 'flutter/cache';
      endpoint = buildUrlByLang(endpoint, isForceUseLang: true);
      endpoint = buildUrlToGetProducts(endpoint);

      final data = await wcConnector.getAsync(endpoint, refreshCache: true);
      if (data == null || data is! Map) {
        throw Exception("Can't get home cache");
      }
      if (data['message'] != null) {
        throw Exception(data['message']);
      }
      var config = Map<String, dynamic>.from(data);
      if (config['HorizonLayout'] != null) {
        // These values ​​must be handled where they are used.
        // var horizontalLayout = config['HorizonLayout'] as List;
        // for (var i = 0; i < horizontalLayout.length; i++) {
        //   if (horizontalLayout[i]['radius'] != null) {
        //     horizontalLayout[i]['radius'] =
        //         double.parse("${horizontalLayout[i]["radius"]}");
        //   }
        //   if (horizontalLayout[i]['size'] != null) {
        //     horizontalLayout[i]['size'] =
        //         double.parse("${horizontalLayout[i]["size"]}");
        //   }
        //   if (horizontalLayout[i]['padding'] != null) {
        //     horizontalLayout[i]['padding'] =
        //         double.parse("${horizontalLayout[i]["padding"]}");
        //   }
        // }
        return config;
      }
      return null;
    } catch (e, trace) {
      printError(e, trace);
      return null;
    }
  }

  @override
  Future<User?> loginGoogle({String? token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          '$domain/wp-json/api/flutter_user/google_login/?second=$cookieLifeTime'
                  '&access_token=$token$isSecure'
              .toUri()!;

      var response = await wcConnector.httpGet(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null ||
          jsonDecode['cookie'] == null ||
          jsonDecode['user'] == null) {
        throw Exception(jsonDecode['message']);
      }
      return User.fromWooJson(
        jsonDecode['user'],
        jsonDecode['cookie'],
        isSocial: true,
      );
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  /// This layout only suitable for the small Categories items
  @override
  Future getCategoryWithCache() async {
    List<Category> getSubCategories(id) {
      return categories.where((o) => o.parent == id).toList();
    }

    bool hasChildren(id) {
      return categories.where((o) => o.parent == id).toList().isNotEmpty;
    }

    List<Category> getParentCategory() {
      return categories.where((item) => item.parent == '0').toList();
    }

    var categoryIds = <String>[];
    var parentCategories = getParentCategory();
    for (var item in parentCategories) {
      if (hasChildren(item.id)) {
        var subCategories = getSubCategories(item.id);
        for (var item in subCategories) {
          categoryIds.add(item.id.toString());
        }
      } else {
        categoryIds.add(item.id.toString());
      }
    }

    return await getCategoryCache(categoryIds);
  }

  Future<Map<String, dynamic>> getCategoryCache(categoryIds) async {
    try {
      final data = await wcConnector.getAsync(
        'flutter/category/cache?categoryIds=${List<String>.from(categoryIds).join(",")}',
      );
      if (data != null) {
        for (var i = 0; i < categoryIds.length; i++) {
          var productsJson = data['${categoryIds[i]}'] as List?;
          var list = <Product>[];
          if (productsJson != null && productsJson.isNotEmpty) {
            for (var item in productsJson) {
              var product = Product.jsonParser(item);
              product.categoryId = categoryIds[i];
              list.add(product);
            }
          }
          categoryCache['${categoryIds[i]}'] = list;
        }
      }

      return categoryCache;
    } catch (e, trace) {
      printLog(trace.toString());
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<List<Tag>> getFilterTags() async {
    try {
      var list = <Tag>[];
      var url = 'products/tags';

      url = buildUrlByLang(url);

      var response = await wcConnector.getAsync(url);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        for (var item in response) {
          list.add(Tag.fromJson(item));
        }
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> getCheckoutUrl(
    Map<String, dynamic> params,
    String? lang,
  ) async {
    try {
      var str = convert.jsonEncode(params);
      var bytes = convert.utf8.encode(str);
      var base64Str = convert.base64.encode(bytes);

      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_user/checkout'.toUri()!,
        body: convert.jsonEncode({'order': base64Str}),
        headers: {'Content-Type': 'application/json'},
      );
      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (response.statusCode == 200 && body is String) {
        var endpoint =
            '$domain/mstore-checkout?code=$body&mobile=true&source_type=utm&utm_source=Mobile%20App&utm_medium=Webview%20Checkout&utm_source_platform=$operatingSystem';
        if (kPaymentConfig.enableWebviewCheckout ||
            kPaymentConfig.enableNativeCheckout ||
            kPaymentConfig.guestCheckout ||
            params['token'] == null) {
          final checkoutPageSlug = Map<String, dynamic>.from(
            kPaymentConfig.checkoutPageSlug,
          );
          String? slug = lang != null ? checkoutPageSlug[lang] : null;
          slug ??= checkoutPageSlug.values.toList().first;
          slug ??= 'checkout';
          slug = slug.contains('?') ? '$slug&' : '$slug?';
          endpoint =
              '$domain/${slug}code=$body&mobile=true&source_type=utm&utm_source=Mobile%20App&utm_medium=Webview%20Checkout&utm_source_platform=$operatingSystem';
        }
        if (UniversalPlatform.isWeb) {
          endpoint += '&platform=web';
        }
        if (kBranchConfig.enable) {
          endpoint = Uri.parse(endpoint).withCurrentBranch().toString();
        }
        printLog('[Checkout URL] $endpoint');
        return endpoint;
      } else {
        var message = body['message'];
        throw Exception(message ?? S.current.canNotSaveOrder);
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<String> submitForgotPassword({
    String? forgotPwLink,
    Map<String, dynamic>? data,
  }) async {
    try {
      var endpoint = '$domain/wp-json/api/flutter_user/reset-password';
      endpoint = buildUrlByLang(endpoint);

      var response = await wcConnector.httpPost(
        endpoint.toUri()!,
        body: convert.jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );
      var result = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return '';
      } else {
        return result['message'];
      }
    } catch (e) {
      printLog(e);
      return 'Unknown Error: $e';
    }
  }

  @override
  Future<Map<String, dynamic>?> getCurrencyRate() async {
    try {
      final url = kCurrencyConfig.enableWOOCSCurrencySwitcher
          ? '$domain/wp-json/woocs/v3/currency'
          : '$domain/wp-json/api/flutter_user/get_currency_rates';
      final response = await wcConnector.httpGet(url.toUri()!);
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body != null && body is Map) {
        var data = Map<String, dynamic>.from(body);
        var currency = <String, dynamic>{};
        for (var key in data.keys) {
          currency[key.toUpperCase()] =
              num.tryParse(
                "${data[key]['rate'] == 0 ? 1 : data[key]['rate']}",
              )?.toDouble() ??
              1.0;
        }
        return currency;
      } else {
        return null;
      }
    } catch (err) {
      return null;
    }
  }

  @override
  Future getCountries() async {
    try {
      var url = '$domain/wp-json/api/flutter_user/get_countries';
      url = buildUrlByLang(url);
      final response = await wcConnector.httpCache(url.toUri()!);
      var body = convert.jsonDecode(response.body);
      return body;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future getStatesByCountryId(countryId) async {
    try {
      var url =
          '$domain/wp-json/api/flutter_user/get_states?country_code=$countryId';
      url = buildUrlByLang(url);
      final response = await wcConnector.httpGet(url.toUri()!);
      var body = convert.jsonDecode(response.body);
      return body;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<dynamic>?>? getCartInfo(String? token) async {
    try {
      var base64Str = EncodeUtils.encodeCookie(token!);
      final response = await wcConnector.httpGet(
        '$domain/wp-json/api/flutter_woo/cart?token=$base64Str'.toUri()!,
      );
      final body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (response.statusCode == 200) {
        return body;
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future syncCartToWebsite(CartModel cartModel, User? user) async {
    try {
      final params = Order().toJson(cartModel, user?.id, false);

      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_woo/cart'.toUri()!,
        body: convert.jsonEncode(params),
        headers: {
          'Content-Type': 'application/json',
          'User-Cookie': EncodeUtils.encodeCookie(user?.cookie ?? ''),
        },
      );
      final body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (response.statusCode == 200) {
        return body;
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getCustomerInfo(String? id) async {
    try {
      final response = await wcConnector.getAsync('customers/$id');
      if (response['message'] != null) {
        throw Exception(response['message']);
      }
      if (response['billing'] != null) {
        final address = Address.fromJson(response);
        final rawBilling = Address.fromJson(response['billing']);
        final billing = rawBilling.copyWith(
          firstName: rawBilling.firstName?.isEmptyOrNull ?? true
              ? address.firstName
              : rawBilling.firstName,
          lastName: rawBilling.lastName?.isEmptyOrNull ?? true
              ? address.lastName
              : rawBilling.lastName,
          email: rawBilling.email?.isEmptyOrNull ?? true
              ? address.email
              : rawBilling.email,
          country: rawBilling.country?.isEmptyOrNull ?? true
              ? kPaymentConfig.defaultCountryISOCode
              : rawBilling.country,
          state: rawBilling.state?.isEmptyOrNull ?? true
              ? kPaymentConfig.defaultStateISOCode
              : rawBilling.state,
        );
        response['billing'] = billing;
      }
      return response;
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<CartTax?> getTaxes(CartModel cartModel, String? token) async {
    try {
      if (isBookingProduct(cartModel)) return null;
      final params = Order().toJson(cartModel, cartModel.user?.id, false);

      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_woo/taxes'.toUri()!,
        body: convert.jsonEncode(params),
        headers: {'Content-Type': 'application/json'},
      );
      final body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (response.statusCode == 200) {
        var taxes = <Tax>[];
        body['items'].forEach((item) {
          taxes.add(Tax.fromJson(item));
        });
        return CartTax(
          items: taxes,
          total: double.parse("${body['taxes_total']}"),
          isIncludingTax: body['is_including_tax'],
        );
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Fee>>? getFees(CartModel cartModel, String? token) async {
    try {
      final params = Order().toJson(cartModel, cartModel.user?.id, false);

      final response = await httpPost(
        '$domain/wp-json/api/flutter_woo/fees'.toUri()!,
        body: convert.jsonEncode(params),
        headers: {'Content-Type': 'application/json'},
      );
      final body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (response.statusCode == 200 && body is List) {
        var fees = <Fee>[];
        for (var item in body) {
          fees.add(Fee.fromJson(item));
        }
        return fees;
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return [];
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Tag>> getTagsByPage({
    int? page,
    required int limit,
    String? categoryIds,
    String? brandIds,
    List<String>? includeIds,
  }) async {
    try {
      var url = 'products/tags?per_page=$limit&page=$page';
      url = buildUrlByLang(url);
      if (isNotBlank(categoryIds)) {
        url += '&category=$categoryIds';
      }
      if (isNotBlank(brandIds)) {
        url += '&brand=$brandIds';
      }
      if (includeIds != null && includeIds.isNotEmpty) {
        url += '&include=${includeIds.join(",")}';
      } else {
        url += '&hide_empty=${kAdvanceConfig.hideEmptyTags}';
      }

      var response = await wcConnector.getAsync(url);

      final listTags = Tag.parseTagList(response);
      return PagingResponse(data: listTags);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<Tag?> getTagById({required tagId}) async {
    try {
      var url = 'products/tags/$tagId';
      var response = await wcConnector.getAsync(url);
      if (response is Map) {
        if (isNotBlank(response['message'])) {
          throw Exception(response['message']);
        }

        return Tag.fromJson(response);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
    return null;
  }

  @override
  Future<Tag?> getTagBySlug(String slug) async {
    try {
      var url = 'products/tags?slug=$slug';
      var response = await wcConnector.getAsync(url);
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        final tagItem = List.from(response).firstOrNull;
        if (tagItem == null) throw S.current.tagNotExist;
        return Tag.fromJson(tagItem);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
    return null;
  }

  @override
  Future<bool> pushNotification(
    cookie, {
    receiverEmail,
    senderName,
    message,
  }) async {
    try {
      var base64Str = EncodeUtils.encodeCookie(cookie);
      final endpoint = '$domain/wp-json/api/flutter_user/notification';
      final res = await wcConnector.httpPost(
        endpoint.toUri()!,
        body: {
          'token': base64Str,
          'receiver': receiverEmail,
          'sender': senderName,
          'message': message,
        },
      );
      if (res.statusCode == 200) {
        return true;
      } else {
        throw Exception(res.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Order>> getVendorOrders({
    required User user,
    dynamic cursor = 1,
  }) async {
    var list = <Order>[];
    try {
      var base64Str = EncodeUtils.encodeCookie(user.cookie!);
      final response = await wcConnector.httpGet(
        '$domain/wp-json/wc/v2/flutter/vendor-orders?page=$cursor&per_page=25&token=$base64Str'
            .toUri()!,
      );
      printLog(
        '$domain/wp-json/wc/v2/flutter/vendor-orders?page=$cursor&token=$base64Str'
            .toUri(),
      );
      var body = convert.jsonDecode(response.body);
      if (body is Map && isNotBlank(body['message'])) {
        throw Exception(body['message']);
      } else if (body is List) {
        for (var item in body) {
          list.add(Order.fromJson(item));
        }
        return PagingResponse(data: list);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }

    return PagingResponse(data: list);
  }

  @override
  Future<Product> createProduct(
    String? cookie,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_multi_vendor/product'.toUri()!,
        body: convert.jsonEncode(data),
        headers: {
          'User-Cookie': EncodeUtils.encodeCookie(cookie ?? ''),
          'Content-Type': 'application/json',
        },
      );
      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body['message'] == null) {
        return Product.jsonParser(body);
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getOwnProducts(
    String? cookie, {
    int? page,
    int? perPage,
  }) async {
    var list = <Product>[];
    try {
      var endPoint = '$domain/wp-json/api/flutter_multi_vendor/products/owner';

      endPoint = endPoint.addUrlQuery(
        'is_all_data=${kAdvanceConfig.enableIsAllData == true}',
      );

      endPoint = buildUrlToGetProducts(endPoint);
      final response = await wcConnector.httpPost(
        endPoint.toUri()!,
        body: convert.jsonEncode({'cookie': cookie, 'page': page}),
        headers: {
          'User-Cookie': EncodeUtils.encodeCookie(cookie ?? ''),
          'Content-Type': 'application/json',
        },
      );
      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body is Map && isNotBlank(body['message'])) {
        throw Exception(body['message']);
      } else if (body is List) {
        for (var item in body) {
          list.add(Product.jsonParser(item));
        }
        return list;
      }
    } catch (e) {
      printError(e);
    }

    return list;
  }

  @override
  Future<dynamic> uploadImage(dynamic data, String? token) async {
    try {
      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_multi_vendor/media'.toUri()!,
        body: convert.jsonEncode(data),
        headers: {
          'User-Cookie': EncodeUtils.encodeCookie(token ?? ''),
          'Content-Type': 'application/json',
        },
      );
      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body['message'] == null) {
        return body;
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Point?> getMyPoint(String? token) async {
    try {
      var base64Str = EncodeUtils.encodeCookie(token!);
      final response = await wcConnector.httpGet(
        '$domain/wp-json/api/flutter_woo/points?token=$base64Str'.toUri()!,
      );
      final body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (response.statusCode == 200) {
        return Point.fromJson(body);
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future updatePoints(String? token, Order? order) async {
    try {
      final response = await wcConnector.httpPatch(
        '$domain/wp-json/api/flutter_woo/points'.toUri()!,
        body: convert.jsonEncode({'cookie': token, 'order_id': order!.id}),
      );
      final body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (response.statusCode == 200) {
        return body;
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<({BookStatus status, String? messageError})>? bookService({
    userId,
    value,
    message,
  }) => null;

  @override
  Future<List<Product>> getProductNearest(location) async {
    try {
      var list = <Product>[];
      var lat = location.latitude;
      var long = location.longitude;
      var urlReq =
          '$domain/wp-json/wp/v2/${DataMapping().kProductPath}?status=publish&_embed=true';
      if (lat != 0 || long != 0) {
        urlReq += '&isGetLocate=true&lat=$lat&long=$long';
      }
      final response = await wcConnector.httpGet(urlReq.toUri()!);
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)) {
          var product = Product.fromListingJson(item);
          var gallery = <String>[];
          for (var item in product.images) {
            if (item.isURL == false) {
              var res = await wcConnector.httpGet(
                '$domain/wp-json/wp/v2/media/$item'.toUri()!,
              );
              gallery.add(convert.jsonDecode(res.body)['source_url']);
            } else {
              gallery.add(item);
            }
          }
          product.images = gallery;
          list.add(product);
        }
      }
      printLog('getProductNearest');
      return list;
    } catch (err) {
      printLog('err at getProduct Recents func ${err.toString()}');
      rethrow;
    }
  }

  @override
  Future<List<ListingBooking>> getBooking({userId, page, perPage}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> createBooking(dynamic bookingInfo) async {
    if (bookingInfo.isAvaliableOrder && bookingInfo.isEmpty == false) {
      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_booking/checkout'.toUri()!,
        body: convert.jsonEncode(bookingInfo.toJsonAPI()),
        headers: {'Content-Type': 'application/json'},
      );

      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (response.statusCode == 200 && body['appointment'] != null) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  @override
  Future<List<StaffBookingModel>> getListStaff(String? idProduct) async {
    final urlAPI = wcConnector.getOAuthURLExternal(
      '$domain/wp-json/api/flutter_booking/get_staffs?product_id=$idProduct',
    );

    final response = await wcConnector.httpGet(
      urlAPI.toUri()!,
      refreshCache: true,
    );

    var body = convert.jsonDecode(response.body);
    if (response.statusCode == 200) {
      final listStaff = <StaffBookingModel>[];
      if (body is List) {
        if (body.isNotEmpty) {
          for (var staff in body) {
            if (staff['id'] != null) {
              listStaff.add(StaffBookingModel.fromJson(staff));
            }
          }
        }
      }
      return listStaff;
    } else {
      return [];
    }
  }

  @override
  Future<List<String>> getSlotBooking(
    String? idProduct,
    String idStaff,
    String date,
  ) async {
    var urlAPI =
        '$domain/wp-json/api/flutter_booking/get_slots?product_id=$idProduct&date=$date';

    if ((idStaff.isNotEmpty) && idStaff != 'null') {
      urlAPI += '&staff_ids=$idStaff';
    }

    final response = await wcConnector.httpGet(urlAPI.toUri()!);
    if (response.body.isNotEmpty) {
      final listSlot = <String>[];
      final result = convert.jsonDecode(response.body);
      if (result is List) {
        for (var item in result) {
          if (item?.isNotEmpty ?? false) {
            listSlot.add('$item');
          }
        }
      }
      return listSlot;
    }
    return <String>[];
  }

  @override
  Future<Map<String, dynamic>>? checkBookingAvailability({data}) => null;

  @override
  Future<List<dynamic>>? getLocations() => null;

  @override
  Future<Product?> getProductByPermalink(String productPermalink) async {
    try {
      // Process the language code in the permalink
      // Full URL case: https://domain.com/en/product/product-slug/
      // Full URL without lang: https://domain.com/product/product-slug/
      // Path only case: /en/product/product-slug or /product/product-slug
      // Use regex to separate the language code and the product slug.
      // Accept both with and without trailing slash.
      final uri = Uri.tryParse(productPermalink);
      final path = uri?.path ?? productPermalink;
      final match = RegExp(r'^(?:/([a-z]{2}))?/.*/([^/]+)/?$').firstMatch(path);
      var languageCode = '';
      var productSlug = '';

      if (match == null) {
        throw Exception('Invalid URL: $productPermalink');
      }

      languageCode = match.group(1) ?? languageCode;
      productSlug = match.group(2) ?? productSlug;

      if (productSlug.isEmpty) {
        throw Exception('Invalid URL: $productPermalink');
      }

      var endpoint = 'products?slug=$productSlug';

      if (languageCode.isNotEmpty) {
        endpoint = endpoint.addUrlQuery('lang=$languageCode');
      }

      final response = await wcConnector.getAsync(endpoint);

      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else {
        final product = List.from(response).firstOrNull;
        if (product == null) throw Exception('Product not found');
        return Product.jsonParser(product);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<Category?> getProductCategoryByPermalink(
    String productCategoryPermalink,
  ) async {
    try {
      final response = await wcConnector.httpGet(
        '$domain/wp-json/api/flutter_woo/product-category/dynamic?url=$productCategoryPermalink'
            .toUri()!,
      );

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Category.fromJson(body[0]);
      } else if (body['message'] != null) {
        throw Exception(body['message']);
      }
      return null;
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<List<Brand>?> getBrands({
    int page = 1,
    int perPage = 10,
    List<String>? categoryIds,
    List<String>? includeIds,
  }) async {
    var list = <Brand>[];
    try {
      var endpoint = 'products/brands?per_page=$perPage&page=$page';
      endpoint = buildUrlByLang(endpoint);
      if (categoryIds != null) {
        endpoint = endpoint.addUrlQuery('category=${categoryIds.join(',')}');
      }
      if (includeIds != null) {
        endpoint = endpoint.addUrlQuery('include=${includeIds.join(',')}');
      } else {
        endpoint = endpoint.addUrlQuery('hide_empty=true');
      }
      var response = await wcConnector.getAsync(endpoint);
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        for (var item in response) {
          list.add(Brand.fromJson(item));
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
    return list;
  }

  @override
  Future<List<Product>?> fetchProductsByBrand({page, brandId}) async {
    var list = <Product>[];
    try {
      var endpoint = 'products?brand=$brandId&page=$page&per_page=10';
      endpoint = buildUrlByLang(endpoint);
      endpoint = buildUrlToGetProducts(endpoint);
      var response = await wcConnector.getAsync(endpoint);
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        for (var item in response) {
          final product = Product.jsonParser(item);

          /// hideOutOfStock product
          if ((kAdvanceConfig.hideOutOfStock) && !(product.inStock ?? false)) {
            continue;
          }

          list.add(product);
        }
        return list;
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
    return list;
  }

  @override
  Future<List<OrderDeliveryDate>> getListDeliveryDates({storeId}) async {
    var list = <OrderDeliveryDate>[];
    try {
      var endpoint = '$domain/wp-json/api/flutter_woo/ddates';
      if (storeId != null) {
        endpoint += '?id=$storeId';
      }
      var response = await wcConnector.httpGet(endpoint.toUri()!);
      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        for (var item in result) {
          list.add(OrderDeliveryDate.fromJson(item));
        }
      }
    } catch (e, trace) {
      printLog(e);
      printLog(trace);
    }
    return list;
  }

  @override
  Future<bool> isUserExisted({String? phone, String? username}) async {
    try {
      var endpoint = '$domain/wp-json/api/flutter_user/check-user?';
      if (phone != null) {
        final mobile = phone.replaceAll('+', '').replaceAll(' ', '');
        endpoint += '&phone=$mobile';
      }
      if (username != null) {
        endpoint += '&username=$username';
      }
      final response = await wcConnector.httpGet(
        endpoint.toUri()!,
        refreshCache: true,
      );
      if (response.statusCode == 200) {
        /// Need to trim. It returns "									true" for some reason 😂.
        return response.body.trim() == 'true';
      }
    } catch (e) {
      printLog('isPhoneNumberExisted $e');
    }
    return false;
  }

  @override
  Future<Category?> getProductCategoryById({required categoryId}) async {
    try {
      var url = 'products/categories/$categoryId';
      var response = await wcConnector.getAsync(url);
      if (response is Map) {
        if (isNotBlank(response['message'])) {
          throw Exception(response['message']);
        }
        return Category.fromJson(response);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
    return null;
  }

  @override
  Future<String?> generateProductCategoryUrl(dynamic productCategoryId) async {
    final categoryId = productCategoryId?.toString();
    if (categoryId == null || categoryId.isEmpty) {
      return null;
    }

    final cate = await getProductCategoryById(categoryId: categoryId);
    if (cate == null) {
      return null;
    }

    return '${ServerConfig().url}/product-category/${cate.slug}';
  }

  @override
  Future<String?> generateProductTagUrl(dynamic productTagId) async {
    final tagId = productTagId?.toString();
    if (tagId == null || tagId.isEmpty) {
      return null;
    }

    final tag = await getTagById(tagId: tagId);
    if (tag == null) {
      return null;
    }

    return '${ServerConfig().url}/product-tag/${tag.slug}';
  }

  @override
  Future<Brand?> getBrandById(brandId) async {
    try {
      var url = 'products/brands/$brandId';
      var response = await wcConnector.getAsync(url);
      if (response is Map) {
        if (isNotBlank(response['message'])) {
          throw Exception(response['message']);
        }
        return Brand.fromJson(response);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
    return null;
  }

  @override
  Future<String?> generateProductBrandUrl(dynamic brandCategoryId) async {
    final brandId = brandCategoryId?.toString();
    if (brandId == null || brandId.isEmpty) {
      return null;
    }

    final brand = await getBrandById(brandId);
    if (brand == null) {
      return null;
    }

    return '${ServerConfig().url}/brand/${brand.slug ?? ''}';
  }

  @override
  Future<Brand?> getBrandBySlug(String slug) async {
    try {
      var url = 'products/brands?slug=$slug';
      var response = await wcConnector.getAsync(url);
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        final brandItem = List.from(response).firstOrNull;
        if (brandItem == null) throw 'This brand does not exist';
        return Brand.fromJson(brandItem);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
    return null;
  }

  @override
  Future<void> deleteProduct({
    required String? productId,
    required String? cookie,
  }) async {
    try {
      final response = await wcConnector.httpDelete(
        '$domain/wp-json/api/flutter_multi_vendor/product/$productId'.toUri()!,
        headers: {
          'User-Cookie': EncodeUtils.encodeCookie(cookie ?? ''),
          'Content-Type': 'application/json',
        },
        enableDio: true,
      );
      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body['message'] == null) {
        return;
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic>? getDataFromScanner(String data, {String? cookie}) async {
    try {
      var endpoint = '$domain/wp-json/api/flutter_woo/scanner?data=$data';
      if (cookie != null) {
        var base64Str = EncodeUtils.encodeCookie(cookie);
        endpoint += '&token=$base64Str';
      }
      final response = await wcConnector.httpGet(
        endpoint.toUri()!,
        enableDio: true,
      );
      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body['code'] == null) {
        if (body['type'] == 'product') {
          return Product.jsonParser(body['data'].first);
        }
        if (body['type'] == 'shop_order') {
          return Order.fromJson(body['data'].first);
        }
        return null;
      } else {
        throw body['code'];
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Category>> getSubCategories({
    dynamic page = 1,
    int limit = 25,
    required String? parentId,
  }) async {
    try {
      var url =
          'products/categories?parent=${parentId ?? _rootCategoryId}&per_page=$limit&page=$page&hide_empty=${kAdvanceConfig.hideEmptyCategories}';

      if (kExcludedCategoryIDs?.isNotEmpty ?? false) {
        url = url.addUrlQuery('exclude=$kExcludedCategoryIDs');
      }
      url = buildUrlByLang(url);
      var response = await wcConnector.getAsync(url);
      return PagingResponse<Category>(
        data: Category.parseCategoryList(response),
      );
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<bool> checkProductPermission(String productId, String? cookie) async {
    try {
      var endpoint =
          '$domain/wp-json/api/flutter_woo/products/$productId/check';
      if (cookie != null) {
        var base64Str = EncodeUtils.encodeCookie(cookie);
        endpoint += '?token=$base64Str';
      }
      final response = await wcConnector.httpGet(
        endpoint.toUri()!,
        enableDio: true,
      );
      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body is Map && isNotBlank(body['code'])) {
        throw body['code'];
      }
      if (body is Map && isNotBlank(body['message'])) {
        throw body['message'];
      }
      return body == true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> deleteAccount(String token) async {
    try {
      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_customer/delete_account'.toUri()!,
        headers: {
          'User-Cookie': EncodeUtils.encodeCookie(token),
          'X-HTTP-Method-Override': 'DELETE', //fix 403 error on some website
          'Content-Type': 'application/json',
        },
      );
      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body is Map && body['message'] != null) {
        if (body['code'] == 'invalid_account') {
          throw Exception(S.current.cannotDeleteAccount);
        }
        throw body['message'];
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<PagingResponse<Product>> getProductsByCategoryId(
    String categoryId, {
    dynamic page = 1,
    int limit = 25,
    String? orderBy,
    String? order,
  }) async {
    var list = <Product>[];
    try {
      var url =
          'products?category=$categoryId&per_page=$limit&page=$page&status=publish';
      url = buildUrlByLang(url);

      if (orderBy != null) {
        url += '&orderby=$orderBy';
      }
      if (order != null) {
        url += '&order=$order';
      }
      final response = await wcConnector.getAsync(url, version: 3);
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        var products = productsFromJsonData(response);
        if (products != null) {
          list.addAll(products);
        }
        return PagingResponse(data: list);
      }
    } catch (err, trace) {
      printError(err, trace);
    }
    return PagingResponse(data: list);
  }

  @override
  Future<Order>? createIAPOrder(Map<String, dynamic> params, User? user) async {
    try {
      final response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_order/create'.toUri()!,
        body: convert.jsonEncode(params),
        headers: {
          'User-Cookie': EncodeUtils.encodeCookie(
            user != null ? user.cookie! : '',
          ),
          'Content-Type': 'application/json',
        },
      );
      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 201 && body['message'] == null) {
        return Order.fromJson(body);
      } else {
        throw Exception(body['message']);
      }
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<RatingCount?>? getProductRatingCount(String productId) async {
    try {
      final response = await wcConnector.httpGet(
        '${wcConnector.url}/wp-json/api/flutter_woo/products/$productId/rating_counts'
            .toUri()!,
      );

      var json = jsonDecode(response.body);

      if (json is Map && isNotBlank(json['message'])) {
        throw Exception(json['message']);
      } else {
        return RatingCount.fromJson(json);
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<PagingResponse<Review>> getListReviewByUserEmail(
    String email, {
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    try {
      var endpoint =
          'products/reviews?per_page=$perPage&page=$page&reviewer_email=$email';
      if (status != null) {
        endpoint += '&status=$status';
      }
      var response = await wcConnector.getAsync(endpoint, version: 3);
      var list = <Review>[];
      if (response is Map && isNotBlank(response['message'])) {
        throw Exception(response['message']);
      } else if (response is List) {
        for (var item in response) {
          list.add(Review.fromJson(item));
        }
        return PagingResponse(data: list, cursor: page);
      }

      return PagingResponse(data: list, cursor: page);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://support.inspireui.com/help-center/
      rethrow;
    }
  }

  @override
  Future<List<Product>> getVideoProducts({
    required int page,
    int perPage = 10,
    String lang = '',
  }) async {
    var list = <Product>[];
    try {
      var endPoint =
          '$domain/wp-json/api/flutter_woo/products/video?per_page=$perPage&page=$page';
      endPoint = buildUrlByLang(endPoint);
      endPoint = buildUrlToGetProducts(endPoint);
      final response = await wcConnector.httpGet(endPoint.toUri()!);
      final body = convert.jsonDecode(response.body);
      if (body is Map && isNotBlank(body['message'])) {
        throw Exception(body['message']);
      } else if (body is List) {
        for (var item in body) {
          list.add(Product.jsonParser(item));
        }
        return list;
      }
    } catch (e) {
      rethrow;
    }
    return list;
  }

  @override
  Future<String?> createPaymentIntentStripe({
    required String totalPrice,
    String? currencyCode,
    String? emailAddress,
    String? name,
    required String paymentMethodId,
  }) async {
    if (isNotEmpty(kStripeConfig['serverEndpoint'])) {
      return super.createPaymentIntentStripe(
        totalPrice: totalPrice,
        currencyCode: currencyCode,
        emailAddress: emailAddress,
        name: name,
        paymentMethodId: paymentMethodId,
      );
    }
    try {
      final urlReq = '$domain/wp-json/api/flutter_stripe/payment_intent';
      final result = await wcConnector.httpPost(
        urlReq.toUri()!,
        body: jsonEncode({
          'payment_method_id': paymentMethodId,
          'email': emailAddress,
          'amount': totalPrice,
          'currencyCode': currencyCode,
          'returnUrl': kStripeConfig['returnUrl'],
          'captureMethod': (kStripeConfig['enableManualCapture'] ?? false)
              ? 'manual'
              : 'automatic',
        }),
        headers: {'content-type': 'application/json'},
      );

      var response = json.decode(result.body);
      if (response['message'] != null) {
        throw Exception(response['message']);
      }
      if (result.statusCode == 200) {
        return response['client_secret'];
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  @override
  Future<StripePaymentIntent?> createPaymentIntentStripeV3({
    String? orderId,
    required String totalPrice,
    String? currencyCode,
    String? emailAddress,
    String? name,
    String? cookie,
    bool? isSplitPayment,
  }) async {
    if (isNotEmpty(kStripeConfig['serverEndpoint'])) {
      return super.createPaymentIntentStripeV3(
        orderId: orderId,
        totalPrice: totalPrice,
        currencyCode: currencyCode,
        emailAddress: emailAddress,
        name: name,
        cookie: cookie,
        isSplitPayment: isSplitPayment,
      );
    }
    try {
      final urlReq = '$domain/wp-json/api/flutter_stripe/payment_intent';
      final result = await wcConnector.httpPost(
        urlReq.toUri()!,
        body: jsonEncode({
          'email': emailAddress,
          'amount': totalPrice,
          'currencyCode': currencyCode,
          'returnUrl': kStripeConfig['returnUrl'],
          'captureMethod': (kStripeConfig['enableManualCapture'] ?? false)
              ? 'manual'
              : 'automatic',
          'request3dSecure': 'any',
          'saveCardAfterCheckout':
              kStripeConfig['saveCardAfterCheckout'] ?? false,
          'orderId': orderId,
          'isSplitPayment': ?isSplitPayment,
        }),
        headers: {'content-type': 'application/json'},
      );

      var response = json.decode(result.body);
      if (response['message'] != null) {
        throw Exception(response['message']);
      }
      if (result.statusCode == 200) {
        // The following fields may be missing from the response and are optional.
        // If split payment is enabled, validate their existence or document as optional.
        return StripePaymentIntent(
          id: response['id'],
          clientSecret: response['client_secret'],
          customerId: response['customer_id'],
          customerEphemeralKeySecret: response.containsKey('ephemeral_key')
              ? response['ephemeral_key']
              : null,
          setupIntentClientSecret: response.containsKey('setup_intent')
              ? response['setup_intent']
              : null,
        );
      }

      throw Exception('Unknown error. Please try again.');
    } catch (e, trace) {
      printError(e, trace);
      rethrow;
    }
  }

  @override
  Future<StripePaymentIntent?> getPaymentIntentStripeV3(String id) async {
    if (isNotEmpty(kStripeConfig['serverEndpoint'])) {
      return super.getPaymentIntentStripeV3(id);
    }
    try {
      final urlReq = '$domain/wp-json/api/flutter_stripe/payment_intent/$id';
      final result = await wcConnector.httpGet(urlReq.toUri()!);

      var response = json.decode(result.body);
      if (result.statusCode == 200) {
        if (response['message'] != null) {
          throw Exception(response['message']);
        }
        return StripePaymentIntent(
          id: response['id'],
          clientSecret: response['client_secret'],
          status: response['status'],
        );
      }

      throw Exception('Unknown error. Please try again.');
    } catch (e, trace) {
      printError(e, trace);
      rethrow;
    }
  }

  @override
  Future<bool> enableNotification({
    String? cookie,
    required bool enabled,
  }) async {
    try {
      if (cookie == null) return enabled;

      final response = await wcConnector.httpPut(
        '$domain/wp-json/api/flutter_notification/settings'.toUri()!,
        body: convert.jsonEncode({'is_on': enabled}),
        headers: {
          'User-Cookie': EncodeUtils.encodeCookie(cookie),
          'Content-Type': 'application/json',
        },
      );

      var body = convert.jsonDecode(response.body);
      checkExpiredCookie(response);
      if (body['message'] != null) {
        throw Exception(body['message']);
      } else {
        return body['is_on'] == true;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Order?> getOrderByOrderId({required String orderId}) async {
    try {
      var url = 'orders/$orderId';
      var response = await wcConnector.getAsync(url);
      if (response is Map) {
        if (isNotBlank(response['message'])) {
          throw Exception(response['message']);
        }

        return Order.fromJson(Map.from(response));
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  @override
  Future<List<ProductComponent>?>? getProductComponents(
    String productId,
  ) async {
    var list = <ProductComponent>[];
    try {
      var endpoint =
          '$domain/wp-json/api/flutter_composite_products/product/$productId/components';
      var response = await wcConnector.httpGet(endpoint.toUri()!);
      if (response.statusCode == 200) {
        var result = convert.jsonDecode(response.body);
        for (var item in result) {
          list.add(ProductComponent.fromJson(item));
        }
      }
    } catch (e, trace) {
      printLog(e);
      printLog(trace);
    }
    return list;
  }

  @override
  List<Product>? productsFromJsonData(dynamic json) {
    try {
      var products = <Product>[];
      if (json is List) {
        for (var item in json) {
          Product? product;
          if (item is Product) {
            product = item;
          }
          if (item is Map) {
            /// ignore the hidden catalog
            if (item['catalog_visibility'] == 'hidden') {
              continue;
            }
            product = Product.jsonParser(item);
          }
          if (product == null) {
            continue;
          }
          if (kAdvanceConfig.hideOutOfStock &&
              !(product.inStock ?? false) &&
              !product.backordersAllowed) {
            continue;
          }
          products.add(product);
        }
      }
      if (products.isNotEmpty) {
        return products;
      }
      return null;
    } catch (e) {
      printLog(e);
      return null;
    }
  }

  @override
  Future<List<Branch>> getAllBranches() async {
    try {
      var response = await wcConnector.httpGet(
        Uri.parse('$domain/wp-json/wp/v2/branches'),
      );
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body is List) {
          var branches = <Branch>[];
          for (var item in body) {
            branches.add(Branch.fromJson(item));
          }
          return branches;
        }
      }
      return <Branch>[];
    } catch (e) {
      return <Branch>[];
    }
  }

  @override
  Future<(double?, double?)> getMinMaxPrices() async {
    try {
      var endPoint = '$domain/wp-json/api/flutter_woo/products/min-max-prices';
      final response = await wcConnector.httpCache(endPoint.toUri()!);
      var body = convert.jsonDecode(response.body);
      if (body is Map) {
        if (isNotBlank(body['message'])) {
          throw Exception(body['message']);
        }

        final minPrice = body['min_price'] != null
            ? double.tryParse('${body['min_price']}')
            : null;
        final maxPrice = body['max_price'] != null
            ? double.tryParse('${body['max_price']}')
            : null;
        return (minPrice, maxPrice);
      }
    } catch (e, trace) {
      printError(e, trace);
    }
    return (null, null);
  }

  @override
  Future<String?> getSizeGuide(String productId) async {
    try {
      var endPoint =
          '$domain/wp-json/api/flutter_woo/products/size-guide/$productId';
      final response = await wcConnector.httpGet(endPoint.toUri()!);

      final body = convert.jsonDecode(response.body);
      if (body is Map) {
        if (isNotBlank(body['message'])) {
          throw Exception(body['message']);
        }
        if (response.statusCode == 200) {
          return body['data'];
        }
      }
    } catch (e, trace) {
      printError(e, trace);
    }
    return null;
  }

  @override
  Future<PagingResponse<PurchasedProduct>> getListPurchasedProduct({
    required String userCookie,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      if (userCookie.isEmpty) {
        return const PagingResponse(data: []);
      }
      var endPoint =
          '$domain/wp-json/api/flutter_review/products?per_page=$perPage&page=$page&dummy=${DateTime.now().millisecondsSinceEpoch}';
      final response = await wcConnector.httpGet(
        endPoint.toUri()!,
        headers: {
          'User-Cookie': userCookie,
          'Content-Type': 'application/json',
        },
      );

      var body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        var list = <PurchasedProduct>[];
        for (var item in body) {
          list.add(PurchasedProduct.fromJson(item));
        }
        return PagingResponse(data: list);
      }
    } catch (e, trace) {
      printError(e, trace);
    }
    return const PagingResponse(data: []);
  }

  @override
  Future smartCodUpdateOrderSuccess(String orderId) async {
    try {
      var response = await wcConnector.httpPost(
        '$domain/wp-json/api/flutter_smart_cod/order_success'.toUri()!,
        body: convert.jsonEncode({'order_id': orderId}),
        headers: {'content-type': 'application/json'},
      );

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return;
      } else if (body['message'] != null) {
        throw body['message'];
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
