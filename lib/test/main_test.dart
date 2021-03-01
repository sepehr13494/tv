import 'package:flutter/material.dart';
import 'package:tv/Screens/back_screen.dart';
import 'package:tv/Screens/home_screen.dart';
import 'package:tv/Screens/setting_screen.dart';
import 'package:tv/Screens/tv_channel.dart';

import '../main.dart';

void main() => runApp(WorldTv());
  // This widget is the root of your application.
  @override class WorldTv extends StatelessWidget {

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.blueGrey,
      title: 'Flutter Demo',
      theme: ThemeData(
      ),
      home: SettingScreen(),
    );
  }
}
