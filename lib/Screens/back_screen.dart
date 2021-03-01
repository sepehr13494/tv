import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BackScreen extends StatefulWidget {
  @override
  _BackScreenState createState() => _BackScreenState();
}
class _BackScreenState extends State<BackScreen> {
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
      //backgroundColor: Colors.black,
      body: Column(
        children: [
          Align(alignment: Alignment.topCenter,),
          Align(alignment: Alignment.bottomCenter,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [Icon(Icons.search,color: Colors.white,size: 30,),
                Text("Channel Search",style: TextStyle(color: Colors.white),)],),
              Column(children: [Icon(Icons.search,color: Colors.white,),
                Text("Channel Search",style: TextStyle(color: Colors.white),)],),
              Column(children: [Icon(Icons.settings,color: Colors.white,),
                Text("Settings",style: TextStyle(color: Colors.white),)],),
              Column(children: [Icon(Icons.account_circle,color: Colors.white,),
                Text("Exit",style: TextStyle(color: Colors.white),)],),
            ],
           ),
          ),
        ],
      ),
    );
  }
}


