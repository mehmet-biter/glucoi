import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/p2p_constants.dart';
import 'package:tradexpro_flutter/utils/alert_util.dart';
import 'package:tradexpro_flutter/utils/button_util.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';

import '../../../models/p2p_gift_card.dart';
import '../../../p2p_common_utils.dart';
import '../p2p_gc_create_ad/p2p_gc_create_ad_screen.dart';
import 'p2p_gc_ads_controller.dart';

class P2PGCAdsScreen extends StatefulWidget {
  const P2PGCAdsScreen({Key? key}) : super(key: key);

  @override
  State<P2PGCAdsScreen> createState() => _P2PGCAdsScreenState();
}

class _P2PGCAdsScreenState extends State<P2PGCAdsScreen> with TickerProviderStateMixin {
  final _controller = Get.put(P2pGCAdsController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getP2pGiftCardUserAdList(false));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid, vertical: Dimens.paddingMin),
          child: Row(
            children: [
              Expanded(flex: 4, child: textAutoSizeKarla("My Gift Card Ads".tr, fontSize: Dimens.regularFontSizeMid, textAlign: TextAlign.start)),
              hSpacer5(),
              Obx(() {
                return Expanded(
                  flex: 6,
                  child: dropDownListIndex(_controller.getOrderTypeMap().values.toList(), _controller.selectedOrderStatus.value, "",
                      hMargin: 0, height: 35, (index) {
                    _controller.selectedOrderStatus.value = index;
                    _controller.getP2pGiftCardUserAdList(false);
                  }),
                );
              }),
            ],
          ),
        ),
        Obx(() => _controller.gcOrderList.isEmpty
            ? handleEmptyViewWithLoading(_controller.isDataLoading.value)
            : Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                  itemCount: _controller.gcOrderList.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (_controller.hasMoreData && index == (_controller.gcOrderList.length - 1)) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => _controller.getP2pGiftCardUserAdList(true));
                    }
                    return P2pGCAdItemView(_controller.gcOrderList[index]);
                  },
                ),
              ))
      ]),
    );
  }
}

class P2pGCAdItemView extends StatelessWidget {
  const P2pGCAdItemView(this.p2pGiftCardAd, {Key? key}) : super(key: key);
  final P2PGiftCardAd p2pGiftCardAd;

  @override
  Widget build(BuildContext context) {
    final status = getGiftCardStatusData(p2pGiftCardAd.status);
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
            twoTextSpace("${"Price".tr} : ", "${p2pGiftCardAd.price ?? ""} ${p2pGiftCardAd.currencyType ?? ""}"),
            vSpacer2(),
            twoTextSpace("${"Amount".tr} : ", "${p2pGiftCardAd.amount ?? ""} ${p2pGiftCardAd.giftCard?.coinType ?? ""}"),
            vSpacer2(),
            twoTextSpace("${"Status".tr} : ", status.first, subColor: status.last),
            vSpacer2(),
            twoTextSpace("${"Created At".tr} : ", formatDate(p2pGiftCardAd.createdAt, format: dateFormatMMMMDddYyy)),
            vSpacer5(),
            if ([P2pGiftCardStatus.active, P2pGiftCardStatus.deActive].contains(p2pGiftCardAd.status))
              Wrap(
                spacing: Dimens.paddingMid,
                runSpacing: Dimens.paddingMid,
                children: [
                  buttonText("Edit".tr, onPressCallback: () async {
                    final result = await Get.to(() => P2PGCCreateAdScreen(preAd: p2pGiftCardAd));
                    if (result != null && result == true) Get.find<P2pGCAdsController>().getP2pGiftCardUserAdList(false);
                  }),
                  buttonText("Delete".tr, bgColor: Colors.redAccent, onPressCallback: () {
                    alertForAction(context,
                        title: "Delete Gift Card Ad",
                        subTitle: "Are you sure to proceed".tr,
                        buttonTitle: "Yes".tr.toUpperCase(),
                        onOkAction: () => Get.find<P2pGCAdsController>().p2pGiftCardDeleteAd(p2pGiftCardAd));
                  }),
                ],
              )
          ],
        ),
      ),
    );
  }
}
