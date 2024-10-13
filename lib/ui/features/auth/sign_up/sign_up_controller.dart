import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tradexpro_flutter/data/local/api_constants.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:tradexpro_flutter/data/remote/api_repository.dart';
import 'package:tradexpro_flutter/ui/features/auth/email_verify/email_verify_page.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/date_util.dart';

class SignUpController extends GetxController {
  TextEditingController firstNameEditController = TextEditingController();
  TextEditingController lastNameEditController = TextEditingController();
  TextEditingController emailEditController = TextEditingController();
  TextEditingController passEditController = TextEditingController();
  TextEditingController confirmPassEditController = TextEditingController();
  TextEditingController dobEditController = TextEditingController();
  TextEditingController referralEditController = TextEditingController();
  DateTime? dob;
  RxBool isShowPassword = false.obs;

  void isInPutDataValid(BuildContext context) {
    final fName = firstNameEditController.text.trim();
    if (fName.isEmpty) {
      showToast("${"First Name".tr} ${"is required".tr}");
      return;
    }

    final lName = lastNameEditController.text.trim();
    if (lName.isEmpty) {
      showToast("${"Last Name".tr} ${"is required".tr}");
      return;
    }

    final email = emailEditController.text.trim();
    if (!GetUtils.isEmail(email)) {
      showToast("Input a valid Email".tr);
      return;
    }

    if (dob == null) {
      showToast("${"Date of Birth".tr} ${"is required".tr}");
      return;
    }

    if (!isValidPassword(passEditController.text)) {
      showToast("Password_invalid_message".trParams({"count": DefaultValue.kPasswordLength.toString()}), isError: true);
      return;
    }

    if (passEditController.text != confirmPassEditController.text) {
      showToast("Password and confirm password not matched".tr);
      return;
    }
    final refCode = referralEditController.text.trim();
    if (refCode.isNotEmpty && refCode.length != DefaultValue.userCodeLength) {
      showToast("Invalid Referral ID".tr);
      return;
    }
    hideKeyboard(context: context);
    signUp(fName, lName, email, refCode);
  }

  void signUp(String fName, String lName, String email, String refCode) {
    showLoadingDialog();
    final bDate = formatDate(dob, format: dateFormatYyyyMMDd);
    APIRepository().registerUser(fName, lName, email, passEditController.text, bDate, refCode).then((resp) {
      hideLoadingDialog();
      if (resp.success) {
        final success = resp.data[APIKeyConstants.success] as bool? ?? false;
        final message = resp.data[APIKeyConstants.message] as String? ?? "";
        showToast(message, isError: !success);
        if (success) {
          Get.off(() => EmailVerifyPage(registrationId: emailEditController.text.trim()));
        }
      }
    }, onError: (err) {
      hideLoadingDialog();
      showToast(err.toString());
    });
  }
}
