import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/models/list_response.dart';
import 'package:tradexpro_flutter/data/models/response.dart';
import 'package:tradexpro_flutter/data/models/top_up.dart';
import 'package:tradexpro_flutter/data/models/utility_bills.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/utils/number_util.dart';

class UtilityBillsController extends GetxController {
  TabController? tabController;
  RxInt selectedTabIndex = 0.obs;
  Rx<UtilityBillData> utilityBillData = UtilityBillData().obs;

  // void getUtilityPageData(Function(UtilityBillData) onSuccess) {
  //   APIRepository().getUtilityPageData().then((resp) {
  //     if (resp.success) {
  //       final value = UtilityBillData.fromJson(resp.data);
  //       onSuccess(value);
  //     } else {
  //       showToast(resp.message);
  //     }
  //   }, onError: (err) {
  //     showToast(err.toString());
  //   });
  // }

  void getFlutterService(Function(UtilityBillData) onSuccess) {

    APIRepository().getFlutterService().then((resp) {
      if (resp.success) {
        final value = UtilityBillData.fromJson(resp.data);
        onSuccess(value);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      showToast(err.toString());
    });
  }

  void getUtilityCountry(UtilityService service, Function(List<TopUpCountry>) onSuccess) async {
    try {
      ServerResponse? resp;
      if (service.reLoadLy ?? false) {
        resp = await APIRepository().getUtilityCountry(service.type ?? "");
      } else {
        resp = await APIRepository().getFlutterCountry(service.type ?? "");
      }
      if (resp.success) {
        final list = List<TopUpCountry>.from(resp.data.map((x) => TopUpCountry.fromJson(x)));
        onSuccess(list);
      } else {
        showToast(resp.message);
      }
    } catch (err) {
      showToast(err.toString());
    }
  }

  void getUtilityBiller(UtilityService service, String country, Function(List<UtilityBiller>) onSuccess) async {
    try {
      ServerResponse? resp;
      if (service.reLoadLy ?? false) {
        resp = await APIRepository().getUtilityBiller(service.type ?? "", country);
      } else {
        resp = await APIRepository().getFlutterBiller(service.type ?? "", country);
      }
      if (resp.success) {
        final data = resp.data[(service.reLoadLy ?? false) ? "content" : "biller"];
        if (data != null) {
          final list = List<UtilityBiller>.from(data.map((x) => UtilityBiller.fromJson(x)));
          onSuccess(list);
        }
      } else {
        showToast(resp.message);
      }
    } catch (err) {
      showToast(err.toString());
    }
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

  void payUtilityBill(String type, String country, int billerId, String coin, String account, double amount, double payAmount, Function() onSuccess,
      {int? amountId}) {
    showLoadingDialog();
    APIRepository().payUtilityBill(type, country, billerId, coin, account, amount, payAmount).then((resp) {
      hideLoadingDialog();
      showToast(resp.message, isError: !resp.success, isLong: !resp.success);
      if (resp.success) onSuccess();
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void getValidateFlutterBiller(UtilityBiller biller, String account, Function() onSuccess) {
    showLoadingDialog();
    APIRepository().getValidateFlutterBiller(biller.itemCode ?? '', biller.billerCode ?? '', account).then((resp) {
      if (resp.success) {
        onSuccess();
      } else {
        hideLoadingDialog();
        showToast(resp.message);
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void payFlutterBiller(String type, String country, String currency, UtilityBiller biller, String account, Function() onSuccess) {
    APIRepository()
        .payFlutterBiller(biller.id ?? 0, country, currency, account, biller.amount ?? 0, biller.billerName ?? "", type, biller.billerCode ?? "")
        .then((resp) {
      hideLoadingDialog();
      showToast(resp.message, isError: !resp.success, isLong: !resp.success);
      if (resp.success) onSuccess();
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  // void getUtilityBillHistory(String key, int limit, int page, Function(ListResponse?) onData) {
  //   APIRepository().getUtilityBillHistory(key, limit, page).then((resp) {
  //     if (resp.success) {
  //       ListResponse listResp = ListResponse.fromJson(resp.data);
  //       onData(listResp);
  //     } else {
  //       showToast(resp.message);
  //       onData(null);
  //     }
  //   }, onError: (err) {
  //     showToast(err.toString());
  //     onData(null);
  //   });
  // }

  void getUtilityHistory(String type, int limit, int page, Function(ListResponse?) onData) {
    APIRepository().getFlutterBillerHistory(type, limit, page).then((resp) {
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
