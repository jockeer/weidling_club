// To parse this JSON data, do
//
//     final subTienda = subTiendaFromJson(jsonString);

import 'dart:convert';

SubTienda subTiendaFromJson(String str) => SubTienda.fromJson(json.decode(str));

String subTiendaToJson(SubTienda data) => json.encode(data.toJson());

class SubTienda {
    String id;
    String name;
    String type;
    List<StoreInfo> data;

    SubTienda({
        this.id,
        this.name,
        this.type,
        this.data,
    });

    factory SubTienda.fromJson(Map<String, dynamic> json) => SubTienda(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        data: List<StoreInfo>.from(json["data"].map((x) => StoreInfo.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class StoreInfo {
    String id;
    String name;

    StoreInfo({
        this.id,
        this.name,
    });

    factory StoreInfo.fromJson(Map<String, dynamic> json) => StoreInfo(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}