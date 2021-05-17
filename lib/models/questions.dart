// To parse this JSON data, do
//
//     final preguntas = preguntasFromJson(jsonString);

import 'dart:convert';

Preguntas preguntasFromJson(String str) => Preguntas.fromJson(json.decode(str));

String preguntasToJson(Preguntas data) => json.encode(data.toJson());

class Preguntas {
    bool status;
    String message;
    List<Pregunta> data;

    Preguntas({
        this.status,
        this.message,
        this.data,
    });

    factory Preguntas.fromJson(Map<String, dynamic> json) => Preguntas(
        status: json["Status"],
        message: json["Message"],
        data: List<Pregunta>.from(json["Data"].map((x) => Pregunta.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "Status": status,
        "Message": message,
        "Data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Pregunta {
    String question;
    String answer;

    Pregunta({
        this.question,
        this.answer,
    });

    factory Pregunta.fromJson(Map<String, dynamic> json) => Pregunta(
        question: json["question"],
        answer: json["answer"],
    );

    Map<String, dynamic> toJson() => {
        "question": question,
        "answer": answer,
    };
}