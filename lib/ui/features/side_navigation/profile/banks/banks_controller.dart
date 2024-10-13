import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/models/fiat_deposit.dart';
import 'package:tradexpro_flutter/data/models/flutter_wave.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';

class BanksController extends GetxController {
  RxList<Bank> userBanks = <Bank>[].obs;
  RxBool isDataLoading = false.obs;
  RxBool isLoadingTRF = false.obs;
  RxMap<String, String> countryMap = <String, String>{}.obs;
  RxList<FlutterWaveBank> flutterWaveBanks = <FlutterWaveBank>[].obs;
  RxInt selectedCountry = 0.obs;
  RxString selectedBankName = "".obs;

  void getUserBankList() {
    isDataLoading.value = true;
    APIRepository().getUserBankList().then((resp) {
      isDataLoading.value = false;
      if (resp.success && resp.data != null) {
        userBanks.value = List<Bank>.from(resp.data.map((x) => Bank.fromJson(x)));
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      isDataLoading.value = false;
      showToast(err.toString());
    });
  }

  void userBankSave(Bank bank) {
    showLoadingDialog();
    APIRepository().userBankSave(bank).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success);
        if (success) {
          Get.back();
          getUserBankList();
        }
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void userBankDelete(Bank bank) {
    showLoadingDialog();
    APIRepository().userBankDelete(bank.id).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success);
        if (success) {
          Get.back();
          getUserBankList();
        }
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void getFlutterWaveBankSaveDetails(String countryCode) {
    isLoadingTRF.value = true;
    APIRepository().getFlutterWaveBankSaveDetails(countryCode).then((resp) {
      isLoadingTRF.value = false;
      if (resp.success && resp.data != null) {
        final fData = FlutterWaveAddBankData.fromJson(resp.data);
        if (countryMap.isEmpty) {
          countryMap.value = fData.countryList ?? {};
          selectedCountry.value = countryMap.keys.toList().indexWhere((element) => element == DefaultValue.country);
        }
        flutterWaveBanks.value = fData.bankList ?? [];
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      isLoadingTRF.value = false;
      showToast(err.toString());
    });
  }

  void flutterWaveBankSave(String account) async {
    showLoadingDialog();
    final bankCode = selectedBankName.value.substringBetween("(", ")");
    final bank = flutterWaveBanks.firstWhereOrNull((element) => element.code == bankCode);
    final countryCode = countryMap.keys.toList()[selectedCountry.value];
    APIRepository().flutterWaveBankSave(bank?.code ?? '', bank?.name ?? '', account, countryMap[countryCode] ?? '').then((resp) {
      hideLoadingDialog();
      showToast(resp.message, isError: !resp.success);
      if (resp.success) {
        Get.back();
        getUserBankList();
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }
}
