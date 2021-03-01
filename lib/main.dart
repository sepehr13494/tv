import 'package:flutter/material.dart';
import 'package:tv/Screens/home_screen.dart';
import 'package:tv/Screens/tv_channel.dart';

void main() => runApp(WorldTv());

class WorldTv extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          brightness: Brightness.dark,
          backgroundColor: Colors.black,
          scaffoldBackgroundColor: Colors.black,
          accentColor: Colors.pink[800],
          textTheme: TextTheme(
            subhead: TextStyle(color: Colors.black),
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.black,
          ),
          toggleButtonsTheme: ToggleButtonsThemeData(color: Colors.pink[800]),
          sliderTheme: SliderThemeData(
            thumbColor: Colors.pink[800],
            activeTrackColor: Colors.pink[800],
          ),
          inputDecorationTheme: InputDecorationTheme(
              fillColor: Colors.grey[100],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Colors.pink[800], width: 2.0),
              ),
              contentPadding: EdgeInsets.all(5),
              hintStyle: TextStyle(color: Colors.grey[700],fontSize: 14)),
          buttonColor: Colors.pink[800],
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                  primary: Colors.pink[800], padding: EdgeInsets.only(top: 15,bottom: 15,left: 35, right: 35)))),
      home: HomeScreen(),
    );
  }
}
