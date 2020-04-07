import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../tools/tool.dart';
import './today.dart';

/// TodaysScheduleを表示
class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}
class HomeState extends State<Home> with WidgetsBindingObserver {
  TodaysSchedule todaysSchedule;
  DateTime now = DateTime.now();
  Timer timer;
  int seconds;
  String name;

  HomeState() {
    seconds = 60 - now.second;
    timer = Timer.periodic(Duration(seconds: seconds), (Timer t) {
      seconds = 60 - now.second;
      setState(() {
        now = DateTime.now();
      });
      todaysSchedule.planList.forEach((plan) {
        if(plan.start.hour==now.hour && plan.start.minute==now.minute) {
          print("appointment time");
          sendNotification(plan.name);
        }
      });
    });
  }

  AppLifecycleState _lastLifecyleState;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  NotificationDetails platformChannelSpecifics;

  Future onSelectNotification(String payload) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Appointment Time: $payload"),
        content: Text("Your Plan is Starting"),
      )
    );
  }

  Future sendNotification(String name) async{
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max,
      priority: Priority.High);
    var iOSPlatformChannelSpecifics =
      IOSNotificationDetails(sound: "slow_spring_board.aiff");
    var platformChannelSpecifics = NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0, "Appointment Time: $name", "Your Plan is Starting",
      platformChannelSpecifics, payload: "$name"
    );
  }

  Future onDidReceiveLocationLocation(int id, String title, String body, String payload) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content:  Text(body),
          actions: <Widget>[
            FlatButton(
              child: Text(payload),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocationLocation);
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: onSelectNotification);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void onDeactivate() {
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("LifecycleWatcherState#didChangeAppLifecycleState state=${state.toString()}");
    setState(() {
      _lastLifecyleState = state;
    });
    if(state==AppLifecycleState.resumed) {
      now = DateTime.now();
    }
  }

  Future<Widget> loadTodaysSchedule() async{
    Map<String, TodaysSchedule> futureScheduleMap = await TodaysSchedulePreference.getFutureScheduleMap();
    if(futureScheduleMap.length==0) {
      return Center(child: Text("予定はなにもない平和な一日", style: TextStyle(fontSize: 30),),);
    }else{
      todaysSchedule = futureScheduleMap["today"];
      if(todaysSchedule==null) {
        name = "undifined";
      }else{
        name = todaysSchedule.name;
      }
      print(todaysSchedule.name);
      if(now.hour==0 && now.minute==0) {
        futureScheduleMap["today"] = futureScheduleMap["tomorrow"];
        futureScheduleMap["tomorrow"] = TodaysSchedule();
        TodaysSchedulePreference.saveTodaysSchedule(futureScheduleMap);
      }
      if(todaysSchedule==null || todaysSchedule.planList==null || (todaysSchedule.name=="undifined" && todaysSchedule.planList==[])) {
        return Center(child: Text("予定はなにもない平和な一日", style: TextStyle(fontSize: 30),),);
      }else{
        todaysSchedule.planList.forEach((plan) => print("appointed plan ${plan.name ??= "null"}"));
        return TodayPlanListView(todaysSchedule);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer(context),
      appBar: AppBar(
        title: Column(
          children: <Widget>[
            Text(
              "${DateFormat("MM/dd/yyyy HH:mm").format(now)}            ",
              style: TextStyle(fontSize: 12),
            ),
            Text(
              "今日の予定は $name",
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: loadTodaysSchedule(),
        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
          if(snapshot.hasData || snapshot.data!=null) {
            return snapshot.data;
          }else{
            return Center(child: Text("データがありません"));
          }
        },
      )
    );
  }
}