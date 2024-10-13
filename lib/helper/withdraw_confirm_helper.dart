import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/utils/local_auth_helper.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'app_helper.dart';

class WithdrawConfirmHelper {
  bool isWithdraw2FActive = getSettingsLocal()?.twoFactorWithdraw == "1";
  late Function(String code) onValidAction;

  void checkWithdrawToConfirmCrypto(BuildContext context, String subTitle, Function(String code) onValid) {
    onValidAction = onValid;
    hideKeyboard();
    if (isWithdraw2FActive && !gUserRx.value.google2FaSecret.isValid) {
      showToast("Please setup your google 2FA".tr);
      return;
    }
    showModalSheetFullScreen(context, _withdrawConfirmView(subTitle, false));
  }

  void checkWithdrawToConfirmFiat(BuildContext context, String subTitle, Function(String code) onValid) {
    onValidAction = onValid;
    isWithdraw2FActive = false;
    hideKeyboard();
    showModalSheetFullScreen(context, _withdrawConfirmView(subTitle, true));
  }

  _withdrawConfirmView(String subTitle, bool isCurrency) {
    final codeEditController = TextEditingController();
    return Column(
      children: [
        vSpacer10(),
        textAutoSizeKarla(isCurrency ? "Fiat Withdrawal".tr : "Withdrawal Coin".tr, fontSize: Dimens.regularFontSizeLarge),
        vSpacer10(),
        textAutoSizeKarla(subTitle, maxLines: 5, fontSize: Dimens.regularFontSizeMid),
        vSpacer10(),
        if (isWithdraw2FActive) textFieldWithSuffixIcon(controller: codeEditController, hint: "Input 2FA code".tr, labelText: "2FA code".tr),
        vSpacer15(),
        buttonRoundedMain(text: "Withdraw".tr, onPressCallback: () => _handleWithdrawProcess(codeEditController.text.trim())),
        vSpacer10(),
      ],
    );
  }

  Future<void> _handleWithdrawProcess(String code) async {
    if (isWithdraw2FActive && code.length < DefaultValue.codeLength) {
      showToast("Code length must be".trParams({"count": DefaultValue.codeLength.toString()}));
      return;
    }
    hideKeyboard();
    final bioAuth = !isWithdraw2FActive && await LocalAuthHelper.isBiometricsSupported(isShow: false);
    if (bioAuth) {
      if (await LocalAuthHelper.checkBiometrics()) {
        onValidAction(code);
      }
    } else {
      onValidAction(code);
    }
  }
}
