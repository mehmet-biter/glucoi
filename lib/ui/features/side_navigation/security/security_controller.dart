import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/models/settings.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/models/user.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/helper/app_helper.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';

import 'phone_verify_screen.dart';


class SecurityController extends GetxController {

  void sendSMS(String phone, bool isResend) {
    showLoadingDialog();
    APIRepository().sendPhoneSMS().then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success);
        if (success && !isResend) {
          Get.to(() => PhoneVerifyScreen(registrationId: phone));
        }
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void verifyPhone(String code) {
    showLoadingDialog();
    APIRepository().verifyPhone(code).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success);
        if (success) {
          Get.back();
          updateGlobalUser();
        }
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void getUserSetting(Function(User) onSuccess) {
    showLoadingDialog();
    APIRepository().getUserSetting().then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final uSettings = UserSettings.fromJson(resp.data);
        if (uSettings.user != null) onSuccess(uSettings.user!);
      } else {
        showToast(resp.message);
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }

  void deleteAccountRequest(String reason, String password, Function() onSuccess) {
    showLoadingDialog();
    APIRepository().profileDeleteRequest(reason, password).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success);
        if (success) onSuccess();
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }
}
