import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/appbar_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/helper/main_bg_view.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_field_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import '../gift_cards_widgets.dart';
import 'gift_cards_buy_controller.dart';

class GiftCardBuyScreen extends StatefulWidget {
  const GiftCardBuyScreen({Key? key, required this.uid}) : super(key: key);
  final String uid;

  @override
  GiftCardBuyScreenState createState() => GiftCardBuyScreenState();
}

class GiftCardBuyScreenState extends State<GiftCardBuyScreen> {
  final _controller = Get.put(GiftCardBuyController());

  // final phoneTextController = TextEditingController();
  // final nameTextController = TextEditingController();
  // final emailTextController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    _controller.isLoading = true;
    _controller.selectedCoin.value = -1;
    _controller.selectedBannerIndex.value = 0;
    // phoneTextController.text = _controller.selectedCountry.value.phoneCode;
    _controller.totalCurrencyAmount.value = 0;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.getGiftCardBuyData(widget.uid, () {
        setState(() {
          if (_controller.giftCardBuyData?.selectedBanner != null) {
            _controller.selectedBanner = _controller.giftCardBuyData!.selectedBanner!;
            _controller.amount.value = _controller.selectedBanner.minRecipientAmount ?? 0;
            _controller.quantity.value = 1;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 3;
    width = width + (MediaQuery.of(context).textScaleFactor > 1 ? 25 : 0);
    final featureList = _featureItemList();
    final banners = _controller.giftCardBuyData?.banners;
    final banner = _controller.selectedBanner;
    final isFixed = banner.denominationType == DenominationType.fixed;
    final minMaxText = isFixed
        ? "${banner.recipientCurrency ?? ""} ${banner.minRecipientAmount}"
        : "${banner.recipientCurrency ?? ""} ${banner.minRecipientAmount} - ${banner.recipientCurrency ?? ""} ${banner.maxRecipientAmount}";
    final unitPrice = (banner.minSenderAmount ?? 0) / (banner.minRecipientAmount ?? 0);

    return Scaffold(
      body: BGViewMain(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
            child: KeyboardDismissOnTap(
              child: Column(
                children: [
                  appBarBackWithActions(title: "Buy Gift Card".tr),
                  _controller.isLoading
                      ? showLoading()
                      : Expanded(
                          child: CustomScrollView(
                            slivers: [
                              if ((_controller.giftCardBuyData?.header.isValid ?? false) ||
                                  (_controller.giftCardBuyData?.description.isValid ?? false))
                                SliverAppBar(
                                  backgroundColor: Colors.transparent,
                                  automaticallyImplyLeading: false,
                                  expandedHeight: width,
                                  collapsedHeight: width,
                                  flexibleSpace: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                                    child: GiftCardTitleView(
                                        title: _controller.giftCardBuyData?.header,
                                        subTitle: _controller.giftCardBuyData?.description,
                                        image: _controller.giftCardBuyData?.banner),
                                  ),
                                ),
                              if (featureList.isNotEmpty)
                                SliverAppBar(
                                  backgroundColor: Colors.transparent,
                                  automaticallyImplyLeading: false,
                                  toolbarHeight: 85,
                                  flexibleSpace: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid, vertical: Dimens.paddingMin),
                                    child: Row(children: featureList),
                                  ),
                                ),
                              SliverPadding(
                                  padding: const EdgeInsets.all(Dimens.paddingMid),
                                  sliver: SliverList.list(children: [
                                    Obx(() => GiftCardImageAndTag(
                                        imagePath: banner.banner, amountText: "${_controller.amount.value} ${banner.recipientCurrency ?? ""}")),
                                    vSpacer15(),
                                    textAutoSizeKarla(banner.title ?? "", maxLines: 3, textAlign: TextAlign.start),
                                    vSpacer10(),
                                    textAutoSizePoppins(minMaxText, textAlign: TextAlign.start, color: Get.theme.primaryColor),
                                    dividerHorizontal(height: Dimens.btnHeightMid),
                                    textAutoSizeKarla("Pay With Currency".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                    vSpacer5(),
                                    Obx(() => dropDownListIndex(_controller.getCoinNameList(), _controller.selectedCoin.value, "Select Coin".tr,
                                            hMargin: 0, (index) {
                                          _controller.selectedCoin.value = index;
                                          _controller.getGiftCardCoinConvert();
                                        })),
                                    vSpacer15(),
                                    textAutoSizeKarla("Amount".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                    vSpacer5(),
                                    textFieldWithWidget(
                                        controller: TextEditingController(text: _controller.amount.value.toString()),
                                        hint: "Enter Amount".tr,
                                        type: const TextInputType.numberWithOptions(decimal: true),
                                        isEnable: !isFixed,
                                        suffixWidget: textFieldTextWidget(banner.recipientCurrency ?? "", hMargin: Dimens.paddingMid),
                                        onTextChange: (text) => _onTextChanged(text, true)),
                                    if (!isFixed)
                                      textAutoSizePoppins("${"Min".tr} ${banner.minRecipientAmount} - ${"Max".tr} ${banner.maxRecipientAmount}",
                                          textAlign: TextAlign.start),
                                    vSpacer15(),
                                    textAutoSizeKarla("Quantity".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                    vSpacer5(),
                                    textFieldWithWidget(
                                        controller: TextEditingController(text: _controller.quantity.value.toString()),
                                        hint: "Enter Quantity".tr,
                                        type: TextInputType.number,
                                        onTextChange: (text) => _onTextChanged(text, false)),
                                    vSpacer15(),
                                    Obx(() => CupertinoFormRow(
                                        padding: EdgeInsets.zero,
                                        prefix: textAutoSizeKarla("Pre-order".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                        child: CupertinoSwitch(
                                          value: _controller.isPreOrder.value,
                                          activeColor: context.theme.focusColor,
                                          onChanged: (value) => _controller.isPreOrder.value = value,
                                        ))),
                                    // vSpacer15(),
                                    // textAutoSizeKarla("Sender Name".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                    // vSpacer5(),
                                    // textFieldWithWidget(controller: nameTextController, hint: "Enter Name".tr, type: TextInputType.name),
                                    // vSpacer15(),
                                    // textAutoSizeKarla("Recipient Email".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                    // vSpacer5(),
                                    // textFieldWithWidget(controller: emailTextController, hint: "Enter Email".tr, type: TextInputType.emailAddress),
                                    // vSpacer15(),
                                    // textAutoSizeKarla("Recipient Phone".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
                                    // vSpacer5(),
                                    // Obx(() => textFieldWithWidget(
                                    //     controller: phoneTextController,
                                    //     hint: "Enter Phone".tr,
                                    //     type: TextInputType.phone,
                                    //     prefixWidget: _phoneCodeView(_controller.selectedCountry.value))),
                                    vSpacer15(),
                                    Obx(() {
                                      final feeAmount = (banner.fees ?? 0) * _controller.quantity.value;
                                      final totalUnitPrice = unitPrice * _controller.amount.value;
                                      final totalPrice = (totalUnitPrice * _controller.quantity.value) + feeAmount;
                                      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        twoTextSpaceFixed("Unit Price".tr, "${coinFormat(totalUnitPrice)} ${banner.senderCurrency ?? ""}"),
                                        vSpacer2(),
                                        twoTextSpaceFixed("Quantity".tr, _controller.quantity.value.toString()),
                                        vSpacer2(),
                                        twoTextSpaceFixed("Service Fees".tr, "${coinFormat(feeAmount)} ${banner.senderCurrency ?? ""}"),
                                        vSpacer2(),
                                        twoTextSpaceFixed("Total Price".tr, "${coinFormat(totalPrice)} ${banner.senderCurrency ?? ""}"),
                                        vSpacer2(),
                                        twoTextSpaceFixed(
                                            "Payable Total".tr, "${coinFormat(_controller.totalCurrencyAmount.value)} ${_controller.getCoinType()}",
                                            flex: 4),
                                        textAutoSizePoppins("(${"You have to Pay in".tr} ${_controller.getCoinType()})", textAlign: TextAlign.start),
                                      ]);
                                    }),
                                    vSpacer15(),
                                    buttonRoundedMain(text: "Buy".tr, onPressCallback: () => _checkInputData()),
                                    dividerHorizontal(height: Dimens.btnHeightMid),
                                    Row(children: [
                                      showImageAsset(imagePath: AssetConstants.icGift, height: Dimens.iconSizeMid, color: Get.theme.focusColor),
                                      textAutoSizeKarla("Gift Card Store".tr, color: Get.theme.focusColor, fontSize: Dimens.regularFontSizeLarge)
                                    ]),
                                    vSpacer15(),
                                    banners.isValid
                                        ? Wrap(
                                            spacing: Dimens.paddingMid,
                                            runSpacing: Dimens.paddingMid,
                                            children: List.generate(banners!.length, (index) {
                                              final gBanner = banners[index];
                                              return GiftBannerItemView(
                                                gBanner: gBanner,
                                                isSelected: _controller.selectedBannerIndex.value == index,
                                                isPriceShow: true,
                                                onTap: () {
                                                  setState(() {
                                                    _controller.selectedCoin.value = -1;
                                                    _controller.selectedBannerIndex.value = index;
                                                    _controller.amount.value = gBanner.minRecipientAmount ?? 0;
                                                    _controller.quantity.value = 1;
                                                    _controller.totalCurrencyAmount.value = 0;
                                                    _controller.selectedBanner = gBanner;
                                                  });
                                                },
                                              );
                                            }))
                                        : showEmptyView(height: Dimens.menuHeight),
                                    vSpacer15()
                                  ]))
                            ],
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _featureItemList() {
    List<Widget> list = [];
    if (_controller.giftCardBuyData?.featureOne.isValid ?? false) {
      list.add(_featureItemView(_controller.giftCardBuyData?.featureOne, _controller.giftCardBuyData?.featureOneIcon));
    }
    if (_controller.giftCardBuyData?.featureTwo.isValid ?? false) {
      list.add(_featureItemView(_controller.giftCardBuyData?.featureTwo, _controller.giftCardBuyData?.featureTwoIcon));
    }
    if (_controller.giftCardBuyData?.featureThree.isValid ?? false) {
      list.add(_featureItemView(_controller.giftCardBuyData?.featureThree, _controller.giftCardBuyData?.featureThreeIcon));
    }
    return list;
  }

  _featureItemView(String? title, String? url) {
    return Expanded(
      child: Column(
        children: [
          ClipOval(
              child: Container(
                  decoration: boxDecorationRoundCorner(color: Get.theme.focusColor),
                  padding: const EdgeInsets.all(2),
                  child: showCircleAvatar(url, size: Dimens.iconSizeLarge))),
          vSpacer5(),
          textAutoSizeKarla(title ?? "", fontSize: Dimens.regularFontSizeMid)
        ],
      ),
    );
  }

  // _phoneCodeView(Country county) {
  //   return InkWell(
  //       onTap: () {
  //         showCountriesPicker(context, (country) {
  //           _controller.selectedCountry.value = country;
  //           phoneTextController.text = country.phoneCode;
  //         });
  //       },
  //       child: FittedBox(
  //         fit: BoxFit.scaleDown,
  //         child: Row(
  //           children: [
  //             hSpacer10(),
  //             Text(Utils.countryCodeToEmoji(county.countryCode)),
  //             Icon(Icons.arrow_drop_down_outlined, size: Dimens.iconSizeMin, color: context.theme.primaryColor),
  //             hSpacer5()
  //           ],
  //         ),
  //       ));
  // }

  void _onTextChanged(String text, bool isAmount) {
    isAmount ? _controller.amount.value = makeDouble(text) : _controller.quantity.value = makeInt(text);
    if (_timer?.isActive ?? false) _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), () {
      _controller.getGiftCardCoinConvert();
    });
  }

  void _checkInputData() async {
    final bannerId = _controller.selectedBanner.uid ?? "";
    if (bannerId.isEmpty) {
      showToast("Gift Card ID not found".tr);
      return;
    }
    if (_controller.getCoinType().isEmpty) {
      showToast("Select your coin".tr);
      return;
    }
    if (_controller.amount.value <= 0) {
      showToast("amount_must_greater_than_0".tr);
      return;
    }
    if (_controller.quantity.value <= 0) {
      showToast("Quantity is required".tr);
      return;
    }
    // final name = nameTextController.text.trim();
    // if (name.isEmpty) {
    //   showToast("Name is required".tr);
    //   return;
    // }
    // final email = emailTextController.text.trim();
    // if (!GetUtils.isEmail(email)) {
    //   showToast("Input a valid Email".tr, context: context);
    //   return;
    // }
    hideKeyboard();
    _controller.giftCardBuyCard();
  }
}

// class GiftCardBuyScreenState extends State<GiftCardBuyScreen> with SingleTickerProviderStateMixin {
//   final _controller = Get.put(GiftCardBuyController());
//   late TabController _tabController;
//   GiftCardBanner? selectedBanner;
//
//   @override
//   void initState() {
//     _tabController = TabController(length: 2, vsync: this);
//     _controller.selectedCoin.value = -1;
//     // _controller.selectedWallet.value = -1;
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//       _controller.getGiftCardBuyData(widget.uid, () => setState(() {}));
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width / 3;
//     width = width + (MediaQuery.of(context).textScaleFactor > 1 ? 25 : 0);
//     final ribbonWidth = MediaQuery.of(context).textScaleFactor > 1 ? 100 : 80;
//     final featureList = _featureItemList();
//     selectedBanner = _controller.giftCardBuyData?.selectedBanner;
//     return Scaffold(
//       body: BGViewMain(
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.only(top: Dimens.paddingMainViewTop),
//             child: KeyboardDismissOnTap(
//               child: Column(
//                 children: [
//                   appBarBackWithActions(title: "Buy Theme Cards".tr),
//                   _controller.isLoading
//                       ? showLoading()
//                       : Expanded(
//                           child: CustomScrollView(
//                             slivers: [
//                               if ((_controller.giftCardBuyData?.header.isValid ?? false) ||
//                                   (_controller.giftCardBuyData?.description.isValid ?? false))
//                                 SliverAppBar(
//                                   backgroundColor: Colors.transparent,
//                                   automaticallyImplyLeading: false,
//                                   expandedHeight: width,
//                                   collapsedHeight: width,
//                                   flexibleSpace: Padding(
//                                     padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
//                                     child: GiftCardTitleView(
//                                         title: _controller.giftCardBuyData?.header,
//                                         subTitle: _controller.giftCardBuyData?.description,
//                                         image: _controller.giftCardBuyData?.banner),
//                                   ),
//                                 ),
//                               if (featureList.isNotEmpty)
//                                 SliverAppBar(
//                                   backgroundColor: Colors.transparent,
//                                   automaticallyImplyLeading: false,
//                                   toolbarHeight: 85,
//                                   flexibleSpace: Padding(
//                                     padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid, vertical: Dimens.paddingMin),
//                                     child: Row(children: featureList),
//                                   ),
//                                 ),
//                               SliverAppBar(
//                                 backgroundColor: Get.theme.scaffoldBackgroundColor,
//                                 automaticallyImplyLeading: false,
//                                 toolbarHeight: 50,
//                                 pinned: true,
//                                 flexibleSpace: Row(
//                                   children: [
//                                     SizedBox(
//                                         width: Get.width - 100,
//                                         child: tabBarUnderline(["Buy 1 Card".tr, "Bulk Create".tr], _tabController,
//                                             indicatorSize: TabBarIndicatorSize.label, onTap: (index) => _controller.selectedTab.value = index)),
//                                     Stack(
//                                       alignment: Alignment.center,
//                                       children: [
//                                         Transform.rotate(
//                                           angle: -math.pi,
//                                           child: showImageAsset(
//                                               imagePath: AssetConstants.icRibbon,
//                                               width: ribbonWidth.toDouble(),
//                                               boxFit: BoxFit.fitWidth,
//                                               color: Get.theme.focusColor),
//                                         ),
//                                         Padding(
//                                           padding: const EdgeInsets.only(left: Dimens.paddingMid),
//                                           child: textAutoSizePoppins("Business".tr, color: Colors.black),
//                                         )
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Obx(() {
//                                 final list = _buyWidgetList(_controller.selectedTab.value, _controller.selectedCoin.value);
//                                 return SliverPadding(
//                                     padding: const EdgeInsets.all(Dimens.paddingMid),
//                                     sliver: SliverList(
//                                       delegate: SliverChildBuilderDelegate((context, index) => list[index], childCount: list.length),
//                                     ));
//                               })
//                             ],
//                           ),
//                         )
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   List<Widget> _featureItemList() {
//     List<Widget> list = [];
//     if (_controller.giftCardBuyData?.featureOne.isValid ?? false) {
//       list.add(_featureItemView(_controller.giftCardBuyData?.featureOne, _controller.giftCardBuyData?.featureOneIcon));
//     }
//     if (_controller.giftCardBuyData?.featureTwo.isValid ?? false) {
//       list.add(_featureItemView(_controller.giftCardBuyData?.featureTwo, _controller.giftCardBuyData?.featureTwoIcon));
//     }
//     if (_controller.giftCardBuyData?.featureThree.isValid ?? false) {
//       list.add(_featureItemView(_controller.giftCardBuyData?.featureThree, _controller.giftCardBuyData?.featureThreeIcon));
//     }
//     return list;
//   }
//
//   _featureItemView(String? title, String? url) {
//     return Expanded(
//       child: Column(
//         children: [
//           ClipOval(
//               child: Container(
//                   decoration: boxDecorationRoundCorner(color: Get.theme.focusColor),
//                   padding: const EdgeInsets.all(2),
//                   child: showCircleAvatar(url, size: Dimens.iconSizeLarge))),
//           vSpacer5(),
//           textAutoSizeKarla(title ?? "", fontSize: Dimens.regularFontSizeMid)
//         ],
//       ),
//     );
//   }
//
//   _walletListView() {
//     return Container(
//       decoration: boxDecorationRoundCorner(),
//       padding: const EdgeInsets.symmetric(vertical: Dimens.paddingMid),
//       child: Column(
//         children: [
//           RadioListTile(
//               value: WalletType.spot,
//               groupValue: _controller.selectedWallet.value,
//               visualDensity: minimumVisualDensity,
//               title: textAutoSizeKarla("Spot Wallet".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
//               subtitle: textAutoSizePoppins("${coinFormat(_controller.walletData.value.exchangeWalletBalance)} ${_controller.getCoinType()}",
//                   fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
//               onChanged: (index) => _controller.selectedWallet.value = index!),
//           vSpacer5(),
//           RadioListTile(
//               value: WalletType.p2p,
//               groupValue: _controller.selectedWallet.value,
//               visualDensity: minimumVisualDensity,
//               title: textAutoSizeKarla("P2P Wallet".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
//               subtitle: textAutoSizePoppins("${coinFormat(_controller.walletData.value.p2PWalletBalance)} ${_controller.getCoinType()}",
//                   fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
//               onChanged: (index) => _controller.selectedWallet.value = index!),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buyWidgetList(int sTab, int selectedCoin) {
//     final banners = _controller.giftCardBuyData?.banners;
//     final amountStr = "${_controller.amount.value} ${_controller.getCoinType()}";
//     final balance = _controller.selectedWallet.value == WalletType.p2p
//         ? _controller.walletData.value.p2PWalletBalance
//         : _controller.walletData.value.exchangeWalletBalance;
//     final availableStr = "${coinFormat(balance)} ${_controller.getCoinType()}";
//     final quantity = sTab == 0 ? 1 : (_controller.quantity.value == 0 ? 1 : _controller.quantity.value);
//     final totalStar = "${_controller.amount.value * quantity} ${_controller.getCoinType()}";
//     List<Widget> list = [
//       GiftCardImageAndTag(imagePath: selectedBanner?.banner, amountText: amountStr),
//       vSpacer15(),
//       textAutoSizeKarla(selectedBanner?.title ?? "", maxLines: 5, textAlign: TextAlign.start),
//       vSpacer10(),
//       textAutoSizePoppins(selectedBanner?.subTitle ?? "", maxLines: 10, textAlign: TextAlign.start, color: Get.theme.primaryColor),
//       dividerHorizontal(height: Dimens.btnHeightMid),
//       textAutoSizeKarla("Buy".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
//       vSpacer5(),
//       dropDownListIndex(_controller.getCoinNameList(), selectedCoin, "Select Coin".tr, hMargin: 0, (index) {
//         _controller.selectedCoin.value = index;
//         _controller.getGiftCardWalletData();
//       }),
//       vSpacer15(),
//       textAutoSizeKarla("Amount".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
//       vSpacer5(),
//       textFieldWithWidget(
//           hint: "Enter Amount".tr,
//           type: const TextInputType.numberWithOptions(decimal: true),
//           suffixWidget: textFieldTextWidget(_controller.getCoinType(), hMargin: Dimens.paddingMid),
//           onTextChange: (text) async => _controller.amount.value = makeDouble(text.trim())),
//       vSpacer5(),
//       twoTextView("${"Available".tr}: ", availableStr),
//       vSpacer15(),
//       _walletListView(),
//       if (sTab == 1)
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             vSpacer15(),
//             textAutoSizeKarla("Quantity".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
//             vSpacer5(),
//             textFieldWithWidget(
//                 hint: "Enter Quantity".tr,
//                 type: const TextInputType.numberWithOptions(decimal: true),
//                 onTextChange: (text) async => _controller.quantity.value = makeInt(text.trim())),
//           ],
//         ),
//       vSpacer15(),
//       textAutoSizeKarla("Note (Optional)".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start),
//       vSpacer5(),
//       textFieldWithSuffixIcon(hint: "Enter note for this order".tr, maxLines: 3, height: 90),
//       vSpacer15(),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           textAutoSizeKarla("Lock".tr, fontSize: Dimens.regularFontSizeLarge),
//           toggleSwitch(selectedValue: _controller.isLock.value, onChange: (value) => _controller.isLock.value = value)
//         ],
//       ),
//       textAutoSizePoppins("lock_info_message".tr, maxLines: 3, textAlign: TextAlign.start),
//       vSpacer15(),
//       twoTextSpace("Fee".tr, "0"),
//       twoTextSpace("Total Amount".tr, totalStar),
//       vSpacer15(),
//       buttonRoundedMain(text: "Buy".tr, onPressCallback: () => _controller.checkAndBuyGiftCard(context)),
//       dividerHorizontal(height: Dimens.btnHeightMid),
//       Row(children: [
//         showImageAsset(imagePath: AssetConstants.icGift, height: Dimens.iconSizeMid, color: Get.theme.focusColor),
//         textAutoSizeKarla("Gift Card Store".tr, color: Get.theme.focusColor, fontSize: Dimens.regularFontSizeLarge)
//       ]),
//       vSpacer15(),
//       banners.isValid
//           ? Wrap(
//               spacing: Dimens.paddingMid,
//               runSpacing: Dimens.paddingMid,
//               children: List.generate(banners!.length, (index) {
//                 final banner = banners[index];
//                 final isSelected = banner.uid == selectedBanner?.uid;
//                 return GiftBannerItemView(
//                   gBanner: banners[index],
//                   isSelected: isSelected,
//                   onTap: () {
//                     setState(() {
//                       _controller.selectedCoin.value = -1;
//                       _controller.selectedWallet.value = 0;
//                       _controller.isLoading = true;
//                     });
//                     _controller.getGiftCardBuyData(banner.uid ?? "", () => setState(() {}));
//                   },
//                 );
//               }))
//           : showEmptyView(height: Dimens.menuHeight),
//       vSpacer15()
//     ];
//
//     return list;
//   }
// }
