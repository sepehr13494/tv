import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:tv/models/tvobject.dart';
import 'package:tv/models/tvDetails.dart';
//import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:xml2json/xml2json.dart';
import 'package:http/http.dart' as http;

class TvCalender extends StatefulWidget {
  final String link;

  const TvCalender({Key key, this.link}) : super(key: key);

  @override
  _TvCalenderState createState() => _TvCalenderState();
}

class _TvCalenderState extends State<TvCalender> {
  TvObject tvObject;
  List<TvDetails> tvProgramDetailsList=[];
  List<String> litems = [];
  String programsViewDate=DateFormat('yyyyMMdd').format(DateTime.now());



  @override
  void initState() {
    //print(DateTime.parse("20210305013500 +0000"));
    print("dsds");
    fetchUrl();
    /*result(tvObject);
    _function();*/
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
                    GestureDetector(
                      onTap: (){
                        tvObject = tvObjectFromJson(myString.replaceAll(r'\', ""));
                      },
                      child: Container(
                        margin: EdgeInsets.all(10),
                        alignment: Alignment.bottomLeft,
                        color: Colors.grey.withOpacity(0.3),
                        width: 150,
                        height: 100,
                      ),
                    ),
                    Container(
                      child: Text('No information'),
                    )
                  ],
                ),
                height: 150,
                width: double.maxFinite,
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: tvProgramDetailsList.length,
                  itemBuilder: (BuildContext ctxt, int index) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Container(
                                  padding: EdgeInsets.all(4),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.all(2),
                                  height: 70,
                                  color: Colors.grey.withOpacity(0.3),
                                         child: Row(
                                           children: [
                                             Container(
                                               child: Text(
                                                 tvProgramDetailsList[index].channel.displayName.t,
                                                 style: TextStyle(color: Colors.white),
                                               ),
                                             ),
                                             Container(),
                                           ],
                                     ),
                                ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(2),
                            height: 70,
                            color: Colors.transparent,
                            child: Container(
                              height: 70,
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemCount:tvProgramDetailsList[index].programms.length,
                                  itemBuilder:
                                      (BuildContext ctxt, int index2) {
                                    return Container(
                                      margin: EdgeInsets.all((2)),
                                      alignment: Alignment.center,
                                      width: 150,
                                      height: 60,
                                      color: Colors.black.withOpacity(0.5),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Container(
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                         margin:EdgeInsets.all(3),
                                                          child: Text(tvProgramDetailsList[index].programms[index2].start.substring(8,10),style: TextStyle(color: Colors.white),)),
                                                      Container(child: Text(":"),),
                                                      Container(
                                                          margin:EdgeInsets.all(3),
                                                          child: Text(tvProgramDetailsList[index].programms[index2].start.substring(10,12),style: TextStyle(color: Colors.white),)),
                                                    ],
                                                  ),),
                                              Container(
                                                child: Row(
                                                  children: [
                                                    Container(
                                                        margin:EdgeInsets.all(3),
                                                        child: Text(tvProgramDetailsList[index].programms[index2].stop.substring(8,10),style: TextStyle(color: Colors.white),)),
                                                    Container(child: Text(":"),),
                                                    Container(
                                                        margin:EdgeInsets.all(3),
                                                        child: Text(tvProgramDetailsList[index].programms[index2].stop.substring(10,12),style: TextStyle(color: Colors.white),)),
                                                  ],
                                                ),),
                                               ],
                                          ),
                                          Container(
                                            margin:EdgeInsets.all(3),
                                            child:  Text(
                                              tvProgramDetailsList[index].programms[index2].title.t,
                                              style: TextStyle(
                                                  color: Colors.white),
                                              textAlign: TextAlign.center,
                                              // textDirection:
                                              // TextDirection.ltr,
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        )
                      ],
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
/*
  Future<void> _function() async {
    Response response = await Dio().get(widget.link);
    final document = XmlDocument.parse(response.data);
    print(document.toString());
    log(document.toXmlString(pretty: true, indent: '\t'));
    print("\n");
    final total = document.findAllElements('channel');
    print(total.first.name);
  }

  List<TvDetails> result(TvObject tvObject){
    for(var ch in tvObject.tv.channel){
      tvProgramDetailsList.add(TvDetails(channel: ch,programms: []));
      for(var pr in tvObject.tv.programme){
          //if(ch.id==pr.channel && programsViewDate==pr.start.substring(0,8)){
          if(ch.id==pr.channel ){
          tvProgramDetailsList.last.programms.add(pr);
        }
        else {
        }
      }
    }
  }*/

  String myString;

