import 'dart:io';

import 'package:weidling/blocs/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/models/contacto.dart';
import 'package:weidling/models/questions.dart';
import 'package:weidling/pages/help_especifico.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/providers/contact_provider.dart';
import 'package:weidling/providers/providers.dart';
import 'package:weidling/providers/questions_provider.dart';
import 'package:weidling/providers/send_message_provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends StatefulWidget {
  HelpPage({Key key}) : super(key: key);

  static final String namePage = "HelpPage";

  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  BlocLoyalty blocGeneral;
  bool cargando;
  String llamarNumero;
  bool internetAvaible;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.cargando = true;
    this.llamarNumero = "70000000";
    this.internetAvaible = true;
  }

  @override
  Widget build(BuildContext context) {
    blocGeneral = Provider.of(context);
    return Scaffold(
      appBar: ContantsWidgetsDefaults.widgetAppBar(
          context, Colores.COLOR_AZUL_WEIDING),
      body: StreamBuilder(
          stream: blocGeneral.cargandoStream,
          builder: (BuildContext contexto, AsyncSnapshot<bool> asyncSnapshot) {
            return ModalProgressHUD(
              inAsyncCall:
                  (asyncSnapshot.data != null) ? asyncSnapshot.data : false,
              color: Colors.white,
              dismissible: false,
              progressIndicator: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Colores.COLOR_NARANJA_ATC_FARMA),
              ),
              child: Stack(
                children: <Widget>[
                  _fondo(),
                  SafeArea(child: _demasElementos(context))
                ],
              ),
            );
          }),
    );
  }

  Future<Contacto> obtenerContacto() {
    ContactProvider proveedorContacto = new ContactProvider();
    return verificarConexion().then((valorDevuelto) {
      if (valorDevuelto[Constantes.estado] == Constantes.respuesta_estado_ok) {
        this.internetAvaible = true;
        return proveedorContacto.obTainContacts();
      } else {
        this.internetAvaible = false;
        return null;
      }
    });
  }

  Widget _contactaMe(BuildContext contexto) {
    ContactProvider proveedorContacto = new ContactProvider();
    final tamanoPhone = MediaQuery.of(contexto).size;
    String mensajeMostrar = "";
    return FutureBuilder(
      future: obtenerContacto(),
      builder: (BuildContext contexto, AsyncSnapshot asyncSnapshot) {
        Contacto contactoRecibido = asyncSnapshot.data;
        if (asyncSnapshot.hasData) {
          if (!contactoRecibido.status) {
            mensajeMostrar = contactoRecibido.email;
          } else {
            this.llamarNumero = contactoRecibido.phone;
            mensajeMostrar =
                "Contáctanos a través de ${contactoRecibido.email} o usando el formulario de consultas :";
          }
          return Container(
            child: Text(
              mensajeMostrar,
              style: TextStyle(
                fontSize: tamanoPhone.width * 0.04,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.0),
          );
        } else {
          if (!this.internetAvaible) {
            return Container(
              child: Center(
                  child: Text(
                "Contáctanos a través de fridolinclub@loyaltyclubs.net o usando el formulario de consultas :",
                style: TextStyle(
                  fontSize: tamanoPhone.width * 0.04,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              )),
            );
          }

          return Container(
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Colores.COLOR_NARANJA_ATC_FARMA),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _elTextFieldEnSi(BuildContext contexto) {
    return TextField(
      style: TextStyle(color: Colors.black),
      maxLines: 10,
      onChanged: (value) {
        this.blocGeneral.addDataToStreamMensaje(value);
      },
      decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromRGBO(240, 240, 240, 1),
          border: new OutlineInputBorder(
            borderRadius: const BorderRadius.all(
              const Radius.circular(20.0),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 0.5),
          ),
          hintText: "Escriba su mensaje...",
          hintStyle: TextStyle(color: Colors.black)),
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

  Widget _elBotonEnSi(BuildContext contexto) {
    SendMessageProvider enviarMensajeProvider = new SendMessageProvider();
    return StreamBuilder<String>(
        stream: this.blocGeneral.mensajeStream,
        builder: (context, snapshot) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: MaterialButton(
                elevation: 10.0,
                minWidth: 200.0,
                height: 50.0,
                onPressed: () {
                  String ultimoValor = snapshot.data;
                  if (ultimoValor == null || ultimoValor.length == 0) {
                    final snackBar = SnackBar(
                      content: Text("Porfavor ingresa un mensaje para enviar"),
                      backgroundColor: Colores.COLOR_AZUL_ATC_FARMA,
                    );
                    Scaffold.of(context).showSnackBar(snackBar);
                  } else {
                    verificarConexion().then((respuesta) {
                      if (respuesta[Constantes.estado] ==
                          Constantes.respuesta_estado_ok) {
                        blocGeneral.addDataToStreamCargando(true);
                        enviarMensajeProvider
                            .enviarMensaje(ultimoValor, context)
                            .then((onValue) {
                          //  if( onValue["estado"] == "correcto" ){
                          blocGeneral.addDataToStreamCargando(false);
                          final snackBar = SnackBar(
                            content: Text(onValue["mensaje_del_servidor"]),
                            backgroundColor: Colores.COLOR_AZUL_ATC_FARMA,
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                          //}
                        }).catchError((onError) {
                          blocGeneral.addDataToStreamCargando(false);
                          final snackBar = SnackBar(
                            content: Text(onError.toString()),
                            backgroundColor: Colores.COLOR_AZUL_ATC_FARMA,
                          );
                          Scaffold.of(context).showSnackBar(snackBar);
                        });
                      } else {
                        final snackBar = SnackBar(
                          content: Text("Revisar su conexion a internet"),
                          backgroundColor: Colores.COLOR_AZUL_ATC_FARMA,
                        );
                        Scaffold.of(context).showSnackBar(snackBar);
                      }
                    });
                  }
                },
                color: Colores.COLOR_AZUL_WEIDING,
                child: Text("Enviar Mensaje",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          );
        });
  }

  Widget _textField(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;
    return Container(
      height: tamanoPhone.height * 0.30,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      width: double.infinity,
      // color: Colors.red,
      child: Stack(
        children: <Widget>[
          _elTextFieldEnSi(contexto),
          _elBotonEnSi(contexto),
        ],
      ),
    );
  }

  Widget _preguntasLabel(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          color: Colores.COLOR_AZUL_WEIDING),
      padding: EdgeInsets.all(10.0),
      child: Text("PREGUNTAS Y RESPUESTAS FRECUENTES",
          style: TextStyle(
            fontSize: tamanoPhone.width * 0.04,
            color: Colors.white,
          )),
    );
  }

  Widget _demasElementos(BuildContext contexto) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          _menuArriba(contexto),
          SizedBox(
            height: 10.0,
          ),
          _contactaMe(contexto),
          SizedBox(
            height: 10.0,
          ),
          _textField(contexto),
          SizedBox(height: 20.0),
          _preguntasLabel(contexto),
          SizedBox(height: 20.0),
          _listaDePreguntasFrecuentes(contexto),
        ],
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
              Navigator.of(contexto).pushReplacementNamed(HomePage.nameOfPage);
            },
          ),
          Text(
            "AYUDA",
            style: TextStyle(
              fontSize: tamanoPhone.width * 0.04,
              color: Colores.COLOR_AZUL_WEIDING,
            ),
          ),
          GestureDetector(
            child: Icon(Icons.call, color: Colores.COLOR_AZUL_WEIDING),
            onTap: () {
              String numeroALlamar = this.llamarNumero;
              launch("tel://$llamarNumero");
            },
          )
        ],
      ),
    );
  }

  Future<List<Pregunta>> getQuestions(BuildContext contexto) {
    PreguntasProvider proveedorDePreguntas = new PreguntasProvider();

    return verificarConexion().then((value) {
      if (value[Constantes.estado] == Constantes.respuesta_estado_ok) {
        this.internetAvaible = true;
        return proveedorDePreguntas.obtenerPreguntas();
      } else {
        final snackBar = SnackBar(
          content: Text('Revisar su conexion a internet'),
          backgroundColor: Colores.COLOR_AZUL_ATC_FARMA,
        );

        // Find the Scaffold in the widget tree and use it to show a SnackBar.
        Scaffold.of(contexto).showSnackBar(snackBar);
        this.internetAvaible = false;
        return null;
      }
    });
  }

  Widget _listaDePreguntasFrecuentes(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;
    return FutureBuilder(
        future: getQuestions(contexto),
        builder: (BuildContext contexto,
            AsyncSnapshot<List<Pregunta>> asyncSnapshot) {
          if (!asyncSnapshot.hasData) {
            if (!this.internetAvaible) {
              return Center(
                  child: Text("Verificar su conexion a internet",
                      style: TextStyle(
                        fontSize: tamanoPhone.width * 0.04,
                        color: Colores.COLOR_AZUL_WEIDING,
                      )));
            }

            return Center(
                child: Text("Solicitando datos...",
                    style: TextStyle(
                      fontSize: tamanoPhone.width * 0.04,
                      color: Colores.COLOR_AZUL_WEIDING,
                    )));
          }
          List<Pregunta> listaPreguntas = asyncSnapshot.data;

          return ListView.builder(
            shrinkWrap: true,
            itemCount: asyncSnapshot.data.length,
            itemBuilder: (BuildContext contexto, int indice) {
              return GestureDetector(
                onTap: () {
                  print(indice); //solo para verificar

                  Map<String, String> seleccionado = {
                    "question": listaPreguntas[indice].question,
                    "answer": listaPreguntas[indice].answer
                  };

                  Navigator.of(contexto)
                      .pushNamed(ShowHelp.namePage, arguments: seleccionado);
                },
                child: Card(
                  color: Color.fromRGBO(171, 171, 171, 1),
                  elevation: 10.0,
                  child: ListTile(
                    title: Text(
                      listaPreguntas[indice].question,
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          );
        });
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
}
