import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../ui/features/side_navigation/profile/profile_screen.dart';

class KycVerifyNeedPage extends StatelessWidget {
  const KycVerifyNeedPage({super.key, this.onCancel});

  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:  false,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMid, horizontal: Dimens.paddingMid),
            margin: const EdgeInsets.symmetric(vertical: Dimens.paddingLarge, horizontal: Dimens.paddingLarge),
            decoration: boxDecorationRoundCorner(color: Get.theme.colorScheme.background),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                vSpacer50(),
                showImageAsset(imagePath: AssetConstants.icKyc, width: context.width / 3, boxFit: BoxFit.fitWidth),
                vSpacer20(),
                textAutoSizeKarla('complete_verification_message'.tr, maxLines: 2),
                vSpacer50(),
                Padding(
                  padding: const EdgeInsets.all(Dimens.paddingLarge),
                  child: Column(
                    children: [
                      vSpacer10(),
                      buttonRoundedMain(
                          text: "Verify".tr.toUpperCase(),
                          onPressCallback: () {
                            Get.back();
                            Get.to(() => const ProfileScreen(viewType: 2));
                          }),
                      vSpacer10(),
                      buttonRoundedMain(
                          text: "i will do it later".tr.toUpperCase(),
                          onPressCallback: () {
                            Get.back();
                            if (onCancel != null) onCancel!();
                          },
                          bgColor: Colors.transparent,
                          textColor: context.theme.primaryColor),
                      vSpacer10(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: context.theme.colorScheme.background,
//     body: SafeArea(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           appBarBackWithActions(title: ""),
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               vSpacer10(),
//               Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Icon(Icons.crop_free, size: context.width / 2, color: Get.theme.focusColor),
//                   Icon(Icons.photo_camera_front_outlined, size: context.width / 4, color: Get.theme.focusColor),
//                 ],
//               ),
//               vSpacer10(),
//               textAutoSizeKarla('complete_verification_message'.tr, maxLines: 2),
//             ],
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingLarge),
//             child: Column(
//               children: [
//                 vSpacer10(),
//                 buttonRoundedMain(
//                     text: "Verify".tr.toUpperCase(),
//                     onPressCallback: () {
//                       if (onDone != null) onDone;
//                     }),
//                 vSpacer10(),
//                 buttonRoundedMain(
//                     text: "i will do it later".tr.toUpperCase(),
//                     onPressCallback: () => Get.back(),
//                     bgColor: Colors.transparent,
//                     textColor: context.theme.primaryColor),
//                 vSpacer10(),
//               ],
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }
}
