import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:tv/Screens/tv_channel.dart';
import 'package:tv/models/ActiveCodeModel.dart';
import 'package:tv/models/appvVersionObj.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _controller = TextEditingController();
  bool hasCode = false;
  String activeCode;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    checkVersion();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: hasCode
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("code : " + activeCode),
                  SizedBox(height: 20),
                  CircularProgressIndicator.adaptive(),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/logo.jpg",
                            width: 100,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            child: Container(
                              color: Colors.grey[900],
                              padding: EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info),
                                  SizedBox(width: 10),
                                  RichText(
                                    text: new TextSpan(
                                      children: [
                                        new TextSpan(
                                          text: 'To load your M3U playlist, create free activation code at ',
                                          style: new TextStyle(fontSize: 10),
                                        ),
                                        new TextSpan(
                                          text: 'zaltv.co',
                                          style: new TextStyle(fontSize: 10,color: Colors.lightBlueAccent),
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
                                            launch('https://zaltv.co');
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  checkCode(_controller.text);
                                },
                                child: Text(
                                  "Activate",
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: _controller,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your activation code',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              List<ActiveCodeResponse> entries = [];
                              for (var entry in jsonDecode(
                                  prefs.getString("codeList") ?? "[]")) {
                                entries.add(ActiveCodeResponse.fromJson(entry));
                              }
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, innerSetState) {
                                        return Dialog(
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: List.generate(
                                                  entries.length, (index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(10.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      setState(() {
                                                        _controller.text = entries[index].code;
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 300,
                                                      padding: EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: Colors.white)
                                                      ),
                                                      child: Center(
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(entries[index].code),
                                                            Spacer(),
                                                            Row(
                                                              children: [
                                                                Text("exp: " + entries[index].expirationDate.toString().split(" ")[0]),
                                                                SizedBox(width: 10),
                                                                IconButton(
                                                                  icon: Icon(Icons.delete),
                                                                  onPressed: (){
                                                                    innerSetState((){
                                                                      entries.removeAt(index);
                                                                      prefs.setString("codeList", jsonEncode(entries));
                                                                    });
                                                                  },
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ),
                                          ),
                                        );
                                      }
                                    );
                                  });
                            },
                            child: Text("My Codes"),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> checkCode(String code) async {
    var response =
        await Dio().post("https://zaltv.co/wp-json/user/status", data: {
      //"code" : "1688917062"
      "code": code,
    });
    print(response.toString());
    final activeCodeObj = activeCodeObjFromJson(response.toString());
    Toast.show(activeCodeObj.response.message, context, gravity: Toast.TOP);
    if (activeCodeObj.response.message == "Success") {
      if (activeCodeObj.response.codeStatus == "Active") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        activeCodeObj.response.code = code;
        prefs.setString("code", activeCodeObj.response.code);
        addToCode(response: activeCodeObj.response);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TvChannel(
                    url: activeCodeObj.response.m3UUrl,
                    xml: activeCodeObj.response.epgLink)));
      } else {
        setState(() {
          hasCode = false;
        });
      }
    } else {
      setState(() {
        hasCode = false;
      });
    }
  }

  Future<void> addToCode({ActiveCodeResponse response}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<ActiveCodeResponse> entries = [];
    for (var entry in jsonDecode(prefs.getString("codeList") ?? "[]")) {
      entries.add(ActiveCodeResponse.fromJson(entry));
    }
    if (entries.where((element) => element.code == response.code).length == 0) {
      entries.add(response);
    }
    prefs.setString("codeList", jsonEncode(entries));
  }

  Future<void> checkExistCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String code = prefs.getString("code") ?? "";
    if (code != "") {
      setState(() {
        hasCode = true;
        activeCode = code;
      });
      checkCode(code);
    }
    print(code);
  }

  Future<void> checkVersion() async {
    try{
      var response = await Dio().post("https://zaltv.co/wp-json/user/app/update", data: {
        "version": (await PackageInfo.fromPlatform()).version,
      },options: Options(
        validateStatus: (status){
          return status<500;
        }
      ));
      print(response.toString());
      final appVersionObj = appVersionObjFromJson(response.toString());
      if (appVersionObj.response.newVersion == (await PackageInfo.fromPlatform()).version) {
        checkExistCode();
      }else{
        checkExistCode();
        showDialog(context: context, builder: (context){
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("New Update Available. Please Update Your App"),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: (){
                    launch(appVersionObj.response.newVersionUrl);
                  }, child: Text("Go To Download Link"))
                ],
              ),
            ),
          );
        });
      }
    }catch (e){
      print(e.toString());
    }
  }
}
