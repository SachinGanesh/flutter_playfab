library flutter_playfab;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_playfab/models/request.dart';
import 'package:flutter_playfab/models/response.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info/device_info.dart';

class EventData {
  String name;
  dynamic data;
  EventData(this.name, this.data);

  @override
  String toString() {
    return name;
  }
}

///Playfab class
class PlayFabClientAPI {
  static String _sessionTicket;
  static String _playFabId;
  static bool _createAccount = true;
  static bool _isLoggedIn = false;
  static bool _isSyncing = false;
  static bool _debugMode = false;
  static String _titleId;
  static List<EventData> _eventQueue;

  /// Initialize PlayFab
  ///
  /// [titleId] : TitleID of your PlayFab app
  static initialize(String titleId) {
    _eventQueue = new List<EventData>();
    _titleId = titleId;
  }

  /// Set debugMode
  static set debugMode(bool mode) => _debugMode = mode;

  /// if account is created
  static bool get isLoggedIn => _isLoggedIn;
  static String get sessionTicket => _sessionTicket;
  static set sessionTicket(String value) {
    _sessionTicket = value;
  }

  static String get playFabId => _playFabId;

  static Future login({Function onSuccess, Function onError}) async {
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
        response = await http
            .post(
          'https://$_titleId.playfabapi.com/Client/LoginWithAndroidDeviceID',
          headers: {
            "Accept": "text/plain, */*; q=0.01",
            "Content-Type": "application/json",
          },
          body:
              '{"AndroidDeviceId": "${deviceData.androidId}","OS": "${deviceData.version}","AndroidDevice": "${deviceData.model}","CreateAccount": $_createAccount,"TitleId": "$_titleId"}',
          encoding: Encoding.getByName("utf-8"),
        )
            .catchError((Object error) {
          throw Exception("Unknown Error");
        });
      } else {
        throw Exception("Unknown Platform");
      }

