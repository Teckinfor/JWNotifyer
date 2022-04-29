import 'package:flutter/material.dart';

class settings extends StatefulWidget {
  String intervalUsed;
  settings({Key? key, required this.intervalUsed}) : super(key: key);

  @override
  State<settings> createState() => _settingsState(intervalUsed: intervalUsed);
}

class _settingsState extends State<settings> {
  String intervalUsed;
  _settingsState({required this.intervalUsed}) : super();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
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
