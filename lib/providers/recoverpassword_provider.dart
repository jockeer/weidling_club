import 'dart:convert';
import 'package:weidling/helper_clases/constantes.dart';

import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';

class RecoverPasswordProvider {
  final preferencias = new SharedPreferencesapp();

  Future hitAccessTokenApi() async {
    Uri url = Uri.parse(NetworkApp.Base +
        NetworkEndPointsApp.hitAccesToken +
        "?client_id=ItacambaApp&client_secret=MWU5MTFlMTg1NzI5YjkyZWY4YTNiNjhkNDBiOWY2NGU");
    final http.Response respuesta = await http.get(url);
    Map<String, dynamic> respuestaEnMap = jsonDecode(respuesta.body);

    try {
      String accessToke = respuestaEnMap["access_token"];
      this.preferencias.agregarValor(Constantes.access_token, accessToke);
    } catch (exepcion) {
      print(exepcion);
    }
  }

  Future<bool> recoverPassword(String email) async {
    final String base = NetworkApp.Base;
    final String endPointLogin = NetworkEndPointsApp.recoverPassword;
    final Uri urlFinal = Uri.parse(base + endPointLogin);
    final String accessToken =
        preferencias.devolverValor(Constantes.access_token, "");

    http.Response respuesta;
    try {
      respuesta = await http
          .post(urlFinal, body: {"email": email, "access_token": accessToken});
    } catch (e) {
      return false;
    }

    try {
      final Map<String, dynamic> decodedData = json.decode(respuesta.body);

      if (decodedData.containsKey(Constantes.error)) {
        if (decodedData[Constantes.error] == "expired_token") {
          hitAccessTokenApi().then((onValue) {
            recoverPassword(email);
          });
        }

        String error = decodedData["error"];
        return false;
      } else {
        if (decodedData[Constantes.status] == true) {
          return true;
        } else {
          return false;
        }
      }
    } catch (error) {
      hitAccessTokenApi();
      return false;
    }
  }
}
