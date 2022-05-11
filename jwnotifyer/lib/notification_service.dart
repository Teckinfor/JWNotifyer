import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher_string.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init(Map article) async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // final IOSInitializationSettings initializationSettingsIOS =
    //     IOSInitializationSettings(
    //   requestSoundPermission: false,
    //   requestBadgePermission: false,
    //   requestAlertPermission: false,
    //   onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    // );

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            //iOS: initializationSettingsIOS,
            macOS: null);

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(article["title"], article["title"],
            channelDescription: "Notification from JWNotifyer",
            importance: Importance.high,
            priority: Priority.high,
            largeIcon: FilePathAndroidBitmap(article["img"])
            );

    const IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);

    await flutterLocalNotificationsPlugin.show(Random().nextInt(110000),
        article["title"], "Click here to open", platformChannelSpecifics,
        payload: jsonEncode({"url":article["url"], "img":article["img"]}));
  }

  void selectNotification(String? payload) async {
    Map jsonDecoded = jsonDecode(payload??'''{}''');
    await launchUrlString(jsonDecoded["url"] ?? "https://jw.org");
    File(jsonDecoded["img"]).delete();
  }
}
