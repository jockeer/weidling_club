import 'dart:convert';

Producto productoFromJson(String str) => Producto.fromJson(json.decode(str));

String productoToJson(Producto data) => json.encode(data.toJson());

class Producto {
  bool status;
  String message;
  List<Punto> data;

  Producto({
    this.status,
    this.message,
    this.data,
  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
        status: json["Status"],
        message: json["Message"],
        data: List<Punto>.from(json["Data"].map((x) => Punto.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Status": status,
        "Message": message,
        "Data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Punto {
  List<num> point;
  String name;
  String logo;

  Punto({
    this.point,
    this.name,
    this.logo,
  });

  factory Punto.fromJson(Map<String, dynamic> json) => Punto(
        point: List<num>.from(json["point"].map((x) => x)),
        name: json["name"],
        logo: json["logo"],
      );

  Map<String, dynamic> toJson() => {
        "point": List<dynamic>.from(point.map((x) => x)),
        "name": name,
        "logo": logo,
      };
}
