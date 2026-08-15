import 'package:flutter/material.dart';
import 'package:flux_localization/flux_localization.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/index.dart'
    show Order, OrderStatus, PointModel, UserModel, OrderStatusExtension;
import '../../../models/order/bank_account_item.dart';
import '../../../services/index.dart';
import '../../../widgets/common/expansion_info.dart';
import '../../base_screen.dart';
import '../webview_checkout_screen.dart';
import 'price_row_item.dart';
import 'product_review.dart';
import 'whatsapp_order.dart';

class OrderedSuccess extends StatefulWidget {
  final Order order;
  final bool hasScroll;

  const OrderedSuccess({required this.order, this.hasScroll = true});

  @override
  BaseScreen<OrderedSuccess> createState() => _OrderedSuccessState();
}

class _OrderedSuccessState extends BaseScreen<OrderedSuccess> {
  Order? order;
  bool isLoading = false;

  ThemeData get theme => Theme.of(context);

  Color get secondaryColor => theme.colorScheme.secondary;
  String get paymentUrl => order?.paymentUrl ?? '';
  bool get showPaymentButton =>
      isLoading == false &&
      order?.status == OrderStatus.pending &&
      paymentUrl.isNotEmpty;

  Future<void> _getOrderByOrderId(String orderId) async {
    if (orderId == '0') return;

    setState(() {
      isLoading = true;
    });
    LoadingHelper.show();

    try {
      final orderDetail = await Services().api.getOrderByOrderId(
        orderId: orderId,
      );

      if (orderDetail != null) {
        order = orderDetail;
      }
    } catch (e, trace) {
      printError(e, trace);
    }

    _handlePoint();
    _updateSmartCodRfOrder();

    LoadingHelper.hide();
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _updateSmartCodRfOrder() {
    if (order?.smartCodIsRfOrder == true) {
      Services().api.smartCodUpdateOrderSuccess(order?.id ?? '');
    }
  }

  void _handlePoint() {
    final user = Provider.of<UserModel>(context, listen: false).user;
    if (user != null &&
        user.cookie != null &&
        kAdvanceConfig.enablePointReward) {
      Services().api.updatePoints(user.cookie, order);
      Provider.of<PointModel>(context, listen: false).getMyPoint(user.cookie);
    }
  }

  Future<void> _handlePayment() async {
    if (paymentUrl.isEmpty) {
      return;
    }

    final user = Provider.of<UserModel>(context, listen: false).user;
    var url = paymentUrl;
    if (user?.cookie != null) {
      url = url.addWooCookieToUrl(user!.cookie);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebviewCheckout(
          url: url,
          onFinish: (orderId) async {
            // Reload order to get updated status
            if (orderId != null) {
              await _getOrderByOrderId(orderId);
            } else if (order?.id != null) {
              await _getOrderByOrderId(order!.id!);
            } else {
              setState(() {});
            }
          },
          onClose: () {},
        ),
      ),
    );
  }

