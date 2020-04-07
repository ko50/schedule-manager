import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
  bool autoSetTomorrow;

  Config({this.autoSetTomorrow}) {
    this.autoSetTomorrow ??= false;
  }

  Config.fromJson(Map<String, dynamic> json)
  : autoSetTomorrow = json["autoSetTomorrow"];

  Map<String, dynamic> toJson() => {
    "autoSetTomorrow" : autoSetTomorrow,
  };
}

class ConfigPrefarence {
  /// 現在の設定を取得します
  static Future<Config> getConfig() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(pref.containsKey("Config")) {
      pref.setString("Config", "");
      return Config();
    }
    if(pref.getString("Config")=="") {
      return Config();
    }
    Map<String, dynamic> myJson = json.decode(pref.getString("Config"));
    Config config = Config.fromJson(myJson);
    return config;
  }

  /// 変更後の設定を保存します
  static Future saveConfig(Config config) async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("Config", json.encode(config.toJson()));
  }
}