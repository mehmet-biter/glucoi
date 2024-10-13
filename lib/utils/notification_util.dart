import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

/* ## Sample format
    {
        "notification": {
            "title": "Title goes here...",
            "body": "Body goes here..."
        },
        "data": {
            "title": "Title goes here...",
            "body": "Body goes here...",
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "is_background": "true",
            "content_available": "true"
        }}
  */

class NotificationUtil {
  NotificationUtil._internal();

  FlutterLocalNotificationsPlugin? _plugin;

  static final NotificationUtil _instance = NotificationUtil._internal();

  static NotificationUtil on() => _instance;

  void configLocalNotification() {
    _plugin ??= FlutterLocalNotificationsPlugin();
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false);
    const initializationSettings = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_notification'), iOS: iosSettings);
    _plugin?.initialize(initializationSettings);
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _plugin?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidImplementation?.requestNotificationsPermission();
      debugPrint('LocalNotificationUtil granted $granted');
    } else if (Platform.isIOS) {
      final iosImplementation = _plugin?.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosImplementation?.requestPermissions(alert: true, badge: true, sound: true);
      debugPrint('LocalNotificationUtil granted $granted');
    }
  }

  Future<void> showNotification(String title, String body, {String? imagePath, int? id}) async {
    if (title.isEmpty && body.isEmpty) return;

    if (Platform.isAndroid) {
      BigPictureStyleInformation? bigPictureStyleInformation;
      if (imagePath != null && imagePath.isNotEmpty) {
        final response = await http.get(Uri.parse(imagePath));
        bigPictureStyleInformation = BigPictureStyleInformation(
          ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes)),
        );
      }

      final androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'default_channel_id',
        'default_channel_name',
        channelDescription: 'default_channel_description',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigPictureStyleInformation,
      );

      final platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: const DarwinNotificationDetails());
      await _plugin?.show(id ?? body.hashCode, title, body, platformChannelSpecifics);
    }
  }
}
