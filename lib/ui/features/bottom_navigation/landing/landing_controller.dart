import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/blog_news.dart';
import 'package:tradexpro_flutter/data/models/settings.dart';
import 'package:tradexpro_flutter/data/models/wallet.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';

class LandingController extends GetxController {
  Rx<LandingData> landingData = LandingData().obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingBalance = false.obs;
  RxInt selectedTab = 0.obs;
  RxList<Blog> latestBlogList = <Blog>[].obs;
  Rx<TotalBalance> wOverview = TotalBalance().obs;

  void getLandingSettings() async {
    isLoading.value = true;
    APIRepository().getCommonSettings().then((resp) {
      isLoading.value = false;
      if (resp.success && resp.data != null && resp.data is Map<String, dynamic>) {
        final settings = resp.data[APIKeyConstants.landingSettings];
        if (settings != null && settings is Map<String, dynamic>) {
          landingData.value = LandingData.fromJson(settings);
        }
      }
    }, onError: (err) {
      isLoading.value = false;
      showToast(err.toString());
    });
  }

  Future<void> getWalletTotalBalance() async {
    if (gUserRx.value.id == 0) return;
    final currency = gUserRx.value.currency ?? '';
    APIRepository().getWalletTotalBalance(currency).then((resp) {
      isLoadingBalance.value = false;
      if (resp.success) {
        wOverview.value = TotalBalance.fromJson(resp.data);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      isLoadingBalance.value = false;
      showToast(err.toString());
    });
  }
}
