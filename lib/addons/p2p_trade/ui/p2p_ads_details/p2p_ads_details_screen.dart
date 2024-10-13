import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/ui/p2p_common_widgets.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'p2p_ads_details_controller.dart';

class P2pAdsDetailsScreen extends StatefulWidget {
  const P2pAdsDetailsScreen({Key? key, required this.uid, required this.adsType}) : super(key: key);
  final String uid;
  final int adsType;

  @override
  P2pAdsDetailsScreenState createState() => P2pAdsDetailsScreenState();
}

class P2pAdsDetailsScreenState extends State<P2pAdsDetailsScreen> {
  final _controller = Get.put(P2pAdsDetailsController());

  @override
  void initState() {
    super.initState();
    _controller.selectedPaymentM.value = -1;
    _controller.fromKey = "";
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getAdsDetails(widget.uid, widget.adsType));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
                child: Column(
                  children: [
                    appBarBackWithActions(title: "Ads Details".tr),
                    Obx(() {
                      final aDetails = _controller.adsDetails;
                      final currency = aDetails.ads?.currency ?? "";
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
                                      P2pUserView(user: aDetails.ads?.user),
                                      coinDetailsItemView("${aDetails.orders ?? 0} ${"Orders".tr.toLowerCase()}",
                                          "${aDetails.completion ?? 0}% ${"Completion".tr.toLowerCase()}",
                                          isSwap: true)
                                    ],
                                  ),
                                  vSpacer10(),
                                  twoTextSpace("Price".tr, "${aDetails.price ?? 0} $currency", subColor: Get.theme.colorScheme.secondary),
                                  twoTextSpace("Available".tr, "${aDetails.available ?? 0} ${aDetails.ads?.coinType ?? ""}"),
                                  twoTextSpace("Payment Time Limit".tr, "${aDetails.ads?.paymentTimes ?? 0} ${"minutes".tr}"),
                                  vSpacer20(),
                                  titleAndDescView("Terms and Conditions".tr, aDetails.ads?.terms ?? ""),
                                  vSpacer20(),
                                  textAutoSizeKarla("I want to pay".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                  vSpacer5(),
                                  textFieldWithWidget(
                                      controller: _controller.priceEditController,
                                      suffixWidget: _textFieldText(currency),
                                      type: TextInputType.number,
                                      onTextChange: (text) => _controller.onTextChanged(widget.uid, widget.adsType, FromKey.up)),
                                  vSpacer2(),
                                  textAutoSizePoppins(
                                      "${"Min price".tr} ${aDetails.minimumPrice ?? 0} $currency - ${"Max price".tr} ${aDetails.maximumPrice ?? 0} $currency"),
                                  vSpacer20(),
                                  textAutoSizeKarla("I will receive".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                  vSpacer5(),
                                  textFieldWithWidget(
                                      controller: _controller.amountEditController,
                                      suffixWidget: _textFieldText(aDetails.ads?.coinType ?? ""),
                                      type: TextInputType.number,
                                      onTextChange: (text) => _controller.onTextChanged(widget.uid, widget.adsType, FromKey.down)),
                                  vSpacer10(),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: buttonText("Get all balance".tr, textColor: Get.theme.primaryColor, bgColor: Colors.grey,
                                        onPressCallback: () {
                                      hideKeyboard(context: context);
                                      _controller.adsAvailableBalance(widget.uid, aDetails.ads?.coinType ?? "", widget.adsType);
                                    }),
                                  ),
                                  vSpacer10(),
                                  textAutoSizeKarla("Select Payment Method".tr.toCapitalizeFirst(), fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                  Obx(() => dropDownListIndex(
                                      _controller.getPaymentNameList(),
                                      _controller.selectedPaymentM.value,
                                      "Select".tr,
                                      hMargin: 0,
                                      (index) => _controller.selectedPaymentM.value = index)),
                                  vSpacer10(),
                                  buttonRoundedMain(
                                      text: widget.adsType == 1 ? "Buy".tr : "Sell".tr,
                                      onPressCallback: () => _controller.checkAndPlaceOrder(context, widget.adsType, widget.uid))
                                ],
                              ),
                            );
                    })
                  ],
                ))),
      ),
    );
  }

  _textFieldText(String text) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Row(
        children: [hSpacer5(), Text(text, style: Get.textTheme.titleSmall?.copyWith(fontSize: Dimens.regularFontSizeMid)), hSpacer10()],
      ),
    );
  }
}
