import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/models/fiat_deposit.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/helper/success_page.dart';
import 'package:tradexpro_flutter/ui/features/bottom_navigation/trade_widgets.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'wallet_deposit_controller.dart';

class CurrencyWalletBankDepositView extends StatefulWidget {
  const CurrencyWalletBankDepositView({Key? key}) : super(key: key);

  @override
  State<CurrencyWalletBankDepositView> createState() => _CurrencyWalletBankDepositViewState();
}

class _CurrencyWalletBankDepositViewState extends State<CurrencyWalletBankDepositView> {
  final _controller = Get.find<WalletDepositController>();
  TextEditingController amountEditController = TextEditingController();
  RxInt selectedBankIndex = 0.obs;
  Rx<File> selectedFile = File("").obs;

  @override
  void initState() {
    selectedBankIndex.value = -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vSpacer10(),
        twoTextSpace("Enter amount".tr, _controller.wallet.value.coinType ?? ""),
        vSpacer5(),
        textFieldWithWidget(
          controller: amountEditController,
          type: const TextInputType.numberWithOptions(decimal: true),
          hint: "Enter amount".tr,
        ),
        Obx(() => textAutoSizePoppins(
            "deposit_Max_min"
                .trParams({"min": coinFormat(_controller.wallet.value.minimumDeposit), "max": coinFormat(_controller.wallet.value.maximumDeposit)}),
            maxLines: 2,
            textAlign: TextAlign.start)),
        vSpacer20(),
        twoTextSpace("Select Bank".tr, ""),
        vSpacer5(),
        Obx(() {
          return dropDownListIndex(_controller.getBankList(_controller.fiatDepositData.value), selectedBankIndex.value, "Select Bank".tr, (index) {
            selectedBankIndex.value = index;
          }, hMargin: 0);
        }),
        Obx(() {
          final bank = selectedBankIndex.value == -1 ? null : _controller.fiatDepositData.value.banks?[selectedBankIndex.value];
          return bank == null ? vSpacer0() : BankDetailsView(bank: bank);
        }),
        vSpacer20(),
        _documentView(),
        vSpacer20(),
        buttonRoundedMain(text: "Deposit".tr, onPressCallback: () => _checkInputData())
      ],
    );
  }

  Widget _documentView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
            width: 150,
            child: buttonText("Select document".tr, onPressCallback: () {
              showImageChooser(context, (chooseFile, isGallery) {
                selectedFile.value = chooseFile;
              }, isCrop: false);
            })),
        Obx(() {
          final text = selectedFile.value.path.isEmpty ? "No document selected".tr : selectedFile.value.name;
          return Expanded(child: textAutoSizePoppins(text, maxLines: 2));
        })
      ],
    );
  }

  void _checkInputData() {
    final amount = makeDouble(amountEditController.text.trim());
    final minAmount = _controller.wallet.value.minimumDeposit ?? 0;
    if (amount < minAmount) {
      showToast("Amount_less_then".trParams({"amount": minAmount.toString()}));
      return;
    }
    final maxAmount = _controller.wallet.value.maximumDeposit ?? 0;
    if (amount > maxAmount) {
      showToast("Amount_greater_then".trParams({"amount": maxAmount.toString()}));
      return;
    }
    // if (amount <= 0) {
    //   showToast("Amount_less_then".trParams({"amount": "0"}));
    //   return;
    // }
    if (selectedBankIndex.value == -1) {
      showToast("select your bank".tr);
      return;
    }
    if (selectedFile.value.path.isEmpty) {
      showToast("select bank document".tr);
      return;
    }

    final bank = _controller.fiatDepositData.value.banks?[selectedBankIndex.value];
    final currency = _controller.wallet.value.coinType ?? "";
    final deposit =
        CreateDeposit(walletId: _controller.wallet.value.id, amount: amount, bankId: bank?.id, file: selectedFile.value, currency: currency);
    _controller.walletCurrencyDeposit(deposit, ({data}) {
      _clearView();
      if (data is String) Get.to(() => SuccessPageFullScreen(subtitle: data));
    });
  }

  void _clearView() {
    amountEditController.text = "";
    selectedBankIndex.value = -1;
    selectedFile.value = File("");
  }
}
