import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'currency_controller.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({Key? key}) : super(key: key);

  @override
  CurrencyScreenState createState() => CurrencyScreenState();
}

class CurrencyScreenState extends State<CurrencyScreen> {
  final _controller = Get.put(CurrencyController());

  @override
  void initState() {
    super.initState();
    _controller.selectedCurrency.value = -1;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getUserSetting());
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
                appBarBackWithActions(title: "Change Currency".tr),
                Obx(() {
                  final list = getCurrencyList(_controller.userSettings.value.fiatCurrency);
                  return ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(Dimens.paddingMid),
                    children: [
                      vSpacer10(),
                      textAutoSizePoppins("Change_primary_currency".trParams({"value": _controller.preCurrency}),
                          maxLines: 2, textAlign: TextAlign.start, color: context.theme.primaryColor),
                      vSpacer10(),
                      dropDownListIndex(list, _controller.selectedCurrency.value, "Select".tr, (value) {
                        _controller.selectedCurrency.value = value;
                      }, hMargin: 0),
                      vSpacer20(),
                      buttonRoundedMain(text: "Update".tr, onPressCallback: () => _controller.saveCurrency()),
                      vSpacer10(),
                      _controller.isLoading.value ? showLoadingSmall() : vSpacer0(),
                    ],
                  );
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
