import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/ui/p2p_common_widgets.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/fiat_deposit.dart';
import 'package:tradexpro_flutter/data/models/flutter_wave.dart';
import 'package:tradexpro_flutter/data/models/history.dart';
import 'package:tradexpro_flutter/data/models/wallet.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/helper/currency_check.dart';
import 'package:tradexpro_flutter/helper/success_page.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'fiat_deposit_controller.dart';

class FlutterWaveDepositScreen extends StatefulWidget {
  const FlutterWaveDepositScreen({Key? key}) : super(key: key);

  @override
  State<FlutterWaveDepositScreen> createState() => _FlutterWaveDepositScreenState();
}

class _FlutterWaveDepositScreenState extends State<FlutterWaveDepositScreen> {
  final _controller = Get.find<FiatDepositController>();
  final amountEditController = TextEditingController();
  final emailEditController = TextEditingController();
  Rx<Wallet> selectedWallet = Wallet(id: 0).obs;

  @override
  Widget build(BuildContext context) {
    emailEditController.text = gUserRx.value.email ?? '';
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
        vSpacer20(),
        twoTextSpace("Email address".tr, ""),
        vSpacer5(),
        textFieldWithWidget(controller: emailEditController, hint: "Enter Email".tr.capitalizeFirst),
        vSpacer20(),
        buttonRoundedMain(text: "Deposit".tr, onPressCallback: () => _checkInputData())
      ],
    );
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
    final minAmount = selectedWallet.value.minimumDeposit ?? 0;
    if (amount < minAmount) {
      showToast("Amount_less_then".trParams({"amount": minAmount.toString()}));
      return;
    }
    final maxAmount = selectedWallet.value.maximumDeposit ?? 0;
    if (amount > maxAmount) {
      showToast("Amount_greater_then".trParams({"amount": maxAmount.toString()}));
      return;
    }

    final email = emailEditController.text.trim();
    if (!GetUtils.isEmail(email)) {
      showToast("Input a valid Email".tr);
      return;
    }
    hideKeyboard();
    final deposit = CreateDeposit(walletId: selectedWallet.value.id, amount: amount, email: email, currency: selectedWallet.value.coinType);
    _handleDeposit(deposit);

    // if (amount <= 0) {
    //   showToast("Amount_less_then".trParams({"amount": "0"}));
    //   return;
    // }
    // final deposit = CreateDeposit(walletId: 58, amount: 22, email: "noman@yahoo.com", currency: "NGN");
    // final fWData = FlutterWaveData(
    //     depositDetails: FiatHistory(id: 14, currencyAmount: 50, currency: "NGN", transactionId: "fw_txn_1706091147_a8c7f40b"),
    //     flutterWaveBankDetails: FlutterWaveBankDetails(
    //         meta: Meta(
    //             authorization: Authorization(
    //                 accountExpiration: 1706091148542, transferAccount: "0067100155", transferBank: "Mock Bank", transferNote: "Mock note"))));
    // Get.bottomSheet(
    //     FlutterWaveBankView(
    //         fwData: fWData,
    //         dData: deposit,
    //         onDone: () => _controller.getFlutterWaveTransactionDone(fWData.depositDetails!.transactionId!, () {
    //               Get.back();
    //               _clearView();
    //               showModalSheetFullScreen(context, const SuccessPage());
    //             })),
    //     isDismissible: false,
    //     enableDrag: false,
    //     isScrollControlled: true);
  }

  void _handleDeposit(CreateDeposit deposit) {
    _controller.currencyDepositProcess(deposit, ({data}) {
      if (data != null && data is Map<String, dynamic>) {
        final fWData = FlutterWaveData.fromJson(data);
        if (fWData.depositDetails?.transactionId.isValid ?? false) {
          if (fWData.flutterWaveBankDetails?.meta?.authorization?.transferAccount.isValid ?? false) {
            Get.bottomSheet(
                FlutterWaveBankView(
                    fwData: fWData,
                    email: deposit.email ?? '',
                    fromKey: FromKey.deposit,
                    onCancel: () {
                      Get.back();
                      _controller.getFlutterWaveTransactionCanceled(fWData.depositDetails!.transactionId!, () => Get.back());
                    },
                    onDone: () {
                      _controller.getFlutterWaveTransactionDone(fWData.depositDetails!.transactionId!, () async {
                        Get.back();
                        final appName = await getAppName();
                        final sub = "deposit_amount_wallet_success".trParams({
                          "amountText": "${fWData.depositDetails?.currency} ${fWData.depositDetails?.currencyAmount}",
                          "walletName": selectedWallet.value.name ?? "",
                          "appName": appName
                        });
                        if (mounted) showModalSheetFullScreen(context, SuccessPage(subtitle: sub), bgColor: context.theme.focusColor);
                        _clearView();
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
    emailEditController.text = "";
    selectedWallet.value = Wallet(id: 0);
  }
}

class FlutterWaveBankView extends StatelessWidget {
  const FlutterWaveBankView(
      {super.key, required this.fwData, required this.email, required this.onDone, required this.onCancel, required this.fromKey});

  final FlutterWaveData fwData;
  final String email;
  final VoidCallback onDone;
  final VoidCallback onCancel;
  final String fromKey;

  @override
  Widget build(BuildContext context) {
    final bank = fwData.flutterWaveBankDetails?.meta?.authorization;
    final deposit = fwData.depositDetails ?? fwData.walletDepositDetails;
    String amountStr = "";
    if (deposit is FiatHistory) {
      amountStr = "${deposit.currencyAmount} ${deposit.currency}";
    } else if (deposit is WalletCurrencyHistory) {
      amountStr = "${deposit.amount} ${deposit.coinType}";
    }

    final endTime = (makesDateFromString(bank?.accountExpiration) ?? DateTime.now()).toLocal();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (fromKey == FromKey.deposit) {
          _showAlertToCancel(context);
        } else {
          navigator?.pop();
        }
      },
      child: Container(
          alignment: Alignment.bottomCenter,
          height: getContentHeight() - Dimens.paddingLargeDouble,
          decoration: boxDecorationTopRound(radius: Dimens.radiusCornerLarge),
          padding: const EdgeInsets.all(Dimens.paddingLarge),
          child: Column(
            children: [
              vSpacer10(),
              Row(
                children: [
                  const AppLogo(size: Dimens.iconSizeLarge),
                  Expanded(child: textAutoSizeKarla(amountStr, textAlign: TextAlign.end)),
                  // Expanded(
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.end,
                  //     children: [
                  //       textAutoSizeKarla(amountStr),
                  //       textAutoSizePoppins(email),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
              vSpacer20(),
              textAutoSizeKarla("Proceed to your Bank app to complete this transfer".tr,
                  maxLines: 2, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
              vSpacer20(),
              Container(
                padding: const EdgeInsets.all(Dimens.paddingLarge),
                decoration: boxDecorationTopRound(color: context.theme.focusColor.withOpacity(0.2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    vSpacer10(),
                    textAutoSizePoppins('Amount'.tr),
                    textWithCopyView(amountStr),
                    vSpacer10(),
                    textAutoSizePoppins('Account Number'.tr),
                    textWithCopyView(bank?.transferAccount ?? ''),
                    vSpacer10(),
                    textAutoSizePoppins('Bank Name'.tr),
                    textAutoSizeKarla(bank?.transferBank ?? '', fontSize: Dimens.regularFontSizeMid),
                    vSpacer10(),
                    textAutoSizePoppins('Beneficiary'.tr),
                    textAutoSizeKarla(bank?.transferNote ?? '', fontSize: Dimens.regularFontSizeMid, maxLines: 3, textAlign: TextAlign.start),
                    dividerHorizontal(height: Dimens.paddingLargeDouble),
                    textAutoSizeKarla("account details valid for specific transaction".tr, fontSize: Dimens.regularFontSizeMid, maxLines: 3),
                    CountDownView(endTime: endTime, onEnd: () => onCancel())
                  ],
                ),
              ),
              vSpacer20(),
              buttonRoundedMain(text: "I have completed the transfer".tr, buttonHeight: Dimens.btnHeightMid, onPressCallback: onDone),
              vSpacer10(),
              if (fromKey == FromKey.deposit)
                buttonText("Change payment method".tr,
                    bgColor: Colors.transparent, textColor: context.theme.primaryColor, onPressCallback: () => _showAlertToCancel(context))
              else
                buttonText("Cancel".tr, bgColor: Colors.transparent, textColor: context.theme.primaryColor, onPressCallback: onCancel),
              vSpacer10(),
            ],
          )),
    );
  }

  void _showAlertToCancel(BuildContext context) {
    alertForAction(context,
        title: "Want to change payment method".tr,
        subTitle: "It will cancel current deposit process".tr,
        buttonTitle: "Proceed".tr,
        onOkAction: onCancel);
  }
}
