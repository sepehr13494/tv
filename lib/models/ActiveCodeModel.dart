// To parse this JSON data, do
//
//     final activeCodeObj = activeCodeObjFromJson(jsonString);

import 'dart:convert';

ActiveCodeObj activeCodeObjFromJson(String str) => ActiveCodeObj.fromJson(json.decode(str));

String activeCodeObjToJson(ActiveCodeObj data) => json.encode(data.toJson());

class ActiveCodeObj {
  ActiveCodeObj({
    this.status,
    this.response,
  });

  String status;
  Response response;

  factory ActiveCodeObj.fromJson(Map<String, dynamic> json) => ActiveCodeObj(
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
    this.message,
    this.m3UUrl,
    this.epgLink,
    this.usedConnections,
    this.maxConnections,
    this.expirationDate,
    this.codeStatus,
    this.codeType,
    this.note,
  });

  String message;
  String m3UUrl;
  String epgLink;
  String usedConnections;
  String maxConnections;
  DateTime expirationDate;
  String codeStatus;
  String codeType;
  String note;

  factory Response.fromJson(Map<String, dynamic> json) => Response(
    message: json["message"],
    m3UUrl: json["m3u_url"],
    epgLink: json["epg_link"],
    usedConnections: json["used_connections"],
    maxConnections: json["max_connections"],
    expirationDate: json["expiration_date"] == null ? null : DateTime.parse(json["expiration_date"]),
    codeStatus: json["code_status"],
    codeType: json["code_type"],
    note: json["note"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "m3u_url": m3UUrl,
    "epg_link": epgLink,
    "used_connections": usedConnections,
    "max_connections": maxConnections,
    "expiration_date": expirationDate.toIso8601String(),
    "code_status": codeStatus,
    "code_type": codeType,
    "note": note,
  };
}
