import 'dart:convert';
import 'dart:io';
import 'package:excel_kit/sheet.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel_kit/excel_kit.dart';

class Local {
  static late File file;
  static Map<String, List<Map>> rfids = {};

  static save(File file) async {
    final jsonData = {'rfids': rfids};
    var encoded = json.encode(jsonData);
    await file.writeAsString(encoded);
  }

  static Future<Map<String, List<Map>>> load() async {
    final directory = await getExternalStorageDirectory();
    file = File('${directory?.path}/rfids.json');
    late dynamic jsonData;

    if (await file.exists()) {
      var contents = await file.readAsString();

      jsonData = json.decode(contents);
      _get(jsonData['rfids']);

      print(rfids);
    } else {
      save(file);
      return {};
    }
    return rfids;
  }

  static update(Map<String, List<Map>> rfidsUpdated) async {
    rfids = rfidsUpdated;
    await save(file);
  }

  static _get(Map s) {
    for (var e in s.keys) {
      rfids[e] = [];
      for (var l in s[e]) {
        rfids[e]?.add(l as Map<dynamic, dynamic>);
      }
    }
  }

  static Future export(Map<String, List<Map>> rfidsExported) async {
    final directory = await getExternalStorageDirectory();
    final path = directory?.path;
    String writePath = "$path/write_test.xlsx";

    List<Map> dataList = [];

    for (var element in rfidsExported.keys) {
      dataList.addAll(rfidsExported[element]!);
    }

    Map<String, String> fieldMap = {
      "EPC": "EPC",
      "Data": "Data",
      "Category": "Category",
    };
    print(writePath);
    ExcelKit.writeFile(writePath, [SheetOption("Sheet1", dataList, fieldMap: fieldMap)]);

    final Email email = Email(
      body: 'Email body',
      subject: 'Email subject',
      recipients: ['example@gmail.com'],
      attachmentPaths: [writePath],
      isHTML: false,
    );

    await FlutterEmailSender.send(email);
    rfidsExported.clear();
    rfids.clear();
    update({});
  }
}
