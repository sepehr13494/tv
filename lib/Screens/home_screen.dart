import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:tv/Screens/tv_channel.dart';
import 'package:tv/models/ActiveCodeModel.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width*0.6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "World TV",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 10),
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
                            Text(
                              "To find free activation code send messege in Telegram",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10
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
                            checkCode();
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> checkCode() async {
    var response = await Dio().post("https://zaltv.co/wp-json/user/status",data: {
      "code" : _controller.text
    });
    print(response.toString());
    final activeCodeObj = activeCodeObjFromJson(response.toString());
    Toast.show(activeCodeObj.response.message, context,gravity: Toast.TOP);
    if (activeCodeObj.response.message == "Success") {
      if (activeCodeObj.response.codeStatus == "Active") {
        Navigator.push(context, MaterialPageRoute(builder: (context) => TvChannel(url: activeCodeObj.response.m3UUrl, xml:activeCodeObj.response.epgLink)));
      }
    }
  }
}
