import 'package:flutter/material.dart';

import '../tools/tool.dart';
import './config.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(context),
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Auto Repeat Scheudle"),
            subtitle: Text("オンにすると、日付が更新されたときに\n自動的に明日の予定に\"今日の予定\"が設定されます"),
            // TODO trailing: , ここにスイッチを追加 & configの実装
          ),
        ],
      ),
    );
  }
}