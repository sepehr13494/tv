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
  ActiveCodeResponse response;

  factory ActiveCodeObj.fromJson(Map<String, dynamic> json) => ActiveCodeObj(
    status: json["Status"],
    response: ActiveCodeResponse.fromJson(json["Response"]),
  );

  Map<String, dynamic> toJson() => {
    "Status": status,
    "Response": response.toJson(),
  };
}

class ActiveCodeResponse {
  ActiveCodeResponse({
    this.message,
    this.m3UUrl,
    this.epgLink,
    this.usedConnections,
    this.maxConnections,
    this.expirationDate,
    this.codeStatus,
    this.codeType,
    this.note,
    this.code,
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
  String code;

  factory ActiveCodeResponse.fromJson(Map<String, dynamic> json) => ActiveCodeResponse(
    message: json["message"],
    m3UUrl: json["m3u_url"],
    epgLink: json["epg_link"],
    usedConnections: json["used_connections"],
    maxConnections: json["max_connections"],
    expirationDate: json["expiration_date"] == null ? null : DateTime.parse(json["expiration_date"]),
    codeStatus: json["code_status"],
    codeType: json["code_type"],
    note: json["note"],
    code: json["code"],
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
    "code": code,
  };
}
