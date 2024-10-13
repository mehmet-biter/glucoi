import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/ui/features/bottom_navigation/activity/activity_screen.dart';
import '../../sell_crypto/sell_crypto_screen.dart';
import '../wallet/swap/swap_screen.dart';
import '../../side_navigation/blog/blog_screen.dart';
import '../../side_navigation/faq/faq_page.dart';
import '../../side_navigation/gift_cards/gift_cards_screen.dart';
import '../../side_navigation/news/news_screen.dart';
import '../../side_navigation/profile/profile_screen.dart';
import '../../side_navigation/referrals/referrals_screen.dart';
import '../../side_navigation/security/security_screen.dart';
import '../../side_navigation/settings/settings_screen.dart';
import '../../side_navigation/top_up/top_up_screen.dart';
import '../../side_navigation/utility_bills/utility_bills_screen.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../../buy_crypto/buy_crypto_screen.dart';
import 'landing_widgets.dart';
import 'wallet_selection/wallet_selection_screen.dart';

class LandingScreenMore extends StatefulWidget {
  const LandingScreenMore({Key? key}) : super(key: key);

  @override
  State<LandingScreenMore> createState() => _LandingScreenMoreState();
}

class _LandingScreenMoreState extends State<LandingScreenMore> {
  final settings = getSettingsLocal();

