import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'banks_controller.dart';

class FlutterWaveBankPage extends StatelessWidget {
  FlutterWaveBankPage({super.key});

  final _controller = Get.find<BanksController>();
  final _acController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _controller.flutterWaveBanks.clear();
    _controller.countryMap.clear();
    _controller.selectedCountry.value = -1;
    _controller.selectedBankName.value = "";
    _controller.getFlutterWaveBankSaveDetails(DefaultValue.country);
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Dimens.paddingMid),
        children: [
          textAutoSizePoppins("Country".tr, textAlign: TextAlign.start),
          Obx(() {
            final list = _controller.countryMap.values.toList();
            return dropDownListIndex(list, _controller.selectedCountry.value, "Select Country".tr, hMargin: 0, (value) {
              _controller.selectedCountry.value = value;
              _controller.selectedBankName.value = '';
              _controller.flutterWaveBanks.clear();
              _controller.getFlutterWaveBankSaveDetails(_controller.countryMap.keys.toList()[value]);
            });
          }),
          Obx(() {
            final list = _controller.flutterWaveBanks.map((element) => "${element.name ?? ""} (${element.code ?? ""})").toList();
            return _controller.selectedCountry.value != -1
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vSpacer10(),
                      textAutoSizePoppins("Bank Name".tr, textAlign: TextAlign.start),
                      vSpacer5(),
                      DropdownWithSearch(
                          items: list,
                          selectedItem: _controller.selectedBankName.value,
                          hint:"Select Bank".tr,
                          onSelect: (value) => _controller.selectedBankName.value = value)
                    ],
                  )
                : vSpacer0();
          }),
          Obx(() {
            return _controller.selectedBankName.value.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vSpacer10(),
                      textAutoSizePoppins("Bank Account Number".tr, textAlign: TextAlign.start),
                      vSpacer5(),
                      textFieldWithSuffixIcon(controller: _acController, hint: "Enter bank account number".tr),
                      vSpacer20(),
                      buttonRoundedMain(text: "Add Bank".tr, onPressCallback: () => _checkInputs(context)),
                    ],
                  )
                : vSpacer0();
          }),
          vSpacer10(),
          Obx(() => _controller.isLoadingTRF.value ? showLoadingSmall() : vSpacer0()),
          vSpacer10(),
        ],
      ),
    );
  }

  void _checkInputs(BuildContext context) {
    if (_controller.selectedCountry.value == -1) {
      showToast("bank country required".tr);
      return;
    }
    if (_controller.selectedBankName.value.isEmpty) {
      showToast("bank name required".tr);
      return;
    }
    final account = _acController.text.trim();
    if (account.isEmpty) {
      showToast("Please, Input account number".tr);
      return;
    }
    hideKeyboard();
    Get.find<BanksController>().flutterWaveBankSave(account);
  }
}
