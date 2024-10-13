import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/faq.dart';
import 'package:tradexpro_flutter/data/models/fiat_deposit.dart';
import 'package:tradexpro_flutter/data/models/list_response.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/helper/two_fa_helper.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';
import 'package:tradexpro_flutter/utils/paystack_util.dart';

class FiatDepositController extends GetxController {
  RxBool isLoading = true.obs;
  RxInt selectedMethodIndex = 0.obs;
  Rx<FiatDeposit> fiatDepositData = FiatDeposit().obs;
  RxList<FAQ> faqList = <FAQ>[].obs;
  bool isDeposit2FActive = false;

  Future<void> getFiatDepositData() async {
    isLoading.value = true;
    APIRepository().getCurrencyDepositData().then((resp) {
      isLoading.value = false;
      if (resp.success) {
        final fData = FiatDeposit.fromJson(resp.data);
        if (fData.paymentMethods.isValid) {
          final obj = fData.paymentMethods!.firstWhereOrNull((element) => element.paymentMethod == PaymentMethodType.flutterWave);
          if (obj != null && fData.paymentMethods!.remove(obj)) fData.paymentMethods!.insert(0, obj);
        }
        fiatDepositData.value = fData;
      } else {
        showToast(resp.message);
      }
      getFAQList();
    }, onError: (err) {
      isLoading.value = false;
      showToast(err.toString());
    });
  }

  Future<void> getFAQList() async {
    APIRepository().getFAQList(1, type: FAQType.deposit).then((resp) {
      if (resp.success) {
        ListResponse response = ListResponse.fromJson(resp.data);
        if (response.data != null) {
          List<FAQ> list = List<FAQ>.from(response.data!.map((x) => FAQ.fromJson(x)));
          faqList.value = list;
        }
      }
    }, onError: (err) {});
  }

  Future<void> getCurrencyDepositRate(int walletId, double amount, Function(double) onRate,
      {String? currency, int? bankId, int? walletIdFrom}) async {
    final pMethod = fiatDepositData.value.paymentMethods?[selectedMethodIndex.value];
    APIRepository().getCurrencyDepositRate(walletId, pMethod?.id ?? 0, amount, currency: currency, bankId: bankId, walletIdFrom: walletIdFrom).then(
        (resp) {
      if (resp.success) {
        final cAmount = makeDouble(resp.data[APIKeyConstants.calculatedAmount]);
        onRate(cAmount);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      showToast(err.message);
    });
  }

  Future<void> currencyDepositProcess(CreateDeposit deposit, Function({dynamic data}) onSuccess) async {
    final pMethod = fiatDepositData.value.paymentMethods?[selectedMethodIndex.value];
    deposit.paymentId = pMethod?.id;
    if ((getSettingsLocal()?.currencyDeposit2FaStatus ?? "") == "1") {
      if (!gUserRx.value.google2FaSecret.isValid) {
        showToast("You need to activate 2FA from settings for proceed this".tr);
        return;
      }
      TwoFAHelper.get2FACode(forText: "Deposit".tr, (code) {
        deposit.code = code;
        depositProcess(deposit, onSuccess);
      });
    } else {
      depositProcess(deposit, onSuccess);
    }
  }

  Future<void> depositProcess(CreateDeposit deposit, Function({dynamic data}) onSuccess) async {
    showLoadingDialog();
    APIRepository().currencyDepositProcess(deposit).then((resp) {
      hideLoadingDialog();

      if (resp.success) {
        if (deposit.code.isValid) Get.back();
        if (fiatDepositData.value.paymentMethods?[selectedMethodIndex.value].paymentMethod == PaymentMethodType.flutterWave) {
          onSuccess(data: resp.data);
        } else {
          showToast(resp.message, isError: !resp.success);
          onSuccess();
        }
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.message);
    });
  }

  List<String> getMethodList(FiatDeposit? fiatDepositData) {
    if (fiatDepositData?.paymentMethods.isValid ?? false) {
      return fiatDepositData!.paymentMethods!.map((e) => e.title ?? "").toList();
    }
    return [];
  }

  List<String> getBankList(FiatDeposit? fiatDepositData) {
    if (fiatDepositData?.banks.isValid ?? false) {
      return fiatDepositData!.banks!.map((e) => e.bankName ?? "").toList();
    }
    return [];
  }

  // Future<void> convertCurrencyAmount(String toCoin, double amount, Function(double) onRate) async {
  //   APIRepository().convertCurrencyAmount("USD", toCoin, amount).then((resp) {
  //     if (resp.success) {
  //       final cAmount = makeDouble(resp.data[APIKeyConstants.convertedAmount]);
  //       onRate(cAmount);
  //     } else {
  //       showToast(resp.message);
  //     }
  //   }, onError: (err) {
  //     showToast(err.message);
  //   });
  // }

  Future<void> paystackPaymentUrlGet(int walletId, double amount, String email, String currency, Function(PaystackData) onSuccess) async {
    final pMethod = fiatDepositData.value.paymentMethods?[selectedMethodIndex.value];
    showLoadingDialog();
    APIRepository().paystackPaymentUrlGet(walletId, pMethod?.id ?? 0, amount, email, 1, currency: currency).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        if (success) {
          final data = PaystackData.fromJson(resp.data[APIKeyConstants.data]);
          onSuccess(data);
        } else {
          showToast(message);
        }
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.message);
    });
  }

  Future<void> getFlutterWaveTransactionDone(String reference, Function() onSuccess) async {
    showLoadingDialog();
    APIRepository().getFlutterWaveTransactionDone(reference, 1).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        onSuccess();
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.message);
    });
  }

  Future<void> getFlutterWaveTransactionCanceled(String reference, Function() onSuccess) async {
    showLoadingDialog();
    APIRepository().getFlutterWaveTransactionCanceled(reference, 1).then((resp) {
      hideLoadingDialog();
      showToast(resp.message, isError: !resp.success);
      if (resp.success) onSuccess();
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.message);
    });
  }
}
