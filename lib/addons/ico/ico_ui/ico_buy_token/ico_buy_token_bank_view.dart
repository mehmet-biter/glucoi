import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/ico/ico_ui/ico_widgets.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_phase.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_settings.dart';
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

import 'ico_buy_token_controller.dart';

class IcoBuyTokenBankView extends StatefulWidget {
  const IcoBuyTokenBankView({super.key});

  @override
  State<IcoBuyTokenBankView> createState() => _IcoBuyTokenBankViewState();
}

class _IcoBuyTokenBankViewState extends State<IcoBuyTokenBankView> {
  final _controller = Get.find<IcoBuyCoinController>();
  final amountEditController = TextEditingController();
  RxInt selectedBankIndex = 0.obs;
  RxInt selectedCurrencyIndex = 0.obs;
  Rx<File> selectedFile = File("").obs;
  Rx<TokenPriceInfo> tokenPrice = TokenPriceInfo().obs;
  Timer? _timer;

  @override
  void initState() {
    selectedBankIndex.value = -1;
    selectedCurrencyIndex.value = -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final phase = _controller.phase.value;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      textAutoSizeKarla("Quantity of token".tr, fontSize: Dimens.regularFontSizeMid),
      vSpacer5(),
      textFieldWithSuffixIcon(
          controller: amountEditController,
          type: const TextInputType.numberWithOptions(decimal: true),
          hint: "Enter Quantity".tr,
          onTextChange: _onTextChanged),
      textAutoSizePoppins("${"Min amount".tr} ${coinFormat(phase.minimumPurchasePrice)} ${"Max amount".tr} ${coinFormat(phase.maximumPurchasePrice)}",
          maxLines: 2),
      vSpacer10(),
      textAutoSizeKarla("Select Bank".tr, fontSize: Dimens.regularFontSizeMid),
      Obx(() => dropDownListIndex(_controller.getBankList(), selectedBankIndex.value, "Select Bank".tr, (index) => selectedBankIndex.value = index,
          hMargin: 0)),
      vSpacer10(),
      textAutoSizeKarla("Select Currency".tr, fontSize: Dimens.regularFontSizeMid),
      Obx(() => dropDownListIndex(_controller.getCurrencyList(), selectedCurrencyIndex.value, "Select Currency".tr, (index) {
            selectedCurrencyIndex.value = index;
            _getAndSetCoinRate();
          }, hMargin: 0)),
      vSpacer10(),
      textAutoSizeKarla("Bank Reference".tr, fontSize: Dimens.regularFontSizeMid),
      vSpacer5(),
      textWithCopyButton(_controller.buySettings.value.ref ?? ""),
      textAutoSizePoppins("further validation and bank payment".tr, maxLines: 2, textAlign: TextAlign.start),
      vSpacer10(),
      _documentView(),
      Obx(() => IcoTokenPriceView(token: tokenPrice.value)),
      Obx(() {
        final bank = selectedBankIndex.value == -1 ? null : _controller.buySettings.value.bank![selectedBankIndex.value];
        return bank == null ? vSpacer0() : IcoBankInfoView(bank: bank);
      }),
      vSpacer10(),
      buttonRoundedMain(text: "Make Payment".tr, onPressCallback: () => _checkInputData()),
      vSpacer10(),
    ]);
  }

  _documentView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: 150,
            child: buttonText("Select document".tr, onPressCallback: () {
              showImageChooser(context, (chooseFile, isGallery) => selectedFile.value = chooseFile, isCrop: false);
            })),
        Obx(() {
          final text = selectedFile.value.path.isEmpty ? "No document selected".tr : selectedFile.value.name;
          return Expanded(child: textAutoSizePoppins(text, maxLines: 2));
        })
      ],
    );
  }

  void _onTextChanged(String amount) {
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), () => _getAndSetCoinRate());
  }

  void _getAndSetCoinRate() {
    if (selectedCurrencyIndex.value == -1) return;
    final amount = makeDouble(amountEditController.text.trim());
    if (amount <= 0) {
      tokenPrice.value = TokenPriceInfo();
    } else {
      final currency = _controller.buySettings.value.currencyList![selectedCurrencyIndex.value];
      _controller.getIcoTokenPriceInfo(amount, currency.code ?? "", (info) => tokenPrice.value = info);
    }
  }

  void _checkInputData() {
    final amount = makeDouble(amountEditController.text.trim());
    if (amount <= 0) {
      showToast("Amount_less_then".trParams({"amount": "0"}));
      return;
    }
    if (selectedBankIndex.value == -1) {
      showToast("select your bank".tr);
      return;
    }
    if (selectedCurrencyIndex.value == -1) {
      showToast("select your currency".tr);
      return;
    }
    if (selectedFile.value.path.isEmpty) {
      showToast("select bank document".tr);
      return;
    }
    hideKeyboard(context: context);
    final bank = _controller.buySettings.value.bank?[selectedBankIndex.value];
    final currency = _controller.buySettings.value.currencyList?[selectedCurrencyIndex.value];
    final createToken = IcoCreateBuyToken(amount: amount, bankId: bank?.id, bankSlip: selectedFile.value, currency: currency?.code ?? "");
    _controller.icoTokenBuy(createToken, () => _clearView());
  }

  void _clearView() {
    selectedCurrencyIndex.value = -1;
    amountEditController.text = "";
    selectedBankIndex.value = -1;
    selectedFile.value = File("");
    tokenPrice.value = TokenPriceInfo();
  }
}
