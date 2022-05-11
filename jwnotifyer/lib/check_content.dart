import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'notification_service.dart';
import 'package:requests/requests.dart';
import 'package:html/parser.dart' show parse;
import 'package:image_downloader/image_downloader.dart';

class Fetcher {
  String _initial = "NN";

  List newContentToNotify = [];

  bool isNotif = false;

  // Continue listing
  final Map<String, String> _link = {
    "Français": "FR",
    "Español": "ES",
    "English": "EN",
    "Italiano": "IT",
    "Nederlands": "NL",
    "Deutsch": "DE",
    "Svenska": "SV",
    "Norsk": "NO",
    "Grec": "EL",
    "Russian": "RU",
  };

  set setInitial(String newInitial) {
    _initial = newInitial;
  }

  Fetcher({String language = "None"}) {
    _initial = _link[language] ?? "NN";
  }

  Future<bool?> main() async {
    if (_initial != "NN") {
      isNotif = await fetchElements() ?? false;
      return isNotif;
    }
    return isNotif;
  }

  Map<String, dynamic> getLinks() {
    Map<String, dynamic> supportedLanguages = {"status": "OK"};
    _link.forEach((key, value) {
      supportedLanguages[key] = true;
    });
    return supportedLanguages;
  }

  Future<bool?> fetchElements() async {
    Map newContent = await getNewElement() ?? {"status": "ERROR"};
    bool isNew = await thereIsNewContent(newContent);

    if (isNew) {
      makeNotification();
    }
    return isNew;
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

  Future<Map?> getNewElement() async {
    if (_initial != "NN") {
      Map document = {"initial": _initial, "status": "OK", "content": []};
      String initialLowercase = _initial.toLowerCase();

      var homeRequest =
          await Requests.get("https://www.jw.org/$initialLowercase");
      homeRequest.raiseForStatus();
      var home = parse(homeRequest.content());

      String whatsNewURI = home
          .getElementsByClassName("whatsNewButton")[0]
          .attributes["href"]
          .toString();

      var whatsNewRequest =
          await Requests.get("https://www.jw.org/$whatsNewURI");
      homeRequest.raiseForStatus();
      var whatsNew = parse(whatsNewRequest.content());
      var newContentBox = whatsNew.getElementsByClassName("whatsNewItems")[0];

      for (int i = 0; i < 5; i++) {
        Map article = {};
        var content = (newContentBox.getElementsByClassName("synopsis")[i]);
        article["title"] =
            parse(content.children[1].children[2].children[0].text)
                .documentElement!
                .text;

        var imageID = await ImageDownloader.downloadImage(content
            .children[0].children[0].children[0].attributes["data-img-size-md"]
            .toString());
        article["img"] = await ImageDownloader.findPath(imageID);

        article["url"] = "https://jw.org" +
            content.children[0].children[0].attributes["href"].toString();
        print(article);
        document["content"].add(article);
      }

      return document;
    }
    return null;
  }

  Future<bool> thereIsNewContent(newContent) async {
    Map existingContent = await readData();
    // Map existingContent = {
    //   "initial": "EN",
    //   "status": "OK",
    //   "content": [
    //     {"title": "MyTitle", "img": "UrlToImage", "url": "UrlToPage"},
    //     {"title": "MyTitle", "img": "UrlToImage", "url": "UrlToPage"},
    //     {"title": "MyTitle", "img": "UrlToImage", "url": "UrlToPage"},
    //     {"title": "MyTitle", "img": "UrlToImage", "url": "UrlToPage"},
    //     {"title": "MyTitle", "img": "UrlToImage", "url": "UrlToPage"}
    //   ]
    // };
    if (existingContent["status"] == "ERROR") {
      await writeData(data: newContent);
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

    if (!newContentToNotify.isEmpty) {
      await writeData(data: newContent);
      return true;
    } else {
      return false;
    }
  }

  bool makeNotification() {
    if (newContentToNotify.isEmpty) {
      return false;
    }

    print("Notification");

    for (Map article in newContentToNotify) {
      NotificationService().init(article);
    }
    return true;
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
