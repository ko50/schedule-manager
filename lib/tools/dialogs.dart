import 'package:flutter/material.Dart';

import '../tools/tool.dart';

/// 新しいスケジュールを追加するとき表示します
Future<String> addScheduleDialog(context) async{
  var controller = TextEditingController();
  String result = await showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add New Schedule"),
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Input Name of New Schedule"
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("cancel"),
            onPressed: () {
              Navigator.of(context).pop(null);
            },
          ),
          FlatButton(
            child: Text("ok"),
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
          ),
        ],
      );
    }
  );
  return result;
}

/// スケジュールを削除するか確認します
Future<bool> removeScheduleDialog(context, String name) async{
  bool result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Really Delete $name?"),
        content: Text("Do you really want to delete this Schedule?\nThis action can't Undo"),
        actions: <Widget>[
          FlatButton(
            child: Text("cancel"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text("ok"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    }
  );
  result ??= false;
  return result;
}

/// planの情報を編集、または新たにplanを追加するときにplanの情報を入力します
Future<List> inputNewPlanDataDialog(context,{String name, TimeOfDay endTime, TimeOfDay startTime}) async{
  var controller = TextEditingController();
  if(name!=null) controller.text = name;
  endTime   ??= TimeOfDay.now();
  startTime ??= TimeOfDay.now();
  List result;
  result = await showDialog<List>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Add New Plan"),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 200,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: "Name of New Plan"
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    width: 200,
                    decoration: bottomBorder(),
                    child: FlatButton(
                      onPressed: () async{
                        startTime = await showPlanTimeInputter(context);
                        startTime ??= TimeOfDay.now();
                        setState(() {
                          startTime = startTime;
                        });
                      },
                      child: Text("${formatTime(startTime)}"),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    width: 200,
                    decoration: bottomBorder(),
                    child: FlatButton(
                      onPressed: () async{
                        endTime = await showPlanTimeInputter(context);
                        endTime ??= TimeOfDay.now();
                        setState(() {
                          endTime = endTime;
                        });
                      },
                      child: Text("${formatTime(endTime)}"),
                    ),
                  )
                ],
              ),
            );
          }
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("cancel"),
            onPressed: () {
              Navigator.of(context).pop(["cancel"]);
            },
          ),
          FlatButton(
            child: Text("ok"),
            onPressed: () {
              Navigator.of(context).pop([controller.text, startTime ??= TimeOfDay.now(), endTime ??= TimeOfDay.now()]);
            },
          ),
        ],
      );
    }
  );
  result ??= ["cancel"];
  return result;
}

/// planを消去するか確認をします
Future<bool> removePlanDialog(context, String name) async{
  bool result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Really Delete $name?"),
        content: Text("Do you really want to delete this Plan?\nThis action can't Undo"),
        actions: <Widget>[
          FlatButton(
            child: Text("cancel"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text("yes"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          )
        ],
      );
    }
  );
  result ??= false;
  return result;
}

/// スケジュールの名前を編集します
Future<String> editScheduleNameDialog(context, String text) async{
  var controller = TextEditingController(text: text);
  String result = await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(hintText: "Input New Name"),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
            child: Text("cancel"),
            onPressed: () {
              Navigator.of(context).pop("");
            },
          ),
          FlatButton(
            child: Text("ok"),
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
          ),
        ],
      );
    }
  );
  return result;
}

Future<List> setFutureScheudleDialog(context) async{
  List result = await showDialog<List>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text("Set Schedule"),
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8.0),
            child: Text("Which do you want to set this schedule to?"),
          ),
          Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  child: Text("Today's Schedule"),
                  onPressed: () {
                    Navigator.of(context).pop([true, "today"]);
                  },
                ),
              ),
            ],
          ),
          Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                child: FlatButton(
                  child: Text("Tomorrow's Schedule"),
                  onPressed: () {
                    Navigator.of(context).pop([true, "tomorrow"]);
                  },
                ),
              ),
            ],
          ),
        ],
      );
    }
  );
  result ??= [false, ""];
  return result;
}

/// 自動設定をオンにするときすでに明日の予定が設定されていた時どうするか尋ねる
Future<bool> forceSettingDialog(context, String errorMessage) async{
  bool result = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("エラー"),
        content: Text(errorMessage),
        actions: <Widget>[
          FlatButton(
            child: Text("cancel"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            child: Text("ok"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    }
  );
  result ??= false;
  return result;
}