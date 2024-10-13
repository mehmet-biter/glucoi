import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/ui/p2p_common_widgets.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/ui/features/side_navigation/gift_cards/gift_cards_widgets.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../../../models/p2p_gift_card.dart';
import 'p2p_gc_create_ad_controller.dart';

class P2PGCCreateAdScreen extends StatefulWidget {
  const P2PGCCreateAdScreen({Key? key, this.preAd, this.p2pGiftCard}) : super(key: key);
  final P2pGiftCard? p2pGiftCard;
  final P2PGiftCardAd? preAd;

  @override
  State<P2PGCCreateAdScreen> createState() => _P2PGCCreateAdScreenState();
}

class _P2PGCCreateAdScreenState extends State<P2PGCCreateAdScreen> with TickerProviderStateMixin {
  final _controller = Get.put(P2pGCCreateAdController());

  @override
  void initState() {
    _controller.onUIUpdate = onUIUpdate;
    _controller.isEdit = widget.preAd != null;
    if (widget.p2pGiftCard != null) _controller.p2pGiftCard = widget.p2pGiftCard!;
    if (widget.preAd != null) _controller.preAd = widget.preAd!;
    _controller.selectedPaymentType.value = -1;
    _controller.selectedCurrency.value = -1;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_controller.isEdit) _controller.getP2pGiftCardDetails();
      _controller.getGiftCardCSettings();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onUIUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final giftCard = _controller.p2pGiftCard.giftCard;
    final amountStr = "${coinFormat(giftCard?.amount)} ${giftCard?.coinType}";
    String imagePath = giftCard?.banner?.banner ?? giftCard?.banner?.banner ?? "";
    return KeyboardDismissOnTap(
      child: Scaffold(
        body: BGViewMain(
          child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
                child: Column(
                  children: [
                    appBarBackWithActions(title: _controller.isEdit ? "Edit Gift Card Ad".tr : "Create Gift Card Ad".tr),
                    _controller.isLoading
                        ? showLoading()
                        : Expanded(
                            child: ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(Dimens.paddingMid),
                              children: [
                                GiftCardImageAndTag(imagePath: imagePath, amountText: amountStr),
                                vSpacer15(),
                                textAutoSizeKarla(giftCard?.banner?.title ?? "", maxLines: 5, textAlign: TextAlign.start),
                                vSpacer10(),
                                textAutoSizePoppins(giftCard?.banner?.brandName ?? "",
                                    maxLines: 10, textAlign: TextAlign.start, color: Get.theme.primaryColor),
                                dividerHorizontal(height: Dimens.btnHeightMid),
                                textAutoSizePoppins("Payment Type".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                Obx(() {
                                  return dropDownListIndex(
                                      ["Bank Transfer".tr, "Crypto Transfer".tr], _controller.selectedPaymentType.value, "Select Payment Type".tr,
                                      hMargin: 0, (index) {
                                    _controller.selectedPaymentType.value = index;
                                    _controller.selectedCurrency.value = -1;
                                  });
                                }),
                                Obx(() {
                                  return _controller.selectedPaymentType.value == -1
                                      ? vSpacer0()
                                      : Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            vSpacer15(),
                                            textAutoSizePoppins("Currency Type".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                            dropDownListIndex(
                                                _controller.getCurrencyNameList(), _controller.selectedCurrency.value, "Select Currency".tr,
                                                hMargin: 0, (index) {
                                              _controller.selectedCurrency.value = index;
                                            }),
                                          ],
                                        );
                                }),
                                vSpacer15(),
                                textAutoSizePoppins("Price".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                vSpacer5(),
                                textFieldWithSuffixIcon(
                                    controller: _controller.priceEditController, hint: "Enter Price".tr, type: TextInputType.number),
                                vSpacer15(),
                                textAutoSizePoppins("Status".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                Obx(() {
                                  return dropDownListIndex(["Active".tr, "Deactivate".tr], _controller.selectedStatus.value, "", hMargin: 0, (index) {
                                    _controller.selectedStatus.value = index;
                                  });
                                }),
                                Obx(() {
                                  return _controller.selectedPaymentType.value == 0
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            vSpacer15(),
                                            textAutoSizePoppins("Payment Method".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                            vSpacer5(),
                                            TagSelectionViewString(
                                                tagList: _controller.getPaymentNameList(),
                                                controller: _controller.paymentTagController,
                                                initialSelection: _controller.selectedPayMethods,
                                                onTagSelected: (list) => _controller.selectedPayMethods = list),
                                          ],
                                        )
                                      : vSpacer0();
                                }),
                                vSpacer15(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    textAutoSizePoppins("Available Regions".tr, fontSize: Dimens.regularFontSizeMid),
                                    Row(
                                      children: [
                                        Obx(() => textAutoSizeKarla(_controller.selectedCountryList.length.toString(),
                                            fontSize: Dimens.regularFontSizeMid, color: Get.theme.colorScheme.secondary)),
                                        buttonOnlyIcon(
                                            iconData: Icons.cancel_outlined,
                                            visualDensity: minimumVisualDensity,
                                            iconColor: Get.theme.primaryColor,
                                            onPressCallback: () => _controller.countryTagController.clearTags())
                                      ],
                                    )
                                  ],
                                ),
                                TagSelectionViewString(
                                    tagList: _controller.getCountryNameList(),
                                    controller: _controller.countryTagController,
                                    initialSelection: _controller.selectedCountryList,
                                    onTagSelected: (list) => _controller.selectedCountryList.value = list),
                                vSpacer15(),
                                textAutoSizePoppins("Time Limit".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                Obx(() {
                                  return dropDownListIndex(_controller.getTimeLimitList(), _controller.selectedTime.value, "", hMargin: 0, (index) {
                                    _controller.selectedTime.value = index;
                                  });
                                }),
                                vSpacer15(),
                                textAutoSizePoppins("Terms And Conditions".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                vSpacer5(),
                                textFieldWithSuffixIcon(
                                    controller: _controller.termsEditController, hint: "Enter Terms And Conditions".tr, maxLines: 3, height: 80),
                                vSpacer15(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    buttonText("Cancel".tr, bgColor: Colors.grey, onPressCallback: () => Get.back()),
                                    hSpacer10(),
                                    buttonText(_controller.isEdit ? "Update".tr : "Create".tr,
                                        textColor: Get.theme.scaffoldBackgroundColor, onPressCallback: () => _controller.checkInputData(context)),
                                  ],
                                )
                              ],
                            ),
                          )
                  ],
                )),
          ),
        ),
      ),
    );
  }
}
