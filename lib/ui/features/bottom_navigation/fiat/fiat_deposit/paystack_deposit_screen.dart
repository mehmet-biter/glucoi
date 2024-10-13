import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/models/fiat_deposit.dart';
import 'package:tradexpro_flutter/data/models/wallet.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/helper/currency_check.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/paystack_util.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'fiat_deposit_controller.dart';

class PayStackDepositScreen extends StatefulWidget {
  const PayStackDepositScreen({Key? key}) : super(key: key);

  @override
  State<PayStackDepositScreen> createState() => _PayStackDepositScreenState();
}

class _PayStackDepositScreenState extends State<PayStackDepositScreen> {
  final _controller = Get.find<FiatDepositController>();
  final amountEditController = TextEditingController();
  final emailEditController = TextEditingController();
  Rx<Wallet> selectedWallet = Wallet(id: 0).obs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vSpacer10(),
        twoTextSpace("Enter amount".tr, "Select Wallet".tr),
        vSpacer5(),
        textFieldWithWidget(
            controller: amountEditController,
            type: const TextInputType.numberWithOptions(decimal: true),
            hint: "Enter amount".tr,
            suffixWidget: Obx(() => walletsSuffixView(_controller.fiatDepositData.value.walletList ?? [], selectedWallet.value,
                onChange: (selected) => selectedWallet.value = selected))),
        Obx(() {
          return selectedWallet.value.coinType.isValid
              ? textAutoSizePoppins(
                  "deposit_Max_min"
                      .trParams({"min": coinFormat(selectedWallet.value.minimumDeposit), "max": coinFormat(selectedWallet.value.maximumDeposit)}),
                  maxLines: 2,
                  textAlign: TextAlign.start)
              : vSpacer0();
        }),
        // twoTextSpace("Enter amount".tr, "Currency(USD)".tr),
        // vSpacer5(),
        // textFieldWithWidget(controller: amountEditController, hint: "Enter amount".tr, type: const TextInputType.numberWithOptions(decimal: true)),
        vSpacer20(),
        twoTextSpace("Email address".tr, ""),
        vSpacer5(),
        textFieldWithWidget(controller: emailEditController, hint: "Enter Email".tr.capitalizeFirst),
        vSpacer20(),
        buttonRoundedMain(text: "Deposit".tr, onPressCallback: () => _checkInputData())
      ],
    );
    // final usdWallet = _controller.fiatDepositData.value.walletList?.firstWhereOrNull((element) => (element.coinType ?? "").toLowerCase() == "usd");
    // if (usdWallet == null) {
    //   return textAutoSizeKarla("USD wallet not found".tr, color: Colors.amber);
    // } else {
    //
    // }
  }

  void _checkInputData() {
    if (selectedWallet.value.id == 0) {
      showToast("select your wallet".tr);
      return;
    }
    if (!CurrencyCheck.checkDepositCurrency(selectedWallet.value.coinType, context)) {
      return;
    }
    final amount = makeDouble(amountEditController.text.trim());
    if (amount <= 0) {
      showToast("Amount_less_then".trParams({"amount": "0"}));
      return;
    }
    final email = emailEditController.text.trim();
    if (!GetUtils.isEmail(email)) {
      showToast("Input a valid Email".tr);
      return;
    }
    hideKeyboard();
    _controller.paystackPaymentUrlGet(selectedWallet.value.id, amount, email, selectedWallet.value.coinType ?? '', (pData) {
      Get.to(() => PaystackPaymentPage(
          paystackData: pData,
          onFinish: (trxData) {
            final deposit = CreateDeposit(
                walletId: selectedWallet.value.id, amount: amount, transactionId: trxData.trxId, currency: selectedWallet.value.coinType);
            _controller.currencyDepositProcess(deposit, ({data}) => _clearView());
          }));
    });
  }

  void _clearView() {
    amountEditController.text = "";
    emailEditController.text = "";
  }
}

// class _PayStackDepositScreenState extends State<PayStackDepositScreen> {
//   final _controller = Get.find<FiatDepositController>();
//   final amountEditController = TextEditingController();
//   final coinEditController = TextEditingController();
//   final emailEditController = TextEditingController();
//   Timer? _timer;
//   Rx<Wallet> selectedWallet = Wallet(id: 0).obs;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         vSpacer10(),
//         twoTextSpace("Enter amount".tr, "Currency(USD)".tr),
//         vSpacer5(),
//         textFieldWithWidget(
//             controller: amountEditController,
//             hint: "Enter amount".tr,
//             onTextChange: _onTextChanged,
//             type: const TextInputType.numberWithOptions(decimal: true)),
//         vSpacer20(),
//         twoTextSpace("Converted amount".tr, "Select Wallet".tr),
//         vSpacer5(),
//         textFieldWithWidget(
//             controller: coinEditController,
//             hint: "0",
//             readOnly: true,
//             suffixWidget: Obx(() => walletsSuffixView(_controller.fiatDepositData.value.walletList ?? [], selectedWallet.value, onChange: (selected) {
//                   selectedWallet.value = selected;
//                   _getAndSetCoinRate();
//                 }))),
//         vSpacer20(),
//         twoTextSpace("Email address".tr, ""),
//         vSpacer5(),
//         textFieldWithWidget(controller: emailEditController, hint: "Enter Email".tr.capitalizeFirst),
//         vSpacer20(),
//         buttonRoundedMain(text: "Deposit".tr, onPressCallback: () => _checkInputData())
//       ],
//     );
//   }
//
//   void _onTextChanged(String amount) {
//     if (_timer?.isActive ?? false) _timer?.cancel();
//     _timer = Timer(const Duration(seconds: 1), () {
//       _getAndSetCoinRate();
//     });
//   }
//
//   void _getAndSetCoinRate() {
//     if (selectedWallet.value.id == 0) return;
//     final amount = makeDouble(amountEditController.text.trim());
//     if (amount <= 0) {
//       coinEditController.text = "0";
//     } else {
//       _controller.convertCurrencyAmount(selectedWallet.value.coinType ?? "", amount, (rate) => coinEditController.text = coinFormat(rate, fixed: 10));
//     }
//   }
//
//   void _checkInputData() {
//     if (selectedWallet.value.id == 0) {
//       showToast("select your wallet".tr);
//       return;
//     }
//     final amount = makeDouble(amountEditController.text.trim());
//     if (amount <= 0) {
//       showToast("Amount_less_then".trParams({"amount": "0"}));
//       return;
//     }
//     final email = emailEditController.text.trim();
//     if (!GetUtils.isEmail(email)) {
//       showToast("Input a valid Email".tr);
//       return;
//     }
//     hideKeyboard();
//     _controller.paystackPaymentUrlGet(selectedWallet.value.id, amount, email, (pData) {
//       Get.to(() => PaystackPaymentPage(
//           paystackData: pData,
//           onFinish: (trxData) {
//             final deposit = CreateDeposit(walletId: selectedWallet.value.id, amount: amount, transactionId: trxData.trxId, currency: "USD");
//             _controller.currencyDepositProcess(deposit, () => _clearView());
//           }));
//     });
//   }
//
//   void _clearView() {
//     selectedWallet.value = Wallet(id: 0);
//     amountEditController.text = "";
//     coinEditController.text = "";
//     emailEditController.text = "";
//   }
// }
