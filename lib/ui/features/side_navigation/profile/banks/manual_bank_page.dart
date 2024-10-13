import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/models/fiat_deposit.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'banks_controller.dart';

class ManualBankPage extends StatelessWidget {
  const ManualBankPage({super.key, this.bank});

  final Bank? bank;

  @override
  Widget build(BuildContext context) {
    final currentBank = bank ?? Bank(id: 0);
    final btnTitle = bank == null ? "Add Bank".tr : "Update Bank".tr;
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Dimens.paddingMid),
        children: [
          textFieldWithSuffixIcon(
              controller: TextEditingController(text: currentBank.accountHolderName ?? ""),
              labelText: "Account Holder Name".tr,
              hint: "".tr,
              onTextChange: (text) => currentBank.accountHolderName = text),
          vSpacer10(),
          textFieldWithSuffixIcon(
              controller: TextEditingController(text: currentBank.accountHolderAddress ?? ""),
              labelText: "Account Holder Address".tr,
              hint: "".tr,
              onTextChange: (text) => currentBank.accountHolderAddress = text),
          vSpacer10(),
          textFieldWithSuffixIcon(
              controller: TextEditingController(text: currentBank.bankName ?? ""),
              labelText: "Bank Name".tr,
              hint: "".tr,
              onTextChange: (text) => currentBank.bankName = text),
          vSpacer10(),
          textFieldWithSuffixIcon(
              controller: TextEditingController(text: currentBank.bankAddress ?? ""),
              labelText: "Bank Address".tr,
              hint: "".tr,
              onTextChange: (text) => currentBank.bankAddress = text),
          vSpacer10(),
          textFieldWithSuffixIcon(
              controller: TextEditingController(text: currentBank.country ?? ""),
              labelText: "Country".tr,
              hint: "".tr,
              onTextChange: (text) => currentBank.country = text),
          vSpacer10(),
          textFieldWithSuffixIcon(
              controller: TextEditingController(text: currentBank.swiftCode ?? ""),
              labelText: "Swift Code".tr,
              hint: "".tr,
              onTextChange: (text) => currentBank.swiftCode = text),
          vSpacer10(),
          textFieldWithSuffixIcon(
              controller: TextEditingController(text: currentBank.iban ?? ""),
              labelText: "IBAN".tr,
              hint: "".tr,
              onTextChange: (text) => currentBank.iban = text),
          vSpacer10(),
          textFieldWithSuffixIcon(
              controller: TextEditingController(text: currentBank.note ?? ""),
              labelText: "Note".tr,
              hint: "".tr,
              onTextChange: (text) => currentBank.note = text),
          vSpacer30(),
          buttonRoundedMain(text: btnTitle, onPressCallback: () => _checkInputs(context, currentBank)),
          vSpacer10(),
        ],
      ),
    );
  }

  void _checkInputs(BuildContext context, Bank bank) {
    if (!bank.accountHolderName.isValid) {
      showToast("Account holder name required".tr);
      return;
    }
    if (!bank.accountHolderAddress.isValid) {
      showToast("Account holder address required".tr);
      return;
    }
    if (!bank.bankName.isValid) {
      showToast("bank name required".tr);
      return;
    }
    if (!bank.bankAddress.isValid) {
      showToast("bank address required".tr);
      return;
    }
    if (!bank.country.isValid) {
      showToast("bank country required".tr);
      return;
    }
    if (!bank.swiftCode.isValid) {
      showToast("bank swift code required".tr);
      return;
    }
    if (!bank.iban.isValid) {
      showToast("bank iban code required".tr);
      return;
    }
    if (!bank.note.isValid) {
      showToast("bank note required".tr);
      return;
    }
    hideKeyboard(context: context);
    Get.find<BanksController>().userBankSave(bank);
  }
}
