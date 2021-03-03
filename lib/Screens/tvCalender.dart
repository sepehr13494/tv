import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class TvCalender extends StatefulWidget {

  final String link;

  const TvCalender({Key key, this.link}) : super(key: key);

  @override
  _TvCalenderState createState() => _TvCalenderState();
}

class _TvCalenderState extends State<TvCalender> {
  List<String> litems = [
    "channel1",
    "channel2",
    "channel3",
    "channel4",
    'channel5',
    'channel6'
  ];

  @override
  void initState() {
    //_function();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.25),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.bottomLeft,
                      color: Colors.grey.withOpacity(0.3),
                      width: 150,
                      height: 100,
                    ),
                    Container(
                      child: Text('No information'),
                    )
                  ],
                ),
                height: 150,
                width: double.maxFinite,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: litems.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(2),
                                height: 50,
                                color: Colors.grey.withOpacity(0.3),
                                child: Text(
                                  litems[index],
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            })
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: litems.length,
                            itemBuilder: (BuildContext ctxt, int index) {
                              return Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(2),
                                height: 50,
                                color: Colors.transparent,
                                child: Container(
                                  height: 50,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      itemCount: litems.length,
                                      itemBuilder:
                                          (BuildContext ctxt, int index) {
                                        return Container(
                                          margin: EdgeInsets.all((2)),
                                          alignment: Alignment.center,
                                          width: 150,
                                          height: 60,
                                          color: Colors.black.withOpacity(0.5),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Container(
                                                      margin:EdgeInsets.all(5),
                                                      child: Text('1:00',style: TextStyle(color: Colors.white),)),
                                                  Container(
                                                    margin:EdgeInsets.all(5),
                                                    child:Text('2:00',style: TextStyle(color: Colors.white),)
                                                  ), ],
                                              ),
                                          Container(
                                          //  padding:EdgeInsets.only(bottom: 5),
                                            child:  Text(
                                                litems[index],
                                                style: TextStyle(
                                                    color: Colors.white),
                                                textAlign: TextAlign.center,
                                                textDirection:
                                                    TextDirection.ltr,
                                              ),)
                                            ],
                                          ),
                                        );
                                      }),
                                ),
                              );
                            })
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _function() async {
    Response response = await Dio().get(widget.link);
    final document = XmlDocument.parse(response.data);
    print(document.toString());
    log(document.toXmlString(pretty: true, indent: '\t'));
    print("\n");
    final total = document.findAllElements('channel');
    print(total.first.name);
  }
}
