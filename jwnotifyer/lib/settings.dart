import 'package:flutter/material.dart';

class settings extends StatefulWidget {
  const settings({Key? key}) : super(key: key);

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
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
                    margin: EdgeInsets.only(top: 130, bottom: 40),
                    child: const Text(
                      "Settings",
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.black),
                    )),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Column(children: [
                    Row(
                      children: [
                        const Text("Check interval"),
                        //DropdownButton(items: , onChanged: (newValue){})
                      ],
                    ),
                    Row(
                      children: const [
                        Text(
                          "The more regular the checks, the more the battery can be consumed",
                          style: TextStyle(fontSize: 10),
                        )
                      ],
                    )
                  ]),
                )
              ],
            )));
  }
}
