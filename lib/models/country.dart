import 'dart:convert';

CountryData countryDataFromJson(String str) => CountryData.fromJson(json.decode(str));

String countryDataToJson(CountryData data) => json.encode(data.toJson());

class CountryData {
    bool status;
    String message;
    List<Paises> data;

    CountryData({
        this.status,
        this.message,
        this.data,
    });

    factory CountryData.fromJson(Map<String, dynamic> json) => CountryData(
        status: json["Status"],
        message: json["Message"],
        data: List<Paises>.from(json["Data"].map((x) => Paises.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Status": status,
        "Message": message,
        "Data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Paises {
    String id;
    String name;

    Paises({
        this.id,
        this.name,
    });

    factory Paises.fromJson(Map<String, dynamic> json) => Paises(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}