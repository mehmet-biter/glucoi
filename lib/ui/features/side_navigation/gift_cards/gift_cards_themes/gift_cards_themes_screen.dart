import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import '../gift_cards_buy/gift_cards_buy_screen.dart';
import '../gift_cards_widgets.dart';
import 'gift_cards_themes_controller.dart';

class GiftCardThemesScreen extends StatefulWidget {
  const GiftCardThemesScreen({Key? key}) : super(key: key);

  @override
  GiftCardThemesScreenState createState() => GiftCardThemesScreenState();
}

class GiftCardThemesScreenState extends State<GiftCardThemesScreen> {
  final _controller = Get.put(GiftCardThemesController());
  final _scrollController = ScrollController();
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getGiftCardThemeData(() => setState(() {}));
      _scrollController.addListener(() {
        if (_scrollController.position.maxScrollExtent == _scrollController.offset) {
          if (_controller.hasMoreData) _controller.getGiftCardThemes(true);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 3;

    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
            child: Column(
              children: [
                appBarBackWithActions(title: "Themed Gift Cards".tr),
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      if ((_controller.giftCardsData?.header.isValid ?? false) || (_controller.giftCardsData?.description.isValid ?? false))
                        SliverAppBar(
                          backgroundColor: Colors.transparent,
                          automaticallyImplyLeading: false,
                          expandedHeight: width,
                          collapsedHeight: width,
                          flexibleSpace: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                            child: GiftCardTitleView(
                                title: _controller.giftCardsData?.header,
                                subTitle: _controller.giftCardsData?.description,
                                image: _controller.giftCardsData?.banner),
                          ),
                        ),
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        backgroundColor: Get.theme.scaffoldBackgroundColor,
                        toolbarHeight: Dimens.menuHeightSettings + 5,
                        pinned: true,
                        flexibleSpace: _topFilterView(),
                      ),
                      Obx(() {
                        return _controller.themeList.isEmpty
                            ? SliverFillRemaining(child: handleEmptyViewWithLoading(_controller.isLoading.value))
                            : SliverPadding(
                                padding: const EdgeInsets.all(10),
                                sliver: SliverGrid.count(
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    crossAxisCount: 2,
                                    childAspectRatio: 1.75,
                                    children: List.generate(_controller.themeList.length, (index) {
                                      final banner = _controller.themeList[index];
                                      return showImageNetwork(
                                          imagePath: banner.banner,
                                          boxFit: BoxFit.cover,
                                          onPressCallback: () => Get.to(() => GiftCardBuyScreen(uid: banner.uid ?? "")));
                                    })));
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTextChanged(String text) {
    if (_searchTimer?.isActive ?? false) _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(seconds: 1), () => _controller.getGiftCardThemes(false));
  }

  _topFilterView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        hSpacer10(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              textAutoSizePoppins("${"Country".tr}:"),
              Obx(() {
                return dropDownListIndex(_controller.getCountryNameList(), _controller.selectedCountry.value, "", (index) {
                  _controller.selectedCountry.value = index;
                  _controller.getGiftCardThemes(false);
                }, hMargin: 0);
              })
            ],
          ),
        ),
        hSpacer10(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              textAutoSizePoppins(""),
              textFieldSearch(controller: _controller.searchController, margin: 0, onTextChange: _onTextChanged)
            ],
          ),
        ),
        hSpacer10()
      ],
    );
  }
}
