import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/models/referral.dart';
import 'package:tradexpro_flutter/data/models/wallet.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/ui/features/side_navigation/referrals/referrals_controller.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';

class ReferralWithdrawView extends StatelessWidget {
  const ReferralWithdrawView({super.key, this.wallet, required this.onWithdrawTap});

  final Wallet? wallet;
  final VoidCallback onWithdrawTap;

  @override
  Widget build(BuildContext context) {
    final settings = getSettingsLocal();
    final minValText = "${coinFormat(settings?.minimumBalanceReferralWithdraw)} NGN";
    final isActive = (wallet?.getBalance() ?? 0) >= (settings?.minimumBalanceReferralWithdraw ?? 0);
    return Container(
        decoration: boxDecorationRoundCorner(),
        padding: const EdgeInsets.all(Dimens.paddingMid),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textAutoSizeTitle("Withdraw Your Rewards".tr, fontSize: Dimens.regularFontSizeMid),
            vSpacer10(),
            twoTextSpaceFixed("${"Withdrawable".tr} :", "${coinFormat(wallet?.getBalance())} ${wallet?.coinType ?? ''}",
                fontSize: Dimens.titleFontSizeSmall),
            vSpacer10(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                isActive ? vSpacer5() : textAutoSizePoppins("${"Can not withdraw until".tr} $minValText", textAlign: TextAlign.end),
                buttonText("Withdraw".tr, onPressCallback: isActive ? onWithdrawTap : null),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () => showBottomSheetFullScreen(context, const ReferralWithdrawHistoryView(), title: "Referral Withdraw History".tr),
                  child: SizedBox(
                      height: Dimens.btnHeightMin,
                      child: textAutoSizePoppins("Referral Withdraw History".tr,
                          decoration: TextDecoration.underline, color: context.theme.primaryColor))),
            )
          ],
        ));
  }
}

class ReferralWithdrawProcessView extends StatelessWidget {
  ReferralWithdrawProcessView({super.key, this.wallet});

  final Wallet? wallet;
  final controller = Get.find<ReferralsController>();
  final amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    controller.getWalletList();
    RxInt selectedWallet = 0.obs;
    selectedWallet.value = -1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vSpacer10(),
        textAutoSizeKarla("Withdraw Referral Balance".tr, fontSize: Dimens.regularFontSizeLarge),
        vSpacer20(),
        textAutoSizePoppins("Amount".tr, color: context.theme.primaryColor),
        textFieldWithSuffixIcon(
            controller: amountController, hint: "Amount to withdraw".tr, type: const TextInputType.numberWithOptions(decimal: true)),
        Align(
            alignment: Alignment.centerRight,
            child: textAutoSizePoppins("${"Available".tr} ${coinFormat(wallet?.getBalance())} ${wallet?.coinType ?? ''}")),
        vSpacer10(),
        textAutoSizePoppins("Select Wallet".tr, color: context.theme.primaryColor),
        Obx(
          () {
            final list = controller.walletList.map((e) => "${e.name ?? ""} (${e.coinType ?? ''})").toList();
            return dropDownListIndex(list, selectedWallet.value, "Select".tr, (index) {
              selectedWallet.value = index;
            }, hMargin: 0);
          },
        ),
        vSpacer15(),
        buttonRoundedMain(text: "Withdraw".tr, onPressCallback: () => _withdrawAction(selectedWallet.value)),
        vSpacer10()
      ],
    );
  }

  _withdrawAction(int selected) {
    final amount = makeDouble(amountController.text.trim());
    if (amount <= 0) {
      showToast("amount_must_greater_than_0".tr);
      return;
    }
    final balance = wallet?.getBalance() ?? 0;
    if (amount > balance) {
      showToast("Amount_greater_then".trParams({"amount": balance.toString()}));
      return;
    }
    if (selected == -1) {
      showToast("select your wallet".tr);
      return;
    }
    hideKeyboard();
    controller.withdrawReferralBalance(amount, controller.walletList[selected]);
  }
}

class ReferralWithdrawHistoryView extends StatelessWidget {
  const ReferralWithdrawHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReferralsController>();
    controller.getReferralWithdrawHistory(false);
    return Obx(() {
      return Expanded(
        child: controller.refWithdrawHistories.isEmpty
            ? handleEmptyViewWithLoading(controller.isLoading.value)
            : ListView.builder(
                padding: const EdgeInsets.all(Dimens.paddingMid),
                itemCount: controller.refWithdrawHistories.length,
                itemBuilder: (context, index) {
                  if (controller.hasMoreData && index == (controller.refWithdrawHistories.length - 1)) controller.getReferralWithdrawHistory(true);
                  return ReferralWithdrawItemView(history: controller.refWithdrawHistories[index]);
                },
              ),
      );
    });
  }
}

class ReferralWithdrawItemView extends StatelessWidget {
  const ReferralWithdrawItemView({super.key, required this.history});

  final ReferralWithdrawHistory history;

  @override
  Widget build(BuildContext context) {
    final statusData = getStatusData(history.status ?? 0);
    return Column(
      children: [
        twoTextSpaceFixed("Amount".tr, "${coinFormat(history.amount)} ${history.referralWalletCurrency ?? ''}"),
        twoTextSpaceFixed("Converted Amount".tr, "${coinFormat(history.convertedAmount)} ${history.walletCoinType ?? ''}", flex: 4),
        twoTextSpaceFixed("Status".tr, statusData.first, subColor: statusData.last),
        twoTextSpaceFixed("Date".tr, formatDate(history.updatedAt, format: dateTimeFormatDdMMMMYyyyHhMm)),
        dividerHorizontal()
      ],
    );
  }
}