  void fetchUrl() async{
    print("salam");
    print(widget.link);
    final Xml2Json xml2Json = Xml2Json();
    /*var xmlString1 = '''<tv generator-info-name="More-TV" generator-info-url="http://client.more-itv.com:8080/">
    <channel id="zdfinfo.de">
<display-name>### ۩ Bein Sports ۩ ### </display-name>
</channel>
<channel id="zdfinfo.de2">
<display-name>SPORT AR: Bein Sport USA HD</display-name>
</channel>
<channel id="zdfinfo.de3">
<display-name>SPORT TR: Bein Sports 1 TR HD</display-name>
<icon src="https://static.epg.best/tr/beINSports1.tr.png"/>
</channel>
<channel id="zdfinfo.de4">
<display-name>SPORT TR: Bein Sports 2 TR HD</display-name>
<icon src="https://static.epg.best/tr/beINSports2.tr.png"/>
</channel>
<channel id="zdfinfo.de5">
<display-name>SPORT TR: Bein Sports 3 TR HD</display-name>
<icon src="https://static.epg.best/tr/beINSports3.tr.png"/>
</channel>
<programme start="20210306082500 +0000" stop="20210306083300 +0000" channel="zdfinfo.de">
<title>Inui</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306083300 +0000" stop="20210306093300 +0000" channel="zdfinfo.de">
<title>Inui</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306093300 +0000" stop="20210306103000 +0000" channel="zdfinfo.de">
<title>Inui</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306103000 +0000" stop="20210306113300 +0000" channel="zdfinfo.de">
<title>Inui</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>

<programme start="20210306082500 +0000" stop="20210306083300 +0000" channel="zdfinfo.de2">
<title>Inui2</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306083300 +0000" stop="20210306093300 +0000" channel="zdfinfo.de2">
<title>Inui2</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306093300 +0000" stop="20210306103000 +0000" channel="zdfinfo.de2">
<title>Inui2</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306103000 +0000" stop="20210306113300 +0000" channel="zdfinfo.de2">
<title>Inui2</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>

<programme start="20210306082500 +0000" stop="20210306083300 +0000" channel="zdfinfo.de3">
<title>Inui3</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306083300 +0000" stop="20210306093300 +0000" channel="zdfinfo.de3">
<title>Inui3</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306093300 +0000" stop="20210306103000 +0000" channel="zdfinfo.de3">
<title>Inui3</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306103000 +0000" stop="20210306113300 +0000" channel="zdfinfo.de3">
<title>Inui3</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>

<programme start="20210306082500 +0000" stop="20210306083300 +0000" channel="zdfinfo.de4">
<title>Inui4</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306083300 +0000" stop="20210306093300 +0000" channel="zdfinfo.de4">
<title>Inui4</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306093300 +0000" stop="20210306103000 +0000" channel="zdfinfo.de4">
<title>Inui4</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306103000 +0000" stop="20210306113300 +0000" channel="zdfinfo.de4">
<title>Inui4</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>

<programme start="20210306082500 +0000" stop="20210306083300 +0000" channel="zdfinfo.de5">
<title>Inui5</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306083300 +0000" stop="20210306093300 +0000" channel="zdfinfo.de5">
<title>Inui5</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306093300 +0000" stop="20210306103000 +0000" channel="zdfinfo.de5">
<title>Inui5</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306103000 +0000" stop="20210306113300 +0000" channel="zdfinfo.de5">
<title>Inui5</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>

<programme start="20210306082500 +0000" stop="20210306083300 +0000" channel="zdfinfo.de6">
<title>Inui6</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306083300 +0000" stop="20210306093300 +0000" channel="zdfinfo.de6">
<title>Inui6</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306093300 +0000" stop="20210306103000 +0000" channel="zdfinfo.de6">
<title>Inui6</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
<programme start="20210306103000 +0000" stop="20210306113300 +0000" channel="zdfinfo.de6">
<title>Inui6</title>
<desc>eizoen 1 - Aflevering 21 van 26 - Verstoppertje in de sneeuw - KRO-NCRV Na een flinke sneeuwstorm gaat Inui op pad om haar vrienden te zoeken. Die zijn door de storm bedekt met een dikke laag sneeuw, dus Inui ziet ze niet. Dat zorgt natuurlijk voor een hoop pret. Onze nieuwe app is nu al te testen! Download hem op apps.gids.tv Inui op tv . CAST:Kathy Wauwgh, Peter van Gucht, Walter Baele, Britt Van Der Borght, , Mat Den Boer</desc>
</programme>
    </tv>''';*/
     final xmlString = await http.get(widget.link);
     xml2Json.parse(utf8.decode(xmlString.bodyBytes));
    //xml2Json.parse(xmlString1);
    var jsonString = xml2Json.toGData();
    myString = jsonString;
    tvObject = tvObjectFromJson(jsonString.replaceAll(r'\', ""));
    print(tvObject.tv.channel[0].displayName);
    for(var i in tvObject.tv.channel){
      List<String> displayNameList=[];
      int count=0;
      //displayNameList.add(i.displayName.t);
      log(displayNameList[count]);
      count++;
    }
    // just for setting icon

  }
}
