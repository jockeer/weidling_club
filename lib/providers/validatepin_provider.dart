import 'dart:convert';
import 'package:weidling/helper_clases/constantes.dart';

import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/providers/FirebaseMessaging/push_notificacions_provider.dart';
import 'package:weidling/providers/hitupdateDeviceToken.dart';

class ValidatePinProvider {
  final preferencias = new SharedPreferencesapp();
  Map<String, dynamic> mapaADevolver;

  Future<Map<String, dynamic>> validatePin(
      Map<String, String> parametros) async {
    final String base = NetworkApp.Base;
    final String endPointLogin = NetworkEndPointsApp.validatePinUser;
    final String urlFinal = base + endPointLogin;

    http.Response respuesta;

    try {
      respuesta = await http.post(urlFinal, body: parametros);
    } catch (e) {
      return this.mapaADevolver = {
        Constantes.estado: Constantes.respuesta_estado_fail,
        Constantes.mensaje: "catch error"
      };
    }

    try {
      final Map<String, dynamic> decodedData = json.decode(respuesta.body);
      if (decodedData[Constantes.status] as bool) {
        this.mapaADevolver = {
          Constantes.estado: Constantes.respuesta_estado_ok,
          Constantes.mensaje: decodedData[Constantes.message],
        };

        this.preferencias.agregarValor(
            Constantes.userSpecificToken, decodedData[Constantes.access_token]);
        this.preferencias.agregarValor(
            Constantes.refreshToken, decodedData["refresh_token"]);
      } else {
        this.mapaADevolver = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje: decodedData[Constantes.message]
        };
      }
    } catch (e) {
      this.mapaADevolver = {
        Constantes.estado: Constantes.respuesta_estado_fail,
        Constantes.mensaje: "El pin es incorrecto"
      };
    }

    return this.mapaADevolver;
  }
}
