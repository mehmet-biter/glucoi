import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/faq.dart';
import 'package:tradexpro_flutter/data/models/fiat_deposit.dart';
import 'package:tradexpro_flutter/data/models/history.dart';
import 'package:tradexpro_flutter/data/models/list_response.dart';
import 'package:tradexpro_flutter/data/models/response.dart';
import 'package:tradexpro_flutter/data/models/wallet.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/paystack_util.dart';

class WalletDepositController extends GetxController {
  RxBool isLoading = true.obs;
  RxInt selectedMethodIndex = 0.obs;
  Rx<FiatDeposit> fiatDepositData = FiatDeposit().obs;
  Rx<Wallet> wallet = Wallet(id: 0).obs;

  Future<void> getFiatDepositData() async {
    isLoading.value = true;
    APIRepository().getWalletCurrencyDeposit().then((resp) {
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
    }, onError: (err) {
      isLoading.value = false;
      showToast(err.toString());
    });
  }

  Future<void> getWalletDetails() async {
    APIRepository().getWalletDetails(wallet.value.id).then((resp) {
      if (resp.success && resp.data != null) {
        wallet.value = Wallet.fromJson(resp.data);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      showToast(err.toString());
    });
  }

  Future<void> walletCurrencyDeposit(CreateDeposit deposit, Function({dynamic data}) onSuccess) async {
    final pMethod = fiatDepositData.value.paymentMethods?[selectedMethodIndex.value];
    deposit.paymentId = pMethod?.id;
    showLoadingDialog();
    APIRepository().walletCurrencyDeposit(deposit).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final paymentMethod = fiatDepositData.value.paymentMethods?[selectedMethodIndex.value].paymentMethod;
        if (deposit.code.isValid) Get.back();
        if (paymentMethod == PaymentMethodType.flutterWave) {
          onSuccess(data: resp.data);
        } else if (paymentMethod == PaymentMethodType.bank) {
          onSuccess(data: resp.message);
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

  Future<void> getWalletDeposit(int id, Function(WalletDeposit) onGetDeposit) async {
    showLoadingDialog();
    APIRepository().getWalletDeposit(id).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final walletDeposit = WalletDeposit.fromJson(resp.data);
        if (walletDeposit.success ?? false) {
          onGetDeposit(walletDeposit);
        } else {
          showToast(walletDeposit.message ?? "");
        }
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  Future<void> getHistoryListData(String type, Function(List<History>) onGetHistory) async {
    APIRepository().getActivityList(0, type).then((resp) {
      if (resp.success) {
        final historyResponse = HistoryResponse.fromJson(resp.data);
        final listResponse = historyResponse.histories;
        if (listResponse != null) {
          final list = List<History>.from(listResponse.data!.map((x) => History.fromJson(x)));
          onGetHistory(list);
        }
      }
    }, onError: (err) {});
  }

  Future<void> getFAQList(int type, Function(List<FAQ>) onList) async {
    APIRepository().getFAQList(1, type: type).then((resp) {
      if (resp.success) {
        ListResponse response = ListResponse.fromJson(resp.data);
        if (response.data != null) {
          List<FAQ> list = List<FAQ>.from(response.data!.map((x) => FAQ.fromJson(x)));
          onList(list);
        }
      }
    }, onError: (err) {});
  }

  Future<void> walletNetworkAddress(Network network, Function(String?) onAddress) async {
    showLoadingDialog();
    APIRepository().walletNetworkAddress(network.walletId ?? 0, network.networkType ?? "").then((resp) {
      hideLoadingDialog();
      showToast(resp.message, isError: !resp.success);
      if (resp.success) {
        final address = resp.data[APIKeyConstants.address] as String?;
        onAddress(address);
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  Future<void> createNetworkAddress(Network network, String coinType, Function(String?) onAddress) async {
    showLoadingDialog();
    APIRepository().createNetworkAddress(network.id, coinType).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        onAddress(resp.data as String?);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  Future<void> paystackPaymentUrlGet(double amount, String email, Function(PaystackData) onSuccess) async {
    final pMethod = fiatDepositData.value.paymentMethods?[selectedMethodIndex.value];
    showLoadingDialog();
    APIRepository().paystackPaymentUrlGet(wallet.value.id, pMethod?.id ?? 0, amount, email, 2, currency: wallet.value.coinType).then((resp) {
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

  Future<void> walletCurrencyDepositFlutterWave(CreateDeposit deposit, Function({dynamic data}) onSuccess) async {
    final pMethod = fiatDepositData.value.paymentMethods?[selectedMethodIndex.value];
    deposit.paymentId = pMethod?.id;
    showLoadingDialog();
    APIRepository().walletCurrencyDepositFlutterWave(deposit).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        if (deposit.code.isValid) Get.back();
        onSuccess(data: resp.data);
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
    APIRepository().getFlutterWaveTransactionDone(reference, 0).then((resp) {
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
    APIRepository().getFlutterWaveTransactionCanceled(reference, 0).then((resp) {
      hideLoadingDialog();
      showToast(resp.message, isError: !resp.success);
      if (resp.success) onSuccess();
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.message);
    });
  }
}
