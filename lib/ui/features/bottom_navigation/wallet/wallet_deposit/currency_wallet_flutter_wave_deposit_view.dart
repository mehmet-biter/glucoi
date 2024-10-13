import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/fiat_deposit.dart';
import 'package:tradexpro_flutter/data/models/flutter_wave.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/helper/success_page.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import '../../fiat/fiat_deposit/flutter_wave_deposit_screen.dart';
import 'wallet_deposit_controller.dart';

class CurrencyWalletFlutterWaveDepositView extends StatefulWidget {
  const CurrencyWalletFlutterWaveDepositView({Key? key}) : super(key: key);

  @override
  State<CurrencyWalletFlutterWaveDepositView> createState() => _CurrencyWalletFlutterWaveDepositViewState();
}

class _CurrencyWalletFlutterWaveDepositViewState extends State<CurrencyWalletFlutterWaveDepositView> {
  final _controller = Get.find<WalletDepositController>();
  final amountEditController = TextEditingController();

  // final emailEditController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // emailEditController.text = gUserRx.value.email ?? '';
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
        // vSpacer10(),
        // twoTextSpace("Email address".tr, ""),
        // vSpacer5(),
        // textFieldWithWidget(controller: emailEditController, hint: "Enter Email".tr.capitalizeFirst),
        vSpacer20(),
        buttonRoundedMain(text: "Deposit".tr, onPressCallback: () => _checkInputData())
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
    // final email = emailEditController.text.trim();
    // if (!GetUtils.isEmail(email)) {
    //   showToast("Input a valid Email".tr);
    //   return;
    // }
    hideKeyboard();
    final deposit = CreateDeposit(
        walletId: _controller.wallet.value.id, amount: amount, email: gUserRx.value.email ?? '', currency: _controller.wallet.value.coinType);
    _handleDeposit(deposit);
  }

  void _handleDeposit(CreateDeposit deposit) {
    _controller.walletCurrencyDepositFlutterWave(deposit, ({data}) {
      if (data != null && data is Map<String, dynamic>) {
        final fWData = FlutterWaveData.fromJson(data);
        if (fWData.walletDepositDetails?.transactionId.isValid ?? false) {
          if (fWData.flutterWaveBankDetails?.meta?.authorization?.transferAccount.isValid ?? false) {
            Get.bottomSheet(
                FlutterWaveBankView(
                    fwData: fWData,
                    email: deposit.email ?? '',
                    fromKey: FromKey.deposit,
                    onCancel: () {
                      Get.back();
                      _controller.getFlutterWaveTransactionCanceled(fWData.walletDepositDetails!.transactionId!, () => Get.back());
                    },
                    onDone: () {
                      _controller.getFlutterWaveTransactionDone(fWData.walletDepositDetails!.transactionId!, () async {
                        Get.back();
                        _clearView();
                        final appName = await getAppName();
                        final sub = "deposit_amount_wallet_success".trParams({
                          "amountText": "${fWData.walletDepositDetails?.coinType} ${fWData.walletDepositDetails?.amount}",
                          "walletName": _controller.wallet.value.name ?? "",
                          "appName": appName
                        });
                        if (mounted) Get.to(() => SuccessPageFullScreen(subtitle: sub));
                        // if (mounted) showModalSheetFullScreen(context, SuccessPage(subtitle: sub), bgColor: context.theme.focusColor);
                      });
                    }),
                isDismissible: false,
                enableDrag: false,
                isScrollControlled: true);
          } else {
            showToast("Bank information not found".tr);
          }
        } else {
          showToast("Invalid Transaction ID".tr);
        }
      }
    });
  }

  void _clearView() {
    amountEditController.text = "";
    // emailEditController.text = "";
  }
}
