import 'package:flutter/material.Dart';
import 'package:intl/intl.dart';

import '../schedule/schedule.dart';
import '../tools/tool.dart';
import '../tools/dialogs.dart';

/// 編集するスケジュールとその予定を表示
class PrevEditSchedule extends StatefulWidget {
  final int index;
  final Schedule schedule;

  PrevEditSchedule(this. index, this.schedule);

  @override
  PrevEditScheduleState createState() => PrevEditScheduleState(index, schedule);
}
class PrevEditScheduleState extends State<PrevEditSchedule> {
  final int index;
  final Schedule schedule;
  String name;

  PrevEditScheduleState(this.index, this.schedule) {
    this.name = schedule.name;
  }

  Widget switchingPlanList() {
    List planList = schedule.planList;
    if(planList==null || planList.length==0) {
      return Center(child: Text("このスケジュールにはまだなにも予定がない\nまずはなにか予定を追加しよう"),);
    }else{
      return Expanded(
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            Plan plan = planList[index];
            return PlanCard(
              plan: plan,
              onTap: () async{
                List newPlanData = await inputNewPlanDataDialog(context, name: plan.name, startTime: plan.start, endTime: plan.end);
                if(newPlanData!=[] && newPlanData[0]!="cancel") {
                  Plan newPlan = Plan(
                    name:  newPlanData[0],
                    start: newPlanData[1],
                    end:   newPlanData[2],
                  );
                  setState(() {
                    planList[index] = newPlan;
                  });
                }
              },
              onLongPress: () async{
                bool delete = await removePlanDialog(context, plan.name);
                if(delete) {
                  setState(() {
                    planList.removeAt(index);
                  });
                }
              },
            );
          },
          itemCount: planList.length,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(context),
      appBar: AppBar(
        title: Text("${schedule.name}"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async{
              bool invalidTime;
              List newPlanData;
              do{
                newPlanData = await inputNewPlanDataDialog(context);
                if(newPlanData[0]=="cancel") break;
                invalidTime = newPlanData[1].hour > newPlanData[2].hour;
                if(newPlanData[1].hour==newPlanData[2].hour && newPlanData[1].minute > newPlanData[2].minute) {
                  invalidTime = true;
                }
                newPlanData ??= ["cancel"];
                if(newPlanData[0]=="cancel") {
                  invalidTime = false;
                  //TODO これだとplan.nameをcancelにすれば無効な時刻でも通るのでカス
                }
                if(invalidTime && newPlanData[0]!="cancel") {
                  await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("無効な時間を設定しないでください"),
                        content: Text("あなたの住んでいる世界線と異なり、\nここでは時間が小さい方から大きい方へ進みます\nそれを踏まえてもう一度入力してください"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("ok"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                  );
                }
                if(newPlanData!=null && newPlanData.length==3) {
                  if(newPlanData[0]==null || newPlanData[0].trim()=="") {
                    await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("予定には名前があるものです"),
                          content: Text("予定は名前を付けてもらえなくて\n悲しがっています\n次はちゃんと名前を付けてあげてください"),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("ok"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      }
                    );
                  }
                }
              }while((newPlanData.length==0 || invalidTime || newPlanData[0]==null || newPlanData[0].trim()=="") && newPlanData[0]!="cancel");
              if(newPlanData[0]!="cancel") {
                setState(() {
                  schedule.planList.add(Plan(name: newPlanData[0], start: newPlanData[1], end: newPlanData[2]));
                });
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () async{
          List<Schedule> scheduleList = await SchedulePreference.getScheduleList();
          scheduleList[index].name     = schedule.name;
          scheduleList[index].planList = schedule.planList;
          await SchedulePreference.saveScheduleList(scheduleList);
          print("planlength ${schedule.planList.length}");
          schedule.sortPlanList();
          Navigator.of(context).pop();
        },
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: bottomBorder(),
            child: Row(
              children: <Widget>[
                Expanded(child: Text("${schedule.name}")),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () async{
                    String newNameOfSchedule = await editScheduleNameDialog(context, schedule.name);
                    if(newNameOfSchedule!=null || newNameOfSchedule.trim()!="") {
                      setState(() {
                        schedule.name = newNameOfSchedule;
                      });
                    }
                  },
                )
              ],
            )
          ),
          switchingPlanList(),
        ],
      ),
    );
  }
}