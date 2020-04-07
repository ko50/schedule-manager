import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../schedule/schedule.dart';
import '../tools/tool.dart';

/// 今日のスケジュールに選択されたScheduleはこのクラスに割り当てられます
class TodaysSchedule extends Schedule {
  Schedule schedule;
  String name;
  List planList;

  TodaysSchedule({this.schedule}) {
    if(schedule==null) {
      this.name = "undifined";
      this.planList = [];
    }else{
      this.name = schedule.name;
      this.planList = schedule.planList;
    }
  }

  TodaysSchedule.fromJson(Map<String, dynamic> json)
    : name     = json["name"],
      planList = (json["planList"].map((plan) => Plan.fromJson(plan))).toList();

  Map<String, dynamic> toJson() => {
    "name"     : name,
    "planList" : planList.map((plan) => plan.toJson()).toList(),
  };
}

class TodaysSchedulePreference {
  /// ローカルからtodaysScheduleらを取得します
  static Future<Map<String, TodaysSchedule>> getFutureScheduleMap() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(!pref.containsKey("FutureScheduleMap")){
      pref.setString("FutureScheduleMap", "");
      return {"today": TodaysSchedule(), "tomorrow": TodaysSchedule()};
    }

    if(pref.getString("FutureScheduleMap")=="") {
      return {"today": TodaysSchedule(), "tomorrow": TodaysSchedule()};
    }

    dynamic myJson = json.decode(pref.getString("FutureScheduleMap"));
    Map<String, TodaysSchedule> futureScheduleMap = {"today": TodaysSchedule(), "tomorrow": TodaysSchedule()};

    futureScheduleMap["today"] = TodaysSchedule.fromJson(myJson["today"] ??= {
        "name":    "",
        "planList": [],
      });
    futureScheduleMap["tomorrow"] = TodaysSchedule.fromJson(myJson["tomorrow"] ??= {
        "name":    "",
        "planList": [],
      });
    return futureScheduleMap;
  }

  /// ローカルにスケジュールのリスト(Json)を保存します
  static Future saveTodaysSchedule(Map<String, TodaysSchedule> futureScheduleMap) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("FutureScheduleMap", jsonEncode(futureScheduleMap));
  }

}

/// 今日の予定をListViewで一覧表示します
class TodayPlanListView extends StatefulWidget {
  final TodaysSchedule todaysSchedule;

  TodayPlanListView(this.todaysSchedule);

  @override
  TodayPlanListViewState createState() => TodayPlanListViewState(todaysSchedule);
}
class TodayPlanListViewState extends State<TodayPlanListView> with WidgetsBindingObserver {
  TodaysSchedule todaysSchedule;

  TodayPlanListViewState(this.todaysSchedule);

  @override
  Widget build(BuildContext context) {
    if(todaysSchedule.planList==null || todaysSchedule.planList.length==0 || todaysSchedule.name=="undifined") {
      return Center(child: Text("このスケジュールには\n予定が何もないです\nまずはなんか追加しろカス", style: TextStyle(fontSize: 40)));
    }else{
      return ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemBuilder: (BuildContext context, int index) {
          Plan plan = todaysSchedule.planList[index];
          return Container(
            child: PlanCard(plan: plan),
          );
        },
        itemCount: todaysSchedule.planList.length,
      );
    }
  }
}