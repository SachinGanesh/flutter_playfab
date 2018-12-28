# flutter_playfab

A package to integrate flutter with PlayFab

## Usage

Import `package:flutter_playfab/flutter_playfab.dart`, and instantiate `PlayFab`


Example:

```dart
import 'package:flutter_playfab/flutter_playfab.dart';

Playfab plafab = Playfab("YOUR_TITLE_ID");
plafab.debugMode = true;

//Logging in
void initState() {
    playfab.logIn();
}

//Sending events
playfab.sendEvent("event_name");

//Sending events with params
playfab.sendEvent("event_name",{"param1":1,"param2":"value2"});

```