import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/list_response.dart';
import 'package:tradexpro_flutter/data/models/wallet.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';

class WalletSelectionController extends GetxController {
  RxList<Wallet> walletList = <Wallet>[].obs;
  RxList<Wallet> mostUsedWallets = <Wallet>[].obs;
  final searchController = TextEditingController();
  RxInt currencyType = 0.obs;
  RxBool isLoading = false.obs;
  String fromKey = "";

  Future<void> getWalletList() async {
    if (gUserRx.value.id == 0) return;
    walletList.clear();
    isLoading.value = true;
    final searchKey = searchController.text.trim();
    final currency = currencyType.value == 0 ? CurrencyType.fiat : CurrencyType.crypto;
    APIRepository().getWalletList(1, currencyType: currency, search: searchKey).then((resp) {
      isLoading.value = false;
      if (resp.success) {
        final wallets = resp.data[APIKeyConstants.wallets];
        if (wallets != null) {
          ListResponse listResponse = ListResponse.fromJson(wallets);
          List<Wallet> list = List<Wallet>.from(listResponse.data!.map((x) => Wallet.fromJson(x)));

          if (fromKey == FromKey.deposit) {
            list = list.where((e) => e.isDeposit == 1).toList();
          } else if (fromKey == FromKey.withdraw) {
            list = list.where((e) => e.isWithdrawal == 1).toList();
          }
          walletList.value = list;
        }
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      isLoading.value = false;
      showToast(err.toString());
    });
  }

  Future<void> getMostUsedWallets() async {
    if (gUserRx.value.id == 0) return;
    mostUsedWallets.clear();
    final currency = currencyType.value == 0 ? CurrencyType.fiat : CurrencyType.crypto;
    APIRepository().getMostUsedWallets(fromKey, currency).then((resp) {
      if (resp.success && resp.data != null) {
        List<Wallet> list = List<Wallet>.from(resp.data!.map((x) => Wallet.fromJson(x)));
        mostUsedWallets.value = list;
      }
    }, onError: (err) {});
  }
}
