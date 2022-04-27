import 'dart:collection';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Map languageFields = {
    "English": {
      "isEnabled": true,
      "infoMessage": "Disabled",
      "lastNotif": DateTime.now()
    },
  };

  Map supportedLanguages = {
    'English': false,
    'Français': true,
    'Español': true,
    'Dutch': true,
    'German': true,
    'Italiano': true
  };

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
        alignment: Alignment.bottomLeft,
        child: Row(children: [
          const Text(
            "Last notification: ",
            style: const TextStyle(fontSize: 10),
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
            height: 50,
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

  List<Container> listActiveLanguages(
      {required Map languageFields, required Map supportedLanguages}) {
    List<Container> tempList = [];
    for (String language in languageFields.keys) {
      tempList.add(Container(
        margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
        height: 100,
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
                        color: Colors.red,
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
                      final List<Locale> locales =
                          WidgetsBinding.instance!.window.locales;
                      print(locales);
                      //////////////////////////////////////////////////////////////// DEBUG FUNCTION
                      languageFields[language]['isEnabled'] = newValue;
                      languageFields[language]['infoMessage'] =
                          (newValue) ? "Enabled" : "Disabled";
                    });
                  })
            ],
          ),
          Container(
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





















  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.settings),
            backgroundColor: Colors.blueGrey ,
            onPressed: (){
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
                  left: 75, right: 75, top: 30, bottom: 50),
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
