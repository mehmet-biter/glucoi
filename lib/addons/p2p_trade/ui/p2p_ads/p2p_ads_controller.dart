import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/p2p_constants.dart';
import 'package:tradexpro_flutter/data/models/list_response.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';

import '../../models/p2p_ads.dart';
import '../../p2p_api_repository.dart';

class P2pAdsController extends GetxController {
  int loadedPage = 0;
  bool hasMoreData = true;
  RxBool isDataLoading = true.obs;
  RxInt sTransactionType = TransactionType.buy.obs;
  RxList<P2PAds> adsList = <P2PAds>[].obs;

  void getP2pAdsList(bool isFromLoadMore) {
    if (!isFromLoadMore) {
      loadedPage = 0;
      hasMoreData = true;
      adsList.clear();
    }
    isDataLoading.value = true;
    loadedPage++;
    P2pAPIRepository().userAdsFilter(sTransactionType.value, loadedPage).then((resp) {
      if (resp.success && resp.data != null) {
        ListResponse listResponse = ListResponse.fromJson(resp.data);
        loadedPage = listResponse.currentPage ?? 0;
        hasMoreData = listResponse.nextPageUrl != null;
        if (listResponse.data != null) {
          List<P2PAds> list = List<P2PAds>.from(listResponse.data!.map((x) => P2PAds.fromJson(x)));
          adsList.addAll(list);
        }
      } else {
        showToast(resp.message);
      }
      isDataLoading.value = false;
    }, onError: (err) {
      isDataLoading.value = false;
      showToast(err.toString());
    });
  }

  void updateList(int type) {
    if (sTransactionType.value == type) getP2pAdsList(false);
  }
}
