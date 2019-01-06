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



//Logging in
void initState() {
    Playfab.init("YOUR_TITLE_ID");
    Playfab.debugMode = true;
    Playfab.logIn();
}

//Sending events
Playfab.sendEvent("event_name");

//Sending events with Body params
Playfab.sendEvent("event_name",{"param1":1,"param2":"value2"});

```