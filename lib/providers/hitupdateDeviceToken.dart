import 'dart:convert';
import 'package:weidling/helper_clases/constantes.dart';

import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'dart:io' show Platform;

import 'package:weidling/providers/FirebaseMessaging/push_notificacions_provider.dart';

class TokenDeviceUpdateProvider {
  final preferencias = new SharedPreferencesapp();
  Map<String, dynamic> mapaADevolver;

  Future<Map<String, dynamic>> updateTokenDevice(String deviceToken) async {
    final String base = NetworkApp.Base;
    final String endPointLogin = NetworkEndPointsApp.actualizarTokenDevice;
    final String urlFinal = base + endPointLogin;

    http.Response respuesta;

    try {
      respuesta = await http.post(urlFinal, body: {
        Constantes.grant_type: "password",
        Constantes.client_id: "ItacambaAppUser",
        Constantes.access_token:
            this.preferencias.devolverValor(Constantes.userSpecificToken, ""),
        Constantes.USER_ID:
            this.preferencias.devolverValor(Constantes.userSpecificToken, ""),
        Constantes.DEVICE_TYPE: (Platform.isAndroid) ? "ANDROID" : "IOS",
        Constantes.DEVICE_TOKEN: deviceToken
      });
    } catch (e) {
      return this.mapaADevolver = {
        Constantes.estado: Constantes.respuesta_estado_fail,
        Constantes.mensaje: "Unknown error"
      };
    }

    try {
      final Map<String, dynamic> decodedData = json.decode(respuesta.body);
      if (decodedData[Constantes.status] as bool) {
        this.mapaADevolver = {
          Constantes.estado: Constantes.respuesta_estado_ok,
          Constantes.mensaje: "Token actualizado con exito",
        };
        print("Token actualizado con exito al registrarse :" + deviceToken);
      } else {
        this.mapaADevolver = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje: decodedData[Constantes.message]
        };
      }
    } catch (e) {
      this.mapaADevolver = {
        Constantes.estado: Constantes.respuesta_estado_fail,
        Constantes.mensaje: "Unknown error"
      };
    }

    return this.mapaADevolver;
  }
}
