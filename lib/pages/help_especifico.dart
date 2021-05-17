import 'package:weidling/helper_clases/constantes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weidling/pages/help_page.dart';

class ShowHelp extends StatelessWidget {
  ShowHelp({Key key}) : super(key: key); // a este le quite el const
  static final String namePage = "ShowHelp";
  Map<String, String> mapaObtenidoDePreguntas;

  @override
  Widget build(BuildContext context) {
    this.mapaObtenidoDePreguntas =
        ModalRoute.of(context).settings.arguments as Map;
    print(mapaObtenidoDePreguntas);
    return Scaffold(
      appBar: ContantsWidgetsDefaults.widgetAppBar(
          context, Colores.COLOR_AZUL_WEIDING),
      body: Stack(
        children: <Widget>[
          _fondo(context),
          SafeArea(child: _otrosElementos(context)),
        ],
      ),
    );
  }

  Widget _otrosElementos(BuildContext contexto) {
    return Column(
      children: <Widget>[
        _menuArriba(contexto),
        Expanded(child: _contenedorPreguntaRespuesta(contexto))
      ],
    );
  }

  Widget _contenedorPreguntaRespuesta(BuildContext contexto) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      color: Colors.transparent,
      width: double.infinity,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        color: Colors.black38,
        child: Column(
          children: <Widget>[
            Text(
              (this.mapaObtenidoDePreguntas != null &&
                      this.mapaObtenidoDePreguntas["question"] != null &&
                      this.mapaObtenidoDePreguntas["question"].length != 0)
                  ? this.mapaObtenidoDePreguntas["question"]
                  : "PREGUNTA",
              style: TextStyle(fontSize: 22.0, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                (this.mapaObtenidoDePreguntas != null &&
                        this.mapaObtenidoDePreguntas["answer"] != null &&
                        this.mapaObtenidoDePreguntas["answer"].length != 0)
                    ? this.mapaObtenidoDePreguntas["answer"]
                    : "RESPUESTA",
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuArriba(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colores.COLOR_AZUL_WEIDING,
            ),
            onTap: () {
              Navigator.of(contexto).pushReplacementNamed(HelpPage.namePage);
            },
          ),
          Text(
            "AYUDA",
            style: TextStyle(
              fontSize: tamanoPhone.width * 0.04,
              color: Colores.COLOR_AZUL_WEIDING,
            ),
          ),
          Icon(
            Icons.call,
            color: Colors.transparent,
          )
        ],
      ),
    );
  }

  Widget _fondo(BuildContext contexto) {
    return Container(
      color: Colors.red,
      width: double.infinity,
      height: double.infinity,
      child: Image(
        image: AssetImage("assets/imagenes/fondo_fridolin.jpg"),
        fit: BoxFit.cover,
      ),
    );
  }
}
