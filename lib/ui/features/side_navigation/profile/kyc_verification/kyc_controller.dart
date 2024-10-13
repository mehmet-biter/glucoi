import 'dart:io';

import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/models/kyc_details.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';

class KycController extends GetxController {
  String appName = '';
  Rx<KycDetails> kycDetailsRx = KycDetails().obs;
  Rx<KycSettings> kycSettingsRx = KycSettings(enabledKycType: 0).obs;
  RxBool isDataLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getAppName().then((value) => appName = value);
  }

  void getKYCSettingsDetails() async {
    APIRepository().getUserKYCSettingsDetails().then((resp) {
      isDataLoading.value = false;
      if (resp.success) {
        final settings = KycSettings.fromJson(resp.data);
        kycSettingsRx.value = settings;
        final kycDetails = kycSettingsRx.value.enabledKycUserDetails;
        if (kycDetails != null && kycDetails is KycDetails) kycDetailsRx.value = kycDetails;
        setKYCVerified(settings);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      isDataLoading.value = false;
      showToast(err.toString());
    });
  }

  // void verifyThirdPartyKyc(String inquiryId, Function(bool) onSuccess) {
  //   showLoadingDialog();
  //   APIRepository().thirdPartyKycVerified(inquiryId).then((resp) {
  //     hideLoadingDialog();
  //     if (resp.success) {
  //       onSuccess(true);
  //     } else {
  //       showToast(resp.message);
  //     }
  //   }, onError: (err) {
  //     hideLoadingDialog();
  //     showToast(err.toString());
  //   });
  // }

  void getKYCDetails(Function(KycDetails) onSuccess) async {
    showLoadingDialog();
    APIRepository().getKYCDetails().then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final details = KycDetails.fromJson(resp.data);
        onSuccess(details);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void uploadDocuments(IdVerificationType type, File frontFile, File backFile, File selfieFile, Function(KycDetails) onSuccess) async {
    showLoadingDialog();
    APIRepository().uploadIdVerificationFiles(type, frontFile, backFile, selfieFile).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success);
        if (success) {
          Get.back();
          getKYCDetails((p0) => onSuccess(p0));
        }
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void verifyKycByDojah(IdVerificationType type, String id, File selfieFile, Function() onSuccess) async {
    showLoadingDialog();
    APIRepository().verifyKycByDojah(type, id, selfieFile).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success);
        if (success) {
          onSuccess();
          getKYCSettingsDetails();
        }
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }
}
