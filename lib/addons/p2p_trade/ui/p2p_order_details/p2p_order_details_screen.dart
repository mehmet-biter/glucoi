import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../../p2p_constants.dart';
import 'order_details_widgets.dart';
import 'p2p_order_chat_page.dart';
import 'p2p_order_details_controller.dart';

class P2pOrderDetailsScreen extends StatefulWidget {
  const P2pOrderDetailsScreen({Key? key, required this.uid}) : super(key: key);
  final String uid;

  @override
  P2pOrderDetailsScreenState createState() => P2pOrderDetailsScreenState();
}

class P2pOrderDetailsScreenState extends State<P2pOrderDetailsScreen> with SingleTickerProviderStateMixin {
  final _controller = Get.put(P2pOrderDetailsController());
  RxInt tabIndex = 0.obs;
  late TabController _tabController;
  late bool isBuy = false;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getOrderDetails(widget.uid));
  }

  @override
  void dispose() {
    _controller.manageChatChannel(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BGViewMain(
        child: SafeArea(child: Obx(() {
          isBuy = _controller.orderDetails.value.userBuyer?.id == gUserRx.value.id;
          final order = _controller.orderDetails.value.order;
          final user = isBuy ? _controller.orderDetails.value.userSeller : _controller.orderDetails.value.userBuyer;
          String pTitle = "Order Details".tr;
          if (_controller.orderDetails.value.order != null) {
            pTitle =
                "${isBuy ? "Buy".tr : "Sell".tr} ${order?.coinType ?? ""} ${(isBuy ? "From".tr : "To".tr).toLowerCase()} ${user?.nickName ?? user?.firstName ?? ""}";
          }

          return Padding(
              padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
              child: Column(
                children: [
                  appBarBackWithActions(title: pTitle, fontSize: Dimens.regularFontSizeMid),
                  tabBarUnderline(["Details".tr, "Conversation".tr], _tabController, onTap: (index) => tabIndex.value = index),
                  dividerHorizontal(height: 0),
                  _controller.isDataLoading ? showLoading() : Obx(() => tabIndex.value == 0 ? _orderDetailsView() : P2pOrderChatPage()),
                ],
              ));
        })),
      ),
    );
  }

  _orderDetailsView() {
    final order = _controller.orderDetails.value.order;
    final dispute = _controller.orderDetails.value.dispute;

    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Dimens.paddingMid),
        children: [
          vSpacer10(),
          twoTextSpaceFixed("${"Order number".tr} : ", order?.orderId ?? "", flex: 4),
          twoTextSpaceFixed("${"Time Created".tr} : ", formatDate(order?.createdAt, format: dateTimeFormatDdMMMMYyyyHhMm), flex: 4),
          vSpacer20(),
          OrderInfoView(order: order),
          OrderTimeLimitView(order: order, dueMinute: _controller.orderDetails.value.dueMinute, onEnd: () => _controller.getOrderDetails(widget.uid)),
          if (dispute != null)
            DisputedView(p2pOrderDetails: _controller.orderDetails.value)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ([P2pTradeStatus.timeExpired, P2pTradeStatus.canceled, P2pTradeStatus.transferDone].contains(order?.status))
                  OrderStatusView(order: order),
                if (order?.status == P2pTradeStatus.escrow)
                  isBuy ? OrderPaymentView(order: order, payInfo: _controller.orderDetails.value.paymentMethods) : OrderStatusView(order: order),
                if (order?.status == P2pTradeStatus.paymentDone && isBuy) OrderStatusView(order: order),
                vSpacer20(),
                order?.status == P2pTradeStatus.transferDone ? OrderReviewView(order: order, isBuy: isBuy) : _buttonsView(),
                vSpacer20(),
              ],
            )
        ],
      ),
    );
  }

  _buttonsView() {
    final order = _controller.orderDetails.value.order;
    return Wrap(
      spacing: Dimens.paddingMid,
      runSpacing: Dimens.paddingMid,
      alignment: WrapAlignment.start,
      children: [
        if (order?.status == P2pTradeStatus.escrow && isBuy)
          buttonText("Cancel".tr, textColor: Get.theme.scaffoldBackgroundColor, onPressCallback: () {
            showModalSheetFullScreen(context, _cancelView());
          }),
        if (order?.status == P2pTradeStatus.paymentDone && !isBuy)
          buttonText("Release".tr, textColor: Get.theme.scaffoldBackgroundColor, onPressCallback: () {
            alertForAction(context,
                title: "Do you want to fund escrow".tr, buttonTitle: "Release".tr, onOkAction: () => _controller.p2pReleaseOrder());
          }),
        if (order?.status == P2pTradeStatus.paymentDone)
          buttonText("Dispute".tr, textColor: Get.theme.scaffoldBackgroundColor, onPressCallback: () {
            showBottomSheetFullScreen(context, OrderDisputeView(order), title: "Dispute Order".tr);
          }),
      ],
    );
  }

  _cancelView() {
    final reasonEditController = TextEditingController();
    return Column(
      children: [
        vSpacer10(),
        textAutoSizeKarla("Cancel Order".tr, fontSize: Dimens.regularFontSizeMid),
        vSpacer20(),
        Align(alignment: Alignment.centerLeft, child: textAutoSizePoppins("Reason to cancel the order".tr)),
        vSpacer5(),
        textFieldWithSuffixIcon(controller: reasonEditController, hint: "Write Your Reason".tr, maxLines: 3, height: 100),
        vSpacer15(),
        buttonRoundedMain(
            text: "Confirm".tr,
            onPressCallback: () {
              final reason = reasonEditController.text.trim();
              if (reason.isEmpty) {
                showToast("reason for the cancellation".tr, context: context);
                return;
              }
              hideKeyboard(context: context);
              _controller.p2pOrderCancel(reason);
            }),
        vSpacer10(),
      ],
    );
  }
}
