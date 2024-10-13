import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/models/p2p_ads.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/ui/p2p_home/p2p_home_controller.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../../models/p2p_settings.dart';
import '../p2p_ads_details/p2p_ads_details_screen.dart';
import '../p2p_common_widgets.dart';

class P2pAdsItemView extends StatelessWidget {
  const P2pAdsItemView(this.p2pAds, this.transactionType, {Key? key}) : super(key: key);
  final P2PAds p2pAds;
  final int transactionType;

  @override
  Widget build(BuildContext context) {
    final btnTitle = transactionType == 1 ? "Buy".tr : "Sell".tr;
    final limitSrt =
        "${coinFormat(p2pAds.minimumTradeSize)} ${p2pAds.currency ?? ""}-${coinFormat(p2pAds.maximumTradeSize)} ${p2pAds.currency ?? ""}";
    return Card(
      margin: const EdgeInsets.symmetric(vertical: Dimens.paddingMin),
      color: Colors.grey.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.paddingMid),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                P2pUserView(user: p2pAds.user),
                gUserRx.value.id == 0
                    ? hSpacer10()
                    : buttonRoundedMain(
                        text: "$btnTitle ${p2pAds.coinType ?? ""}",
                        width: 100,
                        buttonHeight: Dimens.iconSizeMid,
                        onPressCallback: () => Get.to(() => P2pAdsDetailsScreen(uid: p2pAds.uid ?? "", adsType: transactionType)))
              ],
            ),
            vSpacer10(),
            twoTextSpace("${"Price".tr} : ", "${coinFormat(p2pAds.price)} ${p2pAds.currency ?? ""}"),
            vSpacer2(),
            twoTextSpace("${"Available".tr} : ", "${coinFormat(p2pAds.available)} ${p2pAds.coinType ?? ""}"),
            vSpacer2(),
            twoTextSpace("${"Limit".tr} : ", limitSrt),
            vSpacer5(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textAutoSizeKarla("${"Payment".tr} : ", fontSize: Dimens.regularFontSizeMid, color: Get.theme.primaryColorLight),
                Expanded(
                  child: Wrap(
                    runSpacing: Dimens.paddingMin,
                    spacing: Dimens.paddingMin,
                    alignment: WrapAlignment.end,
                    children: List.generate(p2pAds.paymentMethodList?.length ?? 0, (index) {
                      return Container(
                        padding: const EdgeInsets.all(Dimens.paddingMin),
                        decoration: boxDecorationRoundCorner(color: Colors.grey.withOpacity(0.3)),
                        child:
                            textAutoSizeTitle(p2pAds.paymentMethodList![index].adminPaymentMethod?.name ?? "", fontSize: Dimens.regularFontSizeMin),
                      );
                    }),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class P2pHomeFilterView extends StatelessWidget {
  const P2pHomeFilterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<P2PHomeController>();
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Dimens.paddingMid),
        children: [
          textAutoSizePoppins("Limit Amount".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          vSpacer5(),
          textFieldWithSuffixIcon(
              controller: controller.amountEditController,
              hint: "Write Amount".tr,
              type: TextInputType.number,
              onTextChange: (text) => controller.hasFilterChanged = true),
          vSpacer15(),
          textAutoSizePoppins("Fiat".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          Obx(() {
            return dropDownListIndex(controller.getCurrencyNameList(), controller.selectedCurrency.value, "", hMargin: 0, (index) {
              controller.selectedCurrency.value = index;
              controller.hasFilterChanged = true;
            });
          }),
          vSpacer15(),
          textAutoSizePoppins("Payment".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          Obx(() {
            return dropDownListIndex(controller.getPaymentNameList(), controller.selectedPayment.value, "", hMargin: 0, (index) {
              controller.selectedPayment.value = index;
              controller.hasFilterChanged = true;
            });
          }),
          vSpacer15(),
          textAutoSizePoppins("Available Regions".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          Obx(() {
            return dropDownListIndex(controller.getCountryNameList(), controller.selectedCountry.value, "", hMargin: 0, (index) {
              controller.selectedCountry.value = index;
              controller.hasFilterChanged = true;
            });
          }),
          vSpacer20(),
          textDecoration("How P2P works".tr,
              color: Get.theme.primaryColor,
              onTap: () => showBottomSheetFullScreen(context, P2pTutorialView(settings: controller.settings), title: "How P2P works".tr))
        ],
      ),
    );
  }
}

class P2pTutorialView extends StatelessWidget {
  const P2pTutorialView({Key? key, required this.settings}) : super(key: key);
  final P2PAdsSettings settings;

  @override
  Widget build(BuildContext context) {
    RxBool isBuy = true.obs;
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
        children: [
          Obx(() {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buttonTutorialText(isBuy.value, "Buy Crypto".tr, () => isBuy.value = true),
                    hSpacer5(),
                    _buttonTutorialText(!isBuy.value, "Sell Crypto".tr, () => isBuy.value = false)
                  ],
                ),
                if (isBuy.value && settings.p2PBuyStep1Heading.isValid)
                  _tutorialItemView(settings.p2PBuyStep1Icon, settings.p2PBuyStep1Heading, settings.p2PBuyStep1Des),
                if (isBuy.value && settings.p2PBuyStep2Heading.isValid)
                  _tutorialItemView(settings.p2PBuyStep2Icon, settings.p2PBuyStep2Heading, settings.p2PBuyStep2Des),
                if (isBuy.value && settings.p2PBuyStep3Heading.isValid)
                  _tutorialItemView(settings.p2PBuyStep3Icon, settings.p2PBuyStep3Heading, settings.p2PBuyStep3Des),
                if (!isBuy.value && settings.p2PSellStep1Heading.isValid)
                  _tutorialItemView(settings.p2PSellStep1Icon, settings.p2PSellStep1Heading, settings.p2PSellStep1Des),
                if (!isBuy.value && settings.p2PSellStep2Heading.isValid)
                  _tutorialItemView(settings.p2PSellStep2Icon, settings.p2PSellStep2Heading, settings.p2PSellStep2Des),
                if (!isBuy.value && settings.p2PSellStep3Heading.isValid)
                  _tutorialItemView(settings.p2PSellStep3Icon, settings.p2PSellStep3Heading, settings.p2PSellStep3Des),
              ],
            );
          }),
          vSpacer30(),
          textAutoSizeKarla("Advantage of P2P Exchange".tr, fontSize: Dimens.regularFontSizeLarge, textAlign: TextAlign.start),
          vSpacer10(),
          if (settings.p2PAdvantage1Heading.isValid)
            _tutorialItemView(settings.p2PAdvantage1Icon, settings.p2PAdvantage1Heading, settings.p2PAdvantage1Des),
          if (settings.p2PAdvantage2Heading.isValid)
            _tutorialItemView(settings.p2PAdvantage2Icon, settings.p2PAdvantage2Heading, settings.p2PAdvantage2Des),
          if (settings.p2PAdvantage3Heading.isValid)
            _tutorialItemView(settings.p2PAdvantage3Icon, settings.p2PAdvantage3Heading, settings.p2PAdvantage3Des),
          if (settings.p2PAdvantage4Heading.isValid)
            _tutorialItemView(settings.p2PAdvantage4Icon, settings.p2PAdvantage4Heading, settings.p2PAdvantage4Des),
          vSpacer30(),
          textAutoSizeKarla("FAQS".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          vSpacer10(),
          Column(children: List.generate(settings.p2PFaq?.length ?? 0, (index) => faqItem(settings.p2PFaq![index]))),
          vSpacer30(),
          textAutoSizeKarla("Top Payment Methods".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          vSpacer10(),
          Wrap(
            runSpacing: Dimens.paddingMin,
            spacing: Dimens.paddingMin,
            children: List.generate(settings.paymentMethodLanding?.length ?? 0, (index) {
              return Container(
                padding: const EdgeInsets.all(Dimens.paddingMid),
                decoration: boxDecorationRoundCorner(color: Colors.grey.withOpacity(0.3)),
                child: textAutoSizeTitle(settings.paymentMethodLanding![index].name ?? "", fontSize: Dimens.regularFontSizeMid),
              );
            }),
          ),
          vSpacer10(),
        ],
      ),
    );
  }

  _buttonTutorialText(bool selected, String title, VoidCallback onTap) => buttonText(title,
      bgColor: selected ? Get.theme.colorScheme.secondary : Colors.transparent,
      textColor: Get.theme.primaryColor,
      onPressCallback: onTap);

  _tutorialItemView(String? imagePath, String? title, String? subTitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: showImageNetwork(imagePath: imagePath, height: Dimens.iconSizeLargeExtra, width: Dimens.iconSizeLargeExtra, boxFit: BoxFit.cover),
      title: textAutoSizeTitle(title ?? "", fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
      subtitle: textAutoSizePoppins(subTitle ?? "", fontSize: Dimens.regularFontSizeSmall, textAlign: TextAlign.start, maxLines: 100),
    );
  }
}
