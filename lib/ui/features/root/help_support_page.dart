import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';

import '../side_navigation/faq/faq_page.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  HelpSupportPageState createState() => HelpSupportPageState();
}

class HelpSupportPageState extends State<HelpSupportPage> {
  @override
  Widget build(BuildContext context) {
    final hasUser = gUserRx.value.id > 0;
    final settings = getSettingsLocal();
    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
              child: Column(
                children: [
                  appBarBackWithActions(title: "Help_Support".tr),
                  vSpacer10(),
                  if (hasUser && settings?.liveChatStatus == 1)
                    DrawerMenuItem(
                        navTitle: 'Chat With Support'.tr,
                        iconData: Icons.contact_support_outlined,
                        navAction: () async => _initIntercom(settings?.liveChatKey)),
                  DrawerMenuItem(navTitle: 'FAQ'.tr, iconData: Icons.quiz_outlined, navAction: () => Get.to(() => const FAQPage())),
                ],
              )),
        ),
      ),
    );
  }

  _initIntercom(String? key) async {
    if (gUserRx.value.id > 0 && key.isValid) {
      showLoadingDialog();
      await Intercom.instance
          .initialize(key ?? '', iosApiKey: dotenv.env[EnvKeyValue.kIntercomIOSKey], androidApiKey: dotenv.env[EnvKeyValue.kIntercomAndroidKey]);
      await Intercom.instance.loginIdentifiedUser(email: gUserRx.value.email);
      hideLoadingDialog();
      await Intercom.instance.displayMessenger();
    }
  }
}
