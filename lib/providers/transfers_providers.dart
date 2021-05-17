import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/constantes.dart';

import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/models/cards.dart';
import 'package:weidling/models/heper_tienda.dart';
import 'package:weidling/models/tienda.dart';
import 'package:weidling/models/trans_from_server.dart';
import 'package:weidling/models/transferencias.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/pages/login_page.dart';

class HistoryProviders {
  List<Transferencia> listaTransferencias;
  List<String> listaDeFechasPreguntadas;
  final preferencias = new SharedPreferencesapp();

  Future _hitAccessTokenApi() async {
    String url = NetworkApp.Base +
        NetworkEndPointsApp.hitAccesToken +
        "?client_id=ItacambaApp&client_secret=MWU5MTFlMTg1NzI5YjkyZWY4YTNiNjhkNDBiOWY2NGU";
    final http.Response respuesta = await http.get(url);
    Map<String, dynamic> respuestaEnMap = jsonDecode(respuesta.body);

    try {
      String accessToke = respuestaEnMap["access_token"];
      this.preferencias.agregarValor(Constantes.access_token, accessToke);
    } catch (exepcion) {
      print(exepcion);
    }
  }

  void _llenarLaListaDeTransferencias(
      List<TransferElements> listaDeTrasnferenciaFromServer) {
    String fecha;
    this.listaDeFechasPreguntadas = new List();

    for (var i = 0; i < listaDeTrasnferenciaFromServer.length; i++) {
      fecha = listaDeTrasnferenciaFromServer[i].date;

      Transferencia nuevaFechaTransferencia = new Transferencia();
      nuevaFechaTransferencia.fecha = fecha;
      nuevaFechaTransferencia.data = new List();

      for (var j = i; j < listaDeTrasnferenciaFromServer.length; j++) {
        String nuevaFechaConComparar = listaDeTrasnferenciaFromServer[j].date;

        if (!this.listaDeFechasPreguntadas.contains(nuevaFechaConComparar)) {
          if (fecha == nuevaFechaConComparar) {
            this.listaDeFechasPreguntadas.add(fecha);
            DetalleTransferencia detalleTransferencia =
                new DetalleTransferencia();
            detalleTransferencia.detail =
                listaDeTrasnferenciaFromServer[j].detail;
            detalleTransferencia.mount =
                listaDeTrasnferenciaFromServer[j].mount;
            detalleTransferencia.type = listaDeTrasnferenciaFromServer[j].type;
            nuevaFechaTransferencia.data.add(detalleTransferencia);
            listaTransferencias.add(nuevaFechaTransferencia);
          }
        } else {
          DetalleTransferencia detalleTransferencia =
              new DetalleTransferencia();
          detalleTransferencia.detail =
              listaDeTrasnferenciaFromServer[j].detail;
          detalleTransferencia.mount = listaDeTrasnferenciaFromServer[j].mount;
          detalleTransferencia.type = listaDeTrasnferenciaFromServer[j].type;
          nuevaFechaTransferencia.data.add(detalleTransferencia);
        }
      }
    }

    print(this.listaTransferencias);
    this.listaDeFechasPreguntadas.clear();
  }

  Future<Map<String, dynamic>> obtenerTransferencias(
      BuildContext contexto) async {
    this.listaTransferencias = [];
    Map<String, dynamic> mapaADevolver = new Map<String, String>();
    final String base = NetworkApp.Base;
    final String endPointLogin = NetworkEndPointsApp.obtenerTransferencias;
    String urlFinal = base + endPointLogin;

    String userEspecificParametro =
        preferencias.devolverValor(Constantes.userSpecificToken, "");
    final String parteEndUrl = "?access_token=" + userEspecificParametro;

    urlFinal = urlFinal + parteEndUrl;
    http.Response respuesta;
    try {
      respuesta = await http.get(urlFinal);
    } catch (e) {
      return mapaADevolver = {
        Constantes.estado: Constantes.respuesta_estado_fail,
        Constantes.mensaje: e.toString()
      };
    }

    if (respuesta.statusCode == 200) {
      ///todo ok
      try {
        // Map<String, dynamic> mapaRecibido = json.decode(respuesta.body) as Map;
        // List<Map<String, dynamic>> listaDeMapas = mapaRecibido["Data"];

        Transfers transferenciasDesdeElServidor =
            transfersFromJson(respuesta.body);
        if (transferenciasDesdeElServidor.status) {
          _llenarLaListaDeTransferencias(transferenciasDesdeElServidor.data);
          mapaADevolver = {
            Constantes.estado: Constantes.respuesta_estado_ok,
            Constantes.mensaje: this.listaTransferencias
          };
        } else {
          _hitAccessTokenApi();
          mapaADevolver = {
            Constantes.estado: Constantes.respuesta_estado_fail,
            Constantes.mensaje: "Por favor, vuelve a intentarlo"
          };
        }
      } catch (e) {
        print("El error es : " + e.toString());
        mapaADevolver = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje: "When get store, catch entry"
        };
      }
    } else {
      if (respuesta.statusCode == HttpStatus.requestTimeout) {
        mapaADevolver = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje:
              "Por favor, revisa tu conexion a internet. TIMEOUT"
        };
      } else {
        mapaADevolver = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje: "UNKNOW PROBLEM"
        };
      }
    }

    print(mapaADevolver);
    return mapaADevolver;
  }
}
