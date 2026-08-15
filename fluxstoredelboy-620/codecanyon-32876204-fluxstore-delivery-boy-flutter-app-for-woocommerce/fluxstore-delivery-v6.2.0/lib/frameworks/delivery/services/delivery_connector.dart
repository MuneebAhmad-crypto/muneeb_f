import '../../../services/offline_mode/network_aware/http_aware_mixin.dart';
import '../../../services/offline_mode/network_aware/network_aware_api_mixin.dart';
import 'delivery_api.dart';

class DeliveryConnector
    with NetworkAwareApiMixin, HttpAwareMixin
    implements DeliveryAPI {
  DeliveryConnector(String domain) : _deliveryApi = DeliveryAPI(url: domain);

  final DeliveryAPI _deliveryApi;

  @override
  String get keyCacheLocal => 'delivery-connector';

  @override
  String? get url => _deliveryApi.url;

  @override
  set url(String? url) {
    _deliveryApi.url = url;
  }
}
