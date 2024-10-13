import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/models/wallet.dart';
import 'package:tradexpro_flutter/ui/features/bottom_navigation/wallet/swap/swap_screen.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

class CurrencyCheck {
  static const List<String> validCurrency = ["NGN"];

  static bool checkDepositCurrency(String? currency, BuildContext? context) {
    if (validCurrency.contains(currency)) {
      return true;
    } else {
      final con = context ?? Get.context;
      if (con != null) showModalSheetFullScreen(con, const DepositComingSoonView());
      return false;
    }
  }

  static bool checkWithdrawCurrency(String? currency, BuildContext? context) {
    if (validCurrency.contains(currency)) {
      return true;
    } else {
      final con = context ?? Get.context;
      if (con != null) showModalSheetFullScreen(con, WithdrawMessageView(code: currency));
      return false;
    }
  }
}

class DepositComingSoonView extends StatelessWidget {
  const DepositComingSoonView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        vSpacer10(),
        Icon(Icons.rocket, size: Dimens.iconSizeLogo, color: Get.theme.focusColor),
        vSpacer10(),
        textAutoSizeKarla('Coming Soon...'.tr, fontSize: Dimens.regularFontSizeMid),
        vSpacer10(),
        buttonText("Ok".tr.toUpperCase(), onPressCallback: () => Get.back()),
        vSpacer10(),
      ],
    );
  }
}

class WithdrawMessageView extends StatelessWidget {
  const WithdrawMessageView({super.key, this.code});

  final String? code;

  @override
  Widget build(BuildContext context) {
    final text = "${code ?? ''} ${"withdraw is currently unavailable. Instead you can swap your currency to".tr} ${CurrencyCheck.validCurrency}";
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        vSpacer10(),
        Icon(Icons.warning_amber_outlined, size: Dimens.iconSizeLogo, color: Get.theme.focusColor),
        vSpacer10(),
        textAutoSizeKarla(text, fontSize: Dimens.regularFontSizeMid, maxLines: 5),
        vSpacer20(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buttonText("Cancel".tr.toUpperCase(), onPressCallback: () => Get.back(), bgColor: Colors.grey),
            hSpacer10(),
            buttonText("Swap".tr.toUpperCase(), onPressCallback: () {
              Get.back();
              Get.to(() => SwapScreen(preWallet: Wallet(coinType: code, id: 0)));
            }),
          ],
        ),
        vSpacer10(),
      ],
    );
  }
}
