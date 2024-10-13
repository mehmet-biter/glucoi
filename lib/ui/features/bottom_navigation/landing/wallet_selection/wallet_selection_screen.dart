import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/wallet.dart';
import 'package:tradexpro_flutter/helper/currency_check.dart';
import 'package:tradexpro_flutter/ui/features/bottom_navigation/wallet/wallet_widgets.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../../wallet/wallet_deposit/currency_wallet_deposit_screen.dart';
import '../../wallet/wallet_deposit/wallet_deposit_screen.dart';
import '../../wallet/wallet_withdrawal/currency_wallet_withdrawal_page.dart';
import '../../wallet/wallet_withdrawal/wallet_withdraw_screen.dart';
import 'wallet_selection_controller.dart';

class WalletSelectionScreen extends StatefulWidget {
  const WalletSelectionScreen({super.key, required this.fromKey});

  final String fromKey;

  @override
  State<WalletSelectionScreen> createState() => _WalletSelectionScreenState();
}

class _WalletSelectionScreenState extends State<WalletSelectionScreen> with SingleTickerProviderStateMixin {
  final _controller = Get.put(WalletSelectionController());
  late TabController _tabController;
  Timer? searchTimer;

  @override
  void initState() {
    _controller.fromKey = widget.fromKey;
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    _controller.getWalletList();
    _controller.getMostUsedWallets();
  }

  @override
  Widget build(BuildContext context) {
    final title = _controller.fromKey == FromKey.deposit ? "Deposit".tr : "Withdraw".tr;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            appBarBackWithActions(title: title),
            tabBarUnderline(["Fiat".tr ], _tabController, onTap: (index) { // "Crypto".tr removed
              _controller.currencyType.value = index;
              _controller.searchController.text = '';
              _controller.getWalletList();
              _controller.getMostUsedWallets();
            }, indicatorColor: context.theme.focusColor),
            textFieldSearch(controller: _controller.searchController, onTextChange: _onTextChange, height: Dimens.btnHeightMid),
            Obx(() {
              return _controller.mostUsedWallets.isEmpty
                  ? vSpacer0()
                  : Padding(
                      padding: const EdgeInsets.all(Dimens.paddingMid),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textAutoSizePoppins("History".tr, fontSize: Dimens.regularFontSizeMid),
                          vSpacer5(),
                          GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              crossAxisCount: 3,
                              childAspectRatio: 3,
                              children: List.generate(_controller.mostUsedWallets.length, (index) {
                                final wallet = _controller.mostUsedWallets[index];
                                return buttonText(wallet.coinType ?? '', textColor:  context.theme.primaryColor,
                                    bgColor: context.theme.focusColor.withOpacity(0.1), onPressCallback: () => _onTabCurrency(wallet));
                              }))
                        ],
                      ),
                    );
            }),
            Obx(() => _controller.walletList.isEmpty
                ? handleEmptyViewWithLoading(_controller.isLoading.value)
                : Expanded(
                    child: ListView.builder(
                        itemCount: _controller.walletList.length,
                        itemBuilder: (context, index) =>
                            SpotWalletView(wallet: _controller.walletList[index], onTap: () => _onTabCurrency(_controller.walletList[index])))))
          ],
        ),
      ),
    );
  }

  _onTextChange(String text) {
    if (searchTimer?.isActive ?? false) searchTimer?.cancel();
    searchTimer = Timer(const Duration(seconds: 1), () => _controller.getWalletList());
  }

  _onTabCurrency(Wallet wallet) {
    if (widget.fromKey == FromKey.deposit) {
      if (wallet.currencyType == CurrencyType.crypto) {
        Get.back();
        Get.to(() => WalletDepositScreen(wallet: wallet));
      } else if (wallet.currencyType == CurrencyType.fiat) {
        if (CurrencyCheck.checkDepositCurrency(wallet.coinType, context)) {
          Get.back();
          Get.to(() => CurrencyWalletDepositScreen(wallet: wallet));
        }
      }
    } else {
      if (wallet.currencyType == CurrencyType.crypto) {
        Get.back();
        Get.to(() => WalletWithdrawScreen(wallet: wallet));
      } else if (wallet.currencyType == CurrencyType.fiat) {
        if (CurrencyCheck.checkDepositCurrency(wallet.coinType, context)) {
          Get.back();
          Get.to(() => CurrencyWalletWithdrawalScreen(wallet: wallet));
        }
      }
    }
  }
}
