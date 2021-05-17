import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/pages/recover_password.dart';
import 'package:weidling/pages/welcome_page.dart';
import 'package:weidling/providers/FirebaseMessaging/push_notificacions_provider.dart';
import 'package:weidling/providers/hitupdateDeviceToken.dart';
import 'package:weidling/providers/login_provider.dart';
import 'package:weidling/providers/providers.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:connectivity/connectivity.dart';

class LoginPage extends StatefulWidget {
  static final nameOfPage = 'LoginPage';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController textEditingController;
  TextEditingController textEditingControllerPassword;

  bool cargando;
  final preferencias = SharedPreferencesapp();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.preferencias.agregarValor(Constantes.last_page, LoginPage.nameOfPage);
    this
        .preferencias
        .agregarValorBool(Constantes.is_refresh_token_expired, false);
    this.cargando = false;
    this.textEditingControllerPassword = new TextEditingController(text: "");
    this.textEditingController = new TextEditingController(text: "");
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
            _formulario(context),
          ],
        ),
        inAsyncCall: cargando,
        color: Colors.white,
        dismissible: true,
        progressIndicator: CircularProgressIndicator(
          valueColor:
              new AlwaysStoppedAnimation<Color>(Colores.COLOR_AZUL_ATC_FARMA),
        ),
      ),
    );
  }

  Widget _buttonBack(BuildContext context) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FlatButton(
              onPressed: () {
                // Navigator.pop(context);
                Navigator.popAndPushNamed(context, WelcomePage.nameOfPage);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colores.COLOR_AZUL_WEIDING,
              ))
        ],
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    final tamanoPhone = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buttonBack(context),
          Container(
            width: tamanoPhone.width * 0.7,
            child: Image(
              image: AssetImage("assets/imagenes/logo_fridolin.png"),
              fit: BoxFit.cover,
            ),
          ),

          //  SizedBox( height: 50.0, ),

          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colores.COLOR_AZUL_WEIDING,
                /*    boxShadow: <BoxShadow>[
                                          BoxShadow(
                                          color: Color.fromRGBO(102, 10, 11, 1.0),
                                          blurRadius: 3.0,
                                          offset: Offset(0.0, 5.0),
                                          spreadRadius: 3.0
                                        )
                                      ] */
              ),
              padding: EdgeInsets.all(20.0),
              width: tamanoPhone.width * 0.85,
              child: Column(
                children: <Widget>[
                  _textfieldUsuario(context),
                  SizedBox(
                    height: 30.0,
                  ),
                  _textfieldContrasena(context),
                  SizedBox(
                    height: 30.0,
                  ),
                  _botonEnviar(context), // este es para probar el imei
                ],
              )),
          SizedBox(
            height: 40.0,
          ),
          GestureDetector(
              onTap: () {
                print("Tapeado");
                Navigator.of(context)
                    .popAndPushNamed(RecoverPassword.nameOfPage);
              },
              child: Text(
                "¿Olvidaste tu contraseña?",
                style: new TextStyle(color: Colores.COLOR_AZUL_WEIDING),
              ))
        ],
      ),
    );
  }

  Future<bool> verificarInformacion(
      String carnet, String password, BuildContext context) async {
    LoginProvider loginProvider = new LoginProvider();
    final respuesta = await loginProvider.loginUser(carnet, password);

    print("valor final ----------");
    print(respuesta);
    print("------------------------");

    this.setState(() {
      this.cargando = false;
    });

    return respuesta;
  }

  void _submit() {
    this.setState(() {
      this.cargando = true;
    });
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

  Widget _botonEnviar(BuildContext contextoBtnEnviar) {
    final provedorBlocLoyalty = Provider.of(contextoBtnEnviar);
    return StreamBuilder(
      stream: provedorBlocLoyalty.validarCampos,
      builder: (BuildContext contexto, AsyncSnapshot asyncSnapshot) {
        return RaisedButton(
          onPressed: () {
            if (!asyncSnapshot.hasError &&
                provedorBlocLoyalty.ultimoValorCI != null &&
                provedorBlocLoyalty.ultimoValorContrasena != null &&
                provedorBlocLoyalty.ultimoValorCI != "" &&
                provedorBlocLoyalty.ultimoValorContrasena != "") {
              Future<Map<String, dynamic>> resultadoConexion =
                  verificarConexion();
              resultadoConexion.then((mapaRecibido) {
                if (mapaRecibido[Constantes.estado] ==
                    Constantes.respuesta_estado_ok) {
                  _submit();
                  Future<bool> resultado = verificarInformacion(
                      provedorBlocLoyalty.ultimoValorCI,
                      provedorBlocLoyalty.ultimoValorContrasena,
                      contexto);
                  resultado.then((onvalue) {
                    if (onvalue) {
                      // Navigator.of(context).popAndPushNamed(
                      //                      HomePage.nameOfPage
                      //            );
                      TokenDeviceUpdateProvider tokenDeviceUpdateProvider =
                          TokenDeviceUpdateProvider();
                      PushNotificacionProvider pushNotificacionProvider =
                          new PushNotificacionProvider();
                      //SE QUITO TODO ESTO YA QUE AUN NO ESTA EL JSON
                      pushNotificacionProvider.obtainToken().then((token) {
                        print(token);
                        tokenDeviceUpdateProvider
                            .updateTokenDevice(token)
                            .then((onValue) {
                          provedorBlocLoyalty.addDataToStreamCI("");
                          provedorBlocLoyalty.addDataToStreamPassword("");
                          Navigator.of(context)
                              .popAndPushNamed(HomePage.nameOfPage);
                        });
                      });
                    } else {
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
                content: Text("Llenar todos los campos"),
              );

              Scaffold.of(contexto).showSnackBar(snackBar);
            }
          },
          child: Container(
              child: Text("Ingresar"),
              padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          elevation: 30.0,
          color: Colors.white,
          textColor: Colores.COLOR_AZUL_WEIDING,
        );
      },
    );
  }

  Widget _textfieldContrasena(BuildContext context) {
    final provider = Provider.of(context);
    return StreamBuilder(
        stream: provider.contrasenaStream,
        builder: (BuildContext context, AsyncSnapshot<String> asyncSnapshot) {
          return TextField(
            controller: textEditingControllerPassword,
            obscureText: true,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.lock_outline),
                hintText: "Contraseña",
                // labelText: "Contraseña",
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(color: Colors.white),
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              this.preferencias.agregarValor(Constantes.last_password, value);
              provider.addDataToStreamPassword(value);
            },
          );
        });
  }

  Widget _textfieldUsuario(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    return StreamBuilder(
        stream: provedorDeBloc.ciStream,
        builder: (BuildContext contexto, AsyncSnapshot asyncSnapshot) {
          return TextField(
            controller: this.textEditingController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.person),
                hintText: "Número de carnet",
                //  labelText: "Número de carnet",
                fillColor: Colors.white,
                filled: true,
                errorStyle: TextStyle(color: Colors.white),
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              this.preferencias.agregarValor(Constantes.last_ci, value);
              provedorDeBloc.addDataToStreamCI(value);
            },
          );
        });
  }

  Widget _fondoApp() {
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
