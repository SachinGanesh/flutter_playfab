import 'package:flutter/material.dart';
import 'package:flutter_playfab/flutter_playfab.dart';
import 'package:flutter_playfab/models/request.dart';
import 'package:flutter_playfab/models/response.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PlayFab Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter PlayFab Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PlayFabClientAPI.initialize("326A"); // YOUR PLAYFAB ID GOES HERE 326A
    PlayFabClientAPI.debugMode = true;
    PlayFabClientAPI.writePlayerEvent("test_1");
    PlayFabClientAPI.writePlayerEvent("test_2", {
      "Name": "Hello",
      "Year": 2019,
      "data": {"data1": 100, "data2": "2000"}
    });
    PlayFabClientAPI.login(onSuccess: (LoginResult data) {
      print("On Login Success: " + data.sessionTicket);
      PlayFabClientAPI.getTitleData(onSuccess: (TitleData titleData) {});

      // PlayFabClientAPI.pushNotificationRegistration(request:PushNotificationRegistrationRequest(),onSuccess: () {
      //   print("Push Registration Succesfull");
      // },
      // onError: (){
      //   print("Push Registration Failure");
      // });
      PlayFabClientAPI.getPlayerData(onSuccess: (PlayerData playerData) {

        print(playerData.data.values.toString());
        entryList = playerData.data.values.toList();

      });
      PlayFabClientAPI.validateGooglePlayPurchase(
          request: ValidateGooglePlayPurchaseRequest(
        receiptJson:
            "{\"orderId\":\"12999763169054705758.1375794066587622\",\"packageName\":\"com.playfab.android.testbed\",\"productId\":\"com.playfab.android.permatest.consumable\",\"purchaseTime\":1410891177231,\"purchaseState\":0,\"purchaseToken\":\"eaflhokdkobkmomjadmoobgb.AO-J1OwoLkW2cqvBcPEgk6SfGceQpOHALMUFmJYeawa-GuDFtl3oKct-5D28t_KvNscFiJOFiWXIS74vJBYg-CGFJgyrdbxalKEMPzXZrg5nLomCME-jIVFAUrzcPah-_66KPImG5ftsMJKI9uzldqEF9OPcakUEmt-kWoXAsl_6-9HH0gBCwh4\"}",
        signature:
            "ks12w0hHHpuit4xW3Fyoa5XX6TkxZ2KpEnBsLfpHHpeakYs2JgVtlLdgyLp/05Zp8oHAuKZyIAJTd2RIFXWMAUwDNUsI0JPBDMpr2oaL66Kuneg4VrGWJkJZTrvTyQoGpnTDdXfEME31iFKX6CrKHvWlAG9nwWxYatd58l83eevQ8CIrJhka/bC5ynw3j18OmFG7AcxymO37a4HkM8QjytvAYDJeOnDU9mooY7afcHIajtffdyAU9kzGWOqDByiU9IsRdkliwQoQYbuX/R5wQnMVZ+FGDDwO1mybx9B20rm7/WCBnWGy2NLsSAFI77iX8tUy/QebfBQhrVnRORi7bw==",
        currencyCode: "USD",
        purchasePrice: 70,
      ));
    }, onError: () {
      print("On Login Failed");
    });
    PlayFabClientAPI.writePlayerEvent("test_3");
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
    PlayFabClientAPI.writePlayerEvent("button_clicked", {"counter": _counter});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
