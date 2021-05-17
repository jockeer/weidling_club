import 'dart:convert';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constantes.dart';

class Base {
  final preferencias = new SharedPreferencesapp();

  Future hitAccessTokenApi() async {
    String tokenYClave =
        "?client_id=ItacambaApp&client_secret=MWU5MTFlMTg1NzI5YjkyZWY4YTNiNjhkNDBiOWY2NGU";
    String url =
        NetworkApp.Base + NetworkEndPointsApp.hitAccesToken + tokenYClave;

    final http.Response respuesta = await http.get(url); //se cambio a post
    Map<String, dynamic> respuestaEnMap = jsonDecode(respuesta.body);

    try {
      String accessToke = respuestaEnMap["access_token"];
      this.preferencias.agregarValor(Constantes.access_token, accessToke);
    } catch (exepcion) {
      print(exepcion);
    }
  }

  Widget retornarCircularCargando(Color color) {
    return CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(color),
    );
  }

  void showSnackBar(String mensaje, BuildContext contexto, Color colorFondo) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      backgroundColor: colorFondo,
    );

    // Find the Scaffold in the widget tree and use it to show a SnackBar.
    Scaffold.of(contexto).showSnackBar(snackBar);
  }
}