  Widget orderSummary() {
    final lineItems = order?.lineItems;
    final isWalletTopup =
        lineItems?.any((e) => e.name == 'Wallet Topup') ?? false;
    final subtotal = isWalletTopup
        ? 0.0
        : order?.subtotal ?? order?.calculateSubtotal ?? 0;

    return ExpansionInfo(
      title: S.of(context).orderDetail,
      expand: true,
      children: <Widget>[
        if (order?.bacsInfo.isNotEmpty ?? false) const SizedBox(height: 20),
        ...lineItems?.map((item) {
              return ProductReviewWidget(
                item: item,
                isWalletTopup: isWalletTopup,
                currency: order?.currencyCode,
              );
            }).toList() ??
            [],
        const SizedBox(height: 16),
        if (!isWalletTopup) ...[
          PriceRowItemWidget(
            title: S.of(context).subtotal,
            total: subtotal,
            style: theme.textTheme.bodyMedium!.copyWith(color: secondaryColor),
            isWalletTopup: isWalletTopup,
            currency: order?.currencyCode,
          ),
          if (order?.discountTotal case final discountTotal?)
            PriceRowItemWidget(
              title: S.of(context).discount,
              total: discountTotal,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.error,
              ),
              isWalletTopup: isWalletTopup,
              currency: order?.currencyCode,
              isDiscount: true,
            ),
          PriceRowItemWidget(
            title: S.of(context).totalTax,
            total: order?.totalTax,
            style: theme.textTheme.bodyMedium!.copyWith(color: secondaryColor),
            isWalletTopup: isWalletTopup,
            currency: order?.currencyCode,
          ),
          PriceRowItemWidget(
            title: S.of(context).shipping,
            total: order?.totalShipping,
            style: theme.textTheme.bodyMedium!.copyWith(color: secondaryColor),
            isWalletTopup: isWalletTopup,
            currency: order?.currencyCode,
          ),
          if (order?.feeLines.isNotEmpty ?? false)
            ...order!.feeLines.map(
              (e) => PriceRowItemWidget(
                title: e.name ?? '',
                total: double.parse(e.total ?? '0.0'),
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
                isWalletTopup: isWalletTopup,
                currency: order?.currencyCode,
              ),
            ),
        ],
        PriceRowItemWidget(
          title: S.of(context).total,
          total: order?.total,
          style: theme.textTheme.headlineSmall!.copyWith(
            color: secondaryColor,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
          isWalletTopup: isWalletTopup,
          currency: order?.currencyCode,
        ),
      ],
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    setState(() {
      order = widget.order;
    });

    if (order?.id != null) {
      // For WooCommerce
      _getOrderByOrderId(order!.id!);
    } else if (order?.number != null) {
      // For backward with other platforms
      _getOrderByOrderId(order!.number!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);
    final orderStatus =
        order?.status == OrderStatus.unknown && order?.orderStatus != null
        ? order!.orderStatus
        : order?.status?.displayTitle(context);

    final body = ListView(
      physics: widget.hasScroll ? null : const NeverScrollableScrollPhysics(),
      shrinkWrap: widget.hasScroll == false,
      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 200),
      children: <Widget>[
        if ((order?.number != null || order?.id != null) ||
            (orderStatus != null && isLoading == false))
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: theme.primaryColorLight),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: <Widget>[
                  if (order?.number != null || order?.id != null)
                    Row(
                      children: <Widget>[
                        Text(
                          S.of(context).orderNo,
                          style: TextStyle(fontSize: 16, color: secondaryColor),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '#${order!.number ?? order!.id}',
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (orderStatus != null && isLoading == false)
                    Text(
                      orderStatus,
                      style: TextStyle(fontSize: 14, color: secondaryColor),
                    ),
                ],
              ),
            ),
          ),

        /// Thai PromptPay
        /// true: show Thank you message like on the web - https://tppr.me/xrNh1
        Services().thaiPromptPayBuilder(showThankMsg: true, order: order),
        const SizedBox(height: 15),

        if (order?.bacsInfo.isNotEmpty ?? false) ...[
          Text(
            S.of(context).ourBankDetails,
            style: TextStyle(fontSize: 18, color: secondaryColor),
          ),
          ...?order?.bacsInfo.map((e) => BankAccountInfo(bankInfo: e)),
          const SizedBox(height: 15),
        ],

        if (kPaymentConfig.enableOrderDetailSuccessful &&
            order != null &&
            order!.lineItems.isNotEmpty) ...[
          orderSummary(),
          const SizedBox(height: 16),
        ],
        if (!showPaymentButton) ...[
          Text(
            S.of(context).orderSuccessTitle1,
            style: TextStyle(fontSize: 18, color: secondaryColor),
          ),
          const SizedBox(height: 15),
        ],
        if (kWhatsAppOrderConfig
            .getValueList('paymentMethodIds')
            .contains(order?.paymentMethod))
          WhatsappOrder(order: order),
        if (!showPaymentButton)
          Text(
            S.of(context).orderSuccessMsg1,
            style: TextStyle(color: secondaryColor, height: 1.4, fontSize: 14),
          ),
        if (userModel.user == null) ...[
          const SizedBox(height: 15),
          Text(
            S.of(context).orderSuccessTitle2,
            style: TextStyle(fontSize: 18, color: secondaryColor),
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).orderSuccessMsg2,
            style: TextStyle(color: secondaryColor, height: 1.4, fontSize: 14),
          ),
        ],
      ],
    );

    return Stack(
      children: [
        body,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: theme.colorScheme.surface),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showPaymentButton)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _handlePayment,
                      icon: const Icon(Icons.payment, size: 20),
                      label: Text(
                        S.of(context).continueToPayment.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                if (userModel.user != null)
                  TextButton(
                    onPressed: () {
                      final user = Provider.of<UserModel>(
                        context,
                        listen: false,
                      ).user;
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(RouteList.orders, arguments: user);
                    },
                    child: Text(
                      S.of(context).showAllMyOrdered.toUpperCase(),
                      style: TextStyle(color: secondaryColor),
                    ),
                  ),
                if (!showPaymentButton)
                  TextButton(
                    onPressed: () {
                      NavigateTools.navigateToDefaultTab(context);
                    },
                    child: Text(
                      S.of(context).backToShop.toUpperCase(),
                      style: TextStyle(color: secondaryColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BankAccountInfo extends StatelessWidget {
  const BankAccountInfo({super.key, required this.bankInfo});

  final BankAccountItem bankInfo;

  @override
  Widget build(BuildContext context) {
    if ((bankInfo.accountName?.isEmpty ?? true) ||
        (bankInfo.accountNumber?.isEmpty ?? true)) {
      return const SizedBox();
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Theme.of(context).primaryColorLight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bankInfo.accountName ?? '',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 5),
          Row(
            children: <Widget>[
              Text(
                S.of(context).bank.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${bankInfo.bankName}',
                  textAlign: TextAlign.right,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: <Widget>[
              Text(
                S.of(context).accountNumber.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${bankInfo.accountNumber}',
                  textAlign: TextAlign.right,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (bankInfo.sortCode?.isNotEmpty ?? false) const SizedBox(height: 5),
          if (bankInfo.sortCode?.isNotEmpty ?? false)
            Row(
              children: <Widget>[
                Text(
                  S.of(context).sortCode.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${bankInfo.sortCode}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          if (bankInfo.iban?.isNotEmpty ?? false) const SizedBox(height: 5),
          if (bankInfo.iban?.isNotEmpty ?? false)
            Row(
              children: <Widget>[
                Text('IBAN', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${bankInfo.iban}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          if (bankInfo.bic?.isNotEmpty ?? false) const SizedBox(height: 5),
          if (bankInfo.bic?.isNotEmpty ?? false)
            Row(
              children: <Widget>[
                Text(
                  'BIC / Swift: ',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${bankInfo.bic}',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
