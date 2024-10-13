import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

import 'common_utils.dart';

enum LocalAuthAction { add, check, remove }

class LocalAuthHelper {

  static bool isLocalAuthActivated() {
    var finger = GetStorage().read(PreferenceKey.isLocalAuthActive) as bool? ?? false;
    return finger;
  }

  static Future<bool> isBiometricsSupported({bool isShow = true}) async {
    return false;
    // var isSupported = await LocalAuthentication().isDeviceSupported();
    // if (!isSupported && isShow) {
    //   showToast("Please active your device Biometrics first".tr, isError: true);
    // }
    // return isSupported;

  }

  static Future<bool> checkBiometrics() async {
    return await authenticate(LocalAuthAction.check, "Please pass the security step".tr);
  }

  static Future<bool> setBiometrics() async {
    if (await isBiometricsSupported()) {
      if (await authenticate(LocalAuthAction.add, "This will secure your app for unwanted use".tr)) {
        return true;
      }
    }
    return false;
  }

  static Future<bool> removeBiometrics() async {
    if (await isBiometricsSupported(isShow: false)) {
      return await authenticate(LocalAuthAction.remove, "This will remove this security from app".tr);
    } else {
      GetStorage().write(PreferenceKey.isLocalAuthActive, false);
      return true;
    }
  }

  static Future<bool> authenticate(LocalAuthAction localAuthAction, String title) async {
    bool authenticated = false;
    try {
      authenticated = await LocalAuthentication().authenticate(localizedReason: title, options: const AuthenticationOptions(stickyAuth: true));
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable || e.code == auth_error.notEnrolled) {
        showToast(e.message);
      } else {
        showToast(e.message);
      }
    }
    // if (authenticated && localAuthAction == LocalAuthAction.add) {
    //   GetStorage().write(PreferenceKey.isLocalAuthActive, true);
    // } else if (authenticated && localAuthAction == LocalAuthAction.remove) {
    //   GetStorage().write(PreferenceKey.isLocalAuthActive, false);
    // }
    return authenticated;
  }
}
