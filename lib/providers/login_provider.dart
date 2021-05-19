import 'dart:convert';
import 'package:weidling/helper_clases/constantes.dart';

import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';

class LoginProvider {
  final preferencias = new SharedPreferencesapp();

  Future<bool> loginUser(String nroCarnet, String password) async {
    final String base = NetworkApp.Base;
    final String endPointLogin = NetworkEndPointsApp.loginUser;
    final Uri urlFinal = Uri.parse(base + endPointLogin);

    http.Response respuesta;
    try {
      respuesta = await http.post(urlFinal, body: {
        "password": password,
        "grant_type": "password",
        "client_id": "ItacambaAppUser",
        "username": nroCarnet
      });
    } catch (e) {
      return false;
    }

    final Map<String, dynamic> decodedData = json.decode(respuesta.body);

    if (decodedData.containsKey("access_token")) {
      String accessToken = decodedData["access_token"];
      String refreshToken = decodedData["refresh_token"];

      this.preferencias.agregarValor(Constantes.access_token, accessToken);
      this.preferencias.agregarValor(Constantes.refreshToken, refreshToken);
      this.preferencias.agregarValor(Constantes.userSpecificToken, accessToken);
      this.preferencias.agregarValor(Constantes.refreshToken, refreshToken);

      //guardando datos del usuario
      this.preferencias.agregarValor(Constantes.ciUser, nroCarnet);
      this.preferencias.agregarValor(Constantes.password, password);

      return true;
    } else {
      String error = decodedData["error"];
      return false;
    }
  }
}
