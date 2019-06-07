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

class ValidateGooglePlayPurchaseRequest {
  String receiptJson;
  String signature;
  String currencyCode;
  int purchasePrice;

  ValidateGooglePlayPurchaseRequest(
      {this.receiptJson,
      this.signature,
      this.currencyCode,
      this.purchasePrice});

  ValidateGooglePlayPurchaseRequest.fromJson(Map<String, dynamic> json) {
    receiptJson = json['ReceiptJson'];
    signature = json['Signature'];
    currencyCode = json['CurrencyCode'];
    purchasePrice = json['PurchasePrice'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ReceiptJson'] = this.receiptJson;
    data['Signature'] = this.signature;
    data['CurrencyCode'] = this.currencyCode;
    data['PurchasePrice'] = this.purchasePrice;
    return data;
  }
}

enum CloudScriptRevisionOption {
  Live,
  Latest,
  Specific
}

// class ExecuteCloudScriptRequest {
//   String functionName;
//   dynamic functionParameter;
//   bool generatePlayStreamEvent;
//   String revisionSelection;
//   int specificRevision;

//   ExecuteCloudScriptRequest(
//       {this.functionName,
//       this.functionParameter,
//       this.generatePlayStreamEvent,
//       this.revisionSelection,
//       this.specificRevision});

//   ExecuteCloudScriptRequest.fromJson(Map<String, dynamic> json) {
//     functionName = json['FunctionName'];
//     functionParameter = json['FunctionParameter'] != null
//         ? new json. json['FunctionParameter']
//         : null;
//     generatePlayStreamEvent = json['GeneratePlayStreamEvent'];
//     revisionSelection = json['RevisionSelection'];
//     specificRevision = json['SpecificRevision'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['FunctionName'] = this.functionName;
//     if (this.functionParameter != null) {
//       data['FunctionParameter'] = this.functionParameter.toJson();
//     }
//     data['GeneratePlayStreamEvent'] = this.generatePlayStreamEvent;
//     data['RevisionSelection'] = this.revisionSelection;
//     data['SpecificRevision'] = this.specificRevision;
//     return data;
//   }
// }

