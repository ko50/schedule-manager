import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Dart:async';

// import 'package:flutter/material.Dart';

/// 
class Schedule {
  String name;
  List planList;

  Schedule({this.name}) {
    this.planList ??= [];
    planList.sort((a, b) {
      int result = a.start.hour - b.start.hour;
      if(result==0) {
        // TODO ここのロジックは多分そのうち問題起きると思う
        result = a.start.minute - b.start.minute;
      }
      return result;
    });
  }

/// planListを開始時刻ごとに並べ替えます
void sortPlanList() {
  this.planList.sort((a, b) {
    int result = a.start.hour - b.start.hour;
    if(result==0) {
      result = a.start.minute - b.start.minute;
    }
    return result;
  });
}

  Schedule.fromJson(Map<String, dynamic> json)
    : name     = json["name"],
      planList = (json["planList"].map((plan) => Plan.fromJson(plan))).toList();

  Map<String, dynamic> toJson() => {
    "name"     : name,
    "planList" : planList.map((plan) => plan.toJson()).toList(),
  };
}

class Plan {
  String name;
  TimeOfDay start, end;

  Plan({this.name, this.start, this.end});

  Plan.fromJson(Map<String, dynamic> json)
    : name  = json["name"],
      start = TimeOfDay(hour: int.parse(json["start"].split(":")[0]), minute: int.parse(json["start"].split(":")[1])),
      end   = TimeOfDay(hour: int.parse(json["end"].split(":")[0]),   minute: int.parse(json["end"].split(":")[1]  ));

  Map<String, dynamic> toJson() => {
    "name"  : name,
    "start" : start.hour.toString() + ":" + start.minute.toString(),
    "end"   : end.hour.toString()   + ":" + end.minute.toString(),
  };

}

class SchedulePreference {
  Schedule schedule;

  SchedulePreference(this.schedule);

  /// ローカルに保存されているスケジュールのリストを取得します
  static Future<List<Schedule>> getScheduleList() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(!pref.containsKey("ScheduleList")){
      pref.setString("ScheduleList", "");
      return [];
    }

    if(pref.getString("ScheduleList")=="") {
      return [];
    }
    List<dynamic> jsonList = json.decode(pref.getString("ScheduleList"));
    List<Schedule> scheduleList = [];

    for(Map<String, dynamic> json in jsonList) {
      scheduleList.add(Schedule.fromJson(json));
    }
    return scheduleList;
  }

  /// ローカルにスケジュールのリスト(Json)を保存します
  static Future saveScheduleList(List<Schedule> scheduleList) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    List jsonScheudleList = [];
    for(Schedule schedule in scheduleList) {
      jsonScheudleList.add(schedule.toJson());
    }
    pref.setString("ScheduleList", json.encode(jsonScheudleList));
  }

  /// ローカルのScheduleListにスケジュールを追加します
  static void addSchedule(Schedule schedule) async{
    List<Schedule> scheduleList = await getScheduleList();
    scheduleList.add(schedule);
    saveScheduleList(scheduleList);
  }

  /// ScheduleListからスケジュールを削除します
  static Future<Schedule> deleteScheduleAt(int index) async{
    List<Schedule> scheduleList = await getScheduleList();
    Schedule deletedSchedule = scheduleList.removeAt(index);
    saveScheduleList(scheduleList);
    return deletedSchedule;
  }
}
