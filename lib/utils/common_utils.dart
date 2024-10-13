import 'dart:convert';
import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tradexpro_flutter/utils/decorations.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/language_util.dart';
import 'package:tradexpro_flutter/utils/text_util.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:tradexpro_flutter/data/local/constants.dart';

void showToast(String? text, {bool isError = true, bool isLong = false, BuildContext? context}) {
  if (text.isValid) {
    context = context ?? currentContext;
    if (context != null) {
      Widget toast = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: boxDecorationRoundCorner(radius: 25, color: isError ? Colors.red : Theme.of(context).primaryColor),
          child: textAutoSizePoppins(text!, color: isError ? Colors.white : Theme.of(context).colorScheme.background, maxLines: 10));
      FToast().init(context).showToast(child: toast, gravity: ToastGravity.BOTTOM, toastDuration: Duration(seconds: isLong ? 5 : 2));
    } else {
      Fluttertoast.showToast(
          msg: text!,
          toastLength: isLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: isError ? Colors.red : Get.theme.primaryColor,
          textColor: isError ? Colors.white : Get.theme.colorScheme.background);
    }
  }
}

void showLoadingDialog({bool isDismissible = false}) {
  if (Get.isDialogOpen == null || !Get.isDialogOpen!) {
    Get.dialog(Center(child: CircularProgressIndicator(color: Get.theme.focusColor)), barrierDismissible: isDismissible);
  }
}

VisualDensity get minimumVisualDensity => const VisualDensity(horizontal: -4, vertical: -4);

void hideLoadingDialog() {
  if (Get.isDialogOpen != null && Get.isDialogOpen!) {
    Get.back();
  }
}

void hideKeyboard({BuildContext? context}) {
  if (context == null) {
    FocusManager.instance.primaryFocus?.unfocus();
  } else if (FocusScope.of(context).canRequestFocus) {
    FocusScope.of(context).unfocus();
  }
}

void printFunction(String tag, dynamic data) {
  if (kDebugMode) GetUtils.printFunction("$tag => ", data, "");
}

void clearStorage() {
  var storage = GetStorage();
  storage.write(PreferenceKey.accessToken, "");
  storage.write(PreferenceKey.accessTokenEvm, "");
  storage.write(PreferenceKey.isLoggedIn, false);
  storage.write(PreferenceKey.userObject, {});
  storage.write(PreferenceKey.firebaseToken, "");
  storage.write(PreferenceKey.isKycVerified, false);
}

void editTextFocusDisable(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

String getEnumString(dynamic enumValue) {
  String string = enumValue.toString();
  try {
    string = string.split(".").last;
    return string;
  } catch (_) {}
  return "";
}

void callToNumber(String number) async {
  if (number.isEmpty) {
    showToast("The phone number has not been available".tr, isError: true);
    return;
  }
  String url = "tel:$number";
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    showToast("The phone number is invalid".tr, isError: true);
  }
}

void smsToNumber(String number) async {
  if (number.isEmpty) {
    showToast("The phone number has not been available".tr, isError: true);
    return;
  }
  String url = "sms:$number";
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    showToast("The phone number is invalid".tr, isError: true);
  }
}

void mailToAddress(String mail, {String? subject, String? body}) async {
  if (!GetUtils.isEmail(mail)) {
    showToast("Input a valid Email".tr, isError: true);
    return;
  }
  String url = "mailto:$mail?";
  if (subject.isValid) {
    url = "${url}subject=$subject&";
  }
  if (body.isValid) {
    url = "${url}body=$body";
  }

  try {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  } catch (err) {
    showToast(err.toString(), isError: true);
  }
}

void shareText(String? text) => Share.share(text ?? "");

bool systemThemIsDark() => SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

void copyToClipboard(String string) {
  Clipboard.setData(ClipboardData(text: string)).then((_) {
    // showToast("Text copied to clipboard".tr, isError: false);
  });
}

void openUrlInBrowser(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    showToast("The URL is invalid".tr, isError: true);
  }
}

bool isValidPassword(String value) {
  String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~.]).{6,}$';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(value);
}

String removeSpecialChar(String? text) {
  if (text != null && text.isNotEmpty) {
    return text.replaceAll(RegExp(r'[^\w\s]+'), '');
  }
  return "";
}

Future<String> htmlString(String path) async {
  String fileText = await rootBundle.loadString(path);
  String htmlStr = Uri.dataFromString(fileText, mimeType: 'text/html', encoding: Encoding.getByName('utf-8')).toString();
  return htmlStr;
}

