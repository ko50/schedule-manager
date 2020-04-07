import 'package:flutter/material.dart';

import '../tools/tool.dart';
import './config.dart';
import '../mainpage/today.dart';
import '../tools/dialogs.dart';

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}
class SettingsState extends State<Settings> {
  Config config;
  Map<String, TodaysSchedule> futureScheduleList;

  Future loadConfig() async{
    config = await ConfigPrefarence.getConfig();
    futureScheduleList = await TodaysSchedulePreference.getFutureScheduleMap();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(context),
      appBar: AppBar(
        title: Text("Settings"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async{
          ConfigPrefarence.saveConfig(config);
          Navigator.of(context).pop();
        },
      ),
      body: FutureBuilder(
        future: loadConfig(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return ListView(
            children: <Widget>[
              ListTile(
                title: Text("Auto Set Scheudle"),
                subtitle: Text("オンにすると、日付が更新されたときに\n自動的に今日と同じ予定が適用されます"),
                trailing: Switch(
                  value: config.autoSetTomorrow,
                  onChanged: (bool changed) async{
                    bool forceSet = true;
                    if(futureScheduleList["tomorrow"].name!="undifined") {
                      forceSet = await forceSettingDialog(context, "自動設定をオンにしようとしているのに、\nすでに明日の予定が設定されているんですが\n\n明日の予定を消去して設定をオンにしますか？");
                    }
                    if(forceSet) {
                      setState(() {
                        config.autoSetTomorrow = changed;
                      });
                    }
                  },
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}