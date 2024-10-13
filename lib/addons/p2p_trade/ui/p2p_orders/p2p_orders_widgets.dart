import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/models/p2p_order.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../../p2p_common_utils.dart';
import '../p2p_order_details/p2p_order_details_screen.dart';
import 'p2p_orders_controller.dart';

class P2pOrderItemView extends StatelessWidget {
  const P2pOrderItemView(this.p2pOrder, {Key? key, required this.isDisputeList}) : super(key: key);
  final P2POrder p2pOrder;
  final bool isDisputeList;

  @override
  Widget build(BuildContext context) {
    final status = getTradeTypeData(p2pOrder.status, isDispute: isDisputeList);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.to(() => P2pOrderDetailsScreen(uid: p2pOrder.uid ?? "")),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: Dimens.paddingMin),
          color: Colors.grey.withOpacity(0.1),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(Dimens.paddingMid),
            child: Column(
              children: [
                vSpacer5(),
                twoTextSpace("${"Order Id".tr} : ", p2pOrder.orderId ?? ""),
                vSpacer2(),
                twoTextSpace("${"Amount".tr} : ", "${coinFormat(p2pOrder.amount)} ${p2pOrder.coinType ?? ""}"),
                vSpacer2(),
                twoTextSpace("${"Price".tr} : ", "${coinFormat(p2pOrder.price)} ${p2pOrder.currency ?? ""}"),
                vSpacer2(),
                twoTextSpace("${"Seller fees".tr} : ", coinFormat(p2pOrder.sellerFees ?? 0)),
                vSpacer2(),
                twoTextSpace("${"Status".tr} : ", status.first, subColor: status.last),
                vSpacer5(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class P2pOrdersFilterView extends StatelessWidget {
  const P2pOrdersFilterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<P2POrdersController>();
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Dimens.paddingMid),
        children: [
          textAutoSizePoppins("Coin".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          Obx(() {
            return dropDownListIndex(controller.getCoinNameList(), controller.selectedCoin.value, "", hMargin: 0, (index) {
              controller.selectedCoin.value = index;
              controller.hasFilterChanged = true;
            });
          }),
          vSpacer15(),
          textAutoSizePoppins("Order Type".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          Obx(() {
            return dropDownListIndex(controller.getOrderTypeMap().values.toList(), controller.selectedOrderStatus.value, "", hMargin: 0, (index) {
              controller.selectedOrderStatus.value = index;
              controller.hasFilterChanged = true;
            });
          }),
          vSpacer15(),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [textAutoSizePoppins("From".tr, fontSize: Dimens.regularFontSizeMid), _datePickerView(context, true, controller)],
                ),
              ),
              hSpacer15(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [textAutoSizePoppins("To".tr, fontSize: Dimens.regularFontSizeMid), _datePickerView(context, false, controller)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _datePickerView(BuildContext context, bool isStart, P2POrdersController controller) {
    return Obx(() {
      final currentText = isStart ? controller.startDate.value : controller.endDate.value;
      return textFieldWithWidget(
          controller: TextEditingController(text: currentText),
          hint: dateFormatMMDdYyyy,
          suffixWidget: InkWell(
              onTap: () async {
                showDatePickerView(context, (date) {
                  final dateStr = formatDate(date, format: dateFormatMMDdYyyy);
                  isStart ? controller.startDate.value = dateStr : controller.endDate.value = dateStr;
                  controller.hasFilterChanged = true;
                });
              },
              child: Icon(Icons.calendar_month, size: Dimens.iconSizeMid, color: Get.theme.primaryColor)),
          readOnly: true);
    });
  }
}
