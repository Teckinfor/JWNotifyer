import 'package:flutter/material.dart';

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
          value: "Slow")
    ];
    return checkInterval;
  }



  ////////////////////////////
  ////// BUILD FUNCTION //////
  ////////////////////////////



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () { // Button to homepage
            Navigator.pop(context, intervalUsed);
          },
          backgroundColor: Colors.blueGrey,
          icon: const Icon(Icons.save),
          label: const Text("SAVE"),
        ),
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
                  ]),
                )
              ],
            )));
  }
}
