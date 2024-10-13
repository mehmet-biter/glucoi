import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

class TwoFAHelper {
  static void get2FACode(Function(String) onCode, {String? forText, String? buttonText}) {
    TextEditingController codeEditController = TextEditingController();
    var message = "2fa authenticator code input message".tr;
    if (forText.isValid) message = message + "for_space".tr + forText!;
    buttonText = buttonText ?? "Proceed".tr;
    final settings = getSettingsLocal();
    showModalSheetFullScreen(
        Get.context!,
        Column(
          children: [
            vSpacer10(),
            showImageAsset(imagePath: AssetConstants.icAuthenticator, width: Get.width / 4),
            vSpacer10(),
            textAutoSizeKarla(message, maxLines: 3, fontSize: Dimens.regularFontSizeMid),
            vSpacer15(),
            textFieldWithSuffixIcon(controller: codeEditController, labelText: "Your Code".tr, hint: "Your Code".tr, type: TextInputType.number),
            vSpacer20(),
            buttonRoundedMain(
                text: buttonText,
                onPressCallback: () {
                  final code = codeEditController.text.trim();
                  if (code.length != DefaultValue.codeLength) {
                    showToast("Code length must be".trParams({"count": DefaultValue.codeLength.toString()}));
                    return;
                  }
                  onCode(code);
                }),
            vSpacer20(),
            if (settings?.supportEmail.isValid ?? false)
              textSpanWithAction(settings?.messageForLostAuthenticator ?? '', settings?.supportEmail ?? '', () {
                mailToAddress(settings?.supportEmail ?? '', subject: "${"Disable 2FA for".tr} @${gUserRx.value.nickName}");
              }, maxLines: 10, mainColor: Get.theme.primaryColor.withOpacity(0.6)),
            if (settings?.supportEmail.isValid ?? false) vSpacer10(),
          ],
        ));
  }
}
