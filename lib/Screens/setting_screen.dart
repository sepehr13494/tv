
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  double _sliderDiscreteValue=1;
  double _sliderDiscreteValue2=1;
  bool _valuCB=false;
  bool _valuCB2=false;
  int _selectedradio=10;
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
      body: Padding(
        padding: EdgeInsets.only(left: 50,right: 10,top: 10,bottom: 10),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
          width: 10000,
          height: 10000,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(alignment: Alignment.topLeft,
                  child: Text("General",style: TextStyle(color: Colors.pink),),
                ),
                InkWell(
                  onTap: (){
                    setState(() {
                      _valuCB=!_valuCB;
                    });
                  },
                  child: Padding(padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: TextDirection.ltr,
                      children: [
                        Text("Start App automatically after reboot",style: TextStyle(color: Colors.white),),
                        Checkbox(value: _valuCB,hoverColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    setState(() {
                      _valuCB2=!_valuCB2;
                    });
                  },
                  child: Padding(padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection: TextDirection.ltr,
                      children: [
                        Text("Show EPG when a channel is selected",style: TextStyle(color: Colors.white),),
                        Checkbox(value: _valuCB2,hoverColor: Colors.white,),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){
                    showAlertDialog(context);
                  },
                  child: Padding(padding: EdgeInsets.only(top: 25),
                    child: Column(
                      children: [Align(alignment: Alignment.centerLeft,child: Text("Aspect Ratio",style: TextStyle(color: Colors.white),)),
                        Align(alignment: Alignment.centerLeft,child: Text("Force aspect ratio for all streams",style: TextStyle(color: Colors.grey),),),
                      ],
                    ),
                    ),
                ),
                InkWell(
                  onTap: (){

                  },
                  child: Padding(padding: EdgeInsets.only(top: 30),
                    child: Column(
                      children: [Align(alignment: Alignment.centerLeft,child: Text("EDG Time Shift",style: TextStyle(color: Colors.white),)),
                        Align(alignment: Alignment.centerLeft,child: Text("Set the EPG time shift in hours",style: TextStyle(color: Colors.grey),),),
                        Row(textDirection: TextDirection.ltr,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Slider(
                                value: _sliderDiscreteValue,
                                min: 0,
                                max: 100,
                                onChanged: (value) {
                                  setState(() {
                                    _sliderDiscreteValue = value;
                                  });
                                },
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(right: 15),
                                child: Text("10",style: TextStyle(color: Colors.white),)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                InkWell(
                  onTap: (){

                  },
                  child: Padding(padding: EdgeInsets.only(top: 30),
                    child: Column(
                      children: [Align(alignment: Alignment.centerLeft,child: Text("Buffer Time",style: TextStyle(color: Colors.white),)),
                        Align(alignment: Alignment.centerLeft,child: Text("Set in buffer time in milliseconds",style: TextStyle(color: Colors.grey),),),
                        Row(textDirection: TextDirection.ltr,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Slider(
                                value: _sliderDiscreteValue2,
                                min: 0,
                                max: 100,
                                onChanged: (value) {
                                  setState(() {
                                    _sliderDiscreteValue2 = value;
                                  });
                                },
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(right: 15),
                                child: Text("10",style: TextStyle(color: Colors.white),)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                InkWell(
                  onTap: (){

                  },
                  child: Padding(padding: EdgeInsets.only(top: 30),
                    child: Column(
                      children: [Align(alignment: Alignment.centerLeft,child: Text("Change PIN Code",style: TextStyle(color: Colors.white),)),
                        Align(alignment: Alignment.centerLeft,child: Text("Change PIN Code. default (0000)",style: TextStyle(color: Colors.grey),),)
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: (){

                  },
                  child: Padding(padding: EdgeInsets.only(top: 30),
                    child: Column(
                      children: [Align(alignment: Alignment.centerLeft,child: Text("Clear Disk Cache",style: TextStyle(color: Colors.white),)),
                        Align(alignment: Alignment.centerLeft,child: Text("Fresh used disk space",style: TextStyle(color: Colors.grey),),)
                      ],
                    ),
                  ),
                ),
                InkWell(
                    onTap: (){

                    },
                    child: Padding(padding: EdgeInsets.only(top: 25),child: Align(alignment: Alignment.centerLeft,child: Text("Help",style: TextStyle(color: Colors.white),),),)),
              ],
            ),
          ),
        ),
      ),
    );
  }
  showAlertDialog(BuildContext context) {
    // set up the buttons

    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed:  () {},
    );
    
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Select Aspect Ratio"),
      content: Column(
        children: [
          Radio(
            value: 0,
            activeColor: Colors.blue,
            groupValue: _selectedradio,
            onChanged: (value){
              setState(() {
                _selectedradio=value;
              });
            },
          ),
          Radio(
            value: 1,
            activeColor: Colors.blue,
            groupValue: _selectedradio,
            onChanged: ( value){
              setState(() {
                print(value);
                _selectedradio=value;
              });
            },
          ),
        ],
      ),
      actions: [
        cancelButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