      if (response.statusCode == 200) {
        if (_debugMode) debugPrint('logIn Response: success');
        var parsedData =
            PlayFabResultCommon.fromJson(json.decode(response.body));
        if (parsedData.code == 200) {
          var data = LoginResult.fromJson(json.decode(parsedData.data));
          if (data.newlyCreated) {
            if (_debugMode) debugPrint('logIn Response: Account Newly Created');
            prefs.setBool('playfab_account_created', true);
          } else {
            if (_debugMode)
              debugPrint('logIn Response: Account already exists');
          }
          _sessionTicket = data.sessionTicket;
          _playFabId = data.playFabId;
          _isLoggedIn = true;

          prefs.setString("playfab_session_ticket", _sessionTicket);

          /// Send events in queue
          _sendQueuedEvents();
          if (onSuccess != null) onSuccess(data);
        } else {
          if (_debugMode)
            debugPrint('logIn Response Failed: ${parsedData.status}');
        }
        return null;
      } else {
        if (onError != null) onError();
        if (_debugMode) debugPrint('logIn Response: Failed to load');
        // If that response was not OK, throw an error.
        throw Exception('Failed to load');
      }
    }
  }

  static Future getTitleData({Function onSuccess, Function onError}) async {
    if (_isLoggedIn) {
      http.Response response;
      var requestData = GetTitleDataRequest();
      requestData.keys = new List<String>();
      //requestData.keys.add("Key2");
      response = await http.post(
        'https://$_titleId.playfabapi.com/Client/GetTitleData',
        headers: {
          "Accept": "text/plain, */*; q=0.01",
          "Content-Type": "application/json",
          "X-Authentication": _sessionTicket
        },
        body: json.encode(requestData.toJson()),
        encoding: Encoding.getByName("utf-8"),
      );
      if (response.statusCode == 200) {
        if (_debugMode) debugPrint('getTitleData Response: success');
        var parsedData =
            PlayFabResultCommon.fromJson(json.decode(response.body));
        if (parsedData.code == 200) {
          TitleData titleData =
              TitleData.fromJson(json.decode(parsedData.data));

          if (onSuccess != null) onSuccess(titleData);
        } else {
          if (_debugMode)
            debugPrint('getTitleData Response Failed: ${parsedData.status}');
        }
        return null;
      } else {
        if (onError != null) onError();
        if (_debugMode) {
          debugPrint('getTitleData Response: Failed to load');
          print(response.statusCode);
        }
      }
    }
  }

  static Future executeCloudScript() {}

  static Future pushNotificationRegistration({
    @required PushNotificationRegistrationRequest request,
    Function onSuccess,
    Function onError,
  }) async {
    if (Platform.isAndroid) {
      await androidDevicePushNotificationRegistration(
        request: request,
        onSuccess: onSuccess,
        onError: onError,
      );
    } else if (Platform.isIOS) {}
    return;
  }

  static Future androidDevicePushNotificationRegistration({
    @required PushNotificationRegistrationRequest request,
    Function onSuccess,
    Function onError,
  }) async {
    if (_isLoggedIn) {
      http.Response response;
      var requestData = GetTitleDataRequest();
      requestData.keys = new List<String>();
      //requestData.keys.add("Key2");
      response = await http.post(
        'https://$_titleId.playfabapi.com/Client/AndroidDevicePushNotificationRegistration',
        headers: {
          "Accept": "text/plain, */*; q=0.01",
          "Content-Type": "application/json",
          "X-Authentication": _sessionTicket
        },
        body: json.encode(request.toJson()),
        encoding: Encoding.getByName("utf-8"),
      );
      if (response.statusCode == 200) {
        if (_debugMode)
          debugPrint(
              'androidDevicePushNotificationRegistration Response: success');
        if (onSuccess != null) onSuccess();
      } else {
        if (_debugMode)
          debugPrint(
              'androidDevicePushNotificationRegistration Response Failed: ' +
                  response.reasonPhrase);
      }
      return null;
    } else {
      if (onError != null) onError();
      if (_debugMode) {
        debugPrint(
            'androidDevicePushNotificationRegistration Response: Failed to load');
      }
    }
  }

  static Future registerForIOSPushNotification({
    @required PushNotificationRegistrationRequest request,
    Function onSuccess,
    Function onError,
  }) async {
    if (_isLoggedIn) {
      http.Response response;
      var requestData = GetTitleDataRequest();
      requestData.keys = new List<String>();
      //requestData.keys.add("Key2");
      response = await http.post(
        'https://$_titleId.playfabapi.com/Client/RegisterForIOSPushNotification',
        headers: {
          "Accept": "text/plain, */*; q=0.01",
          "Content-Type": "application/json",
          "X-Authentication": _sessionTicket
        },
        body: json.encode(request.toJson()),
        encoding: Encoding.getByName("utf-8"),
      );
      if (response.statusCode == 200) {
        if (_debugMode)
          debugPrint('registerForIOSPushNotification Response: success');
        if (onSuccess != null) onSuccess();
      } else {
        if (_debugMode)
          debugPrint('registerForIOSPushNotification Response Failed: ' +
              response.reasonPhrase);
      }
      return null;
    } else {
      if (onError != null) onError();
      if (_debugMode) {
        debugPrint('registerForIOSPushNotification Response: Failed to load');
      }
    }
  }

  static Future<void> validateGooglePlayPurchase({
    @required ValidateGooglePlayPurchaseRequest request,
    Function onSuccess,
    Function onError,
  }) async {
    if (_isLoggedIn) {
      http.Response response;
      //requestData.keys.add("Key2");
      response = await http.post(
        'https://$_titleId.playfabapi.com/Client/ValidateGooglePlayPurchase',
        headers: {
          "Accept": "text/plain, */*; q=0.01",
          "Content-Type": "application/json",
          "X-Authentication": _sessionTicket
        },
        body: json.encode(request.toJson()),
        encoding: Encoding.getByName("utf-8"),
      );
      if (response.statusCode == 200) {
        if (_debugMode)
          debugPrint('validateGooglePlayPurchase Response: success');
        if (onSuccess != null) onSuccess();
      } else {
        if (_debugMode)
          debugPrint('validateGooglePlayPurchase Response Failed: ' +
              response.reasonPhrase);
      }
      return null;
    } else {
      if (onError != null) onError();
      if (_debugMode) {
        debugPrint('validateGooglePlayPurchase Response: Failed to load');
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

  static writePlayerEvent(String eventName,
      [Map<String, dynamic> params]) async {
    if (_isLoggedIn && !_isSyncing) {
      _event(eventName, params);
    } else {
      if (_eventQueue == null) _eventQueue = List<EventData>();
      _eventQueue.add(EventData(eventName, params));
      _sendQueuedEvents();
    }
  }

  static _event(String eventName, Map<String, dynamic> params) async {
    var requestData = jsonEncode(params);
    if (_isLoggedIn) {
      _isSyncing = true;
      //if(_debugMode) debugPrint('playfab event: Data: ' + requestData);
      try {
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
      } catch (e) {}
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
