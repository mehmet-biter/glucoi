import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/models/gift_card.dart';
import 'package:tradexpro_flutter/ui/features/side_navigation/gift_cards/gift_cards_widgets.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/image_util.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';

import '../../../models/p2p_gift_card.dart';
import '../p2p_gc_create_ad/p2p_gc_create_ad_screen.dart';
import 'p2p_gc_list_controller.dart';

class P2PGCListScreen extends StatefulWidget {
  const P2PGCListScreen({Key? key}) : super(key: key);

  @override
  State<P2PGCListScreen> createState() => _P2PGCListScreenState();
}

class _P2PGCListScreenState extends State<P2PGCListScreen> with TickerProviderStateMixin {
  final _controller = Get.put(P2pGCListController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getP2pGiftCardList(false));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(Dimens.paddingMid),
          child: textAutoSizeKarla("My Gift Card List".tr, fontSize: Dimens.regularFontSizeMid),
        ),
        Obx(() => _controller.giftCardList.isEmpty
            ? handleEmptyViewWithLoading(_controller.isDataLoading.value)
            : Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                  itemCount: _controller.giftCardList.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_controller.hasMoreData && index == (_controller.giftCardList.length - 1)) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getP2pGiftCardList(true));
                    }
                    return P2pGiftCardItemView(_controller.giftCardList[index]);
                  },
                ),
              ))
      ]),
    );
  }
}

class P2pGiftCardItemView extends StatelessWidget {
  const P2pGiftCardItemView(this.p2pGiftCard, {Key? key}) : super(key: key);
  final P2pGiftCard p2pGiftCard;

  @override
  Widget build(BuildContext context) {
    final giftCard = p2pGiftCard.giftCard ?? GiftCard();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showBottomSheetFullScreen(context, P2pGiftCardDetailsView(gCard: giftCard), title: "Gift Card Details".tr),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: Dimens.paddingMin),
          color: Colors.grey.withOpacity(0.1),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(Dimens.paddingMid),
            child: Row(
              children: [
                showImageNetwork(imagePath: giftCard.banner?.banner, height: Dimens.iconSizeLogo, width: Dimens.iconSizeLogo, boxFit: BoxFit.cover),
                hSpacer10(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textAutoSizeKarla(giftCard.banner?.title ?? "", fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start, maxLines: 2),
                      textAutoSizePoppins("${coinFormat(giftCard.amount)} ${giftCard.coinType ?? ""}",
                          fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start, maxLines: 2),
                    ],
                  ),
                ),
                hSpacer5(),
                InkWell(
                  onTap: () async {
                    final result = await Get.to(() => P2PGCCreateAdScreen(p2pGiftCard: p2pGiftCard));
                    if (result != null && result == true) {
                      Get.find<P2pGCListController>().getP2pGiftCardList(false);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(Dimens.paddingMin),
                    decoration: boxDecorationRoundCorner(color: Get.theme.focusColor),
                    child: textAutoSizeKarla("Create_Ad".tr,
                        color: Get.theme.scaffoldBackgroundColor, maxLines: 2, fontSize: Dimens.regularFontSizeExtraMid),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class P2pGiftCardDetailsView extends StatelessWidget {
  P2pGiftCardDetailsView({super.key, required this.gCard});

  final GiftCard gCard;
  final bgColor = Get.theme.scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    String? imagePath = gCard.banner?.banner;
    if (imagePath == null || !imagePath.contains(APIURLConstants.baseUrl)) {
      imagePath = gCard.banner?.banner;
    }
    String amountText = "${gCard.amount ?? 0} ${gCard.coinType ?? ""}";

    return Expanded(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
        children: [
          GiftCardImageAndTag(imagePath: imagePath, amountText: amountText),
          vSpacer20(),
          textAutoSizeKarla(gCard.banner?.title ?? "", maxLines: 5, textAlign: TextAlign.start),
          vSpacer10(),
          textAutoSizePoppins(gCard.banner?.brandName ?? "", maxLines: 10, textAlign: TextAlign.start, color: Get.theme.primaryColor),
          vSpacer20(),
          _cardDetailsView(context),
          vSpacer10(),
        ],
      ),
    );
  }

  _cardDetailsView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        twoTextView("${"Coin Type".tr}: ", gCard.coinType ?? ""),
        vSpacer5(),
        // twoTextView("${"Category".tr}: ", gCard.banner?.category?.name ?? ""),
        vSpacer5(),
        twoTextView("${"Lock".tr}: ", gCard.lockText ?? ""),
        vSpacer5(),
        twoTextView("${"Wallet Type".tr}: ", gCard.walletType ?? ""),
        vSpacer5(),
        twoTextView("${"Status".tr}: ", gCard.statusText ?? ""),
      ],
    );
  }
}
