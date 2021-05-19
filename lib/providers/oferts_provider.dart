import 'dart:convert';
import 'dart:io';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/models/oferta.dart';

class OffertProvider {
  List<Offert> listaOfertas;
  final preferencias = new SharedPreferencesapp();

  void hitAccessTokenApi() async {
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

  Future<List<Offert>> obtenerOfertas() async {
    this.listaOfertas = [];
    final String base = NetworkApp.Base;
    final String endPointLogin = NetworkEndPointsApp.obtenerOfertas;
    String urlFinal = base + endPointLogin;
    String accessToken =
        preferencias.devolverValor(Constantes.access_token, "");
    http.Response respuesta;
    urlFinal = urlFinal + "?access_token=" + accessToken;

    try {
      respuesta = await http.get(Uri.parse(urlFinal));
    } catch (e) {
      return this.listaOfertas;
    }

    if (respuesta.statusCode == 200) {
      ///todo ok

      try {
        Map<String, dynamic> resultadoEnMapa = jsonDecode(respuesta.body);

        if (resultadoEnMapa.containsKey(Constantes.error)) {
          if (resultadoEnMapa[Constantes.error] == Constantes.expired_token) {
            hitAccessTokenApi();
            obtenerOfertas();
          }
        } else {
          Ofertas ofertas = ofertasFromJson(respuesta.body);

          this.listaOfertas = ofertas.data;
          // print("URL Jpg "+ofertas.data[0].urlJpg + " URL Pdf "+ ofertas.data[0].urlPdf);
        }
      } catch (e) {
        print(e);
      }
    } else {
      if (respuesta.statusCode == HttpStatus.requestTimeout) {
        this.listaOfertas.add(
            new Offert(nameCompany: "Porfavor revisa tu conexion a internet"));
      } else {
        this.listaOfertas.add(new Offert(nameCompany: "ERROR"));
      }
    }

    return this.listaOfertas;
  }
}
