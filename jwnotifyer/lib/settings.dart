import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restart_app/restart_app.dart';
import 'copyright_informations.dart';
import 'dart:io';

class Settings extends StatefulWidget {
  final String intervalUsed;
  const Settings({Key? key, required this.intervalUsed}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<Settings> createState() => _SettingsState(intervalUsed: intervalUsed);
}

class _SettingsState extends State<Settings> {
  String intervalUsed;
  _SettingsState({required this.intervalUsed}) : super();

  ///////////////////////
  ////// INSTANCES //////
  ///////////////////////

  //Drop down menu
  List<DropdownMenuItem<String>> get checkInterval {
    List<DropdownMenuItem<String>> checkInterval = [
      const DropdownMenuItem(
          child: Text(
            "Fast (30min)",
            style: TextStyle(fontSize: 15),
          ),
          value: "Fast"),
      const DropdownMenuItem(
          child: Text(
            "Normal (1h)",
            style: TextStyle(fontSize: 15),
          ),
          value: "Normal"),
      const DropdownMenuItem(
          child: Text(
            "Slow (6h)",
            style: TextStyle(fontSize: 15),
          ),
          value: "Slow"),
      const DropdownMenuItem(
          child: Text(
            "Debug Mode",
            style: TextStyle(fontSize: 15),
          ),
          value: "Debug")
    ];
    return checkInterval;
  }

  ////////////////////////////
  ////// BUILD FUNCTION //////
  ////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 130, bottom: 40),
                child: const Text(
                  "Settings",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black),
                )),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              child: Column(children: [
                Row(
                  children: const [
                    Text("Check interval"),
                  ],
                ),
                Row(
                  children: const [
                    Text(
                      "The more regular the checks, the more the battery can be consumed",
                      style: TextStyle(fontSize: 10),
                    )
                  ],
                ),
                Row(
                  children: [
                    DropdownButton(
                        items: checkInterval,
                        value: intervalUsed,
                        onChanged: (String? newValue) {
                          setState(() {
                            intervalUsed = newValue!;
                          });
                        })
                  ],
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 40, bottom: 40),
                      child: StreamBuilder<Map<String, dynamic>?>(
                        stream: FlutterBackgroundService().on('state'),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text("Service state : Down");
                          } else {
                            return const Text("Service state : UP");
                          }
                        },
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 20, bottom: 150),
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          // Confirmation
                          showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                    builder: (context, setState) {
                                  return AlertDialog(
                                      title: const Text("WAIT !"),
                                      content: SingleChildScrollView(
                                          child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                            const Text(
                                                "Are you sure you want to delete all the settings files?"),
                                            Row(children: [
                                              FloatingActionButton.extended(
                                                onPressed: (() {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop('dialog');
                                                }),
                                                label: const Text("Cancel"),
                                              ),
                                              FloatingActionButton.extended(
                                                onPressed: (() {
                                                  deleteAllContent();
                                                }),
                                                label: const Text("Yes"),
                                              )
                                            ])
                                          ])));
                                });
                              });
                        },
                        backgroundColor: Colors.red,
                        icon: const Icon(Icons.delete),
                        label: const Text("DELETE ALL SETTINGS"),
                      ),
                    ),
                  ],
                )
              ]),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      // Button to homepage
                      Navigator.pop(context, intervalUsed);
                    },
                    backgroundColor: Colors.blueGrey,
                    icon: const Icon(Icons.save),
                    label: const Text("SAVE"),
                  ),
                ))
          ],
        ),
      ),
      bottomSheet: const CopyrightInformations(),
    );
  }

  void deleteAllContent() async {
    final directory = await getApplicationDocumentsDirectory();
    File('$directory/ActiveLanguages.json').delete();
    File('$directory/Settings.json').delete();
    File('$directory/AvailalbleLanguages.json').delete();
    Restart.restartApp();
  }
}