Widget dividerHorizontal({Color? color, double height = 20, double? indent, double? width}) {
  return SizedBox(
    width: width,
    child: Divider(height: height, color: color, thickness: 1, endIndent: indent, indent: indent),
  );
}

Widget dividerVertical({Color? color, double width = 10, double? height, double? indent}) {
  return SizedBox(
    height: height,
    child: VerticalDivider(width: width, color: color, thickness: 2, endIndent: indent, indent: indent),
  );
}

double getContentHeight({bool withBottomNav = false, bool withToolbar = false}) {
  var padding = Get.statusBarHeight + Get.bottomBarHeight;
  if (withBottomNav) {
    padding = padding + kBottomNavigationBarHeight;
  }
  if (withToolbar) {
    padding = padding + kToolbarHeight;
  }
  return Get.height - padding;
}

String getMapKey(String? value, Map? map) {
  if (!value.isValid || map == null) return "";
  final key = map.keys.firstWhere((k) => map[k] == value, orElse: () => "");
  return key;
}

void showCountriesPicker(BuildContext context, Function(Country) onChange) {
  showCountryPicker(
    context: context,
    showPhoneCode: true,
    countryListTheme: CountryListThemeData(
      flagSize: 20,
      backgroundColor: context.theme.colorScheme.background,
      textStyle: context.textTheme.bodyMedium,
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
      searchTextStyle: context.textTheme.bodyMedium,
      inputDecoration: InputDecoration(
        hintText: 'Search'.tr,
        isDense: true,
        focusColor: context.theme.primaryColor,
        contentPadding: EdgeInsets.zero,
        prefixIcon: Icon(Icons.search, color: context.theme.primaryColor),
        border: OutlineInputBorder(borderSide: BorderSide(color: context.theme.primaryColor)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.theme.focusColor)),
      ),
    ),
    onSelect: onChange,
  );
}

Future<String> getUserAgent() async {
  try {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if(Platform.isAndroid){
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      final userAgent = 'Android ${deviceInfo.version.release} (SDK ${deviceInfo.version.sdkInt}), ${deviceInfo.manufacturer} ${deviceInfo.model}';
      return userAgent;
    }else if(Platform.isIOS){
      var iosInfo = await deviceInfoPlugin.iosInfo;
      final userAgent = '${iosInfo.systemName} ${iosInfo.systemVersion}, ${iosInfo.name} ${iosInfo.model}';
      return userAgent;
    }
    return "" ;
  } on PlatformException {
    printFunction("getUserAgent", 'Failed to get platform version.');
    return "";
  }
}

//package_info_plus: ^3.0.1
Future<String> getAppId() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.packageName;
}

Future<String> getAppName() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.appName;
}

void openDatePicker(BuildContext context,
    {DateTime? initialDate, DateTime? firstDate, DateTime? lastDate, Function(DateTime)? onPicked, DatePickerEntryMode? initialEntryMode}) async {
  final DateTime? picked = await showDatePicker(
    context: context,
    locale: LanguageUtil.getCurrentLocal(),
    initialEntryMode: initialEntryMode ?? DatePickerEntryMode.calendarOnly,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime.now(),
    lastDate: lastDate ?? DateTime.now().add(const Duration(days: 1000)),
    builder: (context, Widget? child) => Theme(
        data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
                primary: context.theme.focusColor, onPrimary: context.theme.scaffoldBackgroundColor, onSurface: context.theme.primaryColor),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: context.theme.primaryColor))),
        child: child!),
  );
  if (picked != null && onPicked != null) onPicked(picked);
}

Future<List> getDeviceIdentifier() async {
  final deviceInfo = DeviceInfoPlugin();
  String? deviceId;
  int deviceType = DevicePlatformType.web;
  if (Platform.isIOS) {
    deviceType = DevicePlatformType.ios;
    final iosDeviceInfo = await deviceInfo.iosInfo;
    deviceId = iosDeviceInfo.identifierForVendor;
  } else if (Platform.isAndroid) {
    deviceType = DevicePlatformType.android;
    final androidDeviceInfo = await deviceInfo.androidInfo;
    deviceId =
        "${androidDeviceInfo.id}_${androidDeviceInfo.brand}_${androidDeviceInfo.model}_${androidDeviceInfo.device}_${androidDeviceInfo.serialNumber}";
  }
  return [deviceId ?? "", deviceType];
}

bool isTextScaleGetterThanOne(BuildContext context) {
  return [
    const TextScaler.linear(1.1),
    const TextScaler.linear(1.2),
    const TextScaler.linear(1.3),
    const TextScaler.linear(1.4),
    const TextScaler.linear(1.5)
  ].contains(MediaQuery.of(context).textScaler);
}
