import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3u/m3u.dart';
import 'package:toast/toast.dart';
import 'package:tv/Screens/setting_screen.dart';
import 'package:tv/Screens/tvCalender.dart';
import 'package:tv/models/topChannelModel.dart';
import 'package:video_player/video_player.dart';

class TvChannel extends StatefulWidget {

  final String url;
  final String xml;

  const TvChannel({Key key, this.url, this.xml}) : super(key: key);
  @override
  _TvChannelState createState() => _TvChannelState();
}

class _TvChannelState extends State<TvChannel> {

  VideoPlayerController _controller;

  bool showMenu = true;
  bool showBottomMenu = false;

  List<M3uGenericEntry> m3u;
  List<M3uGenericEntry> leftChannels;

  int channelIndex = 0;
  String topChannelName = "";

  Function myListener;

  String upperChannel;
  List<TopChannel> topChannels;

  Future getChannels() async {
    final response = await Dio().get(widget.url);
    m3u = await M3uParser.parse(response.data);
    topChannels = [TopChannel(name: "favorite",m3uGenericEntries: []),TopChannel(name: "AllChannels",m3uGenericEntries: m3u)];
    m3u.forEach((element) {
      if(topChannels.where((elem) => (elem.name == element.attributes['group-title'])).isEmpty){
        topChannels.add(TopChannel(name: element.attributes['group-title'],m3uGenericEntries: [element]));
      }else{
        topChannels.firstWhere((elem) => (elem.name == element.attributes['group-title'])).m3uGenericEntries.add(element);
      }
    });
    topChannelName = "AllChannels";
    leftChannels = topChannels.firstWhere((element) => element.name == "AllChannels").m3uGenericEntries;
    setState(() {});
    //initVideo(m3u[0].link);
  }

  Future<void> initVideo(url) async {
    /*if (_controller != null) {
      setState(() {
        _controller.pause();
        _controller = null;
      });
    }
    _controller = VideoPlayerController.network(url);
    await _controller.initialize().onError((error, stackTrace) {
      Toast.show("sssssssssssssssssssssssssssssssss"+error.toString(), context);
      print("sssssssssssssssssssssssssssssssss"+error.toString());
    }).catchError((e){
      print("sssssssssssssssssssssssssssssssss2"+e.toString());
    });
    setState(() {
      _controller.play();
    });*/
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    getChannels();
    super.initState();
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: m3u == null ? Center(child: CircularProgressIndicator.adaptive()) : Stack(
        children: [
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
                  onTap: (){
                    setState(() {
                      showMenu = !showMenu;
                    });
                  },
              onVerticalDragStart: (details){
                print("vertical drag start");
                print("vertical drag start" + details.toString());
              },
              onVerticalDragEnd: (details){
                print("vertical drag ends");
                print("vertical drag start" + details.toString());
                if (!showMenu) {
                  setState(() {
                    showBottomMenu = true;
                  });
                }
              },
              onVerticalDragCancel: (){
                print("vertical drag cancel");
                setState(() {
                  showBottomMenu = false;
                });
              },
              onVerticalDragDown: (details){
                print("vertical drag down");
                print("vertical drag start" + details.toString());
              },
              child: (_controller != null && _controller.value.initialized)
                      ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                      : Center(child: CircularProgressIndicator.adaptive()),
                ),
          ),
          !showMenu ? Container() : Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.only(top: 70),
              color: Colors.grey[900].withOpacity(0.8),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.ac_unit),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SettingScreen()));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.playlist_play),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TvCalender(link: widget.xml)));
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: leftChannels.length,
                      itemBuilder: (context, index) {
                        return channels(channel: leftChannels[index], index: index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          !showMenu ? Container() : Container(
            height: 70,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.grey[800].withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: ListView.builder(
              itemCount: topChannels.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (){
                    setState(() {
                      leftChannels = topChannels[index].m3uGenericEntries;
                      topChannelName = topChannels[index].name;
                      channelIndex = 0;
                      initVideo(leftChannels[0].link);
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Container(
                      child: Center(
                        child: Text(
                          topChannels[index].name,
                          style: TextStyle(fontSize: 14, color: topChannels[index].name == topChannelName ? Theme.of(context).accentColor : Colors.white),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          !showBottomMenu ? Container() : Align(alignment:Alignment.bottomCenter,child: buttomController()),
        ],
      ),
    );
  }

  Widget channels({M3uGenericEntry channel, int index}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        initVideo(channel.link);
        setState(() {
          channelIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.only(left: 15, right: 5,top: 5,bottom: 5),
        margin: EdgeInsets.only(left: 15, right: 15),
        decoration: index == channelIndex ?  BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Theme.of(context).accentColor),
        ) : null,
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            Container(
              child: Text(index.toString()),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Container(
                child: Center(child: Image.network(channel.attributes['tvg-logo']??"https://picsum.photos/200/200",width: 40,height: 40,)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  child: Text(channel.title??""),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buttomController(){
    M3uGenericEntry channel = m3u[channelIndex];
    return Container(
      color: Colors.black45,
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.network(channel.attributes['tvg-logo']??"https://picsum.photos/200/200",width: 70,height: 70),
              Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(channelIndex.toString()),
                      ),
                      Text(channel.title),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: (){
                  _controller.pause();
                },
                icon: Icon(Icons.pause),
              ),
              Expanded(
                child: Slider(onChanged: (double value) {  }, value: 0),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: (){},
                icon: Icon(
                    Icons.favorite_border_outlined
                ),
              ),
              Text("00:00 / 00:00"),
            ],
          )
        ],
      ),
    );
  }
}
