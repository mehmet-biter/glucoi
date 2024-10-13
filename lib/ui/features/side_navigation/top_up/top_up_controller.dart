import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/models/list_response.dart';
import 'package:tradexpro_flutter/data/models/top_up.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';

class TopUpController extends GetxController {
  RxInt selectedTabIndex = 0.obs;

  void getTopUpData(Function(TopUpData) onSuccess) {
    APIRepository().getTopUpCountry().then((resp) {
      if (resp.success) {
        final value = TopUpData.fromJson(resp.data);
        onSuccess(value);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      showToast(err.toString());
    });
  }

  void getTopUpOperatorsOf(String code, Function(List<TopUpOperator>) onSuccess) {
    APIRepository().getTopUpOperatorsOf(code).then((resp) {
      if (resp.success) {
        final list = List<TopUpOperator>.from(resp.data.map((x) => TopUpOperator.fromJson(x)));
        onSuccess(list);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      showToast(err.toString());
    });
  }

  void getAirTimeConvertPrice(String currency, String coin, double amount, Function(double) onSuccess) {
    APIRepository().getAirTimeConvertPrice(currency, coin, amount).then((resp) {
      if (resp.success) {
        final data = makeDouble(resp.data);
        onSuccess(data);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      showToast(err.toString());
    });
  }

  void makeTopUp(String countryCode, String currency, int operatorId, String phone, double amount, double payAmount, Function() onSuccess) {
    showLoadingDialog();
    APIRepository().makeTopUp(countryCode, currency, operatorId, phone, amount, payAmount).then((resp) {
      hideLoadingDialog();
      showToast(resp.message, isError: !resp.success, isLong: !resp.success);
      if (resp.success) onSuccess();
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void getAirTimeTopUpHistory(String search, int limit, int page, Function(ListResponse?) onData) {
    APIRepository().getAirTimeTopUpHistory(search, limit, page).then((resp) {
      if (resp.success) {
        ListResponse listResp = ListResponse.fromJson(resp.data);
        onData(listResp);
      } else {
        showToast(resp.message);
        onData(null);
      }
    }, onError: (err) {
      showToast(err.toString());
      onData(null);
    });
  }
}
