import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/top_up.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'top_up_controller.dart';

class TopUpHomeScreen extends StatefulWidget {
  const TopUpHomeScreen({Key? key}) : super(key: key);

  @override
  State<TopUpHomeScreen> createState() => _TopUpHomeScreenState();
}

class _TopUpHomeScreenState extends State<TopUpHomeScreen> {
  final _controller = Get.find<TopUpController>();
  Rx<TopUpData> topUpData = TopUpData().obs;
  RxBool isLoading = true.obs;
  RxInt selectedCountry = 0.obs;
  RxInt selectedCoin = 0.obs;
  RxInt selectedOperator = 0.obs;
  RxInt selectedAmount = 0.obs;
  RxList<TopUpOperator> operators = <TopUpOperator>[].obs;
  final _phoneEditController = TextEditingController();
  final _amountEditController = TextEditingController();
  RxDouble totalToPay = 0.0.obs;
  Timer? _timer;

  @override
  void initState() {
    selectedCountry.value = -1;
    selectedCoin.value = -1;
    selectedOperator.value = -1;
    selectedAmount.value = -1;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getTopUpData((p0) => setState(() {
            isLoading.value = false;
            topUpData.value = p0;
          }));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _phoneEditController.dispose();
    _amountEditController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Dimens.paddingMid),
        children: [
          Obx(() {
            List<String> items = <String>[];
            if (topUpData.value.country.isValid) items = topUpData.value.country!.map((e) => e.name ?? "").toList();
            return items.isEmpty
                ? vSpacer0()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vSpacer10(),
                      textAutoSizeKarla("Select Country".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
                      dropDownListIndex(items, selectedCountry.value, "Select".tr, (index) => _getOperatorsData(index), hMargin: 0)
                    ],
                  );
          }),
          Obx(() {
            List<String> items = <String>[];
            if (topUpData.value.coins.isValid) items = topUpData.value.coins!.map((e) => e.coinType ?? "").toList();
            return items.isEmpty
                ? vSpacer0()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vSpacer10(),
                      textAutoSizeKarla("Select Currency".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
                      dropDownListIndex(items, selectedCoin.value, "Select".tr, (index) {
                        selectedCoin.value = index;
                        _getConvertedData();
                      }, hMargin: 0)
                    ],
                  );
          }),
          Obx(() {
            Country countryCode = Country.parse(DefaultValue.country);
            if (selectedCountry.value != -1 && topUpData.value.country != null) {
              final code = topUpData.value.country![selectedCountry.value].code ?? DefaultValue.country;
              countryCode = Country.parse(code);
            }
            _phoneEditController.text = countryCode.phoneCode;
            return operators.isEmpty
                ? vSpacer0()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vSpacer10(),
                      textAutoSizeKarla("Select Operator".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
                      vSpacer5(),
                      Column(
                        children: List.generate(operators.length, (index) {
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                                onTap: () {
                                  selectedAmount.value = -1;
                                  _amountEditController.text = '';
                                  totalToPay.value = 0;
                                  selectedOperator.value = index;
                                },
                                child: TopUpOperatorView(operator: operators[index], isSelected: selectedOperator.value == index)),
                          );
                        }),
                      ),
                      vSpacer10(),
                      textAutoSizeKarla("Recipient Phone".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
                      vSpacer5(),
                      textFieldWithWidget(
                          controller: _phoneEditController,
                          type: TextInputType.phone,
                          prefixWidget: countryPickerView(context, countryCode, (value) {}, showPhoneCode: true, isEnable: false)),
                    ],
                  );
          }),
          Obx(() {
            final operator = (selectedOperator.value != -1 && operators.isNotEmpty) ? operators[selectedOperator.value] : null;
            return operator == null
                ? vSpacer0()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      vSpacer10(),
                      textAutoSizeKarla("Amount".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
                      operator.denominationType == DenominationType.fixed ? vSpacer0() : vSpacer5(),
                      operator.denominationType == DenominationType.fixed
                          ? dropDownListIndex(_getAmountList(operator), selectedAmount.value, "Select Amount".tr, (index) {
                              selectedAmount.value = index;
                              _getConvertedData();
                            }, hMargin: 0)
                          : textFieldWithSuffixIcon(
                              controller: _amountEditController,
                              hint: "Enter Amount".tr,
                              type: const TextInputType.numberWithOptions(decimal: true),
                              onTextChange: _onTextChange)
                    ],
                  );
          }),
          Obx(() => totalToPay.value > 0 ? _rateView() : vSpacer10()),
          Obx(() => isLoading.value ? showLoading() : vSpacer0()),
        ],
      ),
    );
  }

  void _getOperatorsData(int index) async {
    selectedCountry.value = index;
    if (selectedCountry.value == -1) return;
    isLoading.value = true;
    operators.clear();
    selectedOperator.value = -1;
    final code = topUpData.value.country?[selectedCountry.value].code ?? "";
    _controller.getTopUpOperatorsOf(code, (list) {
      isLoading.value = false;
      operators.value = list;
    });
  }

  List<String> _getAmountList(TopUpOperator operator) {
    final list = <String>[];
    if (operator.fixedAmounts != null) {
      final currencyCode = operator.fx?.currencyCode ?? "";
      final rate = operator.fx?.rate ?? 0;
      for (final amount in operator.fixedAmounts!) {
        final value = (amount * rate).toInt();
        list.add("$currencyCode $value");
      }
      return list;
    }
    return list;
  }

  void _onTextChange(String text) {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), () => _getConvertedData());
  }

  void _getConvertedData() {
    if (selectedOperator.value != -1 && operators.isNotEmpty && selectedCoin.value != -1) {
      final operator = operators[selectedOperator.value];
      double amount = 0;
      final rate = operator.fx?.rate ?? 0;
      if (operator.denominationType == DenominationType.fixed && operator.fixedAmounts.isValid) {
        amount = operator.fixedAmounts![selectedAmount.value] * rate;
      } else {
        amount = makeDouble(_amountEditController.text.trim()) / rate;
      }
      if (amount <= 0) {
        totalToPay.value = 0;
        isLoading.value = false;
      } else {
        final coin = topUpData.value.coins![selectedCoin.value].coinType ?? "";
        final currency = operators[selectedOperator.value].senderCurrencyCode ?? "";
        isLoading.value = true;
        _controller.getAirTimeConvertPrice(currency, coin, amount, (p0) {
          isLoading.value = false;
          totalToPay.value = p0;
        });
      }
    }
  }

  _rateView() {
    final coin = topUpData.value.coins.isValid ? (topUpData.value.coins![selectedCoin.value].coinType ?? "") : "";
    final operator = operators[selectedOperator.value];
    final amountStr = operator.denominationType == DenominationType.fixed
        ? _getAmountList(operator)[selectedAmount.value]
        : "${operator.fx?.currencyCode ?? ""} ${_amountEditController.text.trim()}";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vSpacer20(),
        twoTextSpaceFixed("Delivery Amount".tr, amountStr, flex: 4),
        vSpacer5(),
        twoTextSpaceFixed("Total To Pay".tr, "$coin ${coinFormat(totalToPay.value)}", flex: 4),
        vSpacer15(),
        buttonRoundedMain(text: "Confirm".tr, onPressCallback: () => _checkInputData()),
        vSpacer15(),
      ],
    );
  }

  _checkInputData() {
    if (selectedCoin.value == -1) {
      showToast("select your currency".tr);
      return;
    }
    if (selectedOperator.value == -1) {
      showToast("select your operator".tr);
      return;
    }
    final countryCode = topUpData.value.country![selectedCountry.value].code ?? "";
    String phone = _phoneEditController.text.trim();
    if (phone.length > Country.parse(countryCode).phoneCode.length) {
      phone = removeSpecialChar(phone);
    } else {
      showToast("Input a valid Phone".tr);
      return;
    }
    if (totalToPay.value <= 0) {
      showToast("input_select_amount".tr);
      return;
    }

    final operator = operators[selectedOperator.value];
    final rate = operator.fx?.rate ?? 0;
    double amount = operator.denominationType == DenominationType.fixed
        ? operator.fixedAmounts![selectedAmount.value] * rate
        : makeDouble(_amountEditController.text.trim()) / rate;
    final currency = topUpData.value.coins![selectedCoin.value].coinType ?? "";
    hideKeyboard();
    _controller.makeTopUp(countryCode, currency, operator.id ?? 0, phone, amount, totalToPay.value, () => _controller.selectedTabIndex.value = 1);
  }
}

class TopUpOperatorView extends StatelessWidget {
  const TopUpOperatorView({super.key, required this.operator, required this.isSelected});

  final TopUpOperator operator;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final logo = operator.logoUrls.isValid ? operator.logoUrls?.first : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMin),
      child: Row(
        children: [
          Radio(groupValue: operator.id, value: isSelected ? operator.id : "", onChanged: (value) {}),
          showImageNetwork(imagePath: logo, height: Dimens.iconSizeLargeExtra, width: Dimens.iconSizeLargeExtra),
          hSpacer10(),
          Expanded(child: textAutoSizeKarla(operator.name ?? "", fontSize: Dimens.regularFontSizeMid, maxLines: 2, textAlign: TextAlign.start))
        ],
      ),
    );
  }
}
