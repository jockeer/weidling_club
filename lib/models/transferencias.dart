// To parse this JSON data, do
//
//     final transferencias = transferenciasFromJson(jsonString);

import 'dart:convert';

Transferencias transferenciasFromJson(String str) =>
    Transferencias.fromJson(json.decode(str));

String transferenciasToJson(Transferencias data) => json.encode(data.toJson());

class Transferencias {
  Transferencias({
    this.transferencias,
  });

  List<Transferencia> transferencias;

  factory Transferencias.fromJson(Map<String, dynamic> json) => Transferencias(
        transferencias: List<Transferencia>.from(
            json["transferencias"].map((x) => Transferencia.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "transferencias":
            List<dynamic>.from(transferencias.map((x) => x.toJson())),
      };
}

class Transferencia {
  Transferencia({
    this.fecha,
    this.data,
  });

  String fecha;
  List<DetalleTransferencia> data;

  factory Transferencia.fromJson(Map<String, dynamic> json) => Transferencia(
        fecha: json["fecha"],
        data: List<DetalleTransferencia>.from(
            json["data"].map((x) => DetalleTransferencia.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "fecha": fecha,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class DetalleTransferencia {
  DetalleTransferencia({
    this.type,
    this.detail,
    this.mount,
  });

  String type;
  String detail;
  num mount;

  factory DetalleTransferencia.fromJson(Map<String, dynamic> json) =>
      DetalleTransferencia(
        type: json["type"],
        detail: json["detail"],
        mount: json["mount"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "detail": detail,
        "mount": mount,
      };
}
