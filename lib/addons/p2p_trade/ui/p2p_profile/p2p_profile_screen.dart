import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/ui/p2p_common_widgets.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';

import 'p2p_profile_controller.dart';

class P2pProfileScreen extends StatefulWidget {
  const P2pProfileScreen({Key? key, required this.userId}) : super(key: key);
  final int userId;

  @override
  P2pProfileScreenState createState() => P2pProfileScreenState();
}

class P2pProfileScreenState extends State<P2pProfileScreen> {
  final _controller = Get.put(P2pProfileController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getProfileDetails(widget.userId));
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
                    appBarBackWithActions(title: "User Profile".tr),
                    Obx(() {
                      final pDetails = _controller.profileDetails;
                      return _controller.isDataLoading.value
                          ? showLoading()
                          : Padding(
                              padding: const EdgeInsets.all(Dimens.paddingMid),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      P2pUserView(user: pDetails.user, isActiveOnTap: false, withName: true),
                                      coinDetailsItemView("Registered at".tr, "${pDetails.userRegisterAt ?? 0} ${"days ago".tr}")
                                    ],
                                  ),
                                  dividerHorizontal(),
                                  Table(
                                    children: [
                                      TableRow(children: [
                                        coinDetailsItemView("Total trades".tr, "${pDetails.totalTrade ?? 0}"),
                                        coinDetailsItemView("30d Trades".tr, "${pDetails.completionRate30D ?? 0}%"),
                                        coinDetailsItemView("First order at".tr, "${pDetails.firstOrderAt ?? 0} ${"days ago".tr}"),
                                      ]),
                                      TableRow(children: [vSpacer10(), vSpacer10(), vSpacer10()]),
                                      TableRow(children: [
                                        coinDetailsItemView("Positive reviews".tr, "${pDetails.positive ?? 0}"),
                                        coinDetailsItemView("Reviews percentage".tr, "${pDetails.positiveFeedback ?? 0}%"),
                                        coinDetailsItemView("Negative reviews".tr, "${pDetails.negative ?? 0}"),
                                      ]),
                                    ],
                                  ),
                                  vSpacer20(),
                                  Obx(() => tabBarText(["All".tr, "Positive".tr, "Negative".tr], _controller.selectedTab.value,
                                      (p0) => _controller.getFeedBackList(p0))),
                                  vSpacer10(),
                                  Obx(() {
                                    return _controller.feedBackList.isEmpty
                                        ? showEmptyView(height: Dimens.menuHeightSettings)
                                        : ListView.builder(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMin),
                                            shrinkWrap: true,
                                            itemCount: _controller.feedBackList.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              return FeedBackItemView(feedback: _controller.feedBackList[index]);
                                            },
                                          );
                                  })
                                ],
                              ),
                            );
                    })
                  ],
                ))),
      ),
    );
  }


}
