import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:breeze/components/bottom_nav.dart';
import 'package:async/async.dart';

Future _getWeather() async {
  final response =
      await http.get("http://127.0.0.1:8080/get_weather?how=daily");
  return jsonDecode(response.body);
}

class HomePage extends StatefulWidget {
  final bool openBottomNavBar;
  const HomePage({
    Key key,
    this.openBottomNavBar = false,
  }) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  dynamic _weatherData;

  @override
  initState() {
    super.initState();
    _loadWeatherData();
    //Timer.periodic(Duration(seconds: 15), (Timer t) => _loadWeatherData());
  }

  _loadWeatherData() {
    return this._memoizer.runOnce(() async {
      _getWeather().then((value) {
        print("here");
        setState(() {
          _weatherData = value;
        });
        Timer(Duration(seconds: 3), () {
          print("collecting again..");
        });
      });
      //await Future.delayed(const Duration(seconds: 2), () {});
    });
  }

  Widget _buildImageSection() {
    return FadeInDown(
      from: 100,
      duration: Duration(milliseconds: 1000),
      child: Container(
        width: 130,
        height: 130,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.pink.shade50,
          borderRadius: BorderRadius.circular(100),
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset("assets/breeze_icon.png")),
      ),
    );
  }

  Widget _buildInformationSection() {
    return Container(
        padding: EdgeInsets.all(20.0),
        child: Column(children: <Widget>[
          FadeInUp(
              from: 60,
              delay: Duration(milliseconds: 500),
              duration: Duration(milliseconds: 1000),
              child: Text(
                _weatherData["date_collecte"],
                style: TextStyle(color: Colors.grey),
              )),
          SizedBox(
            height: 10,
          ),
          FadeInUp(
              from: 60,
              delay: Duration(milliseconds: 500),
              duration: Duration(milliseconds: 1000),
              child: Text(
                "température : ",
                style: TextStyle(color: Colors.grey),
              )),
          FadeInUp(
              from: 30,
              delay: Duration(milliseconds: 800),
              duration: Duration(milliseconds: 1000),
              child: Text(
                _weatherData["temperature"].toString() + "° C",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 20,
          ),
          FadeInUp(
              from: 60,
              delay: Duration(milliseconds: 500),
              duration: Duration(milliseconds: 1000),
              child: Text(
                "humidité : ",
                style: TextStyle(color: Colors.grey),
              )),
          FadeInUp(
              from: 30,
              delay: Duration(milliseconds: 800),
              duration: Duration(milliseconds: 1000),
              child: Text(
                _weatherData["humidity"].toString() + " %",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              )),
          SizedBox(
            height: 60,
          ),
          Center(
              child: FadeInUp(
                  from: 30,
                  delay: Duration(milliseconds: 800),
                  duration: Duration(milliseconds: 1000),
                  child: Text(
                    "Il fait un peu chaud aujourd'hui, gare aux moustiques!!!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )))
        ]));
  }

  Widget _buildAdvicesButton() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: MediaQuery.of(context).size.width / 1.3,
      child: FadeInUp(
        duration: Duration(milliseconds: 1000),
        child: MaterialButton(
          onPressed: () async {},
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          color: Color(0xff00a8ff),
          child: Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Suivre nos conseils ",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeContent() {
    return Stack(children: [
      SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              _buildImageSection(),
              SizedBox(
                height: 20,
              ),
              _buildInformationSection(),
              SizedBox(
                height: 20,
              ),
              _buildAdvicesButton()
            ],
          ),
        ),
      ),
      BottomNav(
        openBottomNavBar: widget.openBottomNavBar,
      )
    ]);
  }

  Widget _buildHomeContent() {
    if (_weatherData == null || _weatherData.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height / 5,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                    child: Text(
                        "Nous collectons le climat actuel à l'EPT, patientez svp...",
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height / 65))),
              ],
            )
          ],
        ),
      );
    } else {
      return FutureBuilder<dynamic>(
          future: _loadWeatherData(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                  height: MediaQuery.of(context).size.height / 5,
                  child: Center(
                    child: Text(
                      "Patientez svp...",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 50.75,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ));
            } else {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return _homeContent();
              }
            }
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(
                  'EPT weather ',
                  style: TextStyle(color: Colors.black),
                )),
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: _buildHomeContent()));
  }
}
