import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';

import 'ico_dashboard_controller.dart';
import 'ico_dashboard_list_page.dart';
import 'ico_dashboard_withdraw_page.dart';

class ICODashboardScreen extends StatefulWidget {
  const ICODashboardScreen({super.key});

  @override
  State<ICODashboardScreen> createState() => _ICODashboardScreenState();
}

class _ICODashboardScreenState extends State<ICODashboardScreen> {
  final _controller = Get.put(IcoDashboardController());
  final types = ["Applied Launchpad".tr, "ICO Tokens".tr, "Token Buy History".tr, "Token Wallet".tr, "Withdraw".tr];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
                child: Column(
                  children: [
                    appBarBackWithActions(title: "ICO Dashboard".tr),
                    Obx(() => dropDownListIndex(types, _controller.selectedType.value, "", (index) => _controller.selectedType.value = index)),
                    Obx(() => _controller.selectedType.value == 4 ? const IcoDashboardWithdrawPage() : IcoDashboardListPage())
                  ],
                ))),
      ),
    );
  }
}
