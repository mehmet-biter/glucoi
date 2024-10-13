import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/ui/features/bottom_navigation/landing/landing_controller.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/data/models/settings.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';

class CurrencyController extends GetxController {
  Rx<UserSettings> userSettings = UserSettings().obs;
  RxInt selectedCurrency = 0.obs;
  RxBool isLoading = false.obs;
  String preCurrency = gUserRx.value.currency ?? '';

  void getUserSetting() {
    isLoading.value = true;
    APIRepository().getUserSetting().then((resp) {
      isLoading.value = false;
      if (resp.success) {
        userSettings.value = UserSettings.fromJson(resp.data);
        if (userSettings.value.user != null) saveGlobalUser(user: userSettings.value.user);
        if (userSettings.value.fiatCurrency != null) {
          final list = userSettings.value.fiatCurrency ?? [];
          final currency = list.firstWhereOrNull((element) => element.code == (userSettings.value.user?.currency ?? ""));
          if (currency != null) {
            preCurrency = currency.name ?? '';
            selectedCurrency.value = list.indexOf(currency);
          }
        }
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      isLoading.value = false;
      showToast(err.toString());
    });
  }

  void saveCurrency() {
    isLoading.value = true;
    final currency = userSettings.value.fiatCurrency![selectedCurrency.value];
    APIRepository().updateCurrency(currency.code ?? "").then((resp) {
      showToast(resp.message, isError: !resp.success);
      if (resp.success) {
        preCurrency = currency.name ?? '';
        gUserRx.value.currency = currency.code ?? '';
        if (Get.isRegistered<LandingController>()) Get.find<LandingController>().getWalletTotalBalance();
      }
      isLoading.value = false;
    }, onError: (err) {
      isLoading.value = false;
      showToast(err.toString());
    });
  }
}
