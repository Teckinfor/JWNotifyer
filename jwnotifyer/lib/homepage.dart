import 'dart:html';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Map languageFields = {
    "English": {"isEnabled":false,"infoMessage":"Disabled"},
    "Français": {"isEnabled":false,"infoMessage":"Disabled"},
    "Español": {"isEnabled":false,"infoMessage":"Disabled"},
    "Chinese": {"isEnabled":false,"infoMessage":"Disabled"},
    "Dutch": {"isEnabled":false,"infoMessage":"Disabled"},
    "German": {"isEnabled":false,"infoMessage":"Disabled"}
  };

  List<Container> listActiveLanguages({required Map languageFields}) {
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
                      languageFields[language]['isEnabled'] = newValue;
                      languageFields[language]['infoMessage'] = (newValue) ? "Enabled" : "Disabled";
                    });
                  })
            ],
          ),
          
              Container(
                alignment: Alignment.centerRight,
                child: Text(languageFields[language]["infoMessage"], textAlign: TextAlign.right,),
              ),
            
          
        ]),
      ));
    }

    tempList.add(Container(
        height: 100,
        child: TextButton(
          onPressed: () {
            setState(() {});
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
                      children:
                          listActiveLanguages(languageFields: languageFields)),
              ))
        ])),
      ),
    );
  }
}
