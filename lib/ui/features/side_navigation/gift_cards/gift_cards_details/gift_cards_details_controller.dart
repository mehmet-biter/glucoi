import 'package:get/get.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';

class GiftCardDetailsController extends GetxController {
  void getGiftCardCode(String transactionId, Function(String) onSuccess) {
    showLoadingDialog();
    APIRepository().getGiftCardCode(transactionId).then((resp) {
      hideLoadingDialog();
      if (resp.success && resp.data != null) {
        final code = resp.data["reedem_code"] ?? resp.data["reedem_pin"] ?? "";
        onSuccess(code);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }
}
