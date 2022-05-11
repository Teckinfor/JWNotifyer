import 'store_data.dart';
import 'check_content.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// ONLY ANDROID, MUST DO IOS

class FetcherService {

  // Languages added to the HomePage
  Map languageFields = {"status":"OK"};

  // All languages (true : not added to the HomePage)
  Map supportedLanguages = {};

  // Set a timer
  Timer? timer;

  // Set "Normal" as default value of interval
  String intervalValue = "Normal";

  // /!\ MUST BE CHANGE TO 3600
  int interval = 3600;

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: false,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,

        onForeground: onStart,

        // have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
    service.startService();
  }

  bool onIosBackground(ServiceInstance service) {
    WidgetsFlutterBinding.ensureInitialized();
    print('FLUTTER BACKGROUND FETCH');
    onStart(service);
    return true;
  }

  void onStart(ServiceInstance service) {
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

    // ACTION
    timer = Timer.periodic(Duration(seconds: interval), (Timer t) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "JWNotifyer",
          content:
              "Updated at ${DateTime.now()} with interval of $interval seconds",
        );
      }

      getContext();

      checkContentEachLanguage(languageFields: languageFields);

      StoreData().saveActiveLanguages(languageFields);

    });


    service.invoke(
      'state',
      {
        'status':'OK',
      },
    );
  }
  
  // Fetching informations on JW.ORG
  void checkContentEachLanguage({required Map languageFields}) async {
    for (String language in languageFields.keys) {
      if (languageFields[language]["isEnabled"]) {
        Fetcher fetchLanguage = Fetcher(language: language);
        if (await fetchLanguage.main() ?? false) {
          languageFields[language]["lastNotif"] = DateTime.now();
        }
      }
    }
  }

  Future<int> getContext() async {
    List tmpContext = await StoreData().getCurrentContext;

    if (tmpContext[0]["status"] == "ERROR") {
      languageFields = {"status": "OK"};
      supportedLanguages = Fetcher().getLinks();
      return 1;
    } else {
      languageFields = tmpContext[0];
    }

    if (tmpContext[1]["status"] == "ERROR") {
      intervalValue = "Normal";
      interval = 3600;
    } else {
      intervalValue = tmpContext[1]["value"];
      interval = tmpContext[1]["seconds"];
    }

    if (tmpContext[2]["status"] == "ERROR") {
      languageFields = {"status": "OK"};
      supportedLanguages = Fetcher().getLinks();
      return 1;
    } else {
      supportedLanguages = tmpContext[2];
    }

    return 0;
  }
}
