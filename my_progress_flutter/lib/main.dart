import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

// HTTP REST
//
import 'package:http/http.dart';
import 'dart:convert';
import 'Article.dart';
import 'ServiceStatus.dart';
import 'ServicePercentage.dart';
import 'dart:developer';
import 'dart:async';

String myURL = "192.168.43.129:8000";
bool loop = false;

Future sleep1() {
  return new Future.delayed(const Duration(seconds: 1), () => "1");
}

Future<ServicePercentage> fetchServicePercentage() async {
  final response = await get('http://'+ myURL + "/servicepercentage");

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return ServicePercentage.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load ServicePercentage');
  }
}

Future<ServiceStatus> fetchServiceStatus() async {
  final response = await get('http://'+ myURL + "/servicestatus");

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return ServiceStatus.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load ServiceStatus');
  }
}

Future<Article> fetchArticle(String id) async {
  final response = await get('http://'+ myURL + "/article/"+id);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Article.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load article');
  }
}

Future<ServicePercentage> futureServicePercentage;

void main() {
  runApp(MyApp());
}

String format(double n) {
  return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter My Remote Home Controller',
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
      home: MyHomePage(title: 'Flutter My Remote Home Controller'),
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

  Future<Article> futureArticle;
  Future<ServiceStatus> futureServiceStatus;

  double _counter = 0;
  String _counterFMT = "";

  @override
  void initState() {
    super.initState();
    futureArticle = fetchArticle("1");
    futureServiceStatus = fetchServiceStatus();
    futureServicePercentage = fetchServicePercentage();

    const MySec = const Duration(seconds: 3);

    Timer.periodic(MySec, (Timer timer) {
      if(loop)  {
        setState(() {
          futureServicePercentage = fetchServicePercentage();
          // print("Repeat task every one second");
        });  // This statement will be printed after every one second
      }
    }); // Timer
  } // initState

  double getValueFromServicePercentage(ServicePercentage servicePercentage, int valuePerc){

    double n = 0;

    switch(valuePerc) {
      case 1: n = double.parse(servicePercentage.Percentage1); break;
      case 2: n = double.parse(servicePercentage.Percentage2); break;
    }

    n = (n / 1000) + 0.123;

    if(n<0) n=0;
    if(n>1) n=1;

    return  n;
  }

  String getStrValueFromServicePercentage(ServicePercentage servicePercentage, int valuePerc, String symbol){
    var _strFMT = format(getValueFromServicePercentage(servicePercentage, valuePerc)*100) + symbol;
    return _strFMT;
  }

  /*
  void _decrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter-=0.001;
      if(_counter<0) _counter = 0;
      _counterFMT = format(_counter*100) + "%";
    });
  }

  void _incrementCounter() {
    setState(()  {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter+=0.001;
      if(_counter>1) _counter = 1;
       _counterFMT = format(_counter*100) + "%";
      // Article article = await getData("1");
      // _counterFMT = "" + article.Title;
    });
  }
 */

  void _stopValues() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      log('STOP');
      loop = false;
    });
  }

  void _startValues() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      log('START');
      loop = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    /*
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
          // Column is also a layout widget. It takes a list of children and
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
              style: Theme.of(context).textTheme.headline4,
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
     */

    return Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body:
      Column(
          children: <Widget> [
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
            Row( // ROW0 - HEADER
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: FutureBuilder<ServiceStatus>(
                      future: futureServiceStatus,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text("SERVICE REST at " + myURL + ": " + snapshot.data.Status);
                        } else if (snapshot.hasError) {
                          return Text("SERVICE REST at " + myURL + ": KO"); // ${snapshot.error}
                        }
                        // By default, show a loading spinner.
                        return CircularProgressIndicator();
                      },),
                  )
                ]
            ),
            Row(
      //ROW 1
      children: [
              Container(
                padding: EdgeInsets.all(15.0),
                child: FutureBuilder<ServicePercentage>(
                  future: futureServicePercentage,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.0),
                            ),
                            new CircularPercentIndicator(
                              radius: 130.0,
                              animation: true,
                              animationDuration: 1200,
                              lineWidth: 15.0,
                              percent: getValueFromServicePercentage(snapshot.data, 1),
                              center: new Text(
                                getStrValueFromServicePercentage(snapshot.data, 1, "%"),
                                style:
                                new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                              ),
                              circularStrokeCap: CircularStrokeCap.butt,
                              backgroundColor: Colors.yellow,
                              progressColor: Colors.red,
                            ),
                            new Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.0),
                            ),
                            new CircularPercentIndicator(
                              radius: 130.0,
                              animation: true,
                              animationDuration: 1200,
                              lineWidth: 15.0,
                              percent: getValueFromServicePercentage(snapshot.data, 2),
                              center: new Text(
                                getStrValueFromServicePercentage(snapshot.data, 2, "°"),
                                style:
                                new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                              ),
                              circularStrokeCap: CircularStrokeCap.butt,
                              backgroundColor: Colors.blue,
                              progressColor: Colors.green,
                            )
                          ]
                        );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    // By default, show a loading spinner.
                    return CircularProgressIndicator();
                  },
                )
              )
      ]
      ),
          Row( // ROW2
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
/*
              Expanded(
                child: FutureBuilder<ServicePercentage>(
                        future: futureServicePercentage,
                        builder: (context, snapshot) {
                        if (snapshot.hasData) {
                            return Text(snapshot.data.Percentage1);
                        } else if (snapshot.hasError) {
                                    return Text("${snapshot.error}");
                                }
                        // By default, show a loading spinner.
                        return CircularProgressIndicator();
                        },),
              ),

 */
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('Brightness of the bedroom')
                  ] ,
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text('Temperature (in degrees)')
                  ],
                ),
              ),
            ]
        ),

            Row( // ROW3
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Text(loop ? 'DEMO ON' : 'DEMO OFF')
                      ] ,
                    ),
                  )
                ]
            )


     ]
    )
    ,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,  floatingActionButton: Padding(padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              onPressed: _stopValues,
              tooltip: 'RESET',
              child: Icon(Icons.wb_incandescent_outlined),
            ),
            FloatingActionButton(
              onPressed: _startValues,
              tooltip: 'START',
              child: Icon(Icons.wb_incandescent_rounded),
            )
          ],
        ),
      )
      , // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
