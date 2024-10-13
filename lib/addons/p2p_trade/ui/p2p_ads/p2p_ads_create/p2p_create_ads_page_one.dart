import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/ui/p2p_common_widgets.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'p2p_create_ads_controller.dart';

class CreateAdsPageOne extends StatefulWidget {
  const CreateAdsPageOne({Key? key}) : super(key: key);

  @override
  State<CreateAdsPageOne> createState() => _CreateAdsPageOneState();
}

class _CreateAdsPageOneState extends State<CreateAdsPageOne> {
  final _controller = Get.find<P2pCreateAdsController>();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Obx(() => dropDownListIndex(_controller.getCoinNameList(), _controller.selectedCoin.value, "Select Asset".tr, isEditable: !_controller.isEdit,
                (index) {
              _changeCoinCurrency(index, true);
            })),
        Obx(() => dropDownListIndex(_controller.getCurrencyNameList(), _controller.selectedCurrency.value, "Select Currency".tr,
                isEditable: !_controller.isEdit, (index) {
              _changeCoinCurrency(index, false);
            })),
        vSpacer10(),
        Obx(() {
          final currency = _controller.selectedCurrency.value == -1
              ? ""
              : _controller.adsSettings!.currency![_controller.selectedCurrency.value].currencyCode ?? "";
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              hSpacer10(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textAutoSizePoppins("Your Price".tr),
                    textAutoSizeTitle("$currency ${coinFormat(_controller.adsPrice.value.price)}", fontSize: Dimens.regularFontSizeMid),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    textAutoSizePoppins("Lowest Order Price".tr),
                    textAutoSizeTitle("$currency ${coinFormat(_controller.adsPrice.value.lowestPrice)}", fontSize: Dimens.regularFontSizeMid),
                  ],
                ),
              ),
              hSpacer10()
            ],
          );
        }),
        vSpacer20(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
          child: Obx(() {
            final pText = _controller.selectedPriceType.value == 1 ? "Fixed".tr : "${"Floating".tr} (%)";
            _controller.isUpdatePrice
                ? _controller.priceEditController.text = coinFormat(_controller.adsPrice.value.price)
                : _controller.isUpdatePrice = true;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textAutoSizeKarla("Price Type".tr, fontSize: Dimens.regularFontSizeMid),
                    SegmentedControlView(["Fixed".tr, "Floating".tr], _controller.selectedPriceType.value, onChange: (index) {
                      return _controller.selectedPriceType.value = index;
                    }),
                  ],
                ),
                vSpacer10(),
                Row(
                  children: [
                    Expanded(flex: 4, child: textAutoSizeKarla(pText, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start)),
                    Expanded(flex: 6, child: NumberIncrementView(controller: _controller.priceEditController))
                  ],
                ),
              ],
            );
          }),
        ),
        vSpacer20(),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [buttonText("Next".tr, onPressCallback: () => _goToSecondPage()), hSpacer10()]),
      ],
    );
  }

  void _changeCoinCurrency(int index, bool isCoin) {
    isCoin ? _controller.selectedCoin.value = index : _controller.selectedCurrency.value = index;
    if (_controller.selectedCoin.value == -1 || _controller.selectedCurrency.value == -1) return;
    final coinType = _controller.adsSettings!.assets![_controller.selectedCoin.value].coinType ?? "";
    final currency = _controller.adsSettings!.currency![_controller.selectedCurrency.value].currencyCode ?? "";
    _controller.getAdsPrice(coinType, currency);
  }

  void _goToSecondPage() {
    if (_controller.selectedCoin.value == -1) {
      showToast("Select_asset_message".tr, context: context);
      return;
    }
    if (_controller.selectedCurrency.value == -1) {
      showToast("select your currency".tr, context: context);
      return;
    }
    final price = makeDouble(_controller.priceEditController.text.trim());
    if (price <= 0) {
      showToast("price_must_greater_than_0".tr, context: context);
      return;
    }
    final coinType = _controller.adsSettings!.assets![_controller.selectedCoin.value].coinType ?? "";
    final currency = _controller.adsSettings!.currency![_controller.selectedCurrency.value].currencyCode ?? "";
    _controller.currentAds?.coinType = coinType;
    _controller.currentAds?.currency = currency;
    _controller.currentAds?.priceType = _controller.selectedPriceType.value;
    _controller.currentAds?.price = price;
    _controller.currentAds?.priceRate = price;

    _controller.pageController
        .animateToPage(_controller.currentPageCreate + 1, duration: const Duration(milliseconds: 500), curve: Curves.easeInToLinear);
  }
}
