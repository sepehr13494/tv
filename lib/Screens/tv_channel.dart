import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3u/m3u.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:tv/Screens/home_screen.dart';
import 'package:tv/Screens/setting_screen.dart';
import 'package:tv/Screens/tvCalender.dart';
import 'package:tv/models/MyM3uGenericEntry.dart';
import 'package:tv/models/topChannelModel.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class TvChannel extends StatefulWidget {
  final String url;
  final String xml;

  const TvChannel({Key key, this.url, this.xml}) : super(key: key);

  @override
  _TvChannelState createState() => _TvChannelState();
}

class _TvChannelState extends State<TvChannel> with WidgetsBindingObserver{
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
  List<M3uGenericEntry> searchedLeftChannels;
  List<M3uGenericEntry> lockChannels;
  String filterName = "all";
  TextEditingController searchController = TextEditingController();

  Future<String> _appVersion = Future.sync(() async {
    String version = (await PackageInfo.fromPlatform()).version;
    return version;
  });

  Future getChannels() async {
    var response;
    try {
      response = await Dio().get(widget.url);
    } catch (e) {
      print(e.toString());
    }
    String source = response.data;
    if (LineSplitter.split(response.data).elementAt(1).contains('#PLAYLIST')) {
      print("hiiiiiiiiiiiii");
      List<String> lines = LineSplitter.split(response.data).toList(growable: true);
      lines.removeAt(1);
      source = lines.join("\n");
    }
    print(source);
    m3u = await M3uParser.parse(source);
    for (final entry in m3u) {
      print('Title: ${entry.title} Link: ${entry.link} Logo: ${entry.attributes['tvg-logo']}');
    }
    var favorites = await addFavoritesToChannels();
    lockChannels = await addLocksToChannels();
    topChannels = [
      TopChannel(name: "Favorite", m3uGenericEntries: favorites),
      TopChannel(name: "All", m3uGenericEntries: m3u)
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
    topChannelName = "All";
    leftChannels = topChannels
        .firstWhere((element) => element.name == "All")
        .m3uGenericEntries;
    _setFilter(filterName);
  }

  _setFilter(String filter) {
    setState(() {
      searchController.text = "";
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
    searchedLeftChannels = [];
    searchedLeftChannels.addAll(filteredLeftChannels);
    if (lockChannels
            .where((element) => element.title == filteredLeftChannels[0].title)
            .length ==
        0) {
      initVideo(filteredLeftChannels[0].link);
      setState(() {
        channelIndex = m3u.indexWhere((element) => element.title == filteredLeftChannels[0].title);
      });
    } else {
      setState(() {
        channelIndex = -2;
      });
      checkLock(function: () {
        initVideo(filteredLeftChannels[0].link);
        setState(() {
          channelIndex = m3u.indexWhere((element) => element.title == filteredLeftChannels[0].title);
        });
      });
    }
  }

  void _setTopChannel(int index) {
    setState(() {
      leftChannels = topChannels[index].m3uGenericEntries;
      topChannelName = topChannels[index].name;
      _setFilter(filterName);
    });
  }

  Future<void> initVideo(url) async {
    print("kkkkkkkkkk" + url);
    if (_controller != null) {
      setState(() {
        _controller.pause();
        _controller = null;
      });
    }
    _controller = VideoPlayerController.network(url);
    await _controller.initialize().onError((error, stackTrace) {
      Toast.show(error.toString(), context);
      print(error.toString());
    }).catchError((e) {
      print(e.toString());
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
    Wakelock.enable();
    super.initState();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print(state);
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIOverlays([]);
      Wakelock.enable();
    }
    super.didChangeAppLifecycleState(state);
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
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: TextField(
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.search,
                                  color: Colors.pink,
                                ),
                              ),
                              controller: searchController,
                              onChanged: (val) {
                                if (val.length == 0) {
                                  setState(() {
                                    searchedLeftChannels = [];
                                    searchedLeftChannels.addAll(filteredLeftChannels);
                                  });
                                } else {
                                  setState(() {
                                    searchedLeftChannels = [];
                                    searchedLeftChannels.addAll(
                                        filteredLeftChannels.where((element) =>
                                            element.title
                                                .toLowerCase()
                                                .contains(val.toLowerCase())));
                                  });
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: searchedLeftChannels.length == 0
                                ? Center(child: Text("no channel"))
                                : ListView.builder(
                                    itemCount: searchedLeftChannels.length,
                                    itemBuilder: (context, index) {
                                      return channels(
                                          channel: searchedLeftChannels[index],
                                          index: topChannelName == "Favorite" ? m3u.indexWhere((element) => element.title == searchedLeftChannels[index].title) : m3u.indexOf(searchedLeftChannels[index]));
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
                            padding: EdgeInsets.only(left: 20,right: 20),
                            child: Container(
                              child: Center(
                                child: Text(
                                  topChannels[index].name??"",
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
        if (lockChannels
                .where((element) => element.title == channel.title)
                .length ==
            0) {
          initVideo(channel.link);
          setState(() {
            channelIndex = index;
          });
        } else {
          checkLock(function: () {
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
      children: [
        Expanded(
          child: ListView(
            children: List.generate(4, (index) {
              List<String> options = [
                "Change Category",
                "TV Guid",
                "Change Password",
                "logout",
              ];
              List<IconData> icons = [
                Icons.category,
                Icons.list_alt,
                Icons.lock_open_rounded,
                Icons.logout,
              ];
              return GestureDetector(
                onTap: () async {
                  switch (index) {
                    case 0:
                      changeCategory();
                      break;
                    case 1:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TvCalender(
                                  link: widget.xml,
                                  channels: List.generate(
                                      filteredLeftChannels.length, (index) {
                                    return filteredLeftChannels[index].title;
                                  }))));
                      break;
                    case 2:
                      checkLock(function: () {
                        setNewPassWord();
                      });
                      break;
                    case 3:
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("code", "");
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));
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
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: _appVersion,
            builder: (context, snapshot) {
              return Text("App Version : " + snapshot.data);
            },
            initialData: "",
          ),
        )
      ],
    );
  }

  Widget buttomController() {
    List<M3uGenericEntry> favorites = topChannels[0].m3uGenericEntries;
    M3uGenericEntry channel = m3u[channelIndex];
    bool hasLength =
        (channel.link.contains("/movie/") || channel.link.contains("/series/")
            || channel.link.toLowerCase().endsWith(".mp4")
            || channel.link.toLowerCase().endsWith(".mkv")
            || channel.link.toLowerCase().endsWith(".m4p")
            || channel.link.toLowerCase().endsWith(".m4v")
            || channel.link.toLowerCase().endsWith(".mov")
            || channel.link.toLowerCase().endsWith(".avi")
            || channel.link.toLowerCase().endsWith(".wmv")
        );
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
                              value: _controller.value.duration == null
                                  ? 0
                                  : _controller.value.position.inSeconds /
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
                    icon: (favorites
                                .where(
                                    (element) => element.title == channel.title)
                                .length ==
                            0)
                        ? Icon(Icons.favorite_border_outlined)
                        : Icon(Icons.favorite),
                  ),
                  IconButton(
                    onPressed: () {
                      addToLock();
                    },
                    icon: (lockChannels
                                .where(
                                    (element) => element.title == channel.title)
                                .length ==
                            0)
                        ? Icon(Icons.lock_open_rounded)
                        : Icon(Icons.lock),
                  ),
                ],
              ),
              hasLength
                  ? ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (context, VideoPlayerValue value, child) {
                        return Text(
                          _controller.value.duration == null
                              ? ""
                              : (_printDuration(_controller.value.position) +
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
                          border: Border.all(
                              color: filters[index] == filterName
                                  ? Theme.of(context).accentColor
                                  : Colors.white),
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
                element.title == m3u[channelIndex].title)
            .length ==
        0) {
      M3uGenericEntry channel = m3u[channelIndex];
      entries.add(MyM3UGenericEntry(
          title: channel.title,
          link: channel.link,
          logo: channel.attributes["tvg-logo"]));
      setState(() {
        topChannels[0]
            .m3uGenericEntries
            .add(m3u[channelIndex]);
      });
    } else {
      entries.removeWhere((element) =>
          element.title == m3u[channelIndex].title);
      setState(() {
        topChannels[0].m3uGenericEntries.removeWhere((element) =>
            element.title == m3u[channelIndex].title);
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
    if (entries
            .where((element) =>
                element.title == m3u[channelIndex].title)
            .length ==
        0) {
      M3uGenericEntry channel = m3u[channelIndex];
      entries.add(MyM3UGenericEntry(
          title: channel.title,
          link: channel.link,
          logo: channel.attributes["tvg-logo"]));
      setState(() {
        lockChannels.add(m3u[channelIndex]);
      });
      prefs.setString("locks", jsonEncode(entries));
    } else {
      checkLock(function: () {
        entries.removeWhere((element) =>
            element.title == m3u[channelIndex].title);
        setState(() {
          lockChannels.removeWhere((element) =>
              element.title == m3u[channelIndex].title);
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
      if (m3u.where((element) => element.title == entry.title).length != 0) {
        favorites.add(
            M3uGenericEntry(title: entry.title, link: entry.link, attributes: {
              "tvg-logo": entry.logo,
            }));
      }

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
    if ((prefs.getString("password") ?? "0000") == text) {
      return true;
    } else {
      return false;
    }
  }

  void checkLock({Function function}) {
    showDialog(
        context: context,
        builder: (context) {
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
                      Text("Enter Password (default : 0000)"),
                      SizedBox(height: 15),
                      TextField(
                        textAlign: TextAlign.center,
                        controller: controller,
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                          onPressed: () async {
                            bool correctPass =
                                await checkPassword(controller.text);
                            if (correctPass) {
                              Navigator.pop(context);
                              function();
                            } else {
                              Toast.show("Wrong Password", context);
                            }
                          },
                          child: Text("Confirm"))
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void setNewPassWord() {
    showDialog(
        context: context,
        builder: (context) {
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
                      ElevatedButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setString("password", controller.text);
                            Navigator.pop(context);
                          },
                          child: Text("Confirm"))
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
