import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'ico_dashboard_controller.dart';

class IcoDashboardWithdrawPage extends StatefulWidget {
  const IcoDashboardWithdrawPage({super.key});

  @override
  State<IcoDashboardWithdrawPage> createState() => _IcoDashboardWithdrawPageState();
}

class _IcoDashboardWithdrawPageState extends State<IcoDashboardWithdrawPage> {
  final _controller = Get.find<IcoDashboardController>();
  final amountEditController = TextEditingController();
  RxInt selectedCurrencyType = 0.obs;
  RxInt selectedCurrency = 0.obs;
  Timer? _timer;
  RxString infoMessage = "".obs;

  @override
  void initState() {
    selectedCurrencyType.value = -1;
    selectedCurrency.value = -1;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getIcoTokenEarns());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final earn = _controller.icoWithdrawData.value.earns;
      return _controller.isLoading.value
          ? showLoading()
          : Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Dimens.paddingMid),
                children: [
                  Row(
                    children: [
                      Expanded(child: IcoTotalItemView(Icons.calendar_month_outlined, "Total Earned".tr, earn?.currency, earn?.earn)),
                      hSpacer10(),
                      Expanded(child: IcoTotalItemView(Icons.edit_calendar_outlined, "Withdrawal Amount".tr, earn?.currency, earn?.withdraw)),
                    ],
                  ),
                  vSpacer10(),
                  IcoTotalItemView(Icons.event_available_outlined, "Available Amount".tr, earn?.currency, earn?.available),
                  vSpacer20(),
                  textAutoSizeKarla("Currency Type".tr, fontSize: Dimens.regularFontSizeExtraMid, textAlign: TextAlign.start),
                  Obx(() {
                    final list = _controller.icoWithdrawData.value.currencyTypes?.values.toList() ?? [];
                    return dropDownListIndex(list, selectedCurrencyType.value, "Select Currency Type".tr, (index) {
                      selectedCurrency.value = -1;
                      selectedCurrencyType.value = index;
                    }, hMargin: 0);
                  }),
                  vSpacer10(),
                  textAutoSizeKarla("Currency".tr, fontSize: Dimens.regularFontSizeExtraMid, textAlign: TextAlign.start),
                  Obx(() {
                    final list = _getCurrencyList(selectedCurrencyType.value);
                    return dropDownListIndex(list, selectedCurrency.value, "Select Currency".tr, (index) {
                      selectedCurrency.value = index;
                      _getWithdrawPrice();
                    }, hMargin: 0);
                  }),
                  vSpacer10(),
                  textAutoSizeKarla("Amount".tr, fontSize: Dimens.regularFontSizeExtraMid, textAlign: TextAlign.start),
                  vSpacer5(),
                  textFieldWithSuffixIcon(
                      controller: amountEditController,
                      type: const TextInputType.numberWithOptions(decimal: true),
                      hint: "Enter Amount".tr,
                      onTextChange: _onTextChanged),
                  vSpacer2(),
                  Obx(() =>
                      infoMessage.value.isNotEmpty ? textAutoSizePoppins(infoMessage.value, textAlign: TextAlign.start, maxLines: 3) : vSpacer0()),
                  vSpacer20(),
                  buttonRoundedMain(text: "Withdraw".tr, onPressCallback: () => _checkAndMakeWithdraw()),
                  vSpacer10()
                ],
              ),
            );
    });
  }

  List<String> _getCurrencyList(int type) {
    if (type != -1) {
      final key = _controller.icoWithdrawData.value.currencyTypes?.keys.toList()[type];
      if (key == "1") {
        return _controller.icoWithdrawData.value.currencies?.map((e) => e.name ?? "").toList() ?? [];
      } else if (key == "2") {
        return _controller.icoWithdrawData.value.coins?.map((e) => e.coinType ?? "").toList() ?? [];
      }
    }
    return [];
  }

  void _onTextChanged(String amount) {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), () => _getWithdrawPrice());
  }

  void _getWithdrawPrice() {
    if (selectedCurrencyType.value == -1 || selectedCurrency.value == -1) return;
    final amount = makeDouble(amountEditController.text.trim());
    if (amount == 0) {
      infoMessage.value = "";
      return;
    } else if (amount < 0) {
      infoMessage.value = "amount_must_greater_than_0".tr;
      return;
    } else {
      final type = _controller.icoWithdrawData.value.currencyTypes?.keys.toList()[selectedCurrencyType.value];
      final currency = _getCurrencyList(selectedCurrencyType.value)[selectedCurrency.value];
      _controller.icoTokenWithdrawPrice(amount, type ?? "", currency, (error) {
        if (error.isValid) {
          infoMessage.value = error!;
        } else {
          infoMessage.value = "";
        }
      });
    }
  }

  _checkAndMakeWithdraw() {
    if (selectedCurrencyType.value == -1) {
      showToast("Select_currency_type".tr);
      return;
    }
    if (selectedCurrency.value == -1) {
      showToast("select your currency".tr);
      return;
    }
    final amount = makeDouble(amountEditController.text.trim());
    if (amount <= 0) {
      showToast("amount_must_greater_than_0".tr);
      return;
    }
    final type = _controller.icoWithdrawData.value.currencyTypes?.keys.toList()[selectedCurrencyType.value];
    final currency = _getCurrencyList(selectedCurrencyType.value)[selectedCurrency.value];
    _controller.icoTokenWithdrawRequest(amount, type ?? "", currency, () {
      selectedCurrencyType.value = -1;
      selectedCurrency.value = -1;
      amountEditController.text = "";
      infoMessage.value = "";
    });
  }
}

class IcoTotalItemView extends StatelessWidget {
  const IcoTotalItemView(this.icon, this.title, this.currency, this.amount, {super.key});

  final IconData icon;
  final String title;
  final String? currency;
  final double? amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundBorder(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      child: Column(
        children: [
          buttonIconWithBG(
              iconData: icon, bgColor: context.theme.focusColor, iconColor: context.theme.scaffoldBackgroundColor, size: Dimens.iconSizeLarge),
          vSpacer10(),
          textAutoSizeKarla("${coinFormat(amount)} $currency", fontSize: Dimens.regularFontSizeLarge),
          vSpacer5(),
          textAutoSizePoppins(title, color: context.theme.primaryColor),
        ],
      ),
    );
  }
}
