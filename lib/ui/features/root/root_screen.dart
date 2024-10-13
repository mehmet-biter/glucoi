import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/ui/p2p_trade_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/models/settings.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/user.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/ui/features/side_navigation/gift_cards/gift_cards_buy/gift_cards_buy_screen.dart';
import 'package:tradexpro_flutter/ui/features/side_navigation/gift_cards/gift_cards_screen.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/notification_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import '../bottom_navigation/activity/activity_screen.dart';
import '../bottom_navigation/dashboard/dashboard_screen.dart';
import '../bottom_navigation/future_trade/future_trade_screen.dart';
import '../bottom_navigation/landing/landing_screen.dart';
import '../bottom_navigation/market/market_future/future_screen.dart';
import '../bottom_navigation/market/market_spot/market_screen.dart';
import '../bottom_navigation/wallet/wallet_screen.dart';
import '../side_navigation/blog/blog_screen.dart';
import '../side_navigation/currency/currency_screen.dart';
import '../side_navigation/news/news_screen.dart';
import '../side_navigation/profile/profile_screen.dart';
import '../side_navigation/referrals/referrals_screen.dart';
import '../side_navigation/security/security_screen.dart';
import '../side_navigation/settings/settings_screen.dart';
import 'help_support_page.dart';
import 'root_controller.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  RootScreenState createState() => RootScreenState();
}

class RootScreenState extends State<RootScreen> with TickerProviderStateMixin {
  final RootController _controller = Get.put(RootController());
  final autoSizeGroup = AutoSizeGroup();

  // final iconList = [AssetConstants.icLogoTransparentNoPadding, CustomIcons.dashboard, CustomIcons.wallet, CustomIcons.market, CustomIcons.activity];
 // final iconList = [AssetConstants.icLogoTransparentNoPadding, Icons.repeat_on, Icons.account_balance_wallet, Icons.store, Icons.account_tree];
  final iconList = [AssetConstants.icLogoTransparentNoPadding, Icons.card_giftcard,  Icons.settings];

  final titleList = ["Gittiom", "Gift Card".tr, "Setting".tr];
  RxBool isKeyBoardShowing = false.obs;
  int selectedMarketIndex = 0;

  @override
  void initState() {
    currentContext = context;
    _controller.setMyProfile();
    super.initState();
    _controller.changeBottomNavIndex = changeBottomNavTab;
    NotificationUtil.on().requestPermissions();
  }

  @override
  void dispose() {
    hideKeyboard();
    super.dispose();
    currentContext = null;
  }

