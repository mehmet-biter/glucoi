import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:tradexpro_flutter/firebase_options.dart';

import 'notification_util.dart';

class FirebaseMessagingUtil {
  FirebaseMessagingUtil._internal();

  static final FirebaseMessagingUtil _instance = FirebaseMessagingUtil._internal();

  static FirebaseMessagingUtil on() => _instance;

  Future<void> initFirebasePlugin() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
      debugPrint('FirebaseMessaging onMessage ${message?.toMap()}');
      if (message != null) showFlutterNotification(message);
    });

    if (!kIsWeb) await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(alert: true, badge: true, sound: true);

    // debugPrint('FirebaseMessaging getToken ${await FirebaseMessaging.instance.getToken()}');
    // FirebaseMessaging.instance.onTokenRefresh.listen((event) {
    //   debugPrint('FirebaseMessaging onTokenRefresh $event');
    //   FirebaseMessagingUtil.on().updateFirebaseToken(event);
    // });

    //print("FirebaseMessaging ${await FirebaseMessaging.instance.getToken()}");
    // await FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    //   print('FirebaseMessaging getInitialMessage $message');
    //   if (message != null) showFlutterNotification(message);
    // });

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   print('FirebaseMessaging onMessageOpenedApp $message');
    // });
  }

  void setUpCrashlytics() {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  Future<String?> getFCMToken() async => await FirebaseMessaging.instance.getToken();

  void showFlutterNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      NotificationUtil.on().showNotification(notification.title ?? '', notification.body ?? '', id: message.hashCode, imagePath: android.imageUrl);
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FirebaseMessaging backgroundMessage ${message.messageId}');
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // NotificationUtil.on().configLocalNotification();
  // FirebaseMessagingUtil.on().showFlutterNotification(message);
}
