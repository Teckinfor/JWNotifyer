// ignore_for_file: sized_box_for_whitespace

import 'dart:async';
import 'dart:collection';
import 'package:jwnotifyer/check_content.dart';
import 'package:flutter/material.dart';
import 'settings.dart';
import 'store_data.dart';

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
  Map languageFields = {"status": "OK"};

  // All languages (true : not added to the HomePage)
  Map supportedLanguages = {};

  //Check if getContext is run for the first time
  bool havingContent = false;

  // Set a timer
  Timer? timer;

  // Set "Normal" as default value of interval
  String intervalValue = "Normal";

  // /!\ MUST BE CHANGE TO 3600
  int interval = 10;

  /////////////////////////////
  ///// Storage functions /////
  /////////////////////////////

  void getContext() async {
    List tmpContext = await StoreData().getCurrentContext;
    setState(() {
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
        intervalValue = tmpContext[1]["value"];
        interval = tmpContext[1]["seconds"];
      }

      if (tmpContext[2]["status"] == "ERROR" || tmpContext[2].isEmpty) {
        languageFields = {"status": "OK"};
        supportedLanguages = Fetcher().getLinks();
      } else {
        supportedLanguages = tmpContext[2];
      }
    });
  }

  void saveContext() {
    StoreData().saveCurrentContext(
        dataActiveLanguages: languageFields,
        dataSettings: {
          "value": intervalValue,
          "seconds": interval,
          "status": "OK"
        },
        dataAvailableLanguages: supportedLanguages);
  }

  /////////////////////////////
  ////// State functions //////
  /////////////////////////////

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  ///////////////////////
  ////// FUNCTIONS //////
  ///////////////////////

  // Display the time since the last received notification
  Container lastNotificationInformation(
      {required String language, required Map languageFields}) {
    String text = "";
    if (languageFields[language]["lastNotif"] != null) {
      DateTime realDateTime =
          DateTime.parse(languageFields[language]["lastNotif"]);
      num second = ((DateTime.now().millisecondsSinceEpoch / 1000).round() -
          (realDateTime.millisecondsSinceEpoch / 1000).round()) as int;
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
  List<Container> allLanguageList() {
    List<Container> tempList = [];
    SplayTreeMap<String, dynamic> st = SplayTreeMap<String, dynamic>();
    supportedLanguages.forEach((key, value) {
      st[key] = value;
    });
    for (String language in st.keys) {
      if (language == "status") {
        continue;
      }
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
                              "lastNotif": null,
                            };
                            supportedLanguages[language] =
                                supportedLanguages[language] ? false : true;
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                            saveContext();
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
  List<Container> listActiveLanguages() {
    List<Container> tempList = [];
    for (String language in languageFields.keys) {
      if (language == "status") {
        continue;
      }
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
                          saveContext();
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
                      languageFields[language]['isEnabled'] = newValue;
                      languageFields[language]['infoMessage'] =
                          (newValue) ? "Enabled" : "Disabled";
                      saveContext();
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
                builder: (context) {
                  return StatefulBuilder(builder: (context, setState) {
                    return AlertDialog(
                        title: const Text("Languages"),
                        content: SingleChildScrollView(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: allLanguageList())));
                  });
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
    if (!havingContent) {
      getContext();
      havingContent = true;
    }

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
              case "Debug":
                {
                  interval = 10; // 10 secondes
                  break;
                }
              default:
                interval = 3600; // 1 hour
                break;
            }

            saveContext();
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
                child: Column(children: listActiveLanguages()),
              )),
        ])),
      ),
    );
  }
}
