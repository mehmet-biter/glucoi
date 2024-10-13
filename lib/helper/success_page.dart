import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/colors.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key, this.title, this.subtitle, this.onDone, this.btnTitle});

  final String? title;
  final String? subtitle;
  final String? btnTitle;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          vSpacer15(),
          Icon(Icons.verified, size: context.width / 3.2, color: Colors.green),
          vSpacer20(),
          textAutoSizeKarla(title ?? 'Transaction Successful'.tr, color: cCharleston),
          if (subtitle.isValid) vSpacer15(),
          textAutoSizePoppins(subtitle ?? "", maxLines: 10, color: cCharleston),
          vSpacer20(),
          buttonRoundedMain(text: btnTitle ?? "Done".tr, onPressCallback: onDone ?? () => Get.back(), bgColor: cCharleston),
          vSpacer15(),
        ],
      ),
    );
  }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: context.theme.colorScheme.background,
//     body: SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(Dimens.paddingLarge),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             vSpacer15(),
//             Icon(Icons.verified, size: context.width / 3.2, color: Get.theme.focusColor),
//             vSpacer15(),
//             textAutoSizeKarla(title ?? 'Transaction Successful'.tr),
//             if (subtitle.isValid) vSpacer10(),
//             textAutoSizePoppins(subtitle ?? "", maxLines: 10),
//             vSpacer15(),
//             buttonRoundedMain(text: btnTitle ?? "Done".tr, onPressCallback: () => onDone ?? Get.back()),
//             vSpacer15(),
//           ],
//         ),
//       ),
//     ),
//   );
// }
}

class SuccessPageFullScreen extends StatelessWidget {
  const SuccessPageFullScreen({super.key, this.title, this.subtitle, this.onDone, this.btnTitle});

  final String? title;
  final String? subtitle;
  final String? btnTitle;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.focusColor,
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
            child: Padding(
              padding: const EdgeInsets.all(Dimens.paddingLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  vSpacer15(),
                  Icon(Icons.verified, size: context.width / 3.2, color: Colors.green.shade700),
                  vSpacer20(),
                  textAutoSizeKarla(title ?? 'Transaction Successful'.tr, color: cCharleston),
                  if (subtitle.isValid) vSpacer15(),
                  textAutoSizePoppins(subtitle ?? "", maxLines: 10, color: cCharleston),
                  vSpacer20(),
                  buttonRoundedMain(text: btnTitle ?? "Done".tr, onPressCallback: onDone ?? () => Get.back(), bgColor: cCharleston),
                  vSpacer15(),
                ],
              ),
            )),
      ),
    );
  }
}
