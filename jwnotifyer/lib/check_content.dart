import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class Fetcher {
  String _initial = "NN";

  List newContentToNotify = [];

  DateTime? notif;

  // Continue listing
  final Map<String, String> _link = {
    "Français": "FR",
    "Español": "ES",
    "English": "EN",
    "Italiano": "IT",
    "Nederlands": "ND"
  };

  set setInitial(String newInitial) {
    _initial = newInitial;
  }

  Fetcher({String language = "None"}) {
    _initial = _link[language] ?? "NN";
    ((language == "None") ? null : fetchElements());
  }

  Map<String, bool> getLinks() {
    Map<String, bool> supportedLanguages = {};
    _link.forEach((key, value) {
      supportedLanguages[key] = true;
    });
    return supportedLanguages;
  }

  void fetchElements() async {
    Map newContent = getNewElement() ?? {"status": "ERROR"};
    notif = (await thereIsNewContent(newContent) ? makeNotification() : null);
  }

  /*

  {
    "initial":"EN",
    "status":"OK"
    "content":[
      {
        "title":"MyTitle",
        "img":"UrlToImage",
        "url":"UrlToPage"
      },{
        "title":"MyTitle",
        "img":"UrlToImage",
        "url":"UrlToPage"
      },{
        "title":"MyTitle",
        "img":"UrlToImage",
        "url":"UrlToPage"
      },{
        "title":"MyTitle",
        "img":"UrlToImage",
        "url":"UrlToPage"
      },{
        "title":"MyTitle",
        "img":"UrlToImage",
        "url":"UrlToPage"
      }
    ]
  }

  */

  Map? getNewElement() {
    if (_initial != "NN") {
      Map test = {
        "initial": "EN",
        "status": "OK",
        "content": [
          {"title": "MyTitle", "img": "UrlToImage", "url": "UrlToPage"},
          {"title": "MyTitle", "img": "UrlToImage", "url": "UrlToPage"},
          {"title": "MyTitle", "img": "UrlToImage", "url": "UrlToPage"},
          {"title": "MyTitle", "img": "UrlToImage", "url": "UrlToPage"},
          {"title": "MyTitle", "img": "UrlToImage", "url": "UrlToPage"}
        ]
      };
      return test;
    }
    return null;
  }

  Future<bool> thereIsNewContent(newContent) async {
    Map existingContent = await readData();

    if (existingContent["status"] == "ERROR") {
      writeData(data: newContent);
      return false;
    }

    if (newContent["status"] == "ERROR") {
      return false;
    }

    for (Map article in newContent["content"]) {
      bool isIn = false;

      for (Map existingArticle in existingContent["content"]) {
        if (article["title"] == existingArticle["title"]) {
          isIn = true;
        }
      }

      (isIn) ? "" : newContentToNotify.add(article);
    }

    writeData(data: newContent);

    return true;
  }

  DateTime? makeNotification() {
    if (newContentToNotify.isEmpty) {
      return null;
    }

    print("Notification");

    for (Map article in newContentToNotify) {
      //NotificationService().init(article);
    }
    return DateTime.now();
  }

  /*
  DATA STORING
  */

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/lastData_$_initial.json');
  }

  Future<File> writeData({required Map data}) async {
    final file = await _localFile;
    var jsonText = jsonEncode(data);
    // Write the file
    return file.writeAsString(jsonText);
  }

  Future<Map> readData() async {
    try {
      final file = await _localFile;
      final data = await file.readAsString();
      return jsonDecode(data) as Map;
    } catch (e) {
      return {"status": "ERROR"} as Map;
    }
  }
}
