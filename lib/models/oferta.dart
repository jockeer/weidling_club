import 'dart:convert';

Ofertas ofertasFromJson(String str) => Ofertas.fromJson(json.decode(str));

String ofertasToJson(Ofertas data) => json.encode(data.toJson());

class Ofertas {
    Ofertas({
        this.status,
        this.message,
        this.data,
    });

    bool status;
    String message;
    List<Offert> data;

    factory Ofertas.fromJson(Map<String, dynamic> json) => Ofertas(
        status: json["Status"],
        message: json["Message"],
        data: List<Offert>.from(json["Data"].map((x) => Offert.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Status": status,
        "Message": message,
        "Data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Offert {
    Offert({
        this.id,
        this.nameCompany,
        this.urlJpg,
        this.urlPdf,
        this.title,
        this.subtitle,
        this.until,
        this.points,
        this.quantity,
    });

    String id;
    String nameCompany;
    String urlJpg;
    String urlPdf;
    String title;
    String subtitle;
    DateTime until;
    String points;
    String quantity;

    factory Offert.fromJson(Map<String, dynamic> json) => Offert(
        id: json["id"],
        nameCompany: json["name_company"],
        urlJpg: json["url_jpg"],
        urlPdf: json["url_pdf"],
        title: json["title"],
        subtitle: json["subtitle"],
        until: DateTime.parse(json["until"]),
        points: json["points"],
        quantity: json["quantity"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name_company": nameCompany,
        "url_jpg": urlJpg,
        "url_pdf": urlPdf,
        "title": title,
        "subtitle": subtitle,
        "until": "${until.year.toString().padLeft(4, '0')}-${until.month.toString().padLeft(2, '0')}-${until.day.toString().padLeft(2, '0')}",
        "points": points,
        "quantity": quantity,
    };
}