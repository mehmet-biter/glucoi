import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/fiat_deposit.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'banks_controller.dart';
import 'flutter_wave_bank_page.dart';
import 'manual_bank_page.dart';

class BankScreen extends StatefulWidget {
  const BankScreen({Key? key}) : super(key: key);

  @override
  State<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends State<BankScreen> {
  final _controller = Get.put(BanksController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getUserBankList());
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textAutoSizePoppins("Bank List".tr, fontSize: Dimens.regularFontSizeExtraMid),
              buttonText("Add Bank".tr, onPressCallback: () => _showBankMenu())
            ],
          ),
        ),
        vSpacer10(),
        _userBankListView()
      ]),
    );
  }

  void _showBankMenu() async {
    final menuView = await showMenu<int>(
        context: context,
        items: [makePopupMenu('Manual Bank'.tr, 0), makePopupMenu('TRF Bank'.tr, 1)],
        position: RelativeRect.fromLTRB(Get.width - 150, 180, 0, Get.height - 300));
    if (menuView != null && mounted) {
      if (menuView == 0) {
        showBottomSheetFullScreen(context, const ManualBankPage(), title: "Add New Bank".tr);
      } else {
        showBottomSheetFullScreen(context, FlutterWaveBankPage(), title: "Add TRF Bank".tr);
      }
    }
  }

  _userBankListView() {
    return Obx(() => _controller.userBanks.isEmpty
        ? handleEmptyViewWithLoading(_controller.isDataLoading.value, message: "Your bank list will appear here".tr)
        : Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
              shrinkWrap: true,
              itemCount: _controller.userBanks.length,
              itemBuilder: (BuildContext context, int index) => BankItemView(bank: _controller.userBanks[index]),
            ),
          ));
  }
}

class BankItemView extends StatelessWidget {
  const BankItemView({super.key, required this.bank});

  final Bank bank;

  @override
  Widget build(BuildContext context) {
    final colorPL = context.theme.primaryColorLight;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMid),
      child: Column(
        children: [
          twoTextSpaceFixed("Bank Name".tr, bank.bankName ?? "", color: colorPL),
          twoTextSpaceFixed("Account Name".tr, bank.accountHolderName ?? "", color: colorPL, flex: 4),
          twoTextSpaceFixed("Country".tr, bank.country ?? "", color: colorPL),
          twoTextSpaceFixed("Date".tr, formatDate(bank.createdAt, format: dateFormatMMMMDddYyy), color: colorPL),
          Row(
            children: [
              textAutoSizeKarla("${"Actions".tr}: ", color: colorPL, fontSize: Dimens.regularFontSizeMid),
              const Spacer(),
              if (bank.bankType == BankType.manual)
                buttonText("Edit".tr, onPressCallback: () => showBottomSheetFullScreen(context, ManualBankPage(bank: bank), title: "Edit Bank".tr)),
              hSpacer5(),
              buttonText("Delete".tr, bgColor: Colors.redAccent, onPressCallback: () => _deleteBank(context, bank)),
            ],
          ),
          dividerHorizontal()
        ],
      ),
    );
  }

  void _deleteBank(BuildContext context, Bank bank) {
    alertForAction(context,
        title: "Delete Bank".tr,
        subTitle: "bank delete message".tr,
        buttonTitle: "Delete".tr,
        buttonColor: Colors.red,
        onOkAction: () => Get.find<BanksController>().userBankDelete(bank));
  }
}
