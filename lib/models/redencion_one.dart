import 'dart:convert';

RedencionOne redencionOneFromJson(String str) => RedencionOne.fromJson(json.decode(str));

String redencionOneToJson(RedencionOne data) => json.encode(data.toJson());

class RedencionOne {
    bool status;
    String message;
    List<Option> data;

    RedencionOne({
        this.status,
        this.message,
        this.data,
    });

    factory RedencionOne.fromJson(Map<String, dynamic> json) => RedencionOne(
        status: json["Status"],
        message: json["Message"],
        data: List<Option>.from(json["Data"].map((x) => Option.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Status": status,
        "Message": message,
        "Data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Option {
    String id;
    String name;

    Option({
        this.id,
        this.name,
    });

    factory Option.fromJson(Map<String, dynamic> json) => Option(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}