import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/pages/login_page.dart';
import 'package:weidling/providers/providers.dart';
import 'package:weidling/providers/recoverpassword_provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RecoverPassword extends StatefulWidget {
  static final nameOfPage = 'RecoverPassword';
  RecoverPassword({Key key}) : super(key: key);

  @override
  _RecoverPasswordState createState() => _RecoverPasswordState();
}

class _RecoverPasswordState extends State<RecoverPassword> {
  bool cargando;
  final preferencias = new SharedPreferencesapp();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.cargando = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ContantsWidgetsDefaults.widgetAppBar(
            context, Colores.COLOR_AZUL_WEIDING),
        body: ModalProgressHUD(
          child: Stack(
            children: <Widget>[
              _fondoApp(),
              _demasElementos(context),
            ],
          ),
          inAsyncCall: this.cargando,
          color: Colors.white,
          dismissible: true,
          progressIndicator: CircularProgressIndicator(
            valueColor:
                new AlwaysStoppedAnimation<Color>(Colores.COLOR_AZUL_ATC_FARMA),
          ),
        ));
  }

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

  Widget _demasElementos(BuildContext contexto) {
    final tamano = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _parteSuperior(contexto),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: _cuerpo(contexto),
          ),
        ],
      ),
    );
  }

  Widget _textFieldCorreo(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    return StreamBuilder(
      stream: provedorDeBloc.streamEmailRecoverPassword,
      builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
        return TextField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
              prefixIcon: Icon(Icons.email),
              hintText: "Ingresar su email",
              //  labelText: "Ingresar su email",
              fillColor: Colors.white,
              filled: true,
              errorStyle: TextStyle(color: Colors.white),
              errorText: (provedorDeBloc.ultimoValorEmailRecoverPass == "")
                  ? null
                  : asyncSnapshot.error),
          onChanged: (value) {
            provedorDeBloc.addDataToStreamEmailRecoverPass(value);
          },
        );
      },
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

  Future<bool> recuperarContrasena(String email) {
    RecoverPasswordProvider recoverPasswordProvider =
        new RecoverPasswordProvider();

    Future<bool> resultado = recoverPasswordProvider.recoverPassword(email);

    return resultado;
  }

  void _submit() {
    this.setState(() {
      this.cargando = true;
    });
  }

  Future volverAtras(BuildContext contexto) async {
    return Future.delayed(Duration(seconds: 3)).then((value) {
      Navigator.of(contexto).popAndPushNamed(LoginPage.nameOfPage);
    });
  }

  Widget _buttonSend(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    return StreamBuilder(
      stream: provedorDeBloc.streamEmailRecoverPassword,
      builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
        return RaisedButton(
          onPressed: () {
            if (!asyncSnapshot.hasError &&
                provedorDeBloc.ultimoValorEmailRecoverPass != null &&
                provedorDeBloc.ultimoValorEmailRecoverPass != "") {
              Future<Map<String, dynamic>> resultadoConexion =
                  verificarConexion();
              resultadoConexion.then((mapaRecibido) {
                if (mapaRecibido[Constantes.estado] ==
                    Constantes.respuesta_estado_ok) {
                  _submit();
                  Future<bool> resultado = recuperarContrasena(
                      provedorDeBloc.ultimoValorEmailRecoverPass);
                  resultado.then((onvalue) {
                    if (onvalue) {
                      this.setState(() {
                        this.cargando = false;
                      });
                      final SnackBar snackBar = new SnackBar(
                        backgroundColor: Colores.COLOR_AZUL_ATC_FARMA,
                        content: Text(
                            "Correo enviado. Por favor, revisar su correo electrónico y vuelva a ingresar"),
                      );
                      Scaffold.of(contexto).showSnackBar(snackBar);
                      provedorDeBloc.restablecerValor();
                      volverAtras(contexto); //77366111 marcelo

                    } else {
                      this.setState(() {
                        this.cargando = false;
                      });

                      final SnackBar snackBar = new SnackBar(
                        backgroundColor: Colores.COLOR_AZUL_ATC_FARMA,
                        content: Text(
                            "Datos incorrectos, por favor revisar sus datos"),
                      );

                      Scaffold.of(contexto).showSnackBar(snackBar);
                    }
                  });
                } else {
                  final SnackBar snackBar = new SnackBar(
                    backgroundColor: Colores.COLOR_AZUL_ATC_FARMA,
                    content: Text(mapaRecibido[Constantes.mensaje]),
                  );

                  Scaffold.of(contexto).showSnackBar(snackBar);
                  return;
                }
              });
            } else {
              final SnackBar snackBar = new SnackBar(
                backgroundColor: Colores.COLOR_AZUL_ATC_FARMA,
                content: Text("Por favor, ingresar un correo valido"),
              );

              Scaffold.of(contexto).showSnackBar(snackBar);
            }
          },
          child: Container(
              child: Text("Enviar"),
              padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          elevation: 30.0,
          color: Colors.white,
          textColor: Colores.COLOR_AZUL_WEIDING,
        );
      },
    );
  }

  Widget _cuerpo(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
      width: tamanoPhone.width * 0.9,
      height: tamanoPhone.height * 0.35,
      decoration: BoxDecoration(
          color: Colores.COLOR_AZUL_WEIDING,
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      child: Column(
        children: <Widget>[
          _textFieldCorreo(contexto),
          SizedBox(
            height: tamanoPhone.height * 0.05,
          ),
          _buttonSend(contexto)
        ],
      ),
    );
  }

  Widget _parteSuperior(BuildContext context) {
    final tamanoPhone = MediaQuery.of(context).size;
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
              onPressed: () {
                // Navigator.pop(context);
                Navigator.popAndPushNamed(context, LoginPage.nameOfPage);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colores.COLOR_AZUL_WEIDING,
              )),
          Center(
              child: Text(
            "CONTRASEÑA OLVIDADA",
            style: TextStyle(color: Colors.white),
          )),
          FlatButton(
              onPressed: () {
                // Navigator.pop(context);
                //Navigator.popAndPushNamed(context, LoginPage.nameOfPage);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.transparent,
              )),
        ],
      ),
    );
  }

  Widget _fondoApp() {
    return Builder(
      builder: (BuildContext contextoRecoverPassword) {
        verificarConexion().then((onValue) {
          if (onValue[Constantes.estado] == Constantes.respuesta_estado_ok) {
            hitAccessTokenApi();
          } else {
            final SnackBar snackBar = new SnackBar(
              backgroundColor: Colores.COLOR_AZUL_ATC_FARMA,
              content: Text(onValue[Constantes.mensaje]),
            );

            Scaffold.of(contextoRecoverPassword).showSnackBar(snackBar);
          }
        });

        return Container(
          color: Colors.red,
          width: double.infinity,
          height: double.infinity,
          child: Image(
            image: AssetImage("assets/imagenes/fondo_fridolin.jpg"),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
