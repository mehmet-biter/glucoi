import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.focusColor,
      body: GetBuilder<SplashController>(
          init: SplashController(),
          builder: (splashController) {
            return Container(
              padding: const EdgeInsets.all(0),
              width: Get.width,
              height: Get.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// const AppLogo(),
                  showImageAsset(
                      imagePath: AssetConstants.icLogoTransparentNoPadding, height: context.width / 4, width: context.width / 4, color: Colors.white),
                  // Padding(
                  //   padding: const EdgeInsets.all(Dimens.paddingLargeDouble),
                  //   child: textAutoSizeTitle('splashLogoSubText'.tr, color: Colors.white),
                  // ),
                ],
              ),
            );
          }),
    );
  }
}
