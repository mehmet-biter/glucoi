import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tradexpro_flutter/data/remote/socket_provider.dart';
import 'package:tradexpro_flutter/utils/common_utils.dart';
import 'package:tradexpro_flutter/utils/extentions.dart';
import 'package:tradexpro_flutter/utils/firebase_messaging_util.dart';
import 'package:tradexpro_flutter/utils/language_util.dart';
import 'package:tradexpro_flutter/utils/notification_util.dart';
import 'package:tradexpro_flutter/utils/theme.dart';
import 'data/local/constants.dart';
import 'data/local/strings.dart';
import 'data/remote/api_provider.dart';
import 'helper/app_helper.dart';
import 'ui/features/splash/splash_page.dart';

void main() async {
  await dotenv.load(fileName: EnvKeyValue.kEnvFile);
  await GetStorage.init();
  await _setDefaultValues();
  WidgetsFlutterBinding.ensureInitialized();
  gIsDarkMode = ThemeService().loadThemeFromBox();
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: gIsDarkMode ? Brightness.light : Brightness.dark));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((value) => runApp(const MyApp()));
  Get.put(APIProvider());
  Get.put(SocketProvider());
  initBuySellColor();
  FirebaseMessagingUtil.on().initFirebasePlugin();
  FirebaseMessagingUtil.on().setUpCrashlytics();
  NotificationUtil.on().configLocalNotification();
}

Future<void> _setDefaultValues() async {
  GetStorage().writeIfNull(PreferenceKey.isDark, systemThemIsDark());
  GetStorage().writeIfNull(PreferenceKey.isLoggedIn, false);
  GetStorage().writeIfNull(PreferenceKey.isOnBoardingDone, false);
  GetStorage().writeIfNull(PreferenceKey.languageKey, LanguageUtil.defaultLangKey);
  GetStorage().writeIfNull(PreferenceKey.buySellColorIndex, 0);
  GetStorage().writeIfNull(PreferenceKey.buySellUpDown, 0);
  GetStorage().writeIfNull(PreferenceKey.isKycVerified, false);

  final stKey = dotenv.env[EnvKeyValue.kStripKey];
  if (stKey.isValid) {
    Stripe.publishableKey = stKey!;
    await Stripe.instance.applySettings();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: LanguageUtil.getTextDirection(),
      child: GetMaterialApp(
        title: "kAppName".tr,
        debugShowCheckedModeBanner: false,
        defaultTransition: Transition.rightToLeftWithFade,
        theme: Themes.light,
        darkTheme: Themes.dark,
        themeMode: ThemeService().theme,
        translations: Strings(),
        locale: LanguageUtil.getCurrentLocal(),
        fallbackLocale: LanguageUtil.locales.first.local,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          CountryLocalizations.delegate,
        ],
        initialRoute: "/",
        builder: (context, child) {
          final scale = MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
            child: child!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}
