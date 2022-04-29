import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CopyrightInformations extends StatelessWidget {
  const CopyrightInformations({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: 100,
        color: Colors.grey,
        child: Container(
            margin: const EdgeInsetsDirectional.only(
                start: 10, top: 10, bottom: 10),
            width: MediaQuery.of(context).size.width - 150,
            child: RichText(
                text: TextSpan(
                    style: const TextStyle(color: Color.fromARGB(62, 0, 0, 0)),
                    children: [
                  const TextSpan(
                      text:
                          "This application is unofficial and is only intended to facilitate the life of these users by notifying them of the content present on JW.ORG. The code is completely open source and available "),
                  TextSpan(
                      text: "here",
                      style:
                          const TextStyle(decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = (() => launchUrlString(
                            "https://github.com/Teckinfor/JWNotifyer"))),
                  const TextSpan(
                      text:
                          ". In case of problems, please do not contact JW.ORG but inform your problem on "),
                  TextSpan(
                      text: "this page.",
                      style:
                          const TextStyle(decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = (() => launchUrlString(
                            "https://github.com/Teckinfor/JWNotifyer/issues")))
                ]))));
  }
}
