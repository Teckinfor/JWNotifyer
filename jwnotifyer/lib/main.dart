import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:jwnotifyer/homepage.dart';
import 'store_data.dart';
import 'check_content.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'dart:async';
import 'package:path_provider_android/path_provider_android.dart';
import 'package:path_provider_ios/path_provider_ios.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:math';

void main() async {
  // Wait the service
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JWNotifyer',
      home: const HomePage(),
      theme: ThemeData(
        fontFamily: 'Oxygen',
        primaryColor: Colors.grey,
      ),
    );
  }
}

/// SERVICE FUNCTIONS
/// ONLY ANDROID, MUST DO IOS

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,

      //Must stay in background
      isForegroundMode: false, //Only true for debug
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,

      onForeground: onStart,

      // have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  service.startService();
  print("Service created");
}

bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');
  onStart(service);
  return true;
}

void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  //NotificationService2().init();

  if (Platform.isIOS) PathProviderIOS.registerWith();
  if (Platform.isAndroid) PathProviderAndroid.registerWith();

  // Languages added to the HomePage
  Map languageFields = {"status": "OK"};

  // All languages (true : not added to the HomePage)
  Map supportedLanguages = {};

  // Set "Normal" as default value of interval
  String intervalValue = "Normal";

  // /!\ MUST BE CHANGE TO 3600
  int interval = 1;

  // For periodic time change
  int savedInterval = 1;

  List tmpContext = await StoreData().getCurrentContext;

  if (tmpContext[0]["status"] == "ERROR" || tmpContext[0].isEmpty) {
    languageFields = {"status": "OK"};
    supportedLanguages = Fetcher().getLinks();
  } else {
    languageFields = tmpContext[0];
  }

  if (tmpContext[1]["status"] == "ERROR" || tmpContext[1].isEmpty) {
    intervalValue = "Normal";
    interval = 3600;
  } else {
    intervalValue = await tmpContext[1]["value"];
    interval = await tmpContext[1]["seconds"];
  }

  if (tmpContext[2]["status"] == "ERROR" || tmpContext[2].isEmpty) {
    languageFields = {"status": "OK"};
    supportedLanguages = Fetcher().getLinks();
  } else {
    supportedLanguages = tmpContext[2];
  }

  // ACTION
  await getContext(languageFields, supportedLanguages, intervalValue, interval,
      savedInterval);
  periodicTask(service, languageFields, supportedLanguages, intervalValue,
      interval, savedInterval);
}

// Fetching informations on JW.ORG
Future<void> checkContentEachLanguage(languageFields, supportedLanguages,
    intervalValue, interval, savedInterval) async {
  for (String language in languageFields.keys) {
    if (language == "status") {
      continue;
    }
    if (languageFields[language]["isEnabled"]) {
      Fetcher fetchLanguage = Fetcher(language: language);
      if (await fetchLanguage.main() ?? false) {
        final DateFormat format = DateFormat("yyyy-MM-dd HH:mm:ss");
        String datetime = format.format(DateTime.now());
        languageFields[language]["lastNotif"] = datetime;
      }
    }
  }
}

Future<void> getContext(languageFields, supportedLanguages, intervalValue,
    interval, savedInterval) async {
  List tmpContext = await StoreData().getCurrentContext;
  if (tmpContext[0]["status"] == "ERROR" || tmpContext[0].isEmpty) {
    languageFields = {"status": "OK"};
    supportedLanguages = Fetcher().getLinks();
  } else {
    languageFields = tmpContext[0];
  }

  if (tmpContext[1]["status"] == "ERROR" || tmpContext[1].isEmpty) {
    intervalValue = "Normal";
    interval = 3600;
  } else {
    intervalValue = await tmpContext[1]["value"];
    interval = await tmpContext[1]["seconds"];
  }

  if (tmpContext[2]["status"] == "ERROR" || tmpContext[2].isEmpty) {
    languageFields = {"status": "OK"};
    supportedLanguages = Fetcher().getLinks();
  } else {
    supportedLanguages = tmpContext[2];
  }
}

void periodicTask(service, languageFields, supportedLanguages, intervalValue,
    interval, savedInterval) {
  Timer.periodic(Duration(seconds: interval), (Timer t) async {
    // FOR DEBUGGING
    // if (service is AndroidServiceInstance) {
    //   service.setForegroundNotificationInfo(
    //     title: "JWNotifyer",
    //     content:
    //         "Updated at ${DateTime.now()} with interval of $interval seconds",
    //   );
    // }

    List tmpContext = await StoreData().getCurrentContext;

    if (tmpContext[0]["status"] == "ERROR" || tmpContext[0].isEmpty) {
      languageFields = {"status": "OK"};
      supportedLanguages = Fetcher().getLinks();
    } else {
      languageFields = tmpContext[0];
    }

    if (tmpContext[1]["status"] == "ERROR" || tmpContext[1].isEmpty) {
      intervalValue = "Normal";
      interval = 3600;
    } else {
      intervalValue = await tmpContext[1]["value"];
      interval = await tmpContext[1]["seconds"];
    }

    if (tmpContext[2]["status"] == "ERROR" || tmpContext[2].isEmpty) {
      languageFields = {"status": "OK"};
      supportedLanguages = Fetcher().getLinks();
    } else {
      supportedLanguages = tmpContext[2];
    }

    await getContext(languageFields, supportedLanguages, intervalValue,
        interval, savedInterval);
    await checkContentEachLanguage(languageFields, supportedLanguages,
        intervalValue, interval, savedInterval);
    StoreData().saveActiveLanguages(languageFields);
    print("current timer : $interval");
    if (savedInterval != interval) {
      print("another timer");
      savedInterval = interval;
      t.cancel();
      periodicTask(service, languageFields, supportedLanguages, intervalValue,
          interval, savedInterval);
    }
  });
}

class NotificationService2 {
  static final NotificationService2 _notificationService =
      NotificationService2._internal();

  factory NotificationService2() {
    return _notificationService;
  }

  NotificationService2._internal();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
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
        const AndroidNotificationDetails(
      'Notification by language', 'Notification by language',
      channelDescription: "Notification from JWNotifyer",
      importance: Importance.high,
      priority: Priority.high,
      //largeIcon: FilePathAndroidBitmap(article["img"])
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
        "Service is running", "", platformChannelSpecifics,
        payload: (""));
  }

  void selectNotification(String? payload) async {}
}
