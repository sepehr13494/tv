// To parse this JSON data, do
//
//     final appVersionObj = appVersionObjFromJson(jsonString);

import 'dart:convert';

AppVersionObj appVersionObjFromJson(String str) => AppVersionObj.fromJson(json.decode(str));

String appVersionObjToJson(AppVersionObj data) => json.encode(data.toJson());

class AppVersionObj {
  AppVersionObj({
    this.status,
    this.response,
  });

  String status;
  Response response;

  factory AppVersionObj.fromJson(Map<String, dynamic> json) => AppVersionObj(
    status: json["Status"],
    response: Response.fromJson(json["Response"]),
  );

  Map<String, dynamic> toJson() => {
    "Status": status,
    "Response": response.toJson(),
  };
}

class Response {
  Response({
    this.newVersion,
    this.newVersionUrl,
  });

  String newVersion;
  String newVersionUrl;

  factory Response.fromJson(Map<String, dynamic> json) => Response(
    newVersion: json["new_version"],
    newVersionUrl: json["new_version_url"],
  );

  Map<String, dynamic> toJson() => {
    "new_version": newVersion,
    "new_version_url": newVersionUrl,
  };
}
