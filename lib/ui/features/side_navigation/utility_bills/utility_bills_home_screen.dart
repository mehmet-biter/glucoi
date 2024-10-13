import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/top_up.dart';
import 'package:tradexpro_flutter/data/models/utility_bills.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'utility_bills_controller.dart';

class UtilityBillHomeScreen extends StatefulWidget {
  const UtilityBillHomeScreen({Key? key}) : super(key: key);

  @override
  State<UtilityBillHomeScreen> createState() => _UtilityBillHomeScreenState();
}

class _UtilityBillHomeScreenState extends State<UtilityBillHomeScreen> {
  final _controller = Get.find<UtilityBillsController>();
  RxList<TopUpCountry> countries = <TopUpCountry>[].obs;
  RxList<UtilityBiller> billerList = <UtilityBiller>[].obs;
  RxBool isLoading = false.obs;
  RxInt selectedService = 0.obs;
  RxInt selectedCountry = 0.obs;
  RxInt selectedBiller = 0.obs;
  RxInt selectedCoin = 0.obs;
  RxInt selectedAmount = 0.obs;
  final _accountEditController = TextEditingController();
  final _amountEditController = TextEditingController();
  RxDouble totalToPay = 0.0.obs;
  Timer? _timer;

  @override
  void initState() {
    selectedService.value = -1;
    selectedCountry.value = -1;
    selectedBiller.value = -1;
    selectedCoin.value = -1;
    selectedAmount.value = -1;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_controller.utilityBillData.value.services.isValid) return;
      isLoading.value = true;
      _controller.getFlutterService((service) {
        _controller.utilityBillData.value = service;
        isLoading.value = false;
      });
      // _controller.getUtilityPageData((p0) {
      //   utilityBillData.value = p0;
      //   isLoading.value = false;
      // });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    _accountEditController.dispose();
    _amountEditController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: KeyboardDismissOnTap(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(Dimens.paddingMid),
          children: [
            Obx(() {
              List<String> items = <String>[];
              if (_controller.utilityBillData.value.services.isValid) {
                items = _controller.utilityBillData.value.services!.map((e) => (e.name ?? "").toCapitalizeFirst()).toList();
              }
              return items.isEmpty
                  ? vSpacer0()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        vSpacer10(),
                        textAutoSizeKarla("Select Service".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
                        dropDownListIndex(items, selectedService.value, "Select".tr, (index) => _getCountryData(index), hMargin: 0),
                      ],
                    );
            }),
            Obx(() {
              List<String> items = <String>[];
              if (countries.isValid) items = countries.map((e) => e.name ?? "").toList();
              return items.isEmpty
                  ? vSpacer0()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        vSpacer10(),
                        textAutoSizeKarla("Select Country".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
                        dropDownListIndex(items, selectedCountry.value, "Select".tr, (index) => _getUtilityBiller(index), hMargin: 0),
                      ],
                    );
            }),
            Obx(() {
              List<String> items = _getBillerNameList();
              // if (billerList.isValid) items = billerList.map((e) => e.name ?? "").toList();
              return items.isEmpty
                  ? vSpacer0()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        vSpacer10(),
                        textAutoSizeKarla("Select Utility Biller".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
                        dropDownListIndex(items, selectedBiller.value, "Select".tr, (index) => _setBillerData(index), hMargin: 0),
                      ],
                    );
            }),
            Obx(() {
              if (selectedBiller.value == -1) {
                return vSpacer0();
              } else {
                bool isReLoadLy = _controller.utilityBillData.value.services?[selectedService.value].reLoadLy ?? false;
                return isReLoadLy ? _billerDetailsView() : _billerDetailsViewFlutter();
              }
            }),
            Obx(() => totalToPay.value > 0 ? _rateView() : vSpacer10()),
            Obx(() => isLoading.value ? showLoading(padding: Dimens.paddingLargeExtra) : vSpacer0()),
          ],
        ),
      ),
    );
  }

  _getBillerNameList() {
    List<String> items = <String>[];
    if (billerList.isValid) {
      final service = _controller.utilityBillData.value.services?[selectedService.value];
      if (service != null) {
        if (service.reLoadLy ?? false) {
          items = billerList.map((e) => e.name ?? "").toList();
        } else {
          items = billerList.map((e) => "${e.name ?? ""} (${coinFormat(e.amount, fixed: 2)})").toList();
        }
      }
    }
    return items;
  }

  _billerDetailsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vSpacer10(),
        textAutoSizeKarla("Select Currency".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
        Obx(() {
          final items = _controller.utilityBillData.value.coins?.map((e) => e.coinType ?? "").toList() ?? [];
          return dropDownListIndex(items, selectedCoin.value, "Select".tr, hMargin: 0, (index) {
            selectedCoin.value = index;
            _getConvertedData();
          });
        }),
        vSpacer10(),
        textAutoSizeKarla("Account Number".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
        vSpacer5(),
        textFieldWithWidget(controller: _accountEditController, hint: "Enter Account".tr),
        vSpacer10(),
        textAutoSizeKarla("Amount".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
        Obx(() {
          final biller = (selectedBiller.value != -1 && billerList.isNotEmpty) ? billerList[selectedBiller.value] : null;
          return biller == null
              ? vSpacer0()
              : biller.denominationType == DenominationType.fixed
                  ? dropDownListIndex(_getAmountList(biller), selectedAmount.value, "Select Amount".tr, (index) {
                      selectedAmount.value = index;
                      _getConvertedData();
                    }, hMargin: 0)
                  : Padding(
                      padding: const EdgeInsets.only(top: Dimens.paddingMin),
                      child: textFieldWithSuffixIcon(
                          controller: _amountEditController,
                          hint: "Enter Amount".tr,
                          type: const TextInputType.numberWithOptions(decimal: true),
                          onTextChange: _onTextChange),
                    );
        }),
      ],
    );
  }

  _billerDetailsViewFlutter() {
    final biller = billerList[selectedBiller.value];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vSpacer10(),
        textAutoSizeKarla("Select Currency".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
        Obx(() {
          final items = _controller.utilityBillData.value.coins?.map((e) => e.coinType ?? "").toList() ?? [];
          return dropDownListIndex(items, selectedCoin.value, "Select".tr, hMargin: 0, (index) {
            selectedCoin.value = index;
          });
        }),
        vSpacer10(),
        textAutoSizeKarla(biller.labelName ?? "Account Number".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
        vSpacer5(),
        textFieldWithWidget(controller: _accountEditController, hint: "Enter Account".tr),
        vSpacer15(),
        buttonRoundedMain(text: "Confirm".tr, onPressCallback: () => _checkInputDataFlutter()),
        vSpacer15(),
      ],
    );
  }

  _rateView() {
    final coin = _controller.utilityBillData.value.coins.isValid ? (_controller.utilityBillData.value.coins![selectedCoin.value].coinType ?? "") : "";
    final operator = billerList[selectedBiller.value];
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

  void _getCountryData(int index) async {
    selectedService.value = index;
    if (selectedService.value == -1) return;
    isLoading.value = true;
    _clearView(1);
    final serviceType = _controller.utilityBillData.value.services?[selectedService.value];
    if (serviceType != null) {
      _controller.getUtilityCountry(serviceType, (list) {
        isLoading.value = false;
        countries.value = list;
      });
    }
  }

  void _getUtilityBiller(int index) async {
    selectedCountry.value = index;
    if (selectedService.value == -1 || selectedCountry.value == -1) return;

    isLoading.value = true;
    _clearView(2);
    final service = _controller.utilityBillData.value.services![selectedService.value];
    final country = countries[selectedCountry.value].code ?? "";
    _controller.getUtilityBiller(service, country, (list) {
      isLoading.value = false;
      billerList.value = list;
    });
  }

  void _setBillerData(int index) async {
    _clearView(3);
    selectedBiller.value = index;
  }

  void _clearView(int type) {
    if (type == 1) {
      countries.clear();
      selectedCountry.value = -1;
    }
    if (type == 1 || type == 2) {
      billerList.clear();
      selectedBiller.value = -1;
    }
    totalToPay.value = 0;
    selectedCoin.value = -1;
    selectedAmount.value = -1;
    _amountEditController.text = "";
    _accountEditController.text = "";
  }

  List<String> _getAmountList(UtilityBiller biller) {
    final list = <String>[];
    if (biller.internationalFixedAmounts != null) {
      final currencyCode = biller.fx?.currencyCode ?? "";
      final rate = biller.fx?.rate ?? 0;
      for (final fixedAmount in biller.internationalFixedAmounts!) {
        final value = ((fixedAmount.amount ?? 0) * rate).toInt();
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
    if (selectedBiller.value != -1 && billerList.isNotEmpty && selectedCoin.value != -1) {
      final operator = billerList[selectedBiller.value];
      double amount = 0;
      final rate = operator.fx?.rate ?? 0;
      if (operator.denominationType == DenominationType.fixed && operator.internationalFixedAmounts.isValid) {
        amount = operator.internationalFixedAmounts![selectedAmount.value].amount ?? 0;
      } else {
        amount = makeDouble(_amountEditController.text.trim()) / rate;
      }
      if (amount <= 0) {
        totalToPay.value = 0;
      } else {
        final coin = _controller.utilityBillData.value.coins![selectedCoin.value].coinType ?? "";
        final currency = operator.internationalTransactionCurrencyCode ?? "";
        totalToPay.value = 0;
        isLoading.value = true;
        _controller.getAirTimeConvertPrice(currency, coin, amount, (p0) {
          isLoading.value = false;
          totalToPay.value = p0;
        });
      }
    }
  }

  _checkInputData() {
    if (selectedCoin.value == -1) {
      showToast("select your currency".tr);
      return;
    }
    if (selectedBiller.value == -1) {
      showToast("select your biller".tr);
      return;
    }
    final account = _accountEditController.text.trim();
    if (account.isEmpty) {
      showToast("Please, Input account number".tr);
      return;
    }
    if (totalToPay.value <= 0) {
      showToast("input_select_amount".tr);
      return;
    }
    final type = _controller.utilityBillData.value.services![selectedService.value].type ?? "";
    final country = countries[selectedCountry.value].code ?? "";
    final biller = billerList[selectedBiller.value];
    final coin = _controller.utilityBillData.value.coins![selectedCoin.value].coinType ?? "";
    final rate = biller.fx?.rate ?? 0;
    double amount = biller.denominationType == DenominationType.fixed
        ? biller.internationalFixedAmounts![selectedAmount.value].amount ?? 0 * rate
        : makeDouble(_amountEditController.text.trim()) / rate;
    int? amountId = biller.denominationType == DenominationType.fixed ? biller.internationalFixedAmounts![selectedAmount.value].id : null;
    hideKeyboard();
    _controller.payUtilityBill(type, country, biller.id ?? 0, coin, account, amount, totalToPay.value, () => _controller.selectedTabIndex.value = 1,
        amountId: amountId);
  }

  _checkInputDataFlutter() {
    final service = _controller.utilityBillData.value.services?[selectedService.value];
    if (service != null) {
      if (selectedBiller.value == -1) {
        showToast("select your biller".tr);
        return;
      }
      if (selectedCoin.value == -1) {
        showToast("select your currency".tr);
        return;
      }
      final biller = billerList[selectedBiller.value];
      final account = removeSpecialChar(_accountEditController.text.trim());
      if (account.isEmpty) {
        showToast("${biller.labelName ?? "Account Number".tr} ${"is required".tr}");
        return;
      }
      hideKeyboard();
      _controller.getValidateFlutterBiller(biller, account, () {
        final country = countries[selectedCountry.value].code ?? "";
        final currency = _controller.utilityBillData.value.coins![selectedCoin.value].coinType ?? "";
        _controller.payFlutterBiller(service.type ?? "", country, currency, biller, account, () {
          TemporaryData.activityType = service.type;
          _controller.selectedTabIndex.value = 1;
          _controller.tabController?.animateTo(1);
        });
      });
    }
  }
}
