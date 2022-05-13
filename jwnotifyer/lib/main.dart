import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:jwnotifyer/homepage.dart';
import 'store_data.dart';
import 'check_content.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'dart:async';

void main() async {
  // Wait the service
  WidgetsFlutterBinding.ensureInitialized();
  //await initializeService();
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
      isForegroundMode: true, //Only true for debug
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

  // Languages added to the HomePage
  Map languageFields = {"status": "OK"};

  // All languages (true : not added to the HomePage)
  Map supportedLanguages = {};

  // Set "Normal" as default value of interval
  String intervalValue = "Normal";

  // /!\ MUST BE CHANGE TO 3600
  int interval = 1;

  // For periodic time change
  int savedInterval = 3600;

  // ACTION
  //await getContext(languageFields, supportedLanguages, intervalValue, interval,
  //    savedInterval);
  periodicTask(service, languageFields, supportedLanguages, intervalValue,
      interval, savedInterval);

  service.invoke(
    'state',
    {
      'status': 'OK',
    },
  );
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
        languageFields[language]["lastNotif"] = DateTime.now();
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
    //print("test :" + tmpContext[1]);
  } else {
    intervalValue = tmpContext[1]["value"];
    interval = tmpContext[1]["seconds"];
    print("bien");
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
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "JWNotifyer",
        content:
            "Updated at ${DateTime.now()} with interval of $interval seconds",
      );
    }
    print(0);
    await getContext(languageFields, supportedLanguages, intervalValue,
        interval, savedInterval);
    print(1);
    await checkContentEachLanguage(languageFields, supportedLanguages,
        intervalValue, interval, savedInterval);

    print(2);
    StoreData().saveActiveLanguages(languageFields);
    print(3);
    if (savedInterval != interval) {
      savedInterval = interval;
      t.cancel();
      periodicTask(service, languageFields, supportedLanguages, intervalValue,
          interval, savedInterval);
    }
  });
}
