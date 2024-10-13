import 'dart:io';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/models/user.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';

class MyProfileController extends GetxController {
  RxInt selectedType = 0.obs;

  List<String> getProfileMenus() => ['Profile'.tr, 'Edit Profile'.tr, 'Verification and Limit'.tr, "Bank List".tr];

  // List<String> getProfileMenus() => ['Profile'.tr, 'Edit Profile'.tr, 'Phone Verification'.tr, 'Security'.tr, 'KYC Verification'.tr, "Bank List".tr];

  void updateProfile(User updatedUser, File profileImage) {
    showLoadingDialog();
    APIRepository().updateProfile(updatedUser, profileImage).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success);
        if (success) updateGlobalUser();
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void updateProfileImage(File profileImage) {
    showLoadingDialog();
    APIRepository().updateProfileImage(profileImage).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success);
        if (success) updateGlobalUser();
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void getUserActivities(Function(List<UserActivity>) onSuccess) {
    APIRepository().getSelfProfile().then((resp) {
      if (resp.success) {
        final listMap = resp.data[APIKeyConstants.activityLog] as List? ?? [];
        final list = List<UserActivity>.from(listMap.map((x) => UserActivity.fromJson(x)));
        onSuccess(list);
        saveGlobalUser(userMap: resp.data[APIKeyConstants.user]);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      showToast(err.toString());
    });
  }

  // void sendSMS(String phone, bool isResend) {
  //   showLoadingDialog();
  //   APIRepository().sendPhoneSMS().then((resp) {
  //     hideLoadingDialog();
  //     if (resp.success) {
  //       final success = resp.data[APIKeyConstants.success] as bool? ?? false;
  //       final message = resp.data[APIKeyConstants.message] as String? ?? "";
  //       showToast(message, isError: !success);
  //       if (success && !isResend) {
  //         Get.to(() => PhoneVerifyScreen(registrationId: phone));
  //       }
  //     }
  //   }, onError: (err) {
  //     hideLoadingDialog();
  //     showToast(err.toString());
  //   });
  // }

  void updateProfilePhone(String phone) {
    showLoadingDialog();
    APIRepository().updateProfilePhone(phone).then((resp) {
      hideLoadingDialog();
      showToast(resp.message, isError: !resp.success);
      if (resp.success) updateGlobalUser();
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

// void verifyPhone(String code) {
//   showLoadingDialog();
//   APIRepository().verifyPhone(code).then((resp) {
//     hideLoadingDialog();
//     if (resp.success) {
//       final success = resp.data[APIKeyConstants.success] as bool? ?? false;
//       final message = resp.data[APIKeyConstants.message] as String? ?? "";
//       showToast(message, isError: !success);
//       if (success) {
//         Get.back();
//         updateGlobalUser();
//       }
//     }
//   }, onError: (err) {
//     hideLoadingDialog();
//     showToast(err.toString());
//   });
// }
//
// void getUserSetting(Function(User) onSuccess) {
//   showLoadingDialog();
//   APIRepository().getUserSetting().then((resp) {
//     hideLoadingDialog();
//     if (resp.success) {
//       final uSettings = UserSettings.fromJson(resp.data);
//       if (uSettings.user != null) onSuccess(uSettings.user!);
//     } else {
//       showToast(resp.message);
//     }
//   }, onError: (err) {
//     hideLoadingDialog();
//     showToast(err.toString());
//   });
// }
// void deleteAccountRequest(String reason, String password, Function() onSuccess) {
//   showLoadingDialog();
//   APIRepository().profileDeleteRequest(reason, password).then((resp) {
//     hideLoadingDialog();
//     if (resp.success) {
//       final success = resp.data[APIKeyConstants.success] as bool? ?? false;
//       final message = resp.data[APIKeyConstants.message] as String? ?? "";
//       showToast(message, isError: !success);
//       if (success) onSuccess();
//     }
//   }, onError: (err) {
//     hideLoadingDialog();
//     showToast(err.toString());
//   });
// }
}
