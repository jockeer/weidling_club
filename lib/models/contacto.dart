import 'dart:convert';

Contacto contactoFromJson(String str) => Contacto.fromJson(json.decode(str));
String contactoToJson(Contacto data) => json.encode(data.toJson());

class Contacto {
    bool status;
    String message;
    String phone;
    String email;

    Contacto({
        this.status,
        this.message,
        this.phone,
        this.email,
    });

    factory Contacto.fromJson(Map<String, dynamic> json) => Contacto(
        status: json["Status"],
        message: json["Message"],
        phone: json["Phone"],
        email: json["Email"],
    );

    Map<String, dynamic> toJson() => {
        "Status": status,
        "Message": message,
        "Phone": phone,
        "Email": email,
    };
}