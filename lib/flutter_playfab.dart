library flutter_playfab;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';

class EventData {
  String name;
  dynamic data;
  EventData(this.name, this.data);

  @override
  String toString(){
    return name;
  }
}

///Playfab class
class PlayFab {
  static String _sessionTicket;
  static bool _createAccount = true;
  static bool _isLoggedIn = false;
  static bool _isSyncing = false;
  static bool _debugMode = false;
  static String _titleId;
  static List<EventData> _eventQueue;

  /// Initialize PlayFab
  ///
  /// [titleId] : TitleID of your PlayFab app
  static init(String titleId) {
    _eventQueue = new List<EventData>();
    _titleId = titleId;
  }
  /// Set debugMode
  set debugMode(bool mode) => _debugMode = mode;
  /// if account is created
  bool get isLoggedIn => _isLoggedIn;

  static Future logIn() async {
    if (!_isLoggedIn) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _createAccount =
          prefs.getBool('playfab_account_created') ?? false ? false : true;
      final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
      if (_debugMode)
        debugPrint("Creating new Account: " + _createAccount.toString());
      http.Response response;
      if (Platform.isIOS) {
        var deviceData = await deviceInfoPlugin.iosInfo;
        response = await http.post(
          'https://$_titleId.playfabapi.com/Client/LoginWithIOSDeviceID',
          headers: {
            "Accept": "text/plain, */*; q=0.01",
            "Content-Type": "application/json",
          },
          body:
              '{"DeviceId": "${deviceData.identifierForVendor}","OS": "${deviceData.systemVersion}","DeviceModel": "${deviceData.model}","CreateAccount": $_createAccount,"TitleId": "$_titleId"}',
          encoding: Encoding.getByName("utf-8"),
        );
      } else if (Platform.isAndroid) {
        var deviceData = await deviceInfoPlugin.androidInfo;
          response = await http.post(
          'https://$_titleId.playfabapi.com/Client/LoginWithAndroidDeviceID',
          headers: {
            "Accept": "text/plain, */*; q=0.01",
            "Content-Type": "application/json",
          },
          body:
              '{"AndroidDeviceId": "${deviceData.androidId}","OS": "${deviceData.version}","AndroidDevice": "${deviceData.model}","CreateAccount": $_createAccount,"TitleId": "$_titleId"}',
          encoding: Encoding.getByName("utf-8"),
        );
      } else {
        throw Exception("Unknown Platform");
      }

      if (response.statusCode == 200) {
        if (_debugMode) debugPrint('logIn Response: success');
        var parsedData =
            PlayFabLoginResponse.fromJson(json.decode(response.body));
        if (parsedData.code == 200) {
          if (parsedData.data.newlyCreated) {
            if (_debugMode) debugPrint('logIn Response: Account Newly Created');
            prefs.setBool('playfab_account_created', true);
          } else {
            if (_debugMode)
              debugPrint('logIn Response: Account already exists');
          }
          _sessionTicket = parsedData.data.sessionTicket;
          _isLoggedIn = true;

          /// Send events in queue
          _sendQueuedEvents();
        } else {
          if (_debugMode)
            debugPrint('logIn Response Failed: ${parsedData.status}');
        }
        // If server returns an OK response, parse the JSON
        return null;
      } else {
        if (_debugMode) debugPrint('logIn Response: Failed to load');
        // If that response was not OK, throw an error.
        throw Exception('Failed to load');
      }
    }
  }

  static Future _sendQueuedEvents() async {
    if (_isLoggedIn) {
      if (_eventQueue.length > 0) {
        //reverse eventQueue
        //_eventQueue = _eventQueue.reversed.toList();
        _eventQueue.forEach((event) async {
          print(event.name);
          await _event(event.name, event.data);
        });
        _eventQueue.clear();
      }
    }
  }

  static sendEvent(String eventName, [Map<String, dynamic> params]) async {
    if (_isLoggedIn && !_isSyncing) {
      _event(eventName, params);
    } else {
      _eventQueue.add(EventData(eventName, params));
      _sendQueuedEvents();
    }
  }

  static _event(String eventName, Map<String, dynamic> params) async {
    var requestData = jsonEncode(params);
    if (_isLoggedIn) {
      _isSyncing = true;
      //if(_debugMode) debugPrint('playfab event: Data: ' + requestData);
      final response = await http.post(
        'https://$_titleId.playfabapi.com/Client/WritePlayerEvent',
        headers: {
          "Accept": "text/plain, */*; q=0.01",
          "Content-Type": "application/json",
          "X-Authentication": _sessionTicket,
        },
        body: '{"EventName": "$eventName","Body": $requestData}',
        encoding: Encoding.getByName("utf-8"),
      );
      _isSyncing = false;
      if (response.statusCode == 200) {
        if (_debugMode) debugPrint('log event: success');
        // If server returns an OK response, parse the JSON
        return null;
      } else {
        if (_debugMode) debugPrint('log event: Failed to load');
        // If that response was not OK, throw an error.
        throw Exception('Failed to load');
      }
    }
  }
}

class PlayFabLoginResponse {
  int _code;
  String _status;
  PlayFabData _data;

  PlayFabLoginResponse({int code, String status, PlayFabData data}) {
    this._code = code;
    this._status = status;
    this._data = data;
  }

  int get code => _code;
  set code(int code) => _code = code;
  String get status => _status;
  set status(String status) => _status = status;
  PlayFabData get data => _data;
  set data(PlayFabData data) => _data = data;

  PlayFabLoginResponse.fromJson(Map<String, dynamic> json) {
    _code = json['code'];
    _status = json['status'];
    _data =
        json['data'] != null ? new PlayFabData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this._code;
    data['status'] = this._status;
    if (this._data != null) {
      data['data'] = this._data.toJson();
    }
    return data;
  }
}

class PlayFabData {
  String _sessionTicket;
  String _playFabId;
  bool _newlyCreated;

  PlayFabData({String sessionTicket, String playFabId, bool newlyCreated}) {
    this._sessionTicket = sessionTicket;
    this._playFabId = playFabId;
    this._newlyCreated = newlyCreated;
  }

  String get sessionTicket => _sessionTicket;
  set sessionTicket(String sessionTicket) => _sessionTicket = sessionTicket;
  String get playFabId => _playFabId;
  set playFabId(String playFabId) => _playFabId = playFabId;
  bool get newlyCreated => _newlyCreated;
  set newlyCreated(bool newlyCreated) => _newlyCreated = newlyCreated;

  PlayFabData.fromJson(Map<String, dynamic> json) {
    _sessionTicket = json['SessionTicket'];
    _playFabId = json['PlayFabId'];
    _newlyCreated = json['NewlyCreated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SessionTicket'] = this._sessionTicket;
    data['PlayFabId'] = this._playFabId;
    data['NewlyCreated'] = this._newlyCreated;
    return data;
  }
}
