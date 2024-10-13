import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/ui/features/side_navigation/top_up/top_up_home_screen.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';

import 'top_up_controller.dart';
import 'top_up_history_screen.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({Key? key}) : super(key: key);

  @override
  TopUpScreenState createState() => TopUpScreenState();
}

class TopUpScreenState extends State<TopUpScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  final _controller = Get.put(TopUpController());
  final tabList = ["Top Up".tr, "History".tr];

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
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
                appBarBackWithActions(title: "Top Up".tr),
                if (gUserRx.value.id > 0) tabBarUnderline(tabList, _tabController, onTap: (index) => _controller.selectedTabIndex.value = index),
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
          return const TopUpHomeScreen();
        case 1:
          return const TopUpHistoryScreen();
        default:
          return Container();
      }
    });
  }
}
