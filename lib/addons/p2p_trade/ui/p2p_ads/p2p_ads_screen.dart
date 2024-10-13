import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';

import '../../models/p2p_ads.dart';
import '../p2p_common_widgets.dart';
import 'p2p_ads_controller.dart';
import 'p2p_ads_create/p2p_create_ads_page.dart';

class P2PAdsScreen extends StatefulWidget {
  const P2PAdsScreen({Key? key}) : super(key: key);

  @override
  State<P2PAdsScreen> createState() => _P2PAdsScreenState();
}

class _P2PAdsScreenState extends State<P2PAdsScreen> with TickerProviderStateMixin {
  final _controller = Get.put(P2pAdsController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getP2pAdsList(false));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Dimens.paddingMin),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: Get.width - 100),
                      child: SegmentedControlView(["Buy Ads".tr, "Sell Ads".tr], _controller.sTransactionType.value, onChange: (index) {
                        _controller.sTransactionType.value = index;
                        _controller.getP2pAdsList(false);
                      }),
                    )),
                buttonText("Create".tr, textColor: Get.theme.primaryColor, onPressCallback: () => Get.to(() => const P2pCreateAdsPage()))
              ],
            ),
          ),
          Obx(() => _controller.adsList.isEmpty
              ? handleEmptyViewWithLoading(_controller.isDataLoading.value)
              : Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                    itemCount: _controller.adsList.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (_controller.hasMoreData && index == (_controller.adsList.length - 1)) {
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getP2pAdsList(true));
                      }
                      return MyAdsItemView(_controller.adsList[index], _controller.sTransactionType.value == 1);
                    },
                  ),
                ))
        ],
      ),
    );
  }
}

class MyAdsItemView extends StatelessWidget {
  const MyAdsItemView(this.p2pAds, this.isBuy, {Key? key}) : super(key: key);
  final P2PAds p2pAds;
  final bool isBuy;

  @override
  Widget build(BuildContext context) {
    final color = Get.theme.primaryColorLight;
    final limitSrt =
        "${coinFormat(p2pAds.minimumTradeSize)} ${p2pAds.currency ?? ""}-${coinFormat(p2pAds.maximumTradeSize)} ${p2pAds.currency ?? ""}";
    return Card(
      margin: const EdgeInsets.symmetric(vertical: Dimens.paddingMin),
      color: Colors.grey.withOpacity(0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(Dimens.paddingMid),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            vSpacer5(),
            twoTextSpaceFixed("${"Price".tr} : ", "${coinFormat(p2pAds.price)} ${p2pAds.currency ?? ""}", color: color),
            vSpacer2(),
            twoTextSpaceFixed("${"Available".tr} : ", "${coinFormat(p2pAds.available)} ${p2pAds.coinType ?? ""}", color: color),
            vSpacer2(),
            twoTextSpaceFixed("${"Limit".tr} : ", limitSrt, color: color),
            vSpacer2(),
            twoTextSpaceFixed("${"Date".tr} : ", formatDate(p2pAds.createdAt, format: dateTimeFormatDdMMMMYyyyHhMm), color: color),
            vSpacer5(),
            SizedBox(
                height: Dimens.btnHeightMin,
                child: buttonText("Edit".tr, onPressCallback: () => Get.to(() => P2pCreateAdsPage(editableAds: p2pAds, isBuy: isBuy)))),
            vSpacer5(),
          ],
        ),
      ),
    );
  }
}
