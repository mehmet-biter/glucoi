import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/top_up.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';

import 'top_up_controller.dart';

class TopUpHistoryScreen extends StatefulWidget {
  const TopUpHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TopUpHistoryScreen> createState() => _TopUpHistoryScreenState();
}

class _TopUpHistoryScreenState extends State<TopUpHistoryScreen> {
  final _controller = Get.find<TopUpController>();
  RxList<TopUpHistory> histories = <TopUpHistory>[].obs;
  RxBool isLoading = true.obs;
  int loadedPage = 0;
  bool hasMoreData = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => getTopUpHistory(false));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return histories.isEmpty
          ? handleEmptyViewWithLoading(isLoading.value)
          : Expanded(
              child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(Dimens.paddingMid),
                  itemCount: histories.length,
                  itemBuilder: (context, index) {
                    if (hasMoreData && index == (histories.length - 1)) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) => getTopUpHistory(true));
                    }
                    return TopUpHistoryItemView(history: histories[index]);
                  }),
            );
    });
  }

  void getTopUpHistory(bool isFromLoadMore) async {
    if (!isFromLoadMore) {
      loadedPage = 0;
      hasMoreData = false;
      histories.clear();
    }
    isLoading.value = true;
    loadedPage++;
    _controller.getAirTimeTopUpHistory("", DefaultValue.listLimitLarge, loadedPage, (listResp) {
      isLoading.value = false;
      if (listResp != null && listResp.data != null) {
        final list = List<TopUpHistory>.from(listResp.data.map((x) => TopUpHistory.fromJson(x)));
        loadedPage = listResp.currentPage ?? 0;
        hasMoreData = listResp.nextPageUrl != null;
        histories.addAll(list);
      }
    });
  }
}

class TopUpHistoryItemView extends StatelessWidget {
  const TopUpHistoryItemView({Key? key, required this.history}) : super(key: key);
  final TopUpHistory history;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.only(bottom: Dimens.paddingMid),
      child: Column(
        children: [
          twoTextSpaceFixed(history.operatorName ?? "", history.recipientPhone ?? "", flex: 6, maxLine: 2),
          vSpacer5(),
          twoTextSpaceFixed("${history.recipientAmount ?? ""} ${history.recipientCurrency ?? ""}", history.status ?? ""),
          vSpacer5(),
          twoTextSpaceFixed("${"Country".tr}:", history.country?.name ?? ""),
          twoTextSpaceFixed("${"Transaction Id".tr}:", history.transactionId.toString()),
          twoTextSpaceFixed("${"Date".tr}:", formatDate(history.createdAt, format: dateTimeFormatDdMMMMYyyyHhMm)),
        ],
      ),
    );
  }
}
