import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/models/p2p_ads.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';

import '../../models/p2p_settings.dart';
import '../../p2p_constants.dart';
import 'p2p_user_center_controller.dart';

class P2pAddPaymentPage extends StatefulWidget {
  const P2pAddPaymentPage({Key? key, this.paymentInfo}) : super(key: key);
  final P2pPaymentInfo? paymentInfo;

  @override
  State<P2pAddPaymentPage> createState() => _P2pAddPaymentPageState();
}

class _P2pAddPaymentPageState extends State<P2pAddPaymentPage> {
  final _controller = Get.find<P2pUserCenterController>();
  final _acNameEditController = TextEditingController();
  final _acNumberEditController = TextEditingController();
  final _bankNameEditController = TextEditingController();
  final _bankBranchEditController = TextEditingController();
  final _bankReferenceEditController = TextEditingController();
  RxList<P2PPaymentMethod> paymentList = <P2PPaymentMethod>[].obs;
  RxInt selectedPayment = 0.obs;
  RxInt selectedCardType = 0.obs;

  @override
  void initState() {
    super.initState();
    if (widget.paymentInfo == null) {
      selectedPayment.value = -1;
      selectedCardType.value = -1;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getP2pAdminPaymentMethods((p0) => paymentList.value = p0));
    } else {
      setPreInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(Dimens.paddingMid),
        children: [
          if (widget.paymentInfo == null)
            Obx(() => dropDownListIndex(getPaymentNameList(), selectedPayment.value, "Select Payment Method".tr, hMargin: 0, (index) {
                  selectedPayment.value = index;
                })),
          vSpacer15(),
          textFieldWithSuffixIcon(controller: _acNameEditController, hint: "Enter account name".tr, labelText: "Account Name".tr),
          Obx(() {
            final sPayMethodIndex = selectedPayment.value;
            P2PPaymentMethod? sPayMethod;
            sPayMethod =
                widget.paymentInfo == null ? (sPayMethodIndex == -1 ? null : paymentList[sPayMethodIndex]) : widget.paymentInfo?.adminPaymentMethod;
            if (sPayMethod?.paymentType == P2pPaymentType.mobile) {
              return Column(children: [
                vSpacer15(),
                textFieldWithSuffixIcon(
                    controller: _acNumberEditController, hint: "Enter mobile number".tr, labelText: "Mobile Number".tr, type: TextInputType.number),
              ]);
            } else if (sPayMethod?.paymentType == P2pPaymentType.card) {
              return Column(children: [
                vSpacer15(),
                textFieldWithSuffixIcon(
                    controller: _acNumberEditController, hint: "Enter card number".tr, labelText: "Card Number".tr, type: TextInputType.number),
                vSpacer15(),
                Obx(() {
                  return dropDownListIndex(["Debit Card".tr, "Credit Card".tr], selectedCardType.value, "Select Card Type".tr, hMargin: 0, (index) {
                    selectedCardType.value = index;
                  });
                }),
              ]);
            } else if (sPayMethod?.paymentType == P2pPaymentType.bank) {
              return Column(children: [
                vSpacer15(),
                textFieldWithSuffixIcon(controller: _bankNameEditController, hint: "Enter bank name".tr, labelText: "Bank Name".tr),
                vSpacer15(),
                textFieldWithSuffixIcon(
                    controller: _acNumberEditController,
                    hint: "Enter bank account number".tr,
                    labelText: "Bank Account Number".tr,
                    type: TextInputType.number),
                vSpacer15(),
                textFieldWithSuffixIcon(
                    controller: _bankBranchEditController, hint: "Enter account opening branch".tr, labelText: "Account Opening Branch".tr),
                vSpacer15(),
                textFieldWithSuffixIcon(
                    controller: _bankReferenceEditController, hint: "Enter transaction reference".tr, labelText: "Transaction Reference".tr),
              ]);
            }
            return vSpacer0();
          }),
          vSpacer20(),
          buttonRoundedMain(text: "Confirm".tr, onPressCallback: () => checkAndSaveBank())
        ],
      ),
    );
  }

  List<String> getPaymentNameList() {
    List<String> list = [];
    if (paymentList.isValid) {
      list = paymentList.map((e) => e.name ?? "").toList();
    }
    return list;
  }

  void setPreInfo() {
    final pInfo = widget.paymentInfo;
    _acNameEditController.text = pInfo?.username ?? "";
    final adPay = widget.paymentInfo?.adminPaymentMethod;
    _acNumberEditController.text = (adPay?.paymentType == P2pPaymentType.mobile
            ? pInfo?.mobileAccountNumber
            : (adPay?.paymentType == P2pPaymentType.card ? pInfo?.cardNumber : pInfo?.bankAccountNumber)) ??
        "";
    selectedCardType.value = pInfo?.cardType == CardPaymentType.debit ? 0 : 1;

    _bankNameEditController.text = pInfo?.bankName ?? "";
    _bankBranchEditController.text = pInfo?.accountOpeningBranch ?? "";
    _bankReferenceEditController.text = pInfo?.transactionReference ?? "";
  }

  void checkAndSaveBank() {
    final payInfo = widget.paymentInfo ?? P2pPaymentInfo();
    if (widget.paymentInfo == null) {
      if (selectedPayment.value == -1) {
        showToast("Select_Payment_Method_message".tr, context: context);
        return;
      }
    }

    final sPayMethod = widget.paymentInfo?.adminPaymentMethod ?? paymentList[selectedPayment.value];
    payInfo.adminPaymentMethod = sPayMethod;

    final acName = _acNameEditController.text.trim();
    if (acName.isEmpty) {
      showToast("Please, Input account name".tr, context: context);
      return;
    }
    payInfo.username = acName;

    final acNumber = _acNumberEditController.text.trim();
    if (acNumber.isEmpty) {
      final text = sPayMethod.paymentType == P2pPaymentType.mobile
          ? "Please, Input mobile number".tr
          : (sPayMethod.paymentType == P2pPaymentType.card ? "Please, Input card number".tr : "Please, Input account number".tr);
      showToast(text, context: context);
      return;
    }

    if (sPayMethod.paymentType == P2pPaymentType.mobile) {
      payInfo.mobileAccountNumber = acNumber;
    } else if (sPayMethod.paymentType == P2pPaymentType.card) {
      if (selectedCardType.value == -1) {
        showToast("Please, Select card type".tr, context: context);
        return;
      }
      payInfo.cardNumber = acNumber;
      payInfo.cardType = selectedCardType.value == 0 ? CardPaymentType.debit : CardPaymentType.credit;
    } else if (sPayMethod.paymentType == P2pPaymentType.bank) {
      payInfo.bankAccountNumber = acNumber;
      final bankName = _bankNameEditController.text.trim();
      if (bankName.isEmpty) {
        showToast("Please, Input bank name".tr, context: context);
        return;
      }
      payInfo.bankName = bankName;
      final bankBranchName = _bankBranchEditController.text.trim();
      if (bankBranchName.isEmpty) {
        showToast("Please, Input branch name".tr, context: context);
        return;
      }
      payInfo.accountOpeningBranch = bankBranchName;
      final bankReference = _bankReferenceEditController.text.trim();
      if (bankReference.isEmpty) {
        showToast("Please, Input transaction reference".tr, context: context);
        return;
      }
      payInfo.transactionReference = bankReference;
    }
    hideKeyboard(context: context);
    _controller.p2pPaymentMethodSave(payInfo, context);
  }
}
