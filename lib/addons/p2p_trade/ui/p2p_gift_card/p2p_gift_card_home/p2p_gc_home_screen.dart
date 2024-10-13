import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/models/p2p_gift_card.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';

import '../../../p2p_constants.dart';
import '../../p2p_common_widgets.dart';
import 'p2p_gc_home_controller.dart';
import 'p2p_gift_card_buy_page.dart';

class P2PGCHomeScreen extends StatefulWidget {
  const P2PGCHomeScreen({Key? key}) : super(key: key);

  @override
  State<P2PGCHomeScreen> createState() => _P2PGCHomeScreenState();
}

class _P2PGCHomeScreenState extends State<P2PGCHomeScreen> with TickerProviderStateMixin {
  final _controller = Get.put(P2pGCHomeController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getP2pGiftCardAllList(false);
      _controller.getGiftCardCSettings(() => setState(() {}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(Dimens.paddingMid),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textAutoSizeKarla("Market Gift Cards".tr, fontSize: Dimens.regularFontSizeMid),
              buttonOnlyIcon(
                  iconData: Icons.filter_alt_outlined,
                  size: Dimens.iconSizeMin,
                  iconColor: Get.theme.primaryColor,
                  visualDensity: minimumVisualDensity,
                  onPressCallback: () => showBottomSheetFullScreen(context, const P2pGCHomeFilterView(),
                      title: "Filter Ads".tr, onClose: () => _controller.checkFilterChange()))
            ],
          ),
        ),
        Obx(() => _controller.adsList.isEmpty
            ? handleEmptyViewWithLoading(_controller.isDataLoading.value)
            : Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                  itemCount: _controller.adsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_controller.hasMoreData && index == (_controller.adsList.length - 1)) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getP2pGiftCardAllList(true));
                    }
                    return P2pGCAdItemView(_controller.adsList[index]);
                  },
                ),
              ))
      ]),
    );
  }
}

class P2pGCAdItemView extends StatelessWidget {
  const P2pGCAdItemView(this.p2pGCAd, {Key? key}) : super(key: key);
  final P2PGiftCardAd p2pGCAd;

  @override
  Widget build(BuildContext context) {
    List<String> payments = ["Crypto".tr];
    if (p2pGCAd.paymentCurrencyType == PaymentCurrencyType.bank) {
      payments = p2pGCAd.paymentMethods?.map((e) => e.adminPaymentMethod?.name ?? "").toList() ?? [];
    }

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
                P2pUserView(user: p2pGCAd.user),
                buttonRoundedMain(
                    text: "Buy Card".tr,
                    width: 120,
                    textColor: Get.theme.scaffoldBackgroundColor,
                    buttonHeight: Dimens.iconSizeMid,
                    onPressCallback: () =>
                        showBottomSheetFullScreen(context, P2pGiftCardBuyPage(gCardAd: p2pGCAd), title: "Gift Card Add Details".tr))
              ],
            ),
            vSpacer10(),
            twoTextSpace("${"Price".tr} : ", p2pGCAd.price ?? ""),
            vSpacer2(),
            twoTextSpace("${"Value of Card".tr} : ", p2pGCAd.amount ?? ""),
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
                    children: List.generate(payments.length, (index) {
                      return Container(
                        padding: const EdgeInsets.all(Dimens.paddingMin),
                        decoration: boxDecorationRoundCorner(color: Colors.grey.withOpacity(0.3)),
                        child: textAutoSizeTitle(payments[index], fontSize: Dimens.regularFontSizeMin),
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

class P2pGCHomeFilterView extends StatelessWidget {
  const P2pGCHomeFilterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<P2pGCHomeController>();
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Dimens.paddingMid),
        children: [
          textAutoSizePoppins("Price".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          vSpacer5(),
          textFieldWithSuffixIcon(
              controller: controller.priceEditController,
              hint: "Enter Price".tr,
              type: TextInputType.number,
              onTextChange: (text) => controller.hasFilterChanged = true),
          vSpacer15(),
          textAutoSizePoppins("Payment Type".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          Obx(() {
            return dropDownListIndex(["All".tr, "Bank Transfer".tr, "Crypto Transfer".tr], controller.selectedPaymentType.value, "", hMargin: 0,
                (index) {
              controller.selectedPaymentType.value = index;
              controller.selectedCurrency.value = 0;
              controller.hasFilterChanged = true;
            });
          }),
          Obx(() {
            return controller.selectedPaymentType.value == 0
                ? vSpacer0()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vSpacer15(),
                      textAutoSizePoppins("Currency Type".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                      dropDownListIndex(controller.getCurrencyNameList(), controller.selectedCurrency.value, "", hMargin: 0, (index) {
                        controller.selectedCurrency.value = index;
                        controller.hasFilterChanged = true;
                      }),
                    ],
                  );
          }),
          Obx(() {
            return controller.selectedPaymentType.value == 1
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vSpacer15(),
                      textAutoSizePoppins("Payment Method".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                      dropDownListIndex(controller.getPaymentNameList(), controller.selectedPaymentMethod.value, "", hMargin: 0, (index) {
                        controller.selectedPaymentMethod.value = index;
                        controller.hasFilterChanged = true;
                      }),
                    ],
                  )
                : vSpacer0();
          }),
          vSpacer15(),
          textAutoSizePoppins("Available Region".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
          Obx(() {
            return dropDownListIndex(controller.getCountryNameList(), controller.selectedCountry.value, "", hMargin: 0, (index) {
              controller.selectedCountry.value = index;
              controller.hasFilterChanged = true;
            });
          }),
          vSpacer20(),
        ],
      ),
    );
  }
}
