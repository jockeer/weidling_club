import 'dart:convert';
import 'dart:io';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/models/oferta.dart';
import 'package:weidling/models/redencion_one.dart';
import 'package:weidling/pages/redeem_one_page.dart';

class RedeenOneProvider {
  Map<String, dynamic> respuestaAlUI;

  final preferencias = new SharedPreferencesapp();

  void hitAccessTokenApi() async {
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

  Future<Map<String, dynamic>> obtainOptionsRedeen() async {
    final String base = NetworkApp.Base;
    //final String base   = "https://www.stellarclubs.com/";
    final String endPointLogin = NetworkEndPointsApp.getOptionsRedeenOne;
    String urlFinal = base + endPointLogin;

    String accessToken =
        preferencias.devolverValor(Constantes.access_token, "");

    urlFinal = urlFinal + "?access_token=" + accessToken;
    http.Response respuesta;

    try {
      respuesta = await http.get(urlFinal);
    } catch (e) {
      return this.respuestaAlUI = {
        Constantes.estado: Constantes.respuesta_estado_fail,
        Constantes.mensaje: "catch entry"
      };
    }

    if (respuesta.statusCode == 200) {
      ///todo ok

      try {
        Map<String, dynamic> resultadoEnMapa = jsonDecode(respuesta.body);

        if (resultadoEnMapa.containsKey(Constantes.status)) {
          if (resultadoEnMapa[Constantes.status] as bool) {
            RedencionOne redencionOne = redencionOneFromJson(respuesta.body);
            this.respuestaAlUI = {
              Constantes.estado: Constantes.respuesta_estado_ok,
              Constantes.mensaje: redencionOne
            };
          } else {
            //aqui si tiene Status pero es false entonces verificar si el error es igual que expired_token
            if (resultadoEnMapa[Constantes.error] == Constantes.expired_token) {
              hitAccessTokenApi();
              obtainOptionsRedeen();
            } else {
              ///bueno aqui es mas raro aun tambien
              this.respuestaAlUI = {
                Constantes.estado: Constantes.respuesta_estado_fail,
                Constantes.mensaje: "ERROR NO HAY STATUS NI ERROR"
              };
            }
          }
        } else {
          //aqui no tiene la llave Status aqui es mas raro aun
          this.respuestaAlUI = {
            Constantes.estado: Constantes.respuesta_estado_fail,
            Constantes.mensaje: "FORMATO MAL RECIBIDO"
          };
        }
      } catch (e) {
        print(e);
      }
    } else {
      if (respuesta.statusCode == HttpStatus.requestTimeout) {
        this.respuestaAlUI = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje: "TIEMPO DE ESPERA EXCEDIDO, REVISE SU CONEXION"
        };
      } else {
        this.respuestaAlUI = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje: "UKNOWN ERROR"
        };
      }
    }

    return this.respuestaAlUI;
  }
}
