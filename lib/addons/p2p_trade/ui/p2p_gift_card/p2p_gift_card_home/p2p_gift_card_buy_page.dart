import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/models/p2p_gift_card.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/p2p_constants.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/ui/p2p_common_widgets.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/ui/features/side_navigation/gift_cards/gift_cards_widgets.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'p2p_gc_home_controller.dart';

class P2pGiftCardBuyPage extends StatefulWidget {
  const P2pGiftCardBuyPage({super.key, required this.gCardAd});

  final P2PGiftCardAd gCardAd;

  @override
  State<P2pGiftCardBuyPage> createState() => _P2pGiftCardBuyPageState();
}

class _P2pGiftCardBuyPageState extends State<P2pGiftCardBuyPage> {
  final _controller = Get.find<P2pGCHomeController>();
  late P2PGiftCardAd p2pGiftCardAd;
  RxInt selectedPayMethod = 0.obs;

  @override
  void initState() {
    selectedPayMethod.value = -1;
    p2pGiftCardAd = widget.gCardAd;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getP2pGiftCardAdDetails(p2pGiftCardAd.uid ?? "", (gCard) => setState(() => p2pGiftCardAd = gCard));
    });
  }

  @override
  Widget build(BuildContext context) {
    final giftCard = p2pGiftCardAd.giftCard;
    final amountStr = "${coinFormat(giftCard?.amount)} ${giftCard?.coinType}";
    String imagePath = giftCard?.banner?.banner ?? giftCard?.banner?.banner ?? "";
    String price = p2pGiftCardAd.price?.split(" ").first ?? "";

    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
        children: [
          P2pUserView(user: p2pGiftCardAd.user),
          vSpacer10(),
          GiftCardImageAndTag(imagePath: imagePath, amountText: amountStr),
          vSpacer20(),
          textAutoSizeKarla(giftCard?.banner?.title ?? "", maxLines: 5, textAlign: TextAlign.start),
          vSpacer10(),
          textAutoSizePoppins(giftCard?.banner?.brandName ?? "", maxLines: 25, textAlign: TextAlign.start, color: Get.theme.primaryColor),
          dividerHorizontal(height: Dimens.paddingLargeDouble),
          twoTextView("${"Price".tr}: ", "$price ${p2pGiftCardAd.currencyType ?? ""}"),
          vSpacer2(),
          twoTextView("${"Available".tr}: ", "${coinFormat(giftCard?.amount)} ${giftCard?.coinType ?? ""}"),
          vSpacer2(),
          if ((p2pGiftCardAd.timeLimit ?? 0) > 0) twoTextView("${"Payment Time Limit".tr}: ", "${p2pGiftCardAd.timeLimit ?? 0} ${"minutes".tr}"),
          vSpacer10(),
          textAutoSizeKarla("Terms and Conditions".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
          vSpacer2(),
          textAutoSizePoppins(p2pGiftCardAd.termsCondition ?? "", maxLines: 100, textAlign: TextAlign.start, color: Get.theme.primaryColor),
          if (p2pGiftCardAd.paymentCurrencyType == PaymentCurrencyType.bank)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    vSpacer20(),
                    textAutoSizePoppins("Payment Method".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                    vSpacer5(),
                    Obx(() => dropDownListIndex(getPaymentNameList(), selectedPayMethod.value, "Select Payment Method".tr, hMargin: 0, (index) {
                          return selectedPayMethod.value = index;
                        })),
                  ],
                )
              ],
            ),
          vSpacer15(),
          Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                  width: 100,
                  child: buttonText("Buy".tr, textColor: Get.theme.scaffoldBackgroundColor, onPressCallback: () {
                    String? payUid;
                    if (p2pGiftCardAd.paymentCurrencyType == PaymentCurrencyType.bank) {
                      if (selectedPayMethod.value == -1) {
                        showToast("Select_Payment_Method_message".tr);
                        return;
                      }
                      payUid = p2pGiftCardAd.paymentMethods?[selectedPayMethod.value].uid;
                    }
                    _controller.p2pGiftCardPlaceAd(widget.gCardAd, payUid);
                  }))),
          vSpacer15(),
        ],
      ),
    );
  }

  List<String> getPaymentNameList() {
    List<String> list = <String>[];
    if (p2pGiftCardAd.paymentMethods.isValid) {
      list = p2pGiftCardAd.paymentMethods!.map((e) => e.adminPaymentMethod?.name ?? "").toList();
    }
    return list;
  }
}
