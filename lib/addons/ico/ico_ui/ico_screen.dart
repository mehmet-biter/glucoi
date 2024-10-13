import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/ico/ico_constants.dart';
import 'package:tradexpro_flutter/addons/ico/ico_ui/ico_dashboard/ico_dashboard_screen.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_phase.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_settings.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'ico_controller.dart';
import 'ico_launch_token/ico_launch_token_screen.dart';
import 'ico_phase_list_page.dart';
import 'ico_widgets.dart';

class ICOScreen extends StatefulWidget {
  const ICOScreen({super.key});

  @override
  State<ICOScreen> createState() => _ICOScreenState();
}

class _ICOScreenState extends State<ICOScreen> {
  final _controller = Get.put(IcoController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getIcoLaunchpadSettings(() => setState(() {}));
      _controller.getIcoPhaseActiveList(IcoPhaseSortType.featured);
      _controller.getIcoPhaseActiveList(IcoPhaseSortType.recent);
      _controller.getIcoPhaseActiveList(IcoPhaseSortType.future);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lPad = _controller.launchpad;
    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
                child: Column(
                  children: [
                    appBarBackWithActions(title: "ICO".tr),
                    _controller.isDataLoading
                        ? showLoading()
                        : Expanded(
                            child: ListView(
                            padding: const EdgeInsets.all(Dimens.paddingMid),
                            children: [
                              textAutoSizeKarla(lPad.launchpadFirstTitle ?? "", fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                              vSpacer10(),
                              InkWell(
                                onTap: () => alertForAction(context, subTitle: lPad.launchpadFirstDescription ?? "", maxLinesSub: 100),
                                child: textAutoSizeKarla(lPad.launchpadFirstDescription ?? "",
                                    fontSize: Dimens.regularFontSizeMid,
                                    textAlign: TextAlign.start,
                                    maxLines: 5,
                                    minFontSize: Dimens.regularFontSizeSmall),
                              ),
                              vSpacer10(),
                              AllTotalView(lPad: lPad),
                              vSpacer5(),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: buttonText("Launchpad Dashboard".tr,
                                      textColor: gIsDarkMode ? context.theme.scaffoldBackgroundColor : context.theme.primaryColor,
                                      onPressCallback: () => checkLoggedInStatus(context, () => Get.to(() => const ICODashboardScreen())))),
                              vSpacer20(),
                              textAutoSizeKarla(lPad.launchpadSecondTitle ?? "", fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                              vSpacer10(),
                              InkWell(
                                onTap: () => alertForAction(context, subTitle: lPad.launchpadSecondDescription ?? "", maxLinesSub: 100),
                                child: textAutoSizeKarla(lPad.launchpadSecondDescription ?? "",
                                    fontSize: Dimens.regularFontSizeMid,
                                    textAlign: TextAlign.start,
                                    maxLines: 5,
                                    minFontSize: Dimens.regularFontSizeSmall),
                              ),
                              vSpacer10(),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: buttonText("Apply To Launch Token".tr,
                                      borderColor: context.theme.focusColor,
                                      textColor: context.theme.primaryColor,
                                      bgColor: Colors.transparent,
                                      onPressCallback: () => checkLoggedInStatus(context, () => Get.to(() => const IcoLaunchTokenScreen())))),
                              Obx(() => _listView(_controller.featuredList, "Featured Items".tr, IcoPhaseSortType.featured)),
                              Obx(() => _listView(_controller.ongoingList, "Ongoing List".tr, IcoPhaseSortType.recent, isAll: true)),
                              Obx(() => _listView(_controller.futureList, "Future Items".tr, IcoPhaseSortType.future)),
                              vSpacer20(),
                              if (lPad.featureList.isValid)
                                textAutoSizeKarla(lPad.launchpadWhyChooseUsText ?? "",
                                    fontSize: Dimens.regularFontSizeLarge, textAlign: TextAlign.start),
                              if (lPad.featureList.isValid)
                                Column(
                                    children: List.generate(lPad.featureList!.length, (index) => FeaturedItemView(feature: lPad.featureList![index])))
                            ],
                          ))
                  ],
                ))),
      ),
    );
  }

  _listView(List<IcoPhase> list, String title, int type, {bool? isAll}) {
    return list.isValid
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vSpacer20(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                textAutoSizeKarla(title, fontSize: Dimens.regularFontSizeLarge),
                isAll == true
                    ? buttonText("View All".tr, bgColor: Colors.transparent, onPressCallback: () => Get.to(() => ICOPhaseListPage(type: type)))
                    : vSpacer0()
              ]),
              vSpacer10(),
              Column(children: List.generate(list.length, (index) => IcoPhaseItemView(phase: list[index])))
            ],
          )
        : vSpacer0();
  }
}

class AllTotalView extends StatelessWidget {
  const AllTotalView({super.key, required this.lPad});

  final IcoLaunchpad lPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: TotalView(value: lPad.currentFundsLocked, title: "Total Supplied Token".tr)),
              Expanded(child: TotalView(value: lPad.totalFundsRaised, title: "Total Sold Raised".tr)),
            ],
          ),
          vSpacer10(),
          Row(
            children: [
              Expanded(child: TotalView(value: lPad.projectLaunchpad, title: "Projects Launched".tr)),
              Expanded(child: TotalView(value: lPad.allTimeUniqueParticipants, title: "Total Participants".tr)),
            ],
          ),
        ],
      ),
    );
  }
}

class TotalView extends StatelessWidget {
  const TotalView({super.key, required this.value, required this.title});

  final num? value;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textAutoSizeKarla(coinFormat(value), fontSize: Dimens.regularFontSizeMid),
        vSpacer5(),
        textAutoSizeKarla(title ?? "", fontSize: Dimens.regularFontSizeExtraMid),
      ],
    );
  }
}

class FeaturedItemView extends StatelessWidget {
  const FeaturedItemView({super.key, required this.feature});

  final IcoFeature feature;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: boxDecorationRoundCorner(),
        padding: const EdgeInsets.all(Dimens.paddingMid),
        margin: const EdgeInsets.symmetric(vertical: Dimens.paddingMin),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: Dimens.paddingMin),
            child:
                showImageNetwork(imagePath: feature.image, width: Dimens.iconSizeLargeExtra, height: Dimens.iconSizeLargeExtra, boxFit: BoxFit.cover),
          ),
          hSpacer10(),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              textAutoSizePoppins(feature.title ?? "",
                  maxLines: 2, color: context.theme.primaryColor, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
              vSpacer5(),
              textAutoSizePoppins(feature.description ?? "", maxLines: 10, textAlign: TextAlign.start)
            ]),
          )
        ]));
  }
}