  void changeBottomNavTab(int index, bool isShowMenu, {int? subIndex}) async {
    final settings = getSettingsLocal();
    if (index == 1 && isShowMenu) {
      List<PopupMenuItem<int>> menuList = [makePopupMenu('Spot Trading'.tr, 0)];
      if (settings?.enableFutureTrade == 1) menuList.add(makePopupMenu('Future Trading'.tr, 1));
      if (settings?.p2pModule == 1) menuList.add(makePopupMenu('P2P Trading'.tr, 2));

      if (menuList.length > 1) {
        final menuView = await showMenu<int>(
          context: context,
          items: menuList,
          position: RelativeRect.fromLTRB(20, Get.height - 150, Get.width - 150, 0.0),
        );
        if (menuView != null) {
          _controller.selectedTradeIndex = menuView;
          setState(() => _controller.bottomNavIndex = index);
        }
        return;
      }
    } else if (index == 3 && isShowMenu) {
      List<PopupMenuItem<int>> menuList = [makePopupMenu('Market'.tr, 0)];
      if (settings?.enableFutureTrade == 1) menuList.add(makePopupMenu('Future Market'.tr, 1));
      if (menuList.length > 1) {
        final menuView = await showMenu<int>(
          context: context,
          items: menuList,
          position: RelativeRect.fromLTRB(20, Get.height - 150, 0, 0.0),
        );
        if (menuView != null) {
          selectedMarketIndex = menuView;
          setState(() => _controller.bottomNavIndex = index);
        }
        return;
      }
    }

    if (subIndex != null) {
      _controller.selectedTradeIndex = subIndex;
    } else {
      _controller.selectedTradeIndex = TemporaryData.futureCoinPair != null ? 1 : 0;
    }

    setState(() => _controller.bottomNavIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: gIsDarkMode ? Brightness.light : Brightness.dark));
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      drawer: _getDrawerNew(),
      bottomNavigationBar: _bottomNavigationView(),
      body: _controller.bottomNavIndex == 0
          ? _getBody()
          : BGViewMain(
              child: SafeArea(
                child: Padding(padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop), child: _getBody()),
              ),
            ),
    );
  }

  Widget _bottomNavigationView() {
    return AnimatedBottomNavigationBar.builder(
      itemCount: iconList.length,
      tabBuilder: (int index, bool isActive) {
        final iconColor = gIsDarkMode
            ? Colors.white
            : isActive
                ? context.theme.colorScheme.background
                : context.theme.colorScheme.secondary;
        final bgColor = isActive ? context.theme.colorScheme.secondary : context.theme.colorScheme.background;
        final iconView = index == 0
            ? Image.asset(iconList[index] as String, color: iconColor, height: Dimens.iconSizeMin, width: Dimens.iconSizeMin)
            : Icon(iconList[index] as IconData, size: Dimens.iconSizeMin, color: iconColor);

        return isActive
            ? Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
                child: iconView)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [iconView, vSpacer2(), textAutoSizeKarla(titleList[index], fontSize: Dimens.regularFontSizeMin)],
              );
      },
      activeIndex: _controller.bottomNavIndex,
      backgroundColor: context.theme.colorScheme.background,
      splashColor: context.theme.colorScheme.secondary,
      gapLocation: GapLocation.none,
      onTap: (index) => changeBottomNavTab(index, true),
    );
  }

  Widget _getBody() {
    print("this is the bottom nav index: ${_controller.bottomNavIndex}");
    switch (_controller.bottomNavIndex) {
      case 0:
        return const LandingScreen();
      case 1:
        //new code by Nayon.Coders
        return const GiftCardsScreen(); //new code by Nayon.Coders

        //Old code
        // if (_controller.selectedTradeIndex == 0) {
        //   return const DashboardScreen();
        // } else if (_controller.selectedTradeIndex == 1) {
        //   return const FutureTradeScreen();
        // } else if (_controller.selectedTradeIndex == 2) {
        //   return const P2PTradeScreen();
        // } else {
        //   return Container();
        // }
      case 2:
        return const SettingsScreen();
       // return const WalletScreen(); //old code 
      // case 3:
        //Old code
        // if (selectedMarketIndex == 0) {
        //   return const MarketScreen();
        // } else if (selectedMarketIndex == 1) {
        //   return const FutureScreen();
        // } else {
        //   return Container();
        // }
      // case 4:
      //   return const ActivityScreen();
      default:
        return Container();
    }
  }

  _getDrawerNew() {
    return BGViewMain(
      child: Drawer(
          elevation: 0,
          backgroundColor: Colors.transparent,
          width: context.width,
          child: SafeArea(
            child: Obx(() {
              final hasUser = gUserRx.value.id > 0;
              return ListView(
                padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      buttonOnlyIcon(
                          iconPath: AssetConstants.icCloseBox, iconColor: context.theme.primaryColorDark, onPressCallback: () => Get.back()),
                    ],
                  ),
                  if (hasUser) _profileView(gUserRx.value) else signInNeedView(isDrawer: true),
                  vSpacer20(),
                  _drawerMenusView(hasUser),
                ],
              );
            }),
          )),
    );
  }

  Widget _profileView(User user) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.to(() => const ProfileScreen()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            showCircleAvatar(user.photo),
            vSpacer10(),
            textAutoSizeKarla(getName(user.firstName, user.lastName), fontSize: Dimens.regularFontSizeLarge),
            UserCodeView(code: user.userUniqueId),
            textAutoSizeKarla(user.email ?? "", fontSize: Dimens.regularFontSizeMid, fontWeight: FontWeight.normal),
          ],
        ),
      ),
    );
  }

  _drawerMenusView(bool hasUser) {
    final settings = getSettingsLocal();
    return Column(
      children: [
        if (hasUser) DrawerMenuItem(navTitle: 'Profile'.tr, iconPath: AssetConstants.icProfile, navAction: () => Get.to(() => const ProfileScreen())),
        if (hasUser)
          DrawerMenuItem(
              navTitle: 'Referrals'.tr,
              iconPath: AssetConstants.icNavReferrals,
              navAction: () {
                Get.back();
                Get.to(() => const ReferralsScreen());
              }),
        if (hasUser)
          DrawerMenuItem(
              navTitle: 'Activity'.tr,
              iconPath: AssetConstants.icNavActivity,
              navAction: () {
                Get.back();
                changeBottomNavTab(3, false);
              }),
        if (hasUser)
          DrawerMenuItem(
              navTitle: 'Settings'.tr,
              iconPath: AssetConstants.icNavSettings,
              navAction: () {
                Get.back();
                Get.to(() => const SettingsScreen());
              }),
        if (hasUser)
          DrawerMenuItem(navTitle: 'Security'.tr, iconPath: AssetConstants.icNavSecurity, navAction: () => Get.to(() => const SecurityScreen())),
        if (hasUser)
          DrawerMenuItem(
              navTitle: 'Verification and Limit'.tr,
              iconData: Icons.admin_panel_settings,
              navAction: () => Get.to(() => const ProfileScreen(viewType: 2))),
        // if (settings?.navbar?["ico"]?.status == true)
        //   DrawerMenuItem(navTitle: 'ICO'.tr, iconPath: AssetConstants.icIco, navAction: () => Get.to(() => const ICOScreen())),
        // if (hasUser) DrawerMenuItem(navTitle: 'Top Up'.tr, iconPath: AssetConstants.icTopUp, navAction: () => Get.to(() => const TopUpScreen())),
        // if (hasUser)
        //   DrawerMenuItem(navTitle: 'Utility Bill'.tr, iconPath: AssetConstants.icReceipt, navAction: () => Get.to(() => const UtilityBillsScreen())),
        if (hasUser)
        DrawerMenuItem(navTitle: 'Currency'.tr, iconData: Icons.paid_outlined, navAction: () => Get.to(() => const CurrencyScreen())),
        DrawerMenuItem(navTitle: 'Help_Support'.tr, iconData: Icons.live_help_outlined, navAction: () => Get.to(() => const HelpSupportPage())),
        // if (settings?.enableGiftCard == 1)
        //   DrawerMenuItem(navTitle: 'Gift Cards'.tr, iconPath: AssetConstants.icGift, navAction: () => Get.to(() => const GiftCardsScreen())),
        if (settings?.blogNewsModule == 1)
          DrawerMenuItem(navTitle: 'Blog'.tr, iconPath: AssetConstants.icBlog, navAction: () => Get.to(() => const BlogScreen())),
        if (settings?.blogNewsModule == 1)
          DrawerMenuItem(navTitle: 'News'.tr, iconPath: AssetConstants.icNewspaper, navAction: () => Get.to(() => const NewsScreen())),
        if (hasUser) DrawerMenuItem(navTitle: 'Log out'.tr, iconPath: AssetConstants.icNavLogout, navAction: () => _showLogOutAlert()),
        _bottomView(settings),
      ],
    );
  }

  void _showLogOutAlert() {
    alertForAction(context, title: "Log out".tr, subTitle: "Are you want to logout from app".tr, buttonTitle: "YES".tr, onOkAction: () {
      Get.back();
      _controller.logOut();
    });
  }

  _bottomView(CommonSettings? cSettings) {
    final socialView = _socialMediaView();
    return Container(
      margin: const EdgeInsets.all(Dimens.paddingLarge),
      padding: const EdgeInsets.symmetric(vertical: Dimens.paddingLarge, horizontal: Dimens.paddingMid),
      decoration: boxDecorationRoundCorner(),
      child: Column(
        children: [
          if (socialView != null) socialView,
          if (socialView != null) vSpacer10(),
          if (cSettings?.copyrightText.isValid ?? false)
            textSpanWithAction(cSettings?.copyrightText ?? "", " ${cSettings?.appTitle ?? ""}", () => openUrlInBrowser(URLConstants.website),
                maxLines: 2),
        ],
      ),
    );
  }

  _socialMediaView() {
    final objMap = GetStorage().read(PreferenceKey.mediaList);
    if (objMap != null) {
      try {
        final mList = List<SocialMedia>.from(objMap.map((element) => SocialMedia.fromJson(element)));
        if (mList.isValid) {
          return Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: Dimens.paddingMid,
              runSpacing: Dimens.paddingMid,
              children: List.generate(mList.length, (index) {
                final item = mList[index];
                final isValid = item.mediaIcon.isValid && item.mediaLink.isValid;
                return isValid
                    ? showImageNetwork(
                        imagePath: item.mediaIcon,
                        height: Dimens.iconSizeMid,
                        width: Dimens.iconSizeMid,
                        bgColor: Colors.transparent,
                        onPressCallback: () => openUrlInBrowser(item.mediaLink ?? ""))
                    : vSpacer0();
              }));
        }
      } catch (_) {
        printFunction("_socialMediaView error", _);
      }
    }
    return null;
  }
}
