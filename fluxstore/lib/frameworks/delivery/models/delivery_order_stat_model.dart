import 'package:flutter/cupertino.dart';

import '../../../dependency_injection/dependency_injection.dart';
import '../../../models/entities/delivery_stat.dart';
import '../services/delivery.dart';

enum DeliveryStatState { loading, loaded }

class DeliveryStatModel extends ChangeNotifier {
  /// Service
  final _services = injector<DeliveryService>();

  /// State
  var _state = DeliveryStatState.loading;

  /// Your Other Variables Go Here
  DeliveryStat _deliveryStat = DeliveryStat(delivered: 0, pending: 0, total: 0);
  final _user;

  DeliveryStat get deliveryStat => _deliveryStat;
  DeliveryStatState get state => _state;

  /// Constructor
  DeliveryStatModel(this._user) {
    getDeliverStat();
  }

  /// Update state
  void _updateState(state) {
    if (!hasListeners) return;
    _state = state;
    notifyListeners();
  }

  /// Your Defined Functions Go Here

  Future<void> getDeliverStat() async {
    _deliveryStat = await _services.getDeliveryStat(cookie: _user.cookie);
    _updateState(DeliveryStatState.loaded);
  }
}
