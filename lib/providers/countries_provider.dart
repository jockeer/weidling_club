import 'dart:convert';
import 'dart:io';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/models/country.dart';

class Countries {
  Map<String, dynamic> mapaResultadoADevolver;
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

  Future<Map<String, dynamic>> obtenerPaises() async {
    final String base = NetworkApp.Base;
    final String endPointLogin = NetworkEndPointsApp.obtenerPaises;
    String urlFinal = base + endPointLogin;

    String accessToken =
        preferencias.devolverValor(Constantes.access_token, "null");

    urlFinal = urlFinal + "?access_token=" + accessToken;
    http.Response respuesta;
    /*
      body: {"access_token": accessToken}
    */
    try {
      respuesta = await http.get(Uri.parse(urlFinal));
    } catch (e) {
      return this.mapaResultadoADevolver = {
        Constantes.estado: Constantes.respuesta_estado_fail,
        Constantes.mensaje: "Error, catch e"
      };
    }
    print(respuesta.body);
    if (respuesta.statusCode == 200) {
      ///todo ok

      try {
        CountryData countryData = countryDataFromJson(respuesta.body);
        if (countryData.status) {
          this.mapaResultadoADevolver = {
            Constantes.estado: Constantes.respuesta_estado_ok,
            Constantes.mensaje: countryData
          };
        } else {
          this.mapaResultadoADevolver = {
            Constantes.estado: Constantes.respuesta_estado_fail,
            Constantes.mensaje: "Error, no true"
          };
        }
      } catch (e) {
        this.mapaResultadoADevolver = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje: "Error, catch e"
        };
      }
    } else {
      if (respuesta.statusCode == HttpStatus.unauthorized) {
        hitAccessTokenApi();
        return this.mapaResultadoADevolver = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje: "Vuelva a intentarlo"
        };
      }

      if (respuesta.statusCode == HttpStatus.requestTimeout) {
        this.mapaResultadoADevolver = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje:
              "Tiempo de espera excedido, por favor revisar su conexion"
        };
      } else {
        this.mapaResultadoADevolver = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje: "Unknown error"
        };
      }
    }

    return this.mapaResultadoADevolver;
  }
}
