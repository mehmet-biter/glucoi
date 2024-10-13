import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
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
import 'package:tradexpro_flutter/data/models/wallet.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';

import 'p2p_wallet_controller.dart';

class P2PWalletScreen extends StatefulWidget {
  const P2PWalletScreen({Key? key}) : super(key: key);

  @override
  State<P2PWalletScreen> createState() => _P2PWalletScreenState();
}

class _P2PWalletScreenState extends State<P2PWalletScreen> {
  final _controller = Get.put(P2pWalletController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getP2pWalletsList(false));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        textFieldSearch(onTextChange: (text) => _controller.searchWallets(text)),
        Obx(() => _controller.walletList.isEmpty
            ? handleEmptyViewWithLoading(_controller.isDataLoading.value)
            : Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                  itemCount: _controller.walletList.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_controller.hasMoreData && index == (_controller.walletList.length - 1)) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getP2pWalletsList(true));
                    }
                    return P2pWalletItemView(_controller.walletList[index]);
                  },
                ),
              ))
      ]),
    );
  }
}

class P2pWalletItemView extends StatelessWidget {
  const P2pWalletItemView(this.p2pWallet, {Key? key}) : super(key: key);
  final Wallet p2pWallet;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: Dimens.paddingMin),
      color: Colors.grey.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.paddingMid),
        child: Column(
          children: [
            Row(
              children: [
                showCircleAvatar(p2pWallet.coinIcon, size: Dimens.iconSizeMid),
                hSpacer5(),
                textAutoSizeTitle(p2pWallet.name ?? "", fontSize: Dimens.regularFontSizeMid),
              ],
            ),
            vSpacer5(),
            twoTextSpace("${"Symbol".tr} : ", p2pWallet.coinType ?? ""),
            vSpacer2(),
            twoTextSpace("${"Available Balance".tr} : ", coinFormat(p2pWallet.balance)),
            vSpacer2(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textAutoSizeKarla("${"Action".tr} : ", fontSize: Dimens.regularFontSizeMid, color: Get.theme.primaryColorLight),
                hSpacer10(),
                Wrap(
                  children: [
                    buttonOnlyIcon(
                        iconData: Icons.send_outlined,
                        size: Dimens.iconSizeMin,
                        iconColor: Get.theme.primaryColor,
                        visualDensity: minimumVisualDensity,
                        onPressCallback: () => _voidShowTransferView(context, p2pWallet, true)),
                    buttonOnlyIcon(
                        iconData: Icons.wallet_outlined,
                        size: Dimens.iconSizeMin,
                        iconColor: Get.theme.primaryColor,
                        visualDensity: minimumVisualDensity,
                        onPressCallback: () => _voidShowTransferView(context, p2pWallet, false)),
                  ],
                )
              ],
            ),
            vSpacer5(),
          ],
        ),
      ),
    );
  }

  _voidShowTransferView(BuildContext context, Wallet wallet, bool isSend) {
    final message = isSend ? "Send Balance".tr : "Receive Balance".tr;
    final amountEditController = TextEditingController();
    RxString error = "".obs;

    showModalSheetFullScreen(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vSpacer15(),
            textAutoSizeKarla(message, maxLines: 2, fontSize: Dimens.regularFontSizeMid),
            vSpacer20(),
            textFieldWithSuffixIcon(
                controller: amountEditController,
                labelText: "Amount".tr,
                hint: "Your amount".tr,
                type: TextInputType.number,
                onTextChange: (text) => error.value = ""),
            Obx(() => error.value.isValid ? textAutoSizePoppins(error.value, color: Colors.red) : vSpacer0()),
            vSpacer20(),
            buttonRoundedMain(
                text: "Exchange".tr,
                onPressCallback: () {
                  final amount = makeDouble(amountEditController.text.trim());
                  if (amount <= 0) {
                    error.value = "amount_must_greater_than_0".tr;
                    return;
                  }
                  hideKeyboard(context: context);
                  Get.find<P2pWalletController>().transferAmount(wallet, amount, isSend);
                }),
            vSpacer15(),
          ],
        ));
  }
}
