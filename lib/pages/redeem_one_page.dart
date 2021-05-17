import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/models/redencion_one.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/pages/redeem_two_page.dart';
import 'package:weidling/providers/providers.dart';
import 'package:weidling/providers/redeen_one_provider.dart';

class RedeemPageOne extends StatelessWidget {
  RedeemPageOne({Key key}) : super(key: key);
  static final nameOfPage = "RedeemPageOne";
  Map<String, String> mapaParaEnviarPorStream;
  bool internetAvaible = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: ContantsWidgetsDefaults.widgetAppBar(
            context, Colores.COLOR_AZUL_WEIDING),
        body: Stack(
          children: <Widget>[_fondo(), _demasElementos(context)],
        ),
      ),
    );
  }

  Widget _demasElementos(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          _menuArriba(context),
          Expanded(
              child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: _contenedorOpciones(context))),
          SizedBox(
            height: 20.0,
          )
        ],
      ),
    );
  }

  Widget _contenedorOpciones(BuildContext context) {
    final tamanoPhone = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
          color: Colores.COLOR_AZUL_WEIDING,
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      width: tamanoPhone.width * 0.9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Canje de puntos",
            style: TextStyle(color: Colors.white, fontSize: 35.0),
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            "Seleccionar un comercio",
            style: TextStyle(color: Colors.white, fontSize: 25.0),
          ),
          SizedBox(
            height: 30.0,
          ),
          Expanded(child: _textFieldSeleccionar(context)),
          _btnEnviar(context),
          SizedBox(
            height: 50.0,
          )
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> verificarConexion() async {
    Map<String, dynamic> resultadoDeVerificacion;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        resultadoDeVerificacion = {
          Constantes.estado: Constantes.respuesta_estado_ok,
          Constantes.mensaje: "conectado"
        };
      } else {
        resultadoDeVerificacion = {
          Constantes.estado: Constantes.respuesta_estado_fail,
          Constantes.mensaje: "Por favor, revisar su conexion a internet"
        };
      }
    } catch (e) {
      resultadoDeVerificacion = {
        Constantes.estado: Constantes.respuesta_estado_fail,
        Constantes.mensaje: "Por favor, revisar su conexion a internet"
      };
    }
    return resultadoDeVerificacion;
  }

  Widget _btnEnviar(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    return StreamBuilder<Map<String, String>>(
        stream: provedorDeBloc.radioStream,
        builder: (context, snapshot) {
          return Builder(builder: (BuildContext contextoRedeen) {
            return RaisedButton(
              onPressed: (snapshot.hasData)
                  ? () {
                      verificarConexion().then((onValue) {
                        if (onValue[Constantes.estado] ==
                            Constantes.respuesta_estado_ok) {
                          print(this.mapaParaEnviarPorStream);

                          Navigator.of(contexto).pushNamed(
                              //aqui estava popAndPushNamed
                              RedeenTwoPage.nameOfPage,
                              arguments:
                                  provedorDeBloc.ultimoValorSeleccionadoRadi);
                        } else {
                          final snackBar = SnackBar(
                            content: Text('Revisar su conexion a internet'),
                            backgroundColor: Colors.brown,
                          );

                          // Find the Scaffold in the widget tree and use it to show a SnackBar.
                          Scaffold.of(contextoRedeen).showSnackBar(snackBar);
                        }
                      });
                    }
                  : null,
              child: Container(
                  child: Text("Siguiente"),
                  padding:
                      EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              elevation: 30.0,
              color: Colors.white,
              textColor: Colores.COLOR_AZUL_WEIDING,
            );
          });
        });
  }

  Widget radioTile(
      BuildContext contexto, int indice, String title, String value) {
    final provedorDeBloc = Provider.of(contexto);
    return StreamBuilder<Map<String, String>>(
        stream: provedorDeBloc.radioStream,
        builder: (context, snapshot) {
          return Card(
            elevation: 10.0,
            child: RadioListTile(
                activeColor: Colores.COLOR_AZUL_WEIDING,
                title: Text(title),
                value: value,
                groupValue:
                    (snapshot.data != null) ? snapshot.data["id"] : "-1",
                onChanged: (value) {
                  this.mapaParaEnviarPorStream = {"id": value, "title": title};
                  provedorDeBloc
                      .addDataToStreamRadioRedeen(this.mapaParaEnviarPorStream);
                }),
          );
        });
  }

  Future<Map<String, dynamic>> obtenerOpciones() {
    RedeenOneProvider redeenOneProvider = new RedeenOneProvider();
    return verificarConexion().then((valorRecibido) {
      if (valorRecibido[Constantes.estado] == Constantes.respuesta_estado_ok) {
        this.internetAvaible = true;
        return redeenOneProvider.obtainOptionsRedeen();
      } else {
        this.internetAvaible = false;
        return null;
      }
    });
  }

  Widget _textFieldSeleccionar(BuildContext context) {
    Map<String, dynamic> respuesDesdeElprovider;
    return FutureBuilder(
      future: obtenerOpciones(),
      builder: (BuildContext contexto,
          AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
        if (!asyncSnapshot.hasError && asyncSnapshot.hasData) {
          respuesDesdeElprovider = asyncSnapshot.data;
          if (respuesDesdeElprovider.containsKey(Constantes.estado)) {
            if (respuesDesdeElprovider[Constantes.estado] ==
                Constantes.respuesta_estado_ok) {
              List<Option> opcionesLista =
                  (respuesDesdeElprovider[Constantes.mensaje] as RedencionOne)
                      .data;
              return ListView.builder(
                  itemCount: opcionesLista.length,
                  itemBuilder: (BuildContext contexto, int indice) {
                    return radioTile(contexto, indice,
                        opcionesLista[indice].name, opcionesLista[indice].id);
                  });
            } else {
              return Center(child: Text("HUBO UN PROBLEMA VUELVA INTENTARLO"));
            }
          } else {
            return Center(child: Text("HUBO UN PROBLEMA VUELVA INTENTARLO"));
          }
        } else {
          if (!this.internetAvaible) {
            return Center(child: Text("SIN CONEXION A INTERNET"));
          }

          if (asyncSnapshot.hasError) {
            return Center(child: Text("HUBO UN PROBLEMA VUELVA INTENTARLO"));
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Colores.COLOR_AZUL_ATC_FARMA),
              ),
            );
          }
        }
      },
    );
  }

  Widget _fondo() {
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

  Widget _menuArriba(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;
    final provedorDeBloc = Provider.of(contexto);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colores.COLOR_AZUL_WEIDING,
            ),
            onTap: () {
              Navigator.of(contexto).popAndPushNamed(HomePage.nameOfPage);
            },
          ),
          Container(
            width: 200,
            height: 139,
            child: Image(
              image: AssetImage("assets/imagenes/logo_fridolin.png"),
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
}
