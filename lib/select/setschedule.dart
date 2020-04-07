import 'dart:async';
import 'package:flutter/material.dart';

import '../mainpage/today.dart';
import '../schedule/schedule.dart';
import '../tools/tool.dart';
import '../tools/dialogs.dart';
import '../config/config.dart';


class SetTodaysSchedule extends StatefulWidget {
  @override
  SetTodaysScheduleState createState() => SetTodaysScheduleState();
}
class SetTodaysScheduleState extends State<SetTodaysSchedule> {

  Future<Widget> loadScheduleList() async{
    List<Schedule> scheduleList = await SchedulePreference.getScheduleList();
    if(scheduleList==null || scheduleList.length==0) {
      return Center(child: Text("スケジュールが一つもありません\nまずは\"Add and Edit Scheudle\"ページからスケジュールを追加しろください"));
    }else{
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          Schedule schedule = scheduleList[index];
          return Container(
            decoration: bottomBorder(),
            child: ListTile(
              title: Text(schedule.name),
              onTap: () async{
                List will = await setFutureScheudleDialog(context);
                if(will[0]) {
                  Map<String, TodaysSchedule> futureScheduleMap = await TodaysSchedulePreference.getFutureScheduleMap();
                  Config config = await ConfigPrefarence.getConfig();
                  switch(will[1]) {
                    case "today":
                      futureScheduleMap["today"] = TodaysSchedule(schedule: schedule);
                      break;
                    case "tomorrow":
                      if(config.autoSetTomorrow) {
                        await showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("設定できません"),
                              content: Text("Auto Set Tomorrowが有効化されているため\"明日の予定\"を設定できません\n先に設定を無効化してください"),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text("ok"),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            );
                          }
                        );
                      }else{
                        futureScheduleMap["tomorrow"] =  TodaysSchedule(schedule: schedule);
                      }
                      break;
                  }
                  await TodaysSchedulePreference.saveTodaysSchedule(futureScheduleMap);
                }
              },
            ),
          );
        },
        itemCount: scheduleList.length,
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(context),
      appBar: AppBar(
        title: Text("set Today's Schedule"),
      ),
      body: FutureBuilder(
        future: loadScheduleList(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapShot) {
          if(snapShot.hasData) {
            return snapShot.data;
          }else{
            return Text("データがありません");
          }
        },
      ),
    );
  }
}