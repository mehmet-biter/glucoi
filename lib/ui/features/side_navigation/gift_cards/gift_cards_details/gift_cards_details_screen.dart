import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/models/gift_card.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/local_auth_helper.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import '../gift_cards_widgets.dart';

import 'gift_cards_details_controller.dart';

class GiftCardDetailsScreen extends StatelessWidget {
  GiftCardDetailsScreen({super.key, required this.gCard});

  final GiftCard gCard;
  final _controller = Get.put(GiftCardDetailsController());

  @override
  Widget build(BuildContext context) {
    String amountText = "${coinFormat(gCard.payAmount)} ${gCard.coinType ?? ""}";
    final currency = gCard.banner?.recipientCurrency ?? "";
    RxString redeemCode = "".obs;
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
        children: [
          GiftCardImageAndTag(imagePath: gCard.banner?.banner, amountText: amountText),
          vSpacer20(),
          textAutoSizeKarla(gCard.banner?.title ?? "", maxLines: 5, textAlign: TextAlign.start),
          vSpacer10(),
          textAutoSizePoppins(gCard.banner?.brandName ?? "", maxLines: 10, textAlign: TextAlign.start, color: Get.theme.primaryColor),
          vSpacer20(),
          twoTextSpaceFixed("Recipient Amount".tr, "${coinFormat(gCard.recipientAmount)} $currency", flex: 5),
          twoTextSpaceFixed("Unit Price".tr, "${coinFormat(gCard.unitPrice)} $currency"),
          twoTextSpaceFixed("Service Fees".tr, "${coinFormat(gCard.fees)} $currency"),
          twoTextSpaceFixed("Quantity".tr, gCard.quantity.toString()),
          twoTextSpaceFixed("Total Price".tr, "${coinFormat(gCard.totalUnitPrice)} $currency"),
          twoTextSpaceFixed("Paid".tr, amountText),
          twoTextSpaceFixed("Country".tr, gCard.country?.name ?? ""),
          vSpacer20(),
          Obx(() => redeemCode.isNotEmpty
              ? RedeemCodeView(code: redeemCode.value, gCard: gCard)
              : FittedBox(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                  child: buttonText("Redeem Code".tr, onPressCallback: () => _getRedeemCode(context, (code) => redeemCode.value = code)))),
          vSpacer10(),
        ],
      ),
    );
  }

  Future<void> _getRedeemCode(BuildContext context, Function(String) onCode) async {
    if (await LocalAuthHelper.isBiometricsSupported(isShow: false)) {
      if (await LocalAuthHelper.checkBiometrics()) {
        _controller.getGiftCardCode(gCard.transactionId ?? '', onCode);
      }
    } else {
      _controller.getGiftCardCode(gCard.transactionId ?? '', onCode);
    }
  }

// void _getRedeemCode(BuildContext context) {
//   final passEditController = TextEditingController();
//   final view = Column(
//     children: [
//       vSpacer10(),
//       textAutoSizeKarla("Enter your login password".tr, fontSize: Dimens.regularFontSizeMid, maxLines: 2),
//       vSpacer10(),
//       textFieldWithSuffixIcon(controller: passEditController, hint: "Write Your Password".tr),
//       vSpacer10(),
//       Align(
//           alignment: Alignment.centerRight,
//           child: buttonText("Get Code".tr, textColor: bgColor, onPressCallback: () {
//             final password = passEditController.text;
//             if (password.length < DefaultValue.kPasswordLength) {
//               showToast("Password_invalid_length".trParams({"count": DefaultValue.kPasswordLength.toString()}), isError: true);
//               return;
//             }
//             hideKeyboard(context: context);
//             Get.find<GiftCardsController>().getGiftCardCode(gCard.uid ?? "", password, (code) => redeemCode.value = code);
//           })),
//       vSpacer10(),
//     ],
//   );
//   showModalSheetFullScreen(context, view);
// }
}

class RedeemCodeView extends StatelessWidget {
  const RedeemCodeView({super.key, required this.gCard, required this.code});

  final GiftCard gCard;
  final String code;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vSpacer10(),
        textAutoSizeKarla("Redeem code".tr, fontSize: Dimens.regularFontSizeLarge),
        Row(
          children: [
            Expanded(child: textAutoSizePoppins(code, fontSize: Dimens.regularFontSizeLarge, textAlign: TextAlign.start)),
            buttonOnlyIcon(
                iconData: Icons.copy,
                iconColor: context.theme.focusColor,
                visualDensity: minimumVisualDensity,
                onPressCallback: () => copyToClipboard(code)),
            textAutoSizePoppins("Or".tr, fontSize: Dimens.regularFontSizeMid),
            buttonOnlyIcon(
                iconData: Icons.share,
                iconColor: context.theme.focusColor,
                visualDensity: minimumVisualDensity,
                onPressCallback: () => shareText(code)),
          ],
        ),
        vSpacer10(),
      ],
    );
  }

// @override
// Widget build(BuildContext context) {
//   return Column(
//     children: [
//       vSpacer10(),
//       textAutoSizePoppins("Redeem code for".trParams({"name": gCard.banner?.title ?? ''}), maxLines: 3, fontSize: Dimens.regularFontSizeLarge),
//       vSpacer20(),
//       FittedBox(fit: BoxFit.scaleDown, child: textWithCopyView(code, fontSize: Dimens.titleFontSizeSmall)),
//       vSpacer10(),
//       textAutoSizePoppins("Or".tr, fontSize: Dimens.regularFontSizeMid),
//       vSpacer10(),
//       buttonText("Share".tr, onPressCallback: () {
//         final text = "$code ${"is the redeem code for".tr} ${gCard.banner?.title ?? ''}";
//         shareText(text);
//       }),
//       vSpacer20(),
//     ],
//   );
// }
}
