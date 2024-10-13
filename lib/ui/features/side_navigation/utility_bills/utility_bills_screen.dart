import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';

import 'utility_bills_controller.dart';
import 'utility_bills_history_screen.dart';
import 'utility_bills_home_screen.dart';

class UtilityBillsScreen extends StatefulWidget {
  const UtilityBillsScreen({Key? key}) : super(key: key);

  @override
  UtilityBillsScreenState createState() => UtilityBillsScreenState();
}

class UtilityBillsScreenState extends State<UtilityBillsScreen> with SingleTickerProviderStateMixin {
  final _controller = Get.put(UtilityBillsController());
  final tabList = ["Pay Bill".tr, "History".tr];

  @override
  void initState() {
    _controller.tabController = TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
            child: Column(
              children: [
                appBarBackWithActions(title: "Utility Bill".tr),
                if (gUserRx.value.id > 0)
                  tabBarUnderline(tabList, _controller.tabController, onTap: (index) => _controller.selectedTabIndex.value = index),
                dividerHorizontal(height: 0),
                vSpacer5(),
                getTabBody()
              ],
            ),
          ),
        ),
      ),
    );
  }

  getTabBody() {
    return Obx(() {
      switch (_controller.selectedTabIndex.value) {
        case 0:
          return const UtilityBillHomeScreen();
        case 1:
          return const UtilityBillHistoryScreen();
        default:
          return Container();
      }
    });
  }
}
