// To parse this JSON data, do
//
//     final myM3UGenericEntry = myM3UGenericEntryFromJson(jsonString);

import 'dart:convert';

MyM3UGenericEntry myM3UGenericEntryFromJson(String str) => MyM3UGenericEntry.fromJson(json.decode(str));

String myM3UGenericEntryToJson(MyM3UGenericEntry data) => json.encode(data.toJson());

class MyM3UGenericEntry {
  MyM3UGenericEntry({
    this.link,
    this.title,
    this.logo,
  });

  String link;
  String title;
  String logo;

  factory MyM3UGenericEntry.fromJson(Map<String, dynamic> json) => MyM3UGenericEntry(
    link: json["link"],
    title: json["title"],
    logo: json["logo"],
  );

  Map<String, dynamic> toJson() => {
    "link": link,
    "title": title,
    "logo": logo,
  };
}
