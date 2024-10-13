import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/ico/ico_constants.dart';
import 'package:tradexpro_flutter/addons/ico/ico_ui/ico_widgets.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_phase.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'ico_buy_token_bank_view.dart';
import 'ico_buy_token_card_view.dart';
import 'ico_buy_token_controller.dart';
import 'ico_buy_token_paypal_view.dart';
import 'ico_buy_token_wallet_view.dart';

class IcoBuyTokenScreen extends StatefulWidget {
  const IcoBuyTokenScreen({super.key, required this.phase});

  final IcoPhase phase;

  @override
  State<IcoBuyTokenScreen> createState() => _IcoBuyTokenScreenState();
}

class _IcoBuyTokenScreenState extends State<IcoBuyTokenScreen> {
  final _controller = Get.put(IcoBuyCoinController());

  @override
  void initState() {
    _controller.phase.value = widget.phase;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getIcoActivePhaseDetails(widget.phase.id ?? 0);
      _controller.getIcoTokenBuyPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
            child: Padding(
                padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
                child: Column(
                  children: [
                    appBarBackWithActions(title: "Token Payment".tr, fontSize: Dimens.regularFontSizeMid),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(Dimens.paddingMid),
                        children: [
                          vSpacer10(),
                          Obx(() => Container(
                                decoration: boxDecorationRoundBorder(),
                                padding: const EdgeInsets.all(Dimens.paddingMid),
                                child: IcoPhaseInfoView(phase: _controller.phase.value, fromPage: IcoFromKey.buyToken, flex: 4),
                              )),
                          vSpacer10(),
                          Obx(() {
                            final methodList = _controller.getMethodList();
                            return _controller.isDataLoading.value
                                ? showLoading()
                                : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    vSpacer10(),
                                    textAutoSizeKarla("Select Method".tr, fontSize: Dimens.regularFontSizeMid),
                                    dropDownListIndex(methodList, _controller.selectedMethodIndex.value, "Select Method".tr, hMargin: 0, (value) {
                                      _controller.selectedMethodIndex.value = value;
                                    }),
                                    vSpacer10(),
                                    _openPaymentView(_controller.selectedMethodIndex.value)
                                  ]);
                          })
                        ],
                      ),
                    )
                  ],
                ))),
      ),
    );
  }

  _openPaymentView(int selected) {
    final methods = _controller.buySettings.value.paymentMethods?[selected];
    switch (methods?.paymentMethod) {
      case PaymentMethodType.bank:
        return const IcoBuyTokenBankView();
      case PaymentMethodType.card:
        return const IcoBuyTokenCardView();
      case PaymentMethodType.paypal:
        return const IcoBuyTokenPaypalView();
      case PaymentMethodType.crypto:
      case PaymentMethodType.wallet:
        return const IcoBuyTokenWalletView();
      default:
        return Container();
    }
  }
}
