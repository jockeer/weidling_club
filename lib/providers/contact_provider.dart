import 'dart:convert';

import 'package:weidling/helper_clases/constantes.dart';
import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/models/contacto.dart';
import 'dart:io';

class ContactProvider {
  final preferencias = new SharedPreferencesapp();
  Contacto contacto;

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

  Future<Contacto> obTainContacts() async {
    this.contacto = new Contacto();

    final String base = NetworkApp.Base;
    final String endPointLogin = NetworkEndPointsApp.getContact;
    final String accesToken =
        this.preferencias.devolverValor(Constantes.access_token, "");
    final String urlFinal =
        base + endPointLogin + "?access_token=" + accesToken;

    http.Response respuesta;

    try {
      respuesta = await http.get(Uri.parse(urlFinal));
    } catch (e) {
      this.contacto.email = "Catch error";
      return this.contacto;
    }

    if (respuesta.statusCode == 200) {
      try {
        Map<String, dynamic> enMapaResultadoRecibido =
            jsonDecode(respuesta.body);

        if (enMapaResultadoRecibido.containsKey(Constantes.error)) {
          if (enMapaResultadoRecibido[Constantes.error] ==
              Constantes.expired_token) {
            hitAccessTokenApi();
            obTainContacts();
          }
        } else {
          this.contacto = contactoFromJson(respuesta.body);
        }
      } catch (e) {
        this.contacto.email = "error";
      }
    } else {
      if (respuesta.statusCode == HttpStatus.requestTimeout) {
        this.contacto.email = "Revise su conexion a internet porfavor";
      }
    }
    return this.contacto;
  }
}
