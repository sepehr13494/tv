import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:tv/models/tvobject.dart';
import 'package:tv/models/tvDetails.dart';
import 'package:flutter/material.dart';
import 'package:xml2json/xml2json.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';


class TvCalender extends StatefulWidget {
  final String link;
  final List<String> channels;

  const TvCalender({Key key, this.link, this.channels}) : super(key: key);

  @override
  _TvCalenderState createState() => _TvCalenderState();
}

class _TvCalenderState extends State<TvCalender> {

  List<TvDetails> tvProgramDetailsListShow = [];
  List<TvDetails> tvProgramDetailsListAll = [];
  String getDateFromAlert=DateFormat('yyyyMMdd').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day));
  List<TvDetails> tvProgramDetailsListToday = [];
  List<TvDetails> tvProgramDetailsListTomorrow = [];
  List<TvDetails> tvProgramDetailsList2DaysLater= [];
  List<TvDetails> tvProgramDetailsList3DaysLater = [];
  List<TvDetails> tvProgramDetailsList4DaysLater = [];
  List<TvDetails> tvProgramDetailsList5DaysLater = [];
  List<TvDetails> tvProgramDetailsList6DaysLater = [];

  List<String> programViewDateWhen=[DateFormat('yyyyMMdd').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day)),DateFormat('yyyyMMdd').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+1)),DateFormat('yyyyMMdd').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+2)),DateFormat('yyyyMMdd').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+3)),DateFormat('yyyyMMdd').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+4)),DateFormat('yyyyMMdd').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+5)),DateFormat('yyyyMMdd').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+6))];

  int _groupvalu;
  int countday;

  Programme descriptionPrograms;
  final Xml2Json xml2Json = Xml2Json();
  XmlDocument document1;
  bool isLoading=false;
  var xmlString1;
  var xmlString;
  List<String> channelGetfromIds=[];
  List<String> ids=[];
  List<String> selectIds=[];
  int countScrollListener=0;
  int numbertOfView=10;
  var totalPrograms;
  var totalChannels;
  List<XmlElement> xmlListPrograms;
  List<XmlElement> xmlListChannels;
  ScrollController _scrollController = new ScrollController();
  @override
  void initState() {
    print(DateTime.now());
    _function();
    print("recieve data");
    super.initState();
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.withOpacity(0.25),
        body: document1 == null ? Center(child: CircularProgressIndicator.adaptive()) : Column(
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
                  Expanded(child: SingleChildScrollView(
                      padding: EdgeInsets.only(left: 20,right: 20,top: 15),
                      child: Column(
                        children: [
                          Container(
                            child:Text(descriptionPrograms?.title?.t??"") ,
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Container(
                              child: Text(descriptionPrograms?.desc?.t??"")
                          ),
                        ],
                      )
                  )
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Padding(padding: EdgeInsets.only(right: 40),
                    child: InkWell(
                        child: Text(
                          textString(),
                          //programsViewDate = DateFormat('yyyyMMdd').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day));,
                        ),
                        onTap: (){
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                  backgroundColor: Colors.grey[900],
                                  title: Text("Select Day"),
                                  content: SingleChildScrollView(
                                    child: StatefulBuilder(
                                      builder: (BuildContext context, StateSetter innersetState) {
                                        return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: List.generate(7, (index) {
                                              if(index==0){
                                                return ListTile(
                                                  title: Text(
                                                    "Today",
                                                    style: TextStyle(color: Colors.white),
                                                    //style: TextStyle(color: textSelectedColor(selectedRadioButton[0])),
                                                  ),
                                                  leading: Radio(
                                                    activeColor: Colors.pinkAccent,
                                                    value: index,
                                                    groupValue: _groupvalu,
                                                    onChanged: (value) {
                                                      descriptionPrograms=new Programme(title: DisplayName(t: ""),desc: DisplayName(t: ""));
                                                      print(value);
                                                      innersetState(() {
                                                        _groupvalu=value;
                                                        // programsViewDateToday = DateFormat('yyyyMMdd').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day));
                                                        print(programViewDateWhen[0]);
                                                      });
                                                      setState(() {
                                                        // result2(document1);
                                                        //List<bool> selectedRadioButton=[true,false,false,false,false,false];
                                                        tvProgramDetailsListShow=tvProgramDetailsListToday;
                                                        getDateFromAlert=programViewDateWhen[0];
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                );
                                              }
                                              else{
                                                return ListTile(
                                                  title: Text(
                                                    DateFormat('EEEE').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+index)),
                                                    style: TextStyle(color: Colors.white),
                                                    //style: TextStyle(color: textSelectedColor(selectedRadioButton[0])),
                                                  ),
                                                  leading: Radio(
                                                    activeColor: Colors.pinkAccent,
                                                    value: index,
                                                    groupValue: _groupvalu,
                                                    onChanged: (value) {
                                                      descriptionPrograms=new Programme(title: DisplayName(t: ""),desc: DisplayName(t: ""));
                                                      print(value);
                                                      innersetState(() {
                                                        countday=index;
                                                        _groupvalu=value;

                                                      });
                                                      setState(() {
                                                        // result2(document1);
                                                        //List<bool> selectedRadioButton=[true,false,false,false,false,false];
                                                        if(index==1){
                                                          tvProgramDetailsListShow= tvProgramDetailsListTomorrow;
                                                          getDateFromAlert=programViewDateWhen[1];
                                                        }
                                                        else if(index==2){
                                                          tvProgramDetailsListShow= tvProgramDetailsList2DaysLater;
                                                          getDateFromAlert=programViewDateWhen[2];
                                                        }
                                                        else if(index==3){
                                                          tvProgramDetailsListShow= tvProgramDetailsList3DaysLater;
                                                          getDateFromAlert=programViewDateWhen[3];
                                                        }
                                                        else if(index==4){
                                                          tvProgramDetailsListShow= tvProgramDetailsList4DaysLater;
                                                          getDateFromAlert=programViewDateWhen[4];
                                                        }
                                                        else if(index==5){
                                                          tvProgramDetailsListShow= tvProgramDetailsList5DaysLater;
                                                          getDateFromAlert=programViewDateWhen[5];
                                                        }
                                                        else if(index==6){
                                                          tvProgramDetailsListShow= tvProgramDetailsList6DaysLater;
                                                          getDateFromAlert=programViewDateWhen[6];
                                                        }
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                );
                                              }

                                            })
                                        );
                                      },
                                    ),
                                  )
                              );
                            },
                          );
                          setState(() {
                          });
                        }
                    ),),
                ],
              ),
              height: 100,
              width: double.maxFinite,
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Container(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: tvProgramDetailsListShow.length,
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
                                        Expanded(child: Container(
                                          child: Text(
                                            tvProgramDetailsListShow[index].channel
                                                .displayName?.t??"",
                                            style: TextStyle(),
                                          ),
                                        ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    margin: EdgeInsets.all(2),
                                    height: 70,
                                    color: Colors.transparent,
                                    child : tvProgramDetailsListShow[index].programms.length==0 ? Container(child: Text("No information"),) :
                                    Container(
                                      height: 70,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          shrinkWrap: true,
                                          itemCount: tvProgramDetailsListShow[index]
                                              .programms.length,
                                          itemBuilder:
                                              (BuildContext ctxt, int index2) {
                                            return InkWell(
                                              onTap: (){
                                                setState(() {
                                                  descriptionPrograms=tvProgramDetailsListShow[index].programms[index2];
                                                });
                                              },
                                              child: Container(
                                                margin: EdgeInsets.all((2)),
                                                alignment: Alignment.center,
                                                width: 150,
                                                height: 60,
                                                color: Colors.black.withOpacity(0.5),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .spaceBetween,
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
                                                                  margin: EdgeInsets.all(
                                                                      3),
                                                                  child: Text(
                                                                    tvProgramDetailsListShow[index]
                                                                        .programms[index2]
                                                                        .start.substring(
                                                                        8, 10),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),)),
                                                              Container(
                                                                child: Text(":"),),
                                                              Container(
                                                                  margin: EdgeInsets.all(
                                                                      3),
                                                                  child: Text(
                                                                    tvProgramDetailsListShow[index]
                                                                        .programms[index2]
                                                                        .start.substring(
                                                                        10, 12),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),)),
                                                            ],
                                                          ),),
                                                        Container(
                                                          child: Row(
                                                            children: [
                                                              Container(
                                                                  margin: EdgeInsets.all(
                                                                      3),
                                                                  child: Text(
                                                                    tvProgramDetailsListShow[index]
                                                                        .programms[index2]
                                                                        .stop.substring(
                                                                        8, 10),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),)),
                                                              Container(
                                                                child: Text(":"),),
                                                              Container(
                                                                  margin: EdgeInsets.all(
                                                                      3),
                                                                  child: Text(
                                                                    tvProgramDetailsListShow[index]
                                                                        .programms[index2]
                                                                        .stop.substring(
                                                                        10, 12),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),)),
                                                            ],
                                                          ),),
                                                      ],
                                                    ),
                                                    Expanded(child:
                                                    SingleChildScrollView(
                                                      scrollDirection: Axis.vertical,
                                                      padding: EdgeInsets.all(5),
                                                      child: Text(
                                                        tvProgramDetailsListShow[index].programms[index2].title.t.isEmpty?
                                                        "No information":tvProgramDetailsListShow[index].programms[index2].title.t,
                                                        // tvProgramDetailsListShow[index]
                                                        //     .programms[index2].title.t,
                                                        style: TextStyle(
                                                            color: Colors.white),
                                                        textAlign: TextAlign.center,
                                                        // textDirection:
                                                        // TextDirection.ltr,
                                                      ),
                                                    ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ),
                                )
                              ],
                            );
                          }),
                      // isLoading?Container():Center(child: Container(height:50,child: Text("is Loading"),),),
                      //(isLoading&&tvProgramDetailsListShow.length>numbertOfView-4)?Center(child: CircularProgressIndicator(backgroundColor: Colors.white,)):Container(),
                    ],
                  ),
                ),
              ),
            )
          ],
        )
    );
  }
  Future<void> _function() async {
    var response = await http.get(widget.link);
    document1 = XmlDocument.parse(utf8.decode(response.bodyBytes));
    print(document1.toString());
    //log(document.toXmlString(pretty: true,indent: '\t'));
    print("\n");
    // final total = document.findAllElements('channel');
    // print(total.first.name);
    countScrollListener=0;
    tvProgramDetailsListAll=[];
    initialResultForInput(document1);
    tvProgramDetailsListShow=tvProgramDetailsListToday;
    setState(() {
    });
  }

  void initialResultForInput(XmlDocument inputdoc) {
    setState(() {
      isLoading=false;
    });
    //print(inputdoc.toXmlString(pretty: true,indent: '\t'));
    //log(document.toXmlString(pretty: true,indent: '\t'));
    print("\n");
    totalPrograms = inputdoc.findAllElements('programme');
    totalChannels = inputdoc.findAllElements('channel');
    xmlListPrograms = totalPrograms.toList();
    xmlListChannels = totalChannels.toList();
    log(totalChannels.length.toString());
    for (var i = 0; i < xmlListChannels.length; i++) {
      var xmlvar=xmlListChannels[i];
      var sepehrXml = xmlvar.attributes.first;
      print(xmlvar.text);
      String channelName = xmlvar.text;
      if (sepehrXml.value != "") {
        if (widget.channels.contains(channelName)) {
          ids.add(sepehrXml.value);
          channelGetfromIds.add(channelName);
        }
      }
      print(i);
    }
    if (ids.length > numbertOfView - 1) {
      selectIds = ids.sublist(countScrollListener, countScrollListener + numbertOfView);
    }
    else{
      selectIds=ids;
    }
    if (ids.length<= numbertOfView) {
      selectIds = ids;
    }  else{
      selectIds=ids.sublist(0,numbertOfView);
    }
    if (selectIds.length>0) {
      completeInput();
      addListenerToController();
    }
    print("dddddddddddddddddddddddddddddddd:        "+ids.length.toString());
  }
  addListenerToController(){
    print("dgfdgfdgfdgdgf");
    _scrollController.addListener(()  async{
      // print("1111111222222222222222144444444444");
      // print(isLoading.toString());
      if(!isLoading){
        print("3333333333333");
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        print(countScrollListener);
        print(ids.length);

        if(countScrollListener<ids.length){
          // print("2222222222222222222222222");
          if (currentScroll == maxScroll) {
            setState(() {
              isLoading=true;
            });
            // print("loadMore1");
            // print(countScrollListener);
            // print(ids.length);
            if(countScrollListener<ids.length-numbertOfView){
              countScrollListener=countScrollListener+numbertOfView;
              selectIds=ids.sublist(countScrollListener,countScrollListener+numbertOfView);
              completeInput();
            }
            else{
              selectIds=ids.sublist(countScrollListener,ids.length);
              countScrollListener=ids.length;
              completeInput();
            }
          }
        }
      }
    });

    // for(var i=0;i<xmlListChannels.length;i++){
  }
  completeInput() {
    print("ids length     :    "+ids.length.toString());
    for (var ii=0;ii<xmlListPrograms.length;ii++) {
      print(ii);
      if(selectIds.contains(xmlListPrograms[ii].attributes.toList()[2].value)){
        //if for data selected
        Programme programme=Programme(
          start: xmlListPrograms[ii].attributes.toList()[0].value,
          stop: xmlListPrograms[ii].attributes.toList()[1].value,
          channel: xmlListPrograms[ii].attributes.toList()[2].value,
          title: DisplayName(t: xmlListPrograms[ii].children.toList()[0].document.findAllElements('title').elementAt(ii).text),
          desc: DisplayName(t: xmlListPrograms[ii].children.toList()[0].document.findAllElements('desc').elementAt(ii).text),
        );

        //if(channel.id==programme.channel && programsViewDate==programme.start.substring(0,8)){
        Iterable<TvDetails> tvDeteilsElements=tvProgramDetailsListAll.where((element) => element.channel.id==programme.channel);
        if(tvDeteilsElements.length==0){
          int lengthOfTvProg=tvProgramDetailsListAll.length;
          TvDetails tvDetailsInput=TvDetails(channel: Channel(id: programme.channel,displayName: DisplayName(t: channelGetfromIds[lengthOfTvProg])),programms: [programme]);
          // tvProgramDetailsListAll.add(tvDetailsInput);
          print("1111111111111111111111111111111:                  "+programme.start.substring(0,8).toString());

          if(programViewDateWhen[0]==programme.start.substring(0,8).toString()){
            tvProgramDetailsListToday.add(tvDetailsInput);
            tvProgramDetailsListAll.add(tvDetailsInput);
          }
          else if(programViewDateWhen[1]==programme.start.substring(0,8).toString()){
            tvProgramDetailsListTomorrow.add(tvDetailsInput);
            tvProgramDetailsListAll.add(tvDetailsInput);
          }
          else if(programViewDateWhen[2]==programme.start.substring(0,8).toString()){
            tvProgramDetailsList2DaysLater.add(tvDetailsInput);
            tvProgramDetailsListAll.add(tvDetailsInput);
          }
          else if(programViewDateWhen[3]==programme.start.substring(0,8).toString()){
            tvProgramDetailsList3DaysLater.add(tvDetailsInput);
            tvProgramDetailsListAll.add(tvDetailsInput);
          }
          else if(programViewDateWhen[4]==programme.start.substring(0,8).toString()){
            tvProgramDetailsList4DaysLater.add(tvDetailsInput);
            tvProgramDetailsListAll.add(tvDetailsInput);
          }
          else if(programViewDateWhen[5]==programme.start.substring(0,8).toString()){
            tvProgramDetailsList5DaysLater.add(tvDetailsInput);
            tvProgramDetailsListAll.add(tvDetailsInput);
          }
          else if(programViewDateWhen[6]==programme.start.substring(0,8).toString()){
            tvProgramDetailsList6DaysLater.add(tvDetailsInput);
            tvProgramDetailsListAll.add(tvDetailsInput);
          }
        }
        else{
          tvDeteilsElements.first.programms.add(programme);
        }
        xmlListPrograms.remove(xmlListPrograms[ii]);
      }
    }

    setState(() {
      isLoading=false;
    });
  }

  String textString(){
    List months =
    ['jan', 'feb', 'mar', 'apr', 'may','jun','jul','aug','sep','oct','nov','dec'];
    if(getDateFromAlert==DateFormat('yyyyMMdd').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day))) {
      for (var i = 1; i < 12; i++) {
        if (getDateFromAlert.substring(4, 6) == i.toString() ||
            getDateFromAlert.substring(4, 6) == '0' + i.toString()) {
          return "Today," + " " + months[i - 1] + " " +
              getDateFromAlert.substring(6, 8);
        }
      }
    }
    else  {
      for (var i = 1; i < 12; i++) {
        if (getDateFromAlert.substring(4, 6) == i.toString() ||
            getDateFromAlert.substring(4, 6) == '0' + i.toString()) {
          return DateFormat('EEE').format(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day+countday)) + ", " + months[i - 1] + " " +
              getDateFromAlert.substring(6, 8);
        }
      }
    }
    // return "Today,"+" "+"Jun"+" "+programsViewDate.substring(6,8);
  }

}





