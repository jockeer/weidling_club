import 'dart:convert';

CityData cityDataFromJson(String str) => CityData.fromJson(json.decode(str));

String cityDataToJson(CityData data) => json.encode(data.toJson());

class CityData {
    bool status;
    String message;
    List<Cities> data;

    CityData({
        this.status,
        this.message,
        this.data,
    });

    factory CityData.fromJson(Map<String, dynamic> json) => CityData(
        status: json["Status"],
        message: json["Message"],
        data: List<Cities>.from(json["Data"].map((x) => Cities.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Status": status,
        "Message": message,
        "Data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Cities {
    String id;
    String name;

    Cities({
        this.id,
        this.name,
    });

    factory Cities.fromJson(Map<String, dynamic> json) => Cities(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}