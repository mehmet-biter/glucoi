import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'p2p_constants.dart';

List getTradeTypeData(int? type, {bool isDispute = false}) {
  if (isDispute) {
    switch (type) {
      case P2pTradeStatus.refundedByAdmin:
        return ["Refund By Admin".tr, Get.theme.primaryColor];
      case P2pTradeStatus.releasedByAdmin:
        return ["Released By Admin".tr, Get.theme.primaryColor];
      default:
        return ["Disputed".tr, Colors.amber];
    }
  } else {
    switch (type) {
      case P2pTradeStatus.timeExpired:
        return ["Time Expired".tr, Colors.red];
      case P2pTradeStatus.escrow:
        return ["In Escrow".tr, Colors.blue];
      case P2pTradeStatus.paymentDone:
        return ["Payment Done".tr, Colors.green];
      case P2pTradeStatus.transferDone:
        return ["Transfer Done".tr, Colors.green];
      case P2pTradeStatus.canceled:
        return ["Canceled".tr, Colors.red];
      case P2pTradeStatus.refundedByAdmin:
        return ["Refund By Admin".tr, Colors.amber];
      case P2pTradeStatus.releasedByAdmin:
        return ["Released By Admin".tr, Colors.amber];
    }
  }

  return [];
}

List getGiftCardStatusData(int? type) {
  switch (type) {
    case P2pGiftCardStatus.deActive:
      return ["Deactivate".tr, Colors.red];
    case P2pGiftCardStatus.active:
      return ["Active".tr, Colors.blue];
    case P2pGiftCardStatus.success:
      return ["Success".tr, Colors.green];
    case P2pGiftCardStatus.canceled:
      return ["Canceled".tr, Colors.red];
    case P2pGiftCardStatus.onGoing:
      return ["Ongoing".tr, Colors.amber];
  }
  return [];
}

showDatePickerView(BuildContext context, Function(DateTime) onSelected, {DateTime? initialDate, DateTime? firstDate, DateTime? lastDate}) async {
  final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1970),
      lastDate: lastDate ?? DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
            data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                    primary: context.theme.focusColor, onSurface: context.theme.primaryColor, onPrimary: context.theme.primaryColor)),
            child: child!);
      });
  if (picked != null) onSelected(picked);
}
