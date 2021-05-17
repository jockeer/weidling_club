import 'dart:convert';

CuentaPuntos cuentaPuntosFromJson(String str) =>
    CuentaPuntos.fromJson(json.decode(str));

String cuentaPuntosToJson(CuentaPuntos data) => json.encode(data.toJson());

class CuentaPuntos {
  bool status;
  String message;
  Data data;

  CuentaPuntos({
    this.status,
    this.message,
    this.data,
  });

  factory CuentaPuntos.fromJson(Map<String, dynamic> json) => CuentaPuntos(
        status: json["Status"],
        message: json["Message"],
        data: Data.fromJson(json["Data"]),
      );

  Map<String, dynamic> toJson() => {
        "Status": status,
        "Message": message,
        "Data": data.toJson(),
      };
}

class Data {
  String email;
  String name;
  String lastname;
  String ci;
  String expedition;
  String country;
  String city;
  String cellphone;
  DateTime birthdate;
  dynamic gender;
  num cash;

  Data({
    this.email,
    this.name,
    this.lastname,
    this.ci,
    this.expedition,
    this.country,
    this.city,
    this.cellphone,
    this.birthdate,
    this.gender,
    this.cash,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        email: json["email"],
        name: json["name"],
        lastname: json["lastname"],
        ci: json["ci"],
        expedition: json["expedition"],
        country: json["country"],
        city: json["city"],
        cellphone: json["cellphone"],
        birthdate: DateTime.parse(json["birthdate"]),
        gender: json["gender"],
        cash: json["cash"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "lastname": lastname,
        "ci": ci,
        "expedition": expedition,
        "country": country,
        "city": city,
        "cellphone": cellphone,
        "birthdate":
            "${birthdate.year.toString().padLeft(4, '0')}-${birthdate.month.toString().padLeft(2, '0')}-${birthdate.day.toString().padLeft(2, '0')}",
        "gender": gender,
        "cash": cash,
      };
}
