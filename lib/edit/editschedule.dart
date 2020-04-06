import 'package:flutter/material.Dart';

import '../schedule/schedule.dart';
import '../tools/tool.dart';
import '../tools/dialogs.dart';
import './preveditschedule.dart';

/// スケジュールを一覧表示します タップすると編集画面に行けます
class EditSchedule extends StatefulWidget {
  final List<Schedule> scheduleList;

  EditSchedule(this.scheduleList);

  @override
  EditScheduleState createState() => EditScheduleState(scheduleList);
}
class EditScheduleState extends State<EditSchedule> {
  List<Schedule> scheduleList;

  EditScheduleState(this.scheduleList);

  Widget switchingScheduleList(List<Schedule> scheduleList) {
    if(scheduleList==null || scheduleList.length==0) {
      return Center(child: Text("せめてなんか予定立てたらどうですか？"),);
    }else{
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          Schedule schedule = scheduleList[index];
          return Container(
            decoration: bottomBorder(),
            child: ListTile(
              title: Text(schedule.name),
              onTap: () async{
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PrevEditSchedule(index, schedule)
                  ),
                );
              },
              onLongPress: () async{
                bool delete = await removeScheduleDialog(context, schedule.name);
                if(delete) {
                  setState(() {
                    scheduleList.removeAt(index);
                  });
                  await SchedulePreference.saveScheduleList(scheduleList);
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async{
          String result = await addScheduleDialog(context);

          if(result!=null) {
            List<Schedule> changedScheduleList = await SchedulePreference.getScheduleList();
            Schedule newSchedule = Schedule(name: result);
            changedScheduleList.add(newSchedule);
            setState(() {
              scheduleList = changedScheduleList;
            });
            await SchedulePreference.saveScheduleList(scheduleList);
          }
        },

      ),
      appBar: AppBar(
        title: Text("Edit and Add Schedules"),
      ),
      body: switchingScheduleList(scheduleList),
    );
  }
}
