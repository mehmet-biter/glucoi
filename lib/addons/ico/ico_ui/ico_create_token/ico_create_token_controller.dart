import 'dart:io';

import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/ico/ico_api_repository.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_dashboard.dart';
import 'package:tradexpro_flutter/addons/ico/model/ico_settings.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/models/wallet.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';

class IcoCreateTokenController extends GetxController {
  final networkList = [
    Network(id: 4, networkName: "ERC20 Token API".tr, networkType: "ETH"),
    Network(id: 5, networkName: "BEP20 Token API".tr, networkType: "BNB")
  ];
  RxInt selectedNetwork = 0.obs;
  Rx<Contract> contract = Contract().obs;
  Rx<File> selectedFile = File("").obs;
  RxString contractError = "".obs;

  Future<void> icoGetContractAddressDetails(String chainLink, String address) async {
    IcoAPIRepository().icoGetContractAddressDetails(chainLink, address).then((resp) {
      if (resp.success) {
        contract.value = Contract.fromJson(resp.data);
      } else {
        contractError.value = resp.message;
        showToast(resp.message);
      }
    }, onError: (err) {
      showToast(err.toString());
    });
  }

  Future<void> icoCreateUpdateToken(IcoToken token, File file) async {
    showLoadingDialog();
    IcoAPIRepository().icoCreateUpdateToken(token, file).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success);
        if (success){

        }
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }
}
