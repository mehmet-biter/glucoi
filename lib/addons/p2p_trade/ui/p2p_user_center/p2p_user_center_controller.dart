import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/models/p2p_profile_details.dart';
import 'package:tradexpro_flutter/addons/p2p_trade/models/p2p_settings.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/models/list_response.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';

import '../../models/p2p_ads.dart';
import '../../p2p_api_repository.dart';

class P2pUserCenterController extends GetxController {
  P2PProfileDetails profileDetails = P2PProfileDetails();
  RxBool isDataLoading = false.obs;
  RxInt selectedTab = 0.obs;
  RxList<P2pFeedback> feedBackList = <P2pFeedback>[].obs;
  RxList<P2pPaymentInfo> paymentInfoList = <P2pPaymentInfo>[].obs;

  void getUserCenter() {
    isDataLoading.value = true;
    P2pAPIRepository().getP2pUserCenter().then((resp) {
      if (resp.success && resp.data != null) {
        profileDetails = P2PProfileDetails.fromJson(resp.data);
      } else {
        showToast(resp.message);
      }
      isDataLoading.value = false;
      getFeedBackList(0);
      getPaymentMethods();
    }, onError: (err) {
      isDataLoading.value = false;
      showToast(err.toString());
    });
  }

  void getPaymentMethods() {
    P2pAPIRepository().getP2pPaymentMethod().then((resp) {
      if (resp.success && resp.data != null) {
        ListResponse listResponse = ListResponse.fromJson(resp.data);
        if (listResponse.data != null) {
          List<P2pPaymentInfo> list = List<P2pPaymentInfo>.from(listResponse.data!.map((x) => P2pPaymentInfo.fromJson(x)));
          paymentInfoList.value = list;
        }
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      showToast(err.toString());
    });
  }

  void getFeedBackList(int index) {
    selectedTab.value = index;
    if (index == 0) {
      feedBackList.value = profileDetails.feedbackList ?? [];
    } else {
      final type = index == 1 ? 1 : 2;
      final list = profileDetails.feedbackList?.where((e) => e.feedbackType == type).toList();
      feedBackList.value = list ?? [];
    }
  }

  void getP2pAdminPaymentMethods(Function(List<P2PPaymentMethod>) onSuccess) {
    P2pAPIRepository().getP2pAdminPaymentMethods().then((resp) {
      if (resp.success && resp.data != null) {
        List<P2PPaymentMethod> list = List<P2PPaymentMethod>.from(resp.data!.map((x) => P2PPaymentMethod.fromJson(x)));
        onSuccess(list);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      showToast(err.toString());
    });
  }

  void p2pPaymentMethodSave(P2pPaymentInfo paymentInfo, BuildContext context) {
    showLoadingDialog();
    P2pAPIRepository().p2pPaymentMethodSave(paymentInfo).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success, context: context);
        if (success) {
          Get.back();
          getPaymentMethods();
        }
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString(), context: context);
    });
  }

  void p2pPaymentMethodDelete(P2pPaymentInfo paymentInfo, BuildContext context) {
    showLoadingDialog();
    P2pAPIRepository().p2pPaymentMethodDelete(paymentInfo.uid ?? "").then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success, context: context);
        if (success) {
          Get.back();
          paymentInfoList.removeWhere((element) => element.uid == paymentInfo.uid);
        }
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString(), context: context);
    });
  }
}
