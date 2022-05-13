import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class StoreData {
  StoreData();

  void saveCurrentContext(
      {required Map dataActiveLanguages,
      required Map dataSettings,
      required Map dataAvailableLanguages}) {
    saveActiveLanguages(dataActiveLanguages);
    saveSettings(dataSettings);
    saveAvailableLanguages(dataAvailableLanguages);
  }

  void saveActiveLanguages(Map dataActiveLanguages) {
    writeData(_localFileActiveLanguages, dataActiveLanguages);
  }

  void saveSettings(Map dataSettings) {
    writeData(_localFileSettings, dataSettings);
  }

  void saveAvailableLanguages(Map dataAvailableLanguages) {
    writeData(_localFileAvailableLanguages, dataAvailableLanguages);
  }

  Future<List> get getCurrentContext async {
    List tmpList = [];
    tmpList.add(await getActiveLanguages);
    tmpList.add(await getSettings);
    tmpList.add(await getAvailableLanguages);
    return tmpList;
  }

  Future<Map> get getActiveLanguages async {
    return await readData(_localFileActiveLanguages);
  }

  Future<Map> get getSettings async {
    return await readData(_localFileSettings);
  }

  Future<Map> get getAvailableLanguages async {
    return await readData(_localFileAvailableLanguages);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFileActiveLanguages async {
    final path = await _localPath;
    return File('$path/ActiveLanguages.json');
  }

  Future<File> get _localFileSettings async {
    final path = await _localPath;
    return File('$path/Settings.json');
  }

  Future<File> get _localFileAvailableLanguages async {
    final path = await _localPath;
    return File('$path/AvailalbleLanguages.json');
  }

  Future<File> writeData(var localFile, Map data) async {
    final file = await localFile;
    var jsonText = jsonEncode(data);
    return file.writeAsString(jsonText);
  }

  Future<Map> readData(var localFile) async {
    try {
      final file = await localFile;
      final data = await file.readAsString();
      return jsonDecode(data) ?? {"status": "ERROR"};
    } catch (e) {
      return {"status": "ERROR"};
    }
  }
}
