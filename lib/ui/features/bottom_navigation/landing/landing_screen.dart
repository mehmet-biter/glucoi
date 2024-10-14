import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/settings.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/ui/features/bottom_navigation/activity/activity_screen.dart';
import 'package:tradexpro_flutter/ui/features/side_navigation/referrals/referrals_screen.dart';
import 'package:tradexpro_flutter/ui/features/side_navigation/top_up/top_up_screen.dart';
import 'package:tradexpro_flutter/ui/features/side_navigation/utility_bills/utility_bills_screen.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/shimmer_loading/shimmer_view.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../../buy_crypto/buy_crypto_screen.dart';
import '../../sell_crypto/sell_crypto_screen.dart';
import '../../side_navigation/gift_cards/gift_cards_screen.dart';
import '../wallet/swap/swap_screen.dart';
import '../wallet/wallet_widgets.dart';
import 'landing_controller.dart';
import 'landing_screen_more.dart';
import 'landing_widgets.dart';
import 'wallet_selection/wallet_selection_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> with SingleTickerProviderStateMixin {
  final _controller = Get.put(LandingController());
  late final TabController _tabController;
  RxInt selectedIndex = 0.obs;
  final settings = getSettingsLocal();

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    _controller.getWalletTotalBalance();
    _controller.getLandingSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          color: context.theme.focusColor,
          child: Column(
            children: [
              appBarMain(context, title: ""),
              Obx(() => WalletBalanceViewLanding(
                  totalBalance: _controller.wOverview.value,
                  isHide: gBalanceHide.value,
                  isLoading: _controller.isLoadingBalance.value,
                  onSync: () {
                    _controller.isLoadingBalance.value = true;
                    _controller.getWalletTotalBalance();
                  })),
            ],
          )),
      Expanded(child: Obx(() {
        final hasUser = gUserRx.value.id > 0;
        final lData = _controller.landingData.value;
        return ListView(
          padding: const EdgeInsets.all(Dimens.paddingMid),
          children: [
            // Obx(() => WalletBalanceViewTotal(totalBalance: _controller.wOverview.value, isHide: gBalanceHide.value)),
            // _exploreViewSlider(),
            _exploreView(),
            _controller.isLoading.value
                ? const ShimmerViewLanding()
                : Column(
                    children: [
                      vSpacer10(),
                      if (lData.landingSecondSectionStatus == 1 && lData.bannerList.isValid) _bannerListView(lData.bannerList!),
                      vSpacer10(),
                      if (lData.landingFirstSectionStatus == 1) _topTitleView(lData),
                      // if (lData.announcementList.isValid) _announcementListView(lData.announcementList!),
                      // if (lData.landingThirdSectionStatus == 1) _marketTrendListView(),
                    ],
                  ),
            if (!hasUser) signInNeedView(isDrawer: true),
          ],
        );
      }))
    ]);
  }

  _exploreView() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMid),
      height: 200,
      decoration: boxDecorationRoundBorder(radius: Dimens.radiusCornerMid, borderColor: context.theme.focusColor),
      child: _explorePageOne(),
    );
  }

  // _exploreViewSlider() {
  //   return Column(
  //     children: [
  //       vSpacer10(),
  //       CarouselSlider.builder(
  //           itemCount: 1,
  //           itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
  //             return itemIndex == 0 ? _explorePageOne() : _explorePageTwo();
  //           },
  //           options: CarouselOptions(
  //               height: 200, viewportFraction: 1, enableInfiniteScroll: false, onPageChanged: (index, reason) => selectedIndex.value = index)),
  //       Obx(() => Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: List.generate(2, (index) {
  //             return Container(
  //                 width: Dimens.paddingMid,
  //                 height: Dimens.paddingMid,
  //                 margin: const EdgeInsets.symmetric(horizontal: Dimens.paddingMin),
  //                 decoration:
  //                     BoxDecoration(shape: BoxShape.circle, color: context.theme.focusColor.withOpacity(selectedIndex.value == index ? 1 : 0.5)));
  //           }))),
  //       vSpacer10(),
  //     ],
  //   );
  // }

  _explorePageOne() {
    return Wrap(
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
        NavigationIconView(
            title: "Topup".tr,
            icon: Icons.attach_money,
            onTap: () => checkLoggedInAndKYCVerifyStatus(context, () => Get.to(() => const TopUpScreen()))),
        NavigationIconView(
            title: "Utility Bill".tr,
            icon: Icons.receipt_long,
            onTap: () => checkLoggedInAndKYCVerifyStatus(context, () => Get.to(() => const UtilityBillsScreen()))),
        // NavigationIconView(
        //     title: "Spot Trade".tr, icon: Icons.filter_center_focus_outlined, onTap: () => getRootController().changeBottomNavIndex(1, false)),
        // NavigationIconView(
        //     title: "P2P Trade".tr, icon: Icons.people_outline, onTap: () => getRootController().changeBottomNavIndex(1, false, subIndex: 2)),
        // NavigationIconView(
        //     title: "Top Up".tr, icon: Icons.book_online_outlined, onTap: () => checkLoggedInStatus(context, () => Get.to(() => const TopUpScreen()))),
        // NavigationIconView(
        //     title: "Utility Bill".tr,
        //     icon: Icons.receipt_long_outlined,
        //     onTap: () => checkLoggedInStatus(context, () => Get.to(() => const UtilityBillsScreen()))),
        NavigationIconView(title: "Reports".tr, icon: Icons.work_history_outlined, onTap: () => Get.to(ActivityScreen())),

    NavigationIconView(
              title: "Referral".tr,
              icon: Icons.account_tree_outlined,
              onTap: () => checkLoggedInStatus(context, () => Get.to(() => const ReferralsScreen()))),        NavigationIconView(title: "Gift Card".tr, icon: Icons.card_giftcard_outlined, onTap: () => Get.to(() => const GiftCardsScreen())),
        // NavigationIconView(
        //     title: "Fiat".tr, icon: Icons.paid_outlined, onTap: () => checkLoggedInStatus(context, () => Get.to(() => const FiatScreen()))),
        // NavigationIconView(
        //     title: "Swap".tr,
        //     icon: Icons.swap_horizontal_circle_outlined,
        //     onTap: () => checkLoggedInAndKYCVerifyStatus(context, () => Get.to(() => const SwapScreen()))),
        NavigationIconView(title: "More".tr, icon: Icons.dashboard_outlined, onTap: () => Get.to(() => const LandingScreenMore())),
      ],
    );
  }

  // _explorePageTwo() {
  //   return Wrap(
  //     spacing: Dimens.paddingMid,
  //     runSpacing: Dimens.paddingLargeExtra,
  //     crossAxisAlignment: WrapCrossAlignment.start,
  //     runAlignment: WrapAlignment.center,
  //     children: [
  //       NavigationIconView(title: "Wallet".tr, icon: Icons.wallet_outlined, onTap: () => getRootController().changeBottomNavIndex(2, false)),
  //       NavigationIconView(title: "Market".tr, icon: Icons.store_outlined, onTap: () => getRootController().changeBottomNavIndex(3, false)),
  //       NavigationIconView(title: "Reports".tr, icon: Icons.work_history_outlined, onTap: () => getRootController().changeBottomNavIndex(4, false)),
  //       NavigationIconView(
  //           title: "Profile".tr, icon: Icons.person_outlined, onTap: () => checkLoggedInStatus(context, () => Get.to(() => const ProfileScreen()))),
  //       NavigationIconView(
  //           title: "Referral".tr,
  //           icon: Icons.account_tree_outlined,
  //           onTap: () => checkLoggedInStatus(context, () => Get.to(() => const ReferralsScreen()))),
  //       NavigationIconView(title: "Staking".tr, icon: Icons.inventory_2_outlined, onTap: () => Get.to(() => const StakingScreen())),
  //       NavigationIconView(
  //           title: "Swap".tr,
  //           icon: Icons.swap_horizontal_circle_outlined,
  //           onTap: () => checkLoggedInStatus(context, () => Get.to(() => const SwapScreen()))),
  //       NavigationIconView(
  //           title: "Settings".tr,
  //           icon: Icons.settings_outlined,
  //           onTap: () => checkLoggedInStatus(context, () => Get.to(() => const SettingsScreen()))),
  //       NavigationIconView(
  //           title: "Security".tr,
  //           icon: Icons.admin_panel_settings_outlined,
  //           onTap: () => checkLoggedInStatus(context, () => Get.to(() => const SecurityScreen()))),
  //       NavigationIconView(title: "More".tr, icon: Icons.dashboard_outlined, onTap: () => Get.to(() => const LandingScreenMore())),
  //     ],
  //   );
  // }

  _topTitleView(LandingData lData) {
    return Column(
      children: [
        vSpacer10(),
        if (lData.landingTitle.isValid) textAutoSizeKarla(lData.landingTitle ?? "", maxLines: 5, textAlign: TextAlign.start),
        if (lData.landingDescription.isValid) vSpacer10(),
        if (lData.landingDescription.isValid) textAutoSizePoppins(lData.landingDescription ?? "", maxLines: 15, textAlign: TextAlign.start),
        if (lData.landingBannerImage.isValid) vSpacer10(),
        if (lData.landingBannerImage.isValid)
          showImageNetwork(imagePath: lData.landingBannerImage, width: context.width, height: context.width / 2, boxFit: BoxFit.fitWidth),
      ],
    );
  }

  _announcementListView(List<Announcement> list) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimens.paddingMid),
      child: Column(
        children: List.generate(list.length, (index) {
          return AnnouncementItemView(announcement: list[index], onTap: () => showAnnouncementDetailsView(list[index]));
        }),
      ),
    );
  }

  _bannerListView(List<Announcement> list) {
    final height = context.width / 3;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMid),
      child: CarouselSlider.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
            final announcement = list[itemIndex];
            return InkWell(
              onTap: () => showAnnouncementDetailsView(announcement),
              child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMin),
                  child: showCachedNetworkImage(announcement.image ?? "", size: height * 2)),
            );
          },
          options: CarouselOptions(height: height, viewportFraction: 0.6, autoPlay: true, autoPlayInterval: const Duration(seconds: 3))),
    );
  }

  void showAnnouncementDetailsView(Announcement announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          vSpacer30(),
          buttonOnlyIcon(
              iconPath: AssetConstants.icCloseBox,
              size: Dimens.iconSizeMid,
              iconColor: context.theme.primaryColor,
              onPressCallback: () => Get.back()),
          AnnouncementDetailsView(announcement: announcement)
        ],
      ),
    );
  }

  _marketTrendListView() {
    final lData = _controller.landingData.value;
    final list = _controller.selectedTab.value == 0
        ? lData.assetCoinPairs
        : _controller.selectedTab.value == 1
            ? lData.hourlyCoinPairs
            : lData.latestCoinPairs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vSpacer15(),
        textAutoSizeKarla("Market Trend".tr, fontSize: Dimens.regularFontSizeLarge, textAlign: TextAlign.start),
        tabBarUnderline(["Core Assets".tr, "24H Gainer".tr, "New Listing".tr], _tabController,
            isScrollable: true, fontSize: Dimens.regularFontSizeMid, onTap: (index) => _controller.selectedTab.value = index),
        vSpacer5(),
        Row(children: [
          hSpacer10(),
          Expanded(flex: 2, child: textAutoSizePoppins("Market".tr, textAlign: TextAlign.start)),
          hSpacer5(),
          Expanded(flex: 2, child: textAutoSizePoppins("${"Price".tr}/\n${"Change (24h)".tr}", maxLines: 2)),
          hSpacer5(),
          Expanded(flex: 2, child: textAutoSizePoppins("${"Volume".tr}/\n${"Action".tr}", maxLines: 2, textAlign: TextAlign.end)),
          hSpacer10(),
        ]),
        vSpacer5(),
        list.isValid ? Column(children: List.generate(list?.length ?? 0, (index) => MarketTrendItemView(coin: list![index]))) : showEmptyView()
      ],
    );
  }
}
