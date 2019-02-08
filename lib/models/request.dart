class GetTitleDataRequest {
  List<String> keys;

  GetTitleDataRequest({this.keys});

  GetTitleDataRequest.fromJson(Map<String, dynamic> json) {
    keys = json['Keys'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Keys'] = this.keys;
    return data;
  }
}

class PushNotificationRegistrationRequest {
  String deviceToken;
  bool sendPushNotificationConfirmation;
  String confirmationMessage;

  PushNotificationRegistrationRequest(
      {this.deviceToken,
      this.sendPushNotificationConfirmation,
      this.confirmationMessage});

  PushNotificationRegistrationRequest.fromJson(Map<String, dynamic> json) {
    deviceToken = json['DeviceToken'];
    sendPushNotificationConfirmation = json['SendPushNotificationConfirmation'];
    confirmationMessage = json['ConfirmationMessage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DeviceToken'] = this.deviceToken;
    data['SendPushNotificationConfirmation'] =
        this.sendPushNotificationConfirmation;
    data['ConfirmationMessage'] = this.confirmationMessage;
    return data;
  }
}

