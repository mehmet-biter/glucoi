import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_dashboard.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_phase.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';

import '../ico_create_phase/ico_create_phase_screen.dart';
import 'ico_phase_add_dynamic_screen.dart';
import 'ico_token_phase_list_controller.dart';

class IcoTokenPhaseListScreen extends StatefulWidget {
  const IcoTokenPhaseListScreen({super.key, required this.token});

  final IcoToken token;

  @override
  State<IcoTokenPhaseListScreen> createState() => _IcoTokenPhaseListScreenState();
}

class _IcoTokenPhaseListScreenState extends State<IcoTokenPhaseListScreen> {
  final _controller = Get.put(IcoTokenPhaseListController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getIcoListData(false, widget.token.id ?? 0);
    });
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
                    appBarBackWithActions(title: "Token Phase List".tr),
                    Obx(() {
                      return _controller.phaseList.isEmpty
                          ? handleEmptyViewWithLoading(_controller.isLoading.value)
                          : Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(Dimens.paddingMid),
                                itemCount: _controller.phaseList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (_controller.hasMoreData && index == (_controller.phaseList.length - 1) && !_controller.isLoading.value) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((timeStamp) => _controller.getIcoListData(true, widget.token.id ?? 0));
                                  }
                                  return IcoTokenItemView(phase: _controller.phaseList[index]);
                                },
                              ),
                            );
                    })
                  ],
                ))),
      ),
    );
  }
}

class IcoTokenItemView extends StatelessWidget {
  const IcoTokenItemView({super.key, required this.phase});

  final IcoPhase phase;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).textScaleFactor > 1 ?(Dimens.btnHeightMain + 5) : Dimens.btnHeightMain;
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.only(bottom: Dimens.paddingMid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          vSpacer5(),
          textFieldWithSuffixIcon(
              controller: TextEditingController(text: phase.phaseTitle), labelText: "Phase Title", isEnable: false, height: height),
          vSpacer5(),
          twoTextSpaceFixed("Token Name".tr, phase.tokenName ?? ""),
          twoTextSpaceFixed("Total Token".tr, "${coinFormat(phase.totalTokenSupply)} ${phase.coinType ?? ""}"),
          twoTextSpaceFixed("Available Token".tr, "${coinFormat(phase.availableTokenSupply)} ${phase.coinType ?? ""}", flex: 4),
          twoTextSpaceFixed("Coin Price".tr, "${coinFormat(phase.coinPrice)} ${phase.coinCurrency ?? ""}"),
          twoTextSpaceFixed("Start Date".tr, formatDate(phase.startDate, format: dateTimeFormatDdMMMMYyyyHhMm)),
          twoTextSpaceFixed("End Date".tr, formatDate(phase.endDate, format: dateTimeFormatDdMMMMYyyyHhMm)),
          dividerHorizontal(height: 10),
          Row(
            children: [
              toggleSwitch(
                  height: Dimens.btnHeightMin,
                  selectedValue: phase.status == 1,
                  onChange: (v) => Get.find<IcoTokenPhaseListController>().icoSavePhaseStatus(phase)),
              const Spacer(),
              buttonOnlyIcon(
                  iconData: Icons.drive_file_rename_outline_rounded,
                  size: Dimens.iconSizeMid,
                  visualDensity: minimumVisualDensity,
                  iconColor: context.theme.primaryColor,
                  onPressCallback: () => Get.to(() => IcoCreatePhaseScreen(prePhase: phase))),
              buttonOnlyIcon(
                  iconData: Icons.playlist_add_rounded,
                  size: Dimens.iconSizeMid,
                  visualDensity: minimumVisualDensity,
                  iconColor: context.theme.primaryColor,
                  onPressCallback: () => Get.to(() => IcoPhaseAddInfoScreen(prePhase: phase))),
            ],
          )
        ],
      ),
    );
  }
}
