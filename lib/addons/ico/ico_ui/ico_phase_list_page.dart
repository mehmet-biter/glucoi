import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/ico/ico_constants.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_phase.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';

import 'ico_controller.dart';
import 'ico_widgets.dart';

class ICOPhaseListPage extends StatefulWidget {
  const ICOPhaseListPage({super.key, required this.type});

  final int type;

  @override
  State<ICOPhaseListPage> createState() => _ICOPhaseListPageState();
}

class _ICOPhaseListPageState extends State<ICOPhaseListPage> {
  final _controller = Get.find<IcoController>();
  List<IcoPhase> phaseList = <IcoPhase>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getPhaseActiveList(widget.type, (list) {
        phaseList = list;
        isLoading = false;
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == IcoPhaseSortType.recent ? "Ongoing List".tr : "";
    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
                child: Column(
                  children: [
                    appBarBackWithActions(title: title),
                    isLoading
                        ? showLoading()
                        : Expanded(
                            child: ListView.builder(
                            padding: const EdgeInsets.all(Dimens.paddingMid),
                            itemCount: phaseList.length,
                            itemBuilder: (context, index) => IcoPhaseItemView(phase: phaseList[index]),
                          ))
                  ],
                ))),
      ),
    );
  }
}
