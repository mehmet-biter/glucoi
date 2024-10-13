import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/utility_bills.dart';
import 'package:tradexpro_flutter/helper/app_widgets.dart';
import 'package:tradexpro_flutter/utils/common_widgets.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/dimens.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/spacers.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';

import 'utility_bills_controller.dart';

class UtilityBillHistoryScreen extends StatefulWidget {
  const UtilityBillHistoryScreen({Key? key}) : super(key: key);

  @override
  State<UtilityBillHistoryScreen> createState() => _UtilityBillHistoryScreenState();
}

class _UtilityBillHistoryScreenState extends State<UtilityBillHistoryScreen> {
  final _controller = Get.find<UtilityBillsController>();
  RxList<dynamic> histories = <dynamic>[].obs;
  RxBool isLoading = true.obs;
  int loadedPage = 0;
  bool hasMoreData = false;
  RxInt selectedService = 0.obs;

  @override
  void initState() {
    if (TemporaryData.activityType != null) {
      if (_controller.utilityBillData.value.services.isValid) {
        final index = _controller.utilityBillData.value.services!.indexWhere((element) => element.type == TemporaryData.activityType);
        if (index != -1) {
          selectedService.value = index;
        }
      }
      TemporaryData.activityType = null;
    }
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => getUtilityHistory(false));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Obx(() {
            List<String> items = <String>[];
            if (_controller.utilityBillData.value.services.isValid) {
              items = _controller.utilityBillData.value.services!.map((e) => (e.name ?? "").toCapitalizeFirst()).toList();
            }
            return items.isEmpty
                ? vSpacer0()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingMid),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        vSpacer10(),
                        textAutoSizeKarla("Select Service".tr, textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
                        dropDownListIndex(items, selectedService.value, "Select".tr, (index) {
                          selectedService.value = index;
                          getUtilityHistory(false);
                        }, hMargin: 0),
                      ],
                    ),
                  );
          }),
          Obx(() {
            return histories.isEmpty
                ? handleEmptyViewWithLoading(isLoading.value)
                : Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(Dimens.paddingMid),
                        itemCount: histories.length,
                        itemBuilder: (context, index) {
                          if (hasMoreData && index == (histories.length - 1)) {
                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) => getUtilityHistory(true));
                          }
                          final item = histories[index];
                          if (item is UtilityBillHistoryFlutter) {
                            return UtilityHistoryFlutterItemView(history: item);
                          } else if (item is UtilityBillHistory) {
                            return UtilityBillHistoryItemView(history: item);
                          } else {
                            return Container();
                          }
                        }),
                  );
          }),
        ],
      ),
    );
  }

  void getUtilityHistory(bool isFromLoadMore) async {
    if (!isFromLoadMore) {
      loadedPage = 0;
      hasMoreData = false;
      histories.clear();
    }
    isLoading.value = true;
    loadedPage++;
    final service = _controller.utilityBillData.value.services?[selectedService.value];
    _controller.getUtilityHistory(service?.type ?? "", DefaultValue.listLimitLarge, loadedPage, (listResp) {
      isLoading.value = false;
      if (listResp != null && listResp.data != null) {
        List list = [];
        if (service?.reLoadLy == true) {
          list = List<UtilityBillHistory>.from(listResp.data.map((x) => UtilityBillHistory.fromJson(x)));
        } else if (service?.reLoadLy == false) {
          list = List<UtilityBillHistoryFlutter>.from(listResp.data.map((x) => UtilityBillHistoryFlutter.fromJson(x)));
        }
        // final list = List<UtilityBillHistory>.from(listResp.data.map((x) => UtilityBillHistory.fromJson(x)));
        loadedPage = listResp.currentPage ?? 0;
        hasMoreData = listResp.nextPageUrl != null;
        histories.addAll(list);
      }
    });
  }
}

class UtilityBillHistoryItemView extends StatelessWidget {
  const UtilityBillHistoryItemView({Key? key, required this.history}) : super(key: key);
  final UtilityBillHistory history;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.only(bottom: Dimens.paddingMid),
      child: Column(
        children: [
          twoTextSpaceFixed(history.billerName ?? "", history.service?.name ?? "", flex: 6, maxLine: 2),
          vSpacer5(),
          twoTextSpaceFixed("${history.paidAmount ?? ""} ${history.paidCurrency ?? ""}", history.status ?? ""),
          vSpacer5(),
          twoTextSpaceFixed("${"Country".tr}:", history.country?.name ?? ""),
          twoTextSpaceFixed("${"Transaction Id".tr}:", history.transactionId.toString()),
          twoTextSpaceFixed("${"Date".tr}:", formatDate(history.createdAt, format: dateTimeFormatDdMMMMYyyyHhMm)),
        ],
      ),
    );
  }
}

class UtilityHistoryFlutterItemView extends StatelessWidget {
  const UtilityHistoryFlutterItemView({Key? key, required this.history}) : super(key: key);
  final UtilityBillHistoryFlutter history;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationRoundCorner(),
      padding: const EdgeInsets.all(Dimens.paddingMid),
      margin: const EdgeInsets.only(bottom: Dimens.paddingMid),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textAutoSizeKarla(history.name ?? "", textAlign: TextAlign.start, fontSize: Dimens.regularFontSizeMid),
          vSpacer5(),
          twoTextSpaceFixed("${history.amount ?? ""} ${history.currency ?? ""}", (history.status ?? "").toUpperCase()),
          vSpacer5(),
          twoTextSpaceFixed("${"Country".tr}:", history.country?.name ?? ""),
          twoTextSpaceFixed("${"Transaction Id".tr}:", history.ref ?? ''),
          twoTextSpaceFixed("${"Date".tr}:", formatDate(history.createdAt, format: dateTimeFormatDdMMMMYyyyHhMm)),
        ],
      ),
    );
  }
}
