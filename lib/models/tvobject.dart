// To parse this JSON data, do
//
//     final tvObject = tvObjectFromJson(jsonString);

import 'dart:convert';

TvObject tvObjectFromJson(String str) => TvObject.fromJson(json.decode(str));

String tvObjectToJson(TvObject data) => json.encode(data.toJson());

class TvObject {
  TvObject({
    this.tv,
  });

  Tv tv;

  factory TvObject.fromJson(Map<String, dynamic> json) => TvObject(
    tv: Tv.fromJson(json["tv"]),
  );

  Map<String, dynamic> toJson() => {
    "tv": tv.toJson(),
  };
}

class Tv {
  Tv({
    this.generatorInfoName,
    this.generatorInfoUrl,
    this.channel,
    this.programme,
  });

  String generatorInfoName;
  String generatorInfoUrl;
  List<Channel> channel;
  List<Programme> programme;

  factory Tv.fromJson(Map<String, dynamic> json) => Tv(
    generatorInfoName: json["generator-info-name"],
    generatorInfoUrl: json["generator-info-url"],
    channel: List<Channel>.from(json["channel"].map((x) => Channel.fromJson(x))),
    programme: List<Programme>.from(json["programme"].map((x) => Programme.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "generator-info-name": generatorInfoName,
    "generator-info-url": generatorInfoUrl,
    "channel": List<dynamic>.from(channel.map((x) => x.toJson())),
    "programme": List<dynamic>.from(programme.map((x) => x.toJson())),
  };
}

class Channel {
  Channel({
    this.id,
    this.displayName,
    this.icon,
  });

  String id;
  DisplayName displayName;
  Icon icon;

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
    id: json["id"],
    displayName: DisplayName.fromJson(json["display-name"]),
    icon: json["icon"] == null ? null : Icon.fromJson(json["icon"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "display-name": displayName.toJson(),
    "icon": icon == null ? null : icon.toJson(),
  };
}

class DisplayName {
  DisplayName({
    this.t,
  });

  String t;

  factory DisplayName.fromJson(Map<String, dynamic> json) => DisplayName(
    t: json["\u0024t"],
  );

  Map<String, dynamic> toJson() => {
    "\u0024t": t,
  };
}

class Icon {
  Icon({
    this.src,
  });

  String src;

  factory Icon.fromJson(Map<String, dynamic> json) => Icon(
    src: json["src"],
  );

  Map<String, dynamic> toJson() => {
    "src": src,
  };
}

class Programme {
  Programme({
    this.start,
    this.stop,
    this.channel,
    this.title,
    this.desc,
  });

  String start;
  String stop;
  String channel;
  DisplayName title;
  DisplayName desc;

  factory Programme.fromJson(Map<String, dynamic> json) {
    return Programme(
      start: json["start"],
      stop: json["stop"],
      channel: json["channel"],
      title: DisplayName.fromJson(json["title"]),
      desc: DisplayName.fromJson(json["desc"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "start": start,
    "stop": stop,
    "channel": channel,
    "title": title.toJson(),
    "desc": desc.toJson(),
  };
}
