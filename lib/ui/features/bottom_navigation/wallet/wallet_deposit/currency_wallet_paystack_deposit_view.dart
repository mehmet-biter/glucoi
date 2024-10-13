import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/models/fiat_deposit.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/paystack_util.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'wallet_deposit_controller.dart';

class CurrencyWalletPaystackDepositView extends StatefulWidget {
  const CurrencyWalletPaystackDepositView({Key? key}) : super(key: key);

  @override
  State<CurrencyWalletPaystackDepositView> createState() => _CurrencyWalletPaystackDepositViewState();
}

class _CurrencyWalletPaystackDepositViewState extends State<CurrencyWalletPaystackDepositView> {
  final _controller = Get.find<WalletDepositController>();
  final amountEditController = TextEditingController();
  final emailEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vSpacer10(),
        twoTextSpace("Enter amount".tr, _controller.wallet.value.coinType ?? ''),
        vSpacer5(),
        textFieldWithWidget(controller: amountEditController, hint: "Enter amount".tr, type: const TextInputType.numberWithOptions(decimal: true)),
        Obx(() => textAutoSizePoppins(
            "deposit_Max_min"
                .trParams({"min": coinFormat(_controller.wallet.value.minimumDeposit), "max": coinFormat(_controller.wallet.value.maximumDeposit)}),
            maxLines: 2,
            textAlign: TextAlign.start)),
        vSpacer10(),
        twoTextSpace("Email address".tr, ""),
        vSpacer5(),
        textFieldWithWidget(controller: emailEditController, hint: "Enter Email".tr.capitalizeFirst),
        vSpacer20(),
        buttonRoundedMain(text: "Next".tr, onPressCallback: () => _checkInputData())
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
    final email = emailEditController.text.trim();
    if (!GetUtils.isEmail(email)) {
      showToast("Input a valid Email".tr);
      return;
    }
    hideKeyboard();
    _controller.paystackPaymentUrlGet(amount, email, (pData) {
      Get.to(() => PaystackPaymentPage(
          paystackData: pData,
          onFinish: (trxData) {
            final deposit = CreateDeposit(
                walletId: _controller.wallet.value.id, amount: amount, transactionId: trxData.trxId, currency: _controller.wallet.value.coinType);
            _controller.walletCurrencyDeposit(deposit, ({data}) => _clearView());
          }));
    });
  }

  void _clearView() {
    amountEditController.text = "";
    emailEditController.text = "";
  }
}
