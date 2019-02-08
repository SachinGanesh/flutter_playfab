# flutter_playfab

A package to integrate flutter with PlayFab

## Usage

Import `package:flutter_playfab/flutter_playfab.dart`, and instantiate `PlayFab`

## Implemented Endpoints
- Authentication
  - LoginWithIOSDeviceID
  - LoginWithAndroidDeviceID
- Analytics
  - WritePlayerEvent


Example:

```dart
import 'package:flutter_playfab/flutter_playfab.dart';

PlayFabClientAPI.initialize("326A"); // YOUR PLAYFAB ID GOES HERE
PlayFabClientAPI.debugMode  = true; 
PlayFabClientAPI.writePlayerEvent("test_1");

PlayFabClientAPI.writePlayerEvent("test_2", {
    "Name": "Hello",
    "Year": 2019,
    "data": {"data1": 100, "data2": "2000"}
});

PlayFabClientAPI.login(
    onSuccess: (LoginResult data) {
        print("On Login Success: " + data.sessionTicket);
        PlayFabClientAPI.getTitleData(
            onSuccess: (TitleData titleData){
            }
        );
    },
    onError: () {
        print("On Login Failed");
    }
);
PlayFabClientAPI.writePlayerEvent("test_3");
```