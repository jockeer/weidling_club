import 'dart:convert';
import 'dart:io';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/models/cities_f.dart';
import 'package:weidling/models/country.dart';
import 'package:weidling/models/oferta.dart';

class CitiesProvider {
  Map<String, dynamic> mapaResultadoADevolver;
  final preferencias = new SharedPreferencesapp();

  Future hitAccessTokenApi() async {
    String url = NetworkApp.Base +
        NetworkEndPointsApp.hitAccesToken +
        "?client_id=ItacambaApp&client_secret=MWU5MTFlMTg1NzI5YjkyZWY4YTNiNjhkNDBiOWY2NGU	";
    final http.Response respuesta = await http.get(url);
    Map<String, dynamic> respuestaEnMap = jsonDecode(respuesta.body);
    try {
      String accessToke = respuestaEnMap["access_token"];
      this.preferencias.agregarValor(Constantes.access_token, accessToke);
    } catch (exepcion) {
      print(exepcion);
    }
  }

  Future<Map<String, dynamic>> obtenerCities(String countrySelected) async {
    final String base = NetworkApp.Base;
    final String endPointLogin = NetworkEndPointsApp.obtenerCiudades;
    String urlFinal = base + endPointLogin;

    String accessToken =
        preferencias.devolverValor(Constantes.access_token, "null");

    urlFinal = urlFinal +
        "?access_token=" +
        accessToken +
        "&countryid=" +
        countrySelected;

    http.Response respuesta;
    try {
      respuesta = await http.get(urlFinal);
    } catch (e) {
      return this.mapaResultadoADevolver = {
        Constantes.estado: Constantes.respuesta_estado_fail,
        Constantes.mensaje: "Error, catch e"
      };
    }

    if (respuesta.statusCode == 200) {
      ///todo ok

      try {
        CityData cityData = cityDataFromJson(respuesta.body);
        if (cityData.status) {
          this.mapaResultadoADevolver = {
            Constantes.estado: Constantes.respuesta_estado_ok,
            Constantes.mensaje: cityData
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
