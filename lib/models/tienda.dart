import 'dart:convert';

Tienda tiendaFromJson(String str) => Tienda.fromJson(json.decode(str));

String tiendaToJson(Tienda data) => json.encode(data.toJson());

class Tienda {
    bool status;
    String message;
    List<Tiendas> data;

    Tienda({
        this.status,
        this.message,
        this.data,
    });

    factory Tienda.fromJson(Map<String, dynamic> json) => Tienda(
        status: json["Status"],
        message: json["Message"],
        data: List<Tiendas>.from(json["Data"].map((x) => Tiendas.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Status": status,
        "Message": message,
        "Data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Tiendas {
    String id;
    String name;
    String type;
    dynamic data;

    Tiendas({
        this.id,
        this.name,
        this.type,
        this.data,
    });

    factory Tiendas.fromJson(Map<String, dynamic> json) => Tiendas(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        data: json["data"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "data": data,
    };
}

class TiendaInfo {
    String id;
    String name;

    TiendaInfo({
        this.id,
        this.name,
    });

    factory TiendaInfo.fromJson(Map<String, dynamic> json) => TiendaInfo(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}


//Tienda
//Tiendas
//TiendaInfo
