import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3u/m3u.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:tv/Screens/setting_screen.dart';
import 'package:tv/Screens/tvCalender.dart';
import 'package:tv/models/MyM3uGenericEntry.dart';
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
  List<M3uGenericEntry> filteredLeftChannels;
  List<M3uGenericEntry> lockChannels;
  String filterName = "all";

  Future getChannels() async {
    var response;
    try{
      response = await Dio().get(widget.url);
    }catch (e){
      print(e.toString());
    }
    m3u = await M3uParser.parse(response.data);
    var favorites = await addFavoritesToChannels();
    lockChannels = await addLocksToChannels();
    topChannels = [
      TopChannel(name: "favorite", m3uGenericEntries: favorites),
      TopChannel(name: "AllChannels", m3uGenericEntries: m3u)
    ];
    m3u.forEach((element) {
      if (topChannels
          .where((elem) => (elem.name == element.attributes['group-title']))
          .isEmpty) {
        topChannels.add(TopChannel(
            name: element.attributes['group-title'],
            m3uGenericEntries: [element]));
      } else {
        topChannels
            .firstWhere(
                (elem) => (elem.name == element.attributes['group-title']))
            .m3uGenericEntries
            .add(element);
      }
    });
    topChannelName = "AllChannels";
    leftChannels = topChannels
        .firstWhere((element) => element.name == "AllChannels")
        .m3uGenericEntries;
    _setFilter(filterName);
  }

  _setFilter(String filter) {
    setState(() {
      filterName = filter;
    });
    filteredLeftChannels = [];
    switch (filter) {
      case "all":
        filteredLeftChannels.addAll(leftChannels);
        break;
      case "movie":
      case "series":
        filteredLeftChannels.addAll(leftChannels.where((element) {
          return element.link.contains(filter);
        }));
        break;
      case "live":
        filteredLeftChannels.addAll(leftChannels.where((element) {
          return (!element.link.contains("serial") &&
              !element.link.contains("movie"));
        }));
        break;
    }

    if (lockChannels.where((element) => element.title == filteredLeftChannels[0].title).length == 0) {
      initVideo(filteredLeftChannels[0].link);
      setState(() {
        channelIndex = 0;
      });
    }  else{
      setState(() {
        channelIndex = -1;
      });
      checkLock(function: (){
        initVideo(filteredLeftChannels[0].link);
        setState(() {
          channelIndex = 0;
        });
      });
    }
  }

  void _setTopChannel(int index) {
    setState(() {
      leftChannels = topChannels[index].m3uGenericEntries;
      topChannelName = topChannels[index].name;
      channelIndex = 0;
      _setFilter(filterName);
    });
  }

  Future<void> initVideo(url) async {
    print("kkkkkkkkkk"+url);
    if (_controller != null) {
      setState(() {
        _controller.pause();
        _controller = null;
      });
    }
    _controller = VideoPlayerController.network(url);
    await _controller.initialize().onError((error, stackTrace) {
      Toast.show(
          "sssssssssssssssssssssssssssssssss" + error.toString(), context);
      print("sssssssssssssssssssssssssssssssss" + error.toString());
    }).catchError((e) {
      print("sssssssssssssssssssssssssssssssss2" + e.toString());
    });
    setState(() {
      _controller.play();
    });
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
      body: m3u == null
          ? Center(child: CircularProgressIndicator.adaptive())
          : Stack(
              children: [
                Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        showMenu = !showMenu;
                      });
                    },
                    onVerticalDragEnd: (details) {
                      if (!showMenu) {
                        setState(() {
                          showBottomMenu = true;
                        });
                      }
                    },
                    onVerticalDragCancel: () {
                      setState(() {
                        showBottomMenu = false;
                      });
                    },
                    child: (_controller != null &&
                            _controller.value.initialized)
                        ? AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          )
                        : Center(child: CircularProgressIndicator.adaptive()),
                  ),
                ),
                Visibility(
                  visible: showMenu,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height,
                      padding: EdgeInsets.only(top: 70),
                      color: Colors.grey[900].withOpacity(0.8),
                      child: rightDrawer(),
                    ),
                  ),
                ),
                Visibility(
                  visible: showMenu,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height,
                      padding: EdgeInsets.only(top: 80),
                      color: Colors.grey[900].withOpacity(0.8),
                      child: Column(
                        children: [
                          Expanded(
                            child: filteredLeftChannels.length == 0
                                ? Center(child: Text("no channel"))
                                : ListView.builder(
                                    itemCount: filteredLeftChannels.length,
                                    itemBuilder: (context, index) {
                                      return channels(
                                          channel: filteredLeftChannels[index],
                                          index: index);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: showMenu,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Container(
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
                          onTap: () {
                            _setTopChannel(index);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Container(
                              child: Center(
                                child: Text(
                                  topChannels[index].name,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: topChannels[index].name ==
                                              topChannelName
                                          ? Theme.of(context).accentColor
                                          : Colors.white),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                !showBottomMenu
                    ? Container()
                    : Align(
                        alignment: Alignment.bottomCenter,
                        child: buttomController()),
              ],
            ),
    );
  }

  Widget channels({M3uGenericEntry channel, int index}) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (lockChannels.where((element) => element.title == channel.title).length == 0) {
          initVideo(channel.link);
          setState(() {
            channelIndex = index;
          });
        }else{
          checkLock(function: (){
            initVideo(channel.link);
            setState(() {
              channelIndex = index;
            });
          });
        }
      },
      child: Container(
        padding: EdgeInsets.only(left: 15, right: 5, top: 5, bottom: 5),
        margin: EdgeInsets.only(left: 15, right: 15),
        decoration: index == channelIndex
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Theme.of(context).accentColor),
              )
            : null,
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            Container(
              child: Text((index + 1).toString()),
            ),
            Padding(
              padding: EdgeInsets.only(left: 5),
              child: Container(
                child: Center(
                    child: Image.network(
                  channel.attributes['tvg-logo'] ??
                      "https://picsum.photos/200/200",
                  width: 40,
                  height: 40,
                )),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 5, right: 5),
                child: Container(
                  child: Text(channel.title ?? ""),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rightDrawer() {
    return Column(
      children: List.generate(3, (index) {
        List<String> options = [
          "Change Category",
          "TV Guid",
          "Change Password",
        ];
        List<IconData> icons = [
          Icons.category,
          Icons.list_alt,
          Icons.lock_open_rounded,
        ];
        return GestureDetector(
          onTap: () {
            switch (index) {
              case 0:
                changeCategory();
                break;
              case 1:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TvCalender(link: widget.xml)));
                break;
              case 2:
                checkLock(function: (){
                  setNewPassWord();
                });
                break;
            }
          },
          child: ListTile(
            title: Text(
              options[index],
              style: TextStyle(color: Colors.white),
            ),
            leading: Icon(icons[index]),
          ),
        );
      }),
    );
  }

  Widget buttomController() {
    List<M3uGenericEntry> favorites = topChannels[0].m3uGenericEntries;
    M3uGenericEntry channel = filteredLeftChannels[channelIndex];
    bool hasLength = (channel.link.contains("/movie/") || channel.link.contains("/series/"));
    return Container(
      color: Colors.black45,
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.network(
                  channel.attributes['tvg-logo'] ??
                      "https://picsum.photos/200/200",
                  width: 70,
                  height: 70),
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
                onPressed: () {
                  setState(() {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  });
                },
                icon: _controller.value.isPlaying
                    ? Icon(Icons.pause)
                    : Icon(Icons.play_arrow),
              ),
              Expanded(
                child: hasLength
                    ? ValueListenableBuilder(
                        valueListenable: _controller,
                        builder: (context, VideoPlayerValue value, child) {
                          return Slider(
                              onChanged: (double value) {
                                _controller.seekTo(Duration(
                                    seconds: (value *
                                            _controller
                                                .value.duration.inSeconds)
                                        .round()));
                              },
                              value: _controller.value.duration == null ? 0 : _controller.value.position.inSeconds /
                                  _controller.value.duration.inSeconds);
                        })
                    : Slider(
                        onChanged: (double value) {},
                        value: 0,
                      ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      addToFavorite();
                    },
                    icon: (favorites.where((element) => element.title == channel.title).length == 0) ? Icon(Icons.favorite_border_outlined) : Icon(Icons.favorite),
                  ),
                  IconButton(
                    onPressed: () {
                      addToLock();
                    },
                    icon: (lockChannels.where((element) => element.title == channel.title).length == 0) ? Icon(Icons.lock_open_rounded) : Icon(Icons.lock),
                  ),
                ],
              ),
              hasLength
                  ? ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, VideoPlayerValue value, child) {
                        return Text(
                         _controller.value.duration == null ? "" : (_printDuration(_controller.value.position) +
                              " / " +
                              _printDuration(_controller.value.duration)),
                        );
                      },
                    )
                  : Text("00:00 / 00:00"),
            ],
          )
        ],
      ),
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void changeCategory() {
    List<String> filters = ["all", "movie", "series", "live"];
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(filters.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _setFilter(filters[index]);
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: filters[index] == filterName ? Theme.of(context).accentColor : Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text(filters[index])),
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        });
  }

  Future<void> addToFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<MyM3UGenericEntry> entries = [];
    for (var entry in jsonDecode(prefs.getString("favorites") ?? "[]")) {
      entries.add(MyM3UGenericEntry.fromJson(entry));
    }
    if (entries
            .where((element) =>
                element.title == filteredLeftChannels[channelIndex].title)
            .length ==
        0) {
      M3uGenericEntry channel = filteredLeftChannels[channelIndex];
      entries.add(MyM3UGenericEntry(
          title: channel.title,
          link: channel.link,
          logo: channel.attributes["tvg-logo"]));
      setState(() {
        topChannels[0].m3uGenericEntries.add(filteredLeftChannels[channelIndex]);
      });
    }else{
      entries.removeWhere((element) => element.title == filteredLeftChannels[channelIndex].title);
      setState(() {
        topChannels[0].m3uGenericEntries.removeWhere((element) => element.title == filteredLeftChannels[channelIndex].title);
      });
    }
    prefs.setString("favorites", jsonEncode(entries));
  }

  Future<void> addToLock() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<MyM3UGenericEntry> entries = [];
    for (var entry in jsonDecode(prefs.getString("locks") ?? "[]")) {
      entries.add(MyM3UGenericEntry.fromJson(entry));
    }
    if (entries.where((element) => element.title == filteredLeftChannels[channelIndex].title).length == 0) {
      M3uGenericEntry channel = filteredLeftChannels[channelIndex];
      entries.add(MyM3UGenericEntry(
          title: channel.title,
          link: channel.link,
          logo: channel.attributes["tvg-logo"]));
      setState(() {
        lockChannels.add(filteredLeftChannels[channelIndex]);
      });
      prefs.setString("locks", jsonEncode(entries));
    }else{
      checkLock(function: (){
        entries.removeWhere((element) => element.title == filteredLeftChannels[channelIndex].title);
        setState(() {
          lockChannels.removeWhere((element) => element.title == filteredLeftChannels[channelIndex].title);
        });
        prefs.setString("locks", jsonEncode(entries));
      });
    }
  }

  Future<List<M3uGenericEntry>> addFavoritesToChannels() async {
    List<M3uGenericEntry> favorites = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<MyM3UGenericEntry> entries = [];
    for (var entry in jsonDecode(prefs.getString("favorites") ?? "[]")) {
      entries.add(MyM3UGenericEntry.fromJson(entry));
    }
    for (var entry in entries) {
      favorites.add(
          M3uGenericEntry(title: entry.title, link: entry.link, attributes: {
            "tvg-logo": entry.logo,
          }));
    }
    return favorites;
  }

  Future<List<M3uGenericEntry>> addLocksToChannels() async {
    List<M3uGenericEntry> locks = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<MyM3UGenericEntry> entries = [];
    for (var entry in jsonDecode(prefs.getString("locks") ?? "[]")) {
      entries.add(MyM3UGenericEntry.fromJson(entry));
    }
    for (var entry in entries) {
      locks.add(
          M3uGenericEntry(title: entry.title, link: entry.link, attributes: {
            "tvg-logo": entry.logo,
          }));
    }
    return locks;
  }

  Future<bool> checkPassword(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if ((prefs.getString("password")??"0000") == text) {
      return true;
    } else{
      return false;
    }

  }

  void checkLock({Function function}) {
    showDialog(context: context, builder: (context){
      TextEditingController controller = TextEditingController();
      return Dialog(
        child: SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Enter Password"),
                  SizedBox(height: 15),
                  TextField(
                    textAlign: TextAlign.center,
                    controller: controller,
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(onPressed: () async {
                    bool correctPass = await checkPassword(controller.text);
                    if (correctPass) {
                      Navigator.pop(context);
                      function();
                    }else{
                      Toast.show("Wrong Password", context);
                    }
                  }, child: Text("Confirm"))
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void setNewPassWord() {
    showDialog(context: context, builder: (context){
      TextEditingController controller = TextEditingController();
      return Dialog(
        child: SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Enter New Password"),
                  SizedBox(height: 15),
                  TextField(
                    textAlign: TextAlign.center,
                    controller: controller,
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("password", controller.text);
                    Navigator.pop(context);
                  }, child: Text("Confirm"))
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
