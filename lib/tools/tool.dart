import 'package:flutter/material.Dart';
import 'package:intl/intl.dart';

import '../mainpage/home.dart';
import '../schedule/schedule.dart';
import '../select/setschedule.dart';
import '../edit/editschedule.dart';
import '../config/settings.dart';

BoxDecoration bottomBorder() {
  return BoxDecoration(
    border: Border(
      bottom: BorderSide(width: 1.0, color: Colors.grey),
    ),
  );
}

ListTile _drawerListTile(var context, String title, Widget targetPage) {
  return ListTile(
    title: Text(title, style: TextStyle(
      color: Colors.blue[600],
    )),
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => targetPage
        ),
      );
    },
  );
}

Drawer drawer(var context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Text("Schedule Manager", style: TextStyle(
            fontSize: 30,
            color: Theme.of(context).primaryTextTheme.title.color,
          )),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
          ),
        ),
        _drawerListTile(context, "Today's Schedule", Home()),
        ListTile(
            title: Text("Edit and Add Schedule", style: TextStyle(
              color: Colors.blue[600],
            )),
            onTap: () async{
              List<Schedule> scheduleList = await SchedulePreference.getScheduleList();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditSchedule(scheduleList)
                ),
              );
            },
        ),
        _drawerListTile(context, "Set Schedule", SetTodaysSchedule()),
        _drawerListTile(context, "Settings", Settings()),
      ],
    ),
  );
}

class PlanCard extends StatefulWidget {
  final Plan plan;
  final Function onTap, onLongPress;

  PlanCard({this.plan, this.onTap, this.onLongPress});

  @override
  PlanCardState createState() => PlanCardState(plan, onTap, onLongPress);
}
class PlanCardState extends State<PlanCard> {
  Plan plan;
  Function onTap, onLongPress;
  String name;
  TimeOfDay start, end;
  double cardLength;

  PlanCardState(this.plan, this.onTap, this.onLongPress) {
    this.onTap ??= () {};
    this.onLongPress ??= () {};
    this.name = plan.name;
    this.start = plan.start;
    this.end = plan.end;
    int hourDif = end.hour - start.hour;
    int minutesDif = end.minute - start.minute;
    if(minutesDif>=0) {
      this.cardLength = (60*(hourDif) + minutesDif).toDouble();
    }else{
      this.cardLength = (60*(hourDif) - minutesDif).toDouble();
    }
    
  }

  String formatSmallerTenTime(int time) {
    String result = "$time";
    if(time<10) result = "0$time";
    return result;
  }

  @override
  Widget build(BuildContext context) {
    String startHour = formatSmallerTenTime(start.hour);
    String startMinu = formatSmallerTenTime(start.minute);
    String endHour = formatSmallerTenTime(end.hour);
    String endMinu = formatSmallerTenTime(end.minute);
    if(cardLength<30) cardLength = 30;
    return Container(
      height: cardLength,
      child: Card(
        child: ListTile(
          title: Text("$name"),
          trailing: Text("$startHour : $startMinu\n     to     \n$endHour : $endMinu"),
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}

String formatTime(TimeOfDay timeOfDay) {
  DateTime now = DateTime.now();
  DateTime persedTime = DateTime(
    now.year,
    now.month,
    now.day,
    timeOfDay.hour,
    timeOfDay.minute,
  );
  return "${DateFormat.Hm().format(persedTime)}";
}

Future<TimeOfDay> showPlanTimeInputter(context) async{
  TimeOfDay result = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );
  return result;
}
