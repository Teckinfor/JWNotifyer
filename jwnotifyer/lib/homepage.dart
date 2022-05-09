// ignore_for_file: sized_box_for_whitespace

import 'dart:async';
import 'dart:collection';
import 'package:jwnotifyer/check_content.dart';
import 'settings.dart';
import 'package:flutter/material.dart';
import 'check_content.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ///////////////////////
  ////// INSTANCES //////
  ///////////////////////

  // Languages added to the HomePage
  Map languageFields = {};

  // All languages (true : not added to the HomePage)
  Map supportedLanguages = Fetcher().getLinks();

  // Set a timer
  Timer? timer;

  // Set "Normal" as default value of interval
  String intervalValue = "Normal";

  /////////////////////////////
  ////// State functions //////
  /////////////////////////////

  @override
  void initState() {
    super.initState();

    int interval = 3600;
    switch (intervalValue) {
      case "Slow":
        {
          interval = 21600; // 6 hours
          break;
        }
      case "Fast":
        {
          interval = 1800; // 30 minutes
          break;
        }
      default:
        interval = 3600; // 1 hour
        break;
    }

    // Auto check (must be modified)
    timer = Timer.periodic(Duration(seconds: interval),
        (Timer t) => checkContentEachLanguage(languageFields: languageFields));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  ///////////////////////
  ////// FUNCTIONS //////
  ///////////////////////

  // Fetching informations on JW.ORG
  void checkContentEachLanguage({required Map languageFields}) {
    for (String language in languageFields.keys) {
      if (languageFields[language]["isEnabled"]) {
        print("CURRENTLY CHECKING FOR $language with $intervalValue interval");
        //languageFields[language]["lastNotif"] = Fetcher(language: language).notif ?? languageFields[language]["lastNotif"];
      }
    }
  }

  // Display the time since the last received notification
  Container lastNotificationInformation(
      {required String language, required Map languageFields}) {
    String text = "";
    if (languageFields[language]["lastNotif"] != null) {
      num second = ((DateTime.now().millisecondsSinceEpoch / 1000).round() -
          (languageFields[language]["lastNotif"].millisecondsSinceEpoch / 1000)
              .round()) as int;
      if (second > 31536000) {
        int years = (second / 31536000).round();
        text = (years == 1) ? "$years year ago" : "$years years ago";
      } else if (second > 86400) {
        int days = (second / 86400).round();
        text = (days == 1) ? "$days day ago" : "$days days ago";
      } else if (second > 3600) {
        int hours = (second / 3600).round();
        text = (hours == 1) ? "$hours hour ago" : "$hours hours ago";
      } else if (second > 60) {
        int minutes = (second / 60).round();
        text = (minutes == 1) ? "$minutes minute ago" : "$minutes minutes ago";
      } else {
        text = (second == 1) ? "$second second ago" : "$second seconds ago";
      }

      return Container(
        margin: const EdgeInsets.only(left: 15),
        alignment: Alignment.bottomLeft,
        child: Row(children: [
          const Text(
            "Last notification: ",
            style: TextStyle(fontSize: 10),
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 10),
          )
        ]),
      );
    }

    return Container();
  }

  // Display all languages available in "Add language" option
  List<Container> allLanguageList(
      {required Map supportedLanguages, required Map languageFields}) {
    List<Container> tempList = [];
    SplayTreeMap<String, bool> st = SplayTreeMap<String, bool>();
    supportedLanguages.forEach((key, value) {
      st[key] = value;
    });
    for (String language in st.keys) {
      if (supportedLanguages[language]) {
        tempList.add(Container(
            height: 65,
            child: Column(
              children: [
                const Divider(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(language),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            languageFields[language] = {
                              "isEnabled": false,
                              "infoMessage": "Disabled",
                              "lastNotif": null
                            };
                            supportedLanguages[language] =
                                supportedLanguages[language] ? false : true;
                          });
                        },
                        child: const Icon(Icons.add),
                      )
                    ]),
              ],
            )));
      }
    }
    return tempList;
  }

  // Display all languages added to the HomePage
  List<Container> listActiveLanguages(
      {required Map languageFields, required Map supportedLanguages}) {
    List<Container> tempList = [];
    for (String language in languageFields.keys) {
      tempList.add(Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
        height: 95,
        child: Column(children: [
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          languageFields.remove(language);
                          supportedLanguages[language] =
                              supportedLanguages[language] ? false : true;
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.blueGrey,
                      )),
                  Text(
                    language,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  )
                ],
              ),
              Switch(
                  value: languageFields[language]['isEnabled'],
                  onChanged: (newValue) {
                    setState(() {
                      //////////////////////////////////////////////////////////////// DEBUG FUNCTION
                      //////////////////////////////////////////////////////////////// Used to detect the device language for a future feature
                      //final List<Locale> locales =
                      //    WidgetsBinding.instance!.window.locales;
                      //print(locales);
                      //////////////////////////////////////////////////////////////// DEBUG FUNCTION
                      languageFields[language]['isEnabled'] = newValue;
                      languageFields[language]['infoMessage'] =
                          (newValue) ? "Enabled" : "Disabled";
                    });
                  })
            ],
          ),
          Container(
            //margin: EdgeInsets.only(bottom: 10),
            alignment: Alignment.centerRight,
            child: Text(
              languageFields[language]["infoMessage"],
              textAlign: TextAlign.right,
            ),
          ),
          lastNotificationInformation(
              language: language, languageFields: languageFields)
        ]),
      ));
    }

    tempList.add(Container(
        height: 100,
        child: TextButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                      title: const Text("Languages"),
                      content: SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: allLanguageList(
                                  supportedLanguages: supportedLanguages,
                                  languageFields: languageFields))));
                });
          },
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all(Colors.blueGrey),
              overlayColor: MaterialStateProperty.all(
                  const Color.fromARGB(62, 96, 125, 139)),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)))),
          child: Container(
              margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
              child: Column(
                children: [
                  const Divider(),
                  Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                        Text("Add a language ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blueGrey)),
                        Icon(
                          Icons.add,
                          color: Colors.blueGrey,
                        )
                      ])),
                ],
              )),
        )));
    return tempList;
  }

  ////////////////////////////
  ////// BUILD FONCTION //////
  ////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.settings),
          label: const Text("Settings"),
          backgroundColor: Colors.blueGrey,
          onPressed: () async {
            intervalValue = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Settings(intervalUsed: intervalValue)),
            );
          }),
      body: Container(
        color: Colors.grey,
        child: Center(
            child: Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: const Text(
              "JW Notifyer",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ),
          const Text("Manage JW.ORG notifications by language"),
          Container(
              height: MediaQuery.of(context).size.height - 250,
              margin: const EdgeInsets.only(
                  left: 25, right: 25, top: 30, bottom: 50),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 177, 176, 176),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  border: Border.all(color: Colors.black)),
              child: SingleChildScrollView(
                child: Column(
                    children: listActiveLanguages(
                        languageFields: languageFields,
                        supportedLanguages: supportedLanguages)),
              )),
        ])),
      ),
    );
  }
}
