library playfab.clientapi.models;

import 'dart:convert';


class PlayFabResultCommon {
  int code;
  String status;
  String data;

  PlayFabResultCommon({this.code, this.status, this.data});

  PlayFabResultCommon.fromJson(Map<String, dynamic> jsonData, ) {
    code = jsonData['code'];
    status = jsonData['status'];

    data = jsonData['data'] != null ? json.encode(jsonData['data']): null;
    //data = json['data'] != null ? new data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['status'] = this.status;
    if (this.data != null) {
      data['data'] = this.data;//.toJson();
    }
    return data;
  }
}

class TitleData {
  Map<String, dynamic> data;

  TitleData({this.data});

  TitleData.fromJson(Map<String, dynamic> jsonData) {
    data = jsonData['Data'] != null ? jsonData['Data'] : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data;
    }
    return data;
  }
}

class LoginResult {
  String sessionTicket;
  String playFabId;
  bool newlyCreated;

  LoginResult({this.sessionTicket, this.playFabId, this.newlyCreated});

  LoginResult.fromJson(Map<String, dynamic> json) {
    sessionTicket = json['SessionTicket'];
    playFabId = json['PlayFabId'];
    newlyCreated = json['NewlyCreated'];
  }

  LoginResult.parse(Map<String, dynamic> json) {
    sessionTicket = json['data']['SessionTicket'];
    playFabId = json['data']['PlayFabId'];
    newlyCreated = json['data']['NewlyCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SessionTicket'] = this.sessionTicket;
    data['PlayFabId'] = this.playFabId;
    data['NewlyCreated'] = this.newlyCreated;
    return data;
  }
}
