import 'package:flutter_background_service/flutter_background_service.dart';
import 'check_content.dart';

import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

abstract class Service {
  Service() {
    initializeService();
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
        iosConfiguration: IosConfiguration(
            // auto start service
            autoStart: true,

            // this will executed when app is in foreground in separated isolate
            onForeground: onStart,

            // you have to enable background fetch capability on xcode project
            onBackground: onIosBackground),

        androidConfiguration: AndroidConfiguration(
            // auto start service
            autoStart: true,

            // this will executed when app is in foreground or background in separated isolate
            onStart: onStart,
            isForegroundMode: true));
  }

  // to ensure this executed
  // run app from xcode, then from xcode menu, select Simulate Background Fetch
  bool onIosBackground(ServiceInstance service) {
    WidgetsFlutterBinding.ensureInitialized();
    print('FLUTTER BACKGROUND FETCH');
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

    // bring to foreground
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: "JWNotifyerService",
          content: "Updated at ${DateTime.now()}",
        );
      }

      /// you can see this log in logcat
      print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

      // test using external plugin
      final deviceInfo = DeviceInfoPlugin();
      String? device;
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        device = androidInfo.model;
      }

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        device = iosInfo.model;
      }

      service.invoke(
        'update',
        {
          "current_date": DateTime.now().toIso8601String(),
          "device": device,
        },
      );
    });
  }

  // Make a loop to fetch all valid language
  void checkContent() {
    Fetcher(language: "English");
  }
}
