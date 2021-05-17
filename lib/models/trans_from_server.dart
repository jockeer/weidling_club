// To parse this JSON data, do
//
//     final transfers = transfersFromJson(jsonString);

import 'dart:convert';

Transfers transfersFromJson(String str) => Transfers.fromJson(json.decode(str));

String transfersToJson(Transfers data) => json.encode(data.toJson());

class Transfers {
  Transfers({
    this.status,
    this.message,
    this.data,
  });

  bool status;
  String message;
  List<TransferElements> data;

  factory Transfers.fromJson(Map<String, dynamic> json) => Transfers(
        status: json["Status"],
        message: json["Message"],
        data: List<TransferElements>.from(
            json["Data"].map((x) => TransferElements.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Status": status,
        "Message": message,
        "Data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class TransferElements {
  TransferElements({
    this.type,
    this.date,
    this.detail,
    this.mount,
  });

  String type;
  String date;
  String detail;
  num mount;

  factory TransferElements.fromJson(Map<String, dynamic> json) =>
      TransferElements(
        type: json["type"],
        date: json["date"],
        detail: json["detail"],
        mount: json["mount"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "date": date,
        "detail": detail,
        "mount": mount,
      };
}
