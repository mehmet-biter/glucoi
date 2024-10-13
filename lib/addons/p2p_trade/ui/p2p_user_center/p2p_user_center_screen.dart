import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/models/p2p_ads.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/ui/p2p_common_widgets.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'p2p_add_payment_page.dart';
import 'p2p_user_center_controller.dart';

class P2PUserCenterScreen extends StatefulWidget {
  const P2PUserCenterScreen({Key? key}) : super(key: key);

  @override
  State<P2PUserCenterScreen> createState() => _P2PUserCenterScreenState();
}

class _P2PUserCenterScreenState extends State<P2PUserCenterScreen> {
  final _controller = Get.put(P2pUserCenterController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getUserCenter());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pDetails = _controller.profileDetails;
      return _controller.isDataLoading.value
          ? showLoading()
          : Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(Dimens.paddingMid),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      P2pUserView(user: pDetails.user, isActiveOnTap: false, withName: true),
                      _countItemView("Registered at".tr, "${pDetails.userRegisterAt ?? 0} ${"days ago".tr}")
                    ],
                  ),
                  dividerHorizontal(),
                  Table(
                    children: [
                      TableRow(children: [
                        _countItemView("Total trades".tr, "${pDetails.totalTrade ?? 0}"),
                        _countItemView("30d Trades".tr, "${pDetails.completionRate30D ?? 0}%"),
                        _countItemView("First order at".tr, "${pDetails.firstOrderAt ?? 0} ${"days ago".tr}"),
                      ]),
                      TableRow(children: [vSpacer10(), vSpacer10(), vSpacer10()]),
                      TableRow(children: [
                        _countItemView("Positive reviews".tr, "${pDetails.positive ?? 0}"),
                        _countItemView("Reviews percentage".tr, "${pDetails.positiveFeedback ?? 0}%"),
                        _countItemView("Negative reviews".tr, "${pDetails.negative ?? 0}"),
                      ]),
                    ],
                  ),
                  vSpacer20(),
                  Container(
                    decoration: boxDecorationRoundCorner(),
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid, vertical: Dimens.paddingMin),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            textAutoSizeKarla("P2P Payment Methods".tr, fontSize: Dimens.regularFontSizeMid),
                            buttonText("Add".tr, textColor: Get.theme.primaryColor, onPressCallback: () {
                              showBottomSheetFullScreen(context, const P2pAddPaymentPage(), title: "Add payment method".tr);
                            })
                          ],
                        ),
                        vSpacer5(),
                        Column(
                            children: List.generate(_controller.paymentInfoList.length, (index) {
                          return _paymentInfoItemView(_controller.paymentInfoList[index]);
                        }))
                      ],
                    ),
                  ),
                  vSpacer20(),
                  Obx(() =>
                      tabBarText(["All".tr, "Positive".tr, "Negative".tr], _controller.selectedTab.value, (p0) => _controller.getFeedBackList(p0))),
                  vSpacer10(),
                  Obx(() {
                    return _controller.feedBackList.isEmpty
                        ? showEmptyView(height: Dimens.menuHeightSettings)
                        : Column(
                            children: List.generate(
                                _controller.feedBackList.length, (index) => FeedBackItemView(feedback: _controller.feedBackList[index])));
                  })
                ],
              ),
            );
    });
  }

  _paymentInfoItemView(P2pPaymentInfo paymentInfo) {
    return Container(
      decoration: boxDecorationRoundCorner(color: Get.theme.colorScheme.secondary.withOpacity(0.15)),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.only(bottom: Dimens.paddingMid),
      child: Row(
        children: [
          Expanded(
              child: textAutoSizeKarla(paymentInfo.adminPaymentMethod?.name ?? " ",
                  fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start, maxLines: 2)),
          buttonOnlyIcon(
              iconData: Icons.drive_file_rename_outline,
              size: Dimens.iconSizeMin,
              iconColor: Get.theme.primaryColor,
              visualDensity: minimumVisualDensity,
              onPressCallback: () =>
                  showBottomSheetFullScreen(context, P2pAddPaymentPage(paymentInfo: paymentInfo), title: "Edit payment method".tr)),
          buttonOnlyIcon(
              iconData: Icons.delete_outline,
              size: Dimens.iconSizeMin,
              iconColor: Colors.redAccent,
              visualDensity: minimumVisualDensity,
              onPressCallback: () => _deletePaymentMethod(paymentInfo))
        ],
      ),
    );
  }

  _deletePaymentMethod(P2pPaymentInfo paymentInfo) {
    alertForAction(context,
        title: "Delete Payment Method".tr,
        subTitle: "Do you want to delete this payment info".tr,
        buttonTitle: "Delete".tr,
        buttonColor: Colors.redAccent,
        onOkAction: () => _controller.p2pPaymentMethodDelete(paymentInfo, context));
  }

   _countItemView(String? title, String? subtitle) {
    return Column(
      children: [
        textAutoSizeKarla(title ?? "", fontSize: Dimens.regularFontSizeSmall, maxLines: 2),
        textAutoSizeKarla((subtitle ?? "").toString(), fontSize: Dimens.regularFontSizeMid),
      ],
    );
  }
}