  @override
  Widget build(BuildContext context) {
    final settings = getSettingsLocal();
    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
          child: Column(
            children: [
              appBarBackWithActions(title: "Quick Access".tr),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(Dimens.paddingMid),
                  children: [
                    vSpacer10(),
                    Wrap(
                      spacing: Dimens.paddingMid,
                      runSpacing: Dimens.paddingLargeExtra,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runAlignment: WrapAlignment.center,
                      children: [
                        NavigationIconView(
                            title: "Deposit".tr,
                            icon: Icons.file_download_outlined,
                            onTap: () => checkLoggedInAndKYCVerifyStatus(context, () => Get.to(() => const WalletSelectionScreen(fromKey: FromKey.deposit)))),
                        NavigationIconView(
                            title: "Withdraw".tr,
                            icon: Icons.file_upload_outlined,
                            onTap: () => checkLoggedInAndKYCVerifyStatus(context, () => Get.to(() => const WalletSelectionScreen(fromKey: FromKey.withdraw)))),
                        // NavigationIconView(
                        //     title: "Buy".tr,
                        //     icon: Icons.local_mall_outlined,
                        //     onTap: () => checkLoggedInAndKYCVerifyStatus(context, () => Get.to(() => const BuyCryptoScreen()))),
                        // NavigationIconView(
                        //     title: "Sell".tr,
                        //     icon: Icons.sell_outlined,
                        //     onTap: () => checkLoggedInAndKYCVerifyStatus(context, () => Get.to(() => const SellCryptoScreen()))),
                        NavigationIconView(
                            title: "Top Up".tr,
                            icon: Icons.book_online_outlined,
                            onTap: () => checkLoggedInStatus(context, () => Get.to(() => const TopUpScreen()))),
                        NavigationIconView(
                            title: "Utility Bill".tr,
                            icon: Icons.receipt_long_outlined,
                            onTap: () => checkLoggedInStatus(context, () => Get.to(() => const UtilityBillsScreen()))),
                        NavigationIconView(
                            title: "Gift Card".tr, icon: Icons.card_giftcard_outlined, onTap: () => Get.to(() => const GiftCardsScreen())),
                        // NavigationIconView(
                        //     title: "Fiat".tr,
                        //     icon: Icons.paid_outlined,
                        //     onTap: () => checkLoggedInStatus(context, () => Get.to(() => const FiatScreen()))),
                        // NavigationIconView(
                        //     title: "Swap".tr,
                        //     icon: Icons.swap_horizontal_circle_outlined,
                        //     onTap: () => checkLoggedInAndKYCVerifyStatus(context, () => Get.to(() => const SwapScreen()))),
                        // NavigationIconView(
                        //     title: "Market".tr,
                        //     icon: Icons.store_outlined,
                        //     onTap: () {
                        //       Get.back();
                        //       getRootController().changeBottomNavIndex(3, false);
                        //     }),
                        NavigationIconView(
                            title: "Reports".tr,
                            icon: Icons.work_history_outlined,
                            onTap: () => checkLoggedInStatus(context, () => Get.to(() => const ActivityScreen()))),

                        NavigationIconView(
                            title: "Profile".tr,
                            icon: Icons.person_outlined,
                            onTap: () => checkLoggedInStatus(context, () => Get.to(() => const ProfileScreen()))),
                        NavigationIconView(
                            title: "Referral".tr,
                            icon: Icons.account_tree_outlined,
                            onTap: () => checkLoggedInStatus(context, () => Get.to(() => const ReferralsScreen()))),
                        // NavigationIconView(title: "Staking".tr, icon: Icons.inventory_2_outlined, onTap: () => Get.to(() => const StakingScreen())),
                        // if (settings?.navbar?["ico"]?.status == true)
                        //   NavigationIconView(title: "ICO".tr, icon: Icons.local_atm_outlined, onTap: () => Get.to(() => const ICOScreen())),
                        NavigationIconView(
                            title: "Settings".tr,
                            icon: Icons.settings_outlined,
                            onTap: () => checkLoggedInStatus(context, () => Get.to(() => const SettingsScreen()))),
                        NavigationIconView(
                            title: "Security".tr,
                            icon: Icons.admin_panel_settings_outlined,
                            onTap: () => checkLoggedInStatus(context, () => Get.to(() => const SecurityScreen()))),
                      ],
                    ),
                    // vSpacer30(),
                    // textAutoSizeKarla("Assets".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeLarge),
                    // vSpacer10(),
                    // Wrap(
                    //   spacing: Dimens.paddingMid,
                    //   runSpacing: Dimens.paddingLargeExtra,
                    //   crossAxisAlignment: WrapCrossAlignment.start,
                    //   runAlignment: WrapAlignment.center,
                    //   children: [
                    //     // NavigationIconView(
                    //     //     title: "Spot Wallet".tr,
                    //     //     icon: Icons.account_balance_wallet_outlined,
                    //     //     onTap: () => _openBottomTab(walletType: WalletViewType.spot)),
                    //     // if (settings?.p2pModule == 1)
                    //     //   NavigationIconView(
                    //     //       title: "P2P Wallet".tr, icon: Icons.people_outlined, onTap: () => _openBottomTab(walletType: WalletViewType.p2p)),
                    //     if (settings?.enableFutureTrade == 1)
                    //       NavigationIconView(
                    //           title: "Future Wallet".tr,
                    //           icon: Icons.autorenew_outlined,
                    //           onTap: () => _openBottomTab(walletType: WalletViewType.future)),
                    //   ],
                    // ),
                    // vSpacer30(),
                    // textAutoSizeKarla("Trade".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeLarge),
                    // vSpacer10(),
                    // Wrap(
                    //   alignment: WrapAlignment.start,
                    //   spacing: Dimens.paddingMid,
                    //   runSpacing: Dimens.paddingLargeExtra,
                    //   crossAxisAlignment: WrapCrossAlignment.start,
                    //   runAlignment: WrapAlignment.center,
                    //   children: [
                    //     NavigationIconView(
                    //         title: "Spot Trade".tr, icon: Icons.filter_center_focus_outlined, onTap: () => _openBottomTab(tradeType: 0)),
                    //     // NavigationIconView(title: "P2P Trade".tr, icon: Icons.people_outline, onTap: () => _openBottomTab(tradeType: 2)),
                    //     if (settings?.enableFutureTrade == 1)
                    //       NavigationIconView(title: "Future Trade".tr, icon: Icons.autorenew_outlined, onTap: () => _openBottomTab(tradeType: 1)),
                    //   ],
                    // ),
                    vSpacer30(),
                    textAutoSizeKarla("Info".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeLarge),
                    vSpacer10(),
                    Wrap(
                      alignment: WrapAlignment.start,
                      spacing: Dimens.paddingMid,
                      runSpacing: Dimens.paddingLargeExtra,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      runAlignment: WrapAlignment.center,
                      children: [
                        NavigationIconView(
                            title: "Blog".tr,
                            icon: Icons.rss_feed_outlined,
                            onTap: () => checkLoggedInStatus(context, () => Get.to(() => const BlogScreen()))),
                        NavigationIconView(
                            title: "News".tr,
                            icon: Icons.newspaper_outlined,
                            onTap: () => checkLoggedInStatus(context, () => Get.to(() => const NewsScreen()))),
                        NavigationIconView(
                            title: "FAQ".tr,
                            icon: Icons.quiz_outlined,
                            onTap: () => checkLoggedInStatus(context, () => Get.to(() => const FAQPage()))),
                      ],
                    ),
                    vSpacer10(),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }

  void _openBottomTab({int? walletType, int? tradeType}) {
    Get.back();
    if (walletType != null) {
      TemporaryData.switchViewId = walletType;
      getRootController().changeBottomNavIndex(2, false);
    } else if (tradeType != null) {
      getRootController().changeBottomNavIndex(1, false, subIndex: tradeType);
    }
  }
}
