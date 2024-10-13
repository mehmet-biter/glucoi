import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/list_response.dart';
import 'package:tradexpro_flutter/data/models/referral.dart';
import 'package:tradexpro_flutter/data/models/wallet.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';

class ReferralsController extends GetxController {
  Rx<ReferralData> referralData = ReferralData().obs;

  RxString selectedType = "".obs;
  TextEditingController textEditController = TextEditingController();
  TextEditingController codeEditController = TextEditingController();
  RxList<Wallet> walletList = <Wallet>[].obs;
  RxList<ReferralWithdrawHistory> refWithdrawHistories = <ReferralWithdrawHistory>[].obs;
  bool hasMoreData = true;
  int loadedPage = 0;
  RxBool isLoading = false.obs;

  void getReferralData() async {
    showLoadingDialog();
    APIRepository().getReferralApp().then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        referralData.value = ReferralData.fromJson(resp.data);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void getWalletList() async {
    if (walletList.isNotEmpty) return;
    APIRepository().getWalletList(1, limit: 100).then((resp) {
      if (resp.success) {
        final wallets = resp.data[APIKeyConstants.wallets];
        if (wallets != null) {
          ListResponse listResponse = ListResponse.fromJson(wallets);
          walletList.value = List<Wallet>.from(listResponse.data!.map((x) => Wallet.fromJson(x)));
        }
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      showToast(err.toString());
    });
  }

  void withdrawReferralBalance(double amount, Wallet wallet) async {
    showLoadingDialog();
    APIRepository().withdrawReferralBalance(wallet.id, amount).then((resp) {
      hideLoadingDialog();
      showToast(resp.message, isError: !resp.success);
      if (resp.success) {
        Get.back();
        getReferralData();
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void getReferralWithdrawHistory(bool isLoadMore) async {
    if (!isLoadMore) {
      loadedPage = 0;
      hasMoreData = true;
      refWithdrawHistories.clear();
    }
    isLoading.value = true;
    loadedPage++;
    APIRepository().getReferralWithdrawHistory(loadedPage, DefaultValue.listLimitMedium).then((resp) {
      isLoading.value = false;
      if (resp.success && resp.data != null) {
        ListResponse listResponse = ListResponse.fromJson(resp.data);
        final histories = List<ReferralWithdrawHistory>.from(listResponse.data!.map((x) => ReferralWithdrawHistory.fromJson(x)));
        loadedPage = listResponse.currentPage ?? 0;
        hasMoreData = listResponse.nextPageUrl != null;
        refWithdrawHistories.addAll(histories);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      isLoading.value = false;
      showToast(err.toString());
    });
  }
}
