import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/providers/FirebaseMessaging/push_notificacions_provider.dart';
import 'package:weidling/providers/hitupdateDeviceToken.dart';
import 'package:weidling/providers/providers.dart';
import 'package:weidling/providers/validatepin_provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EnterPinPage extends StatefulWidget {
  EnterPinPage({Key key}) : super(key: key);
  static final nameOfPage = 'EnterPinPage';

  @override
  _EnterPinPageState createState() => _EnterPinPageState();
}

class _EnterPinPageState extends State<EnterPinPage> {
  Map<String, String> mapaRecibido;
  VerificadorInternet verificadorInternet;
  Base base;
  final preferencias = new SharedPreferencesapp();
  String el_pin = null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.mapaRecibido = null;
    verificadorInternet = new VerificadorInternet();
    base = new Base();
  }

  @override
  Widget build(BuildContext context) {
    this.mapaRecibido =
        ModalRoute.of(context).settings.arguments as Map<String, String>;
    this.el_pin = this.mapaRecibido[Constantes.pin];
    final provedorDeBloc = Provider.of(context);
    return Scaffold(
      appBar: ContantsWidgetsDefaults.widgetAppBar(
          context, Colores.COLOR_AZUL_WEIDING),
      body: StreamBuilder<bool>(
          stream: provedorDeBloc.streamLoadingPinScreen,
          builder: (context, snapshot) {
            return ModalProgressHUD(
              child: Stack(
                children: <Widget>[_fondoApp(), _demas_elementos(context)],
              ),
              inAsyncCall: snapshot.data ?? false,
              color: Colors.white,
              dismissible: false,
              progressIndicator: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Colores.COLOR_AZUL_ATC_FARMA),
              ),
            );
          }),
    );
  }

  Widget _demas_elementos(BuildContext contextoDemasElementos) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 40.0,
          ),
          _parteSuperior(contextoDemasElementos),
          Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 30.0),
              child: _cuerpoDeCampos(contextoDemasElementos)),
          SizedBox(
            height: 50.0,
          ),
          _btnVerPinDeValidacion(contextoDemasElementos),
        ],
      ),
    );
  }

  Widget _cuerpoDeCampos(BuildContext contextoCuerpo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      decoration: BoxDecoration(
          color: Colores.COLOR_AZUL_WEIDING,
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      child: Column(
        children: <Widget>[
          Text(
            Constantes.MENSAJE_PIN,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 30.0,
          ),
          textFieldCI(contextoCuerpo),
          SizedBox(
            height: 30.0,
          ),
          _btnValidarPin(contextoCuerpo)
        ],
      ),
    );
  }

  Widget _btnVerPinDeValidacion(BuildContext contextoBtn) {
    final provedorDeBloc = Provider.of(contextoBtn);
    return RaisedButton(
      onPressed: () {
        showDialogWhereIsPin(contextoBtn);
      },
      child: Container(
          child: Text("Ver pin de validación"),
          padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0)),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      elevation: 30.0,
      color: Colores.COLOR_AZUL_WEIDING,
      textColor: Colors.white,
    );
  }

  void showDialogWhereIsPin(BuildContext contextoVerPin) {
    final tamanoPhone = MediaQuery.of(contextoVerPin).size;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: Colores.COLOR_AZUL_WEIDING),
              height: tamanoPhone.height * 0.35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: tamanoPhone.width * 0.45,
                      height: tamanoPhone.width * 0.45,
                      child: Image(
                          image: AssetImage(
                              "assets/imagenes/imagenes_farmacorp/farmacorp_logo.png"))),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Su pin de validación es: " + el_pin,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _btnValidarPin(BuildContext contextoBtn) {
    ValidatePinProvider validadorPin = new ValidatePinProvider();
    final provedorDeBloc = Provider.of(contextoBtn);
    return StreamBuilder(
        stream: provedorDeBloc.streamPinValidator,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          return RaisedButton(
            onPressed: (!asyncSnapshot.hasError &&
                    asyncSnapshot.hasData &&
                    provedorDeBloc.ultimoValorPinValidator != "")
                ? () {
                    verificadorInternet.verificarConexion().then((onValue) {
                      if (onValue[Constantes.estado] ==
                          Constantes.respuesta_estado_ok) {
                        //_isSubmit(true);
                        provedorDeBloc.addDataToLoadinPinScreen(true);
                        String accessToken = this
                            .preferencias
                            .devolverValor(Constantes.access_token, "null");
                        this.mapaRecibido.update(Constantes.pin, (elValor) {
                          return provedorDeBloc.ultimoValorPinValidator;
                        });

                        if (accessToken == null || accessToken == "null") {
                          base.hitAccessTokenApi().then((onValue) {
                            ///aqui enviar los datos pero ya con los accessToken
                            validadorPin
                                .validatePin(this.mapaRecibido)
                                .then((onValue) {
                              // _isSubmit(false);

                              if (onValue[Constantes.estado] ==
                                  Constantes.respuesta_estado_ok) {
                                //Navigator.of(contextoBtn).popAndPushNamed(HomePage.nameOfPage);

                                TokenDeviceUpdateProvider
                                    tokenDeviceUpdateProvider =
                                    TokenDeviceUpdateProvider();
                                PushNotificacionProvider
                                    pushNotificacionProvider =
                                    new PushNotificacionProvider();
                                //SE QUITO TODO ESTO YA QUE AUN NO ESTA EL JSON
                                pushNotificacionProvider
                                    .obtainToken()
                                    .then((token) {
                                  print("Token por registro :" + token);
                                  tokenDeviceUpdateProvider
                                      .updateTokenDevice(token)
                                      .then((onValue) {
                                    provedorDeBloc
                                        .addDataToLoadinPinScreen(false);
                                    Navigator.of(contextoBtn)
                                        .popAndPushNamed(HomePage.nameOfPage);
                                  });
                                });
                              } else {
                                base.showSnackBar(onValue[Constantes.mensaje],
                                    contexto, Colores.COLOR_AZUL_ATC_FARMA);
                              }
                            });
                          });
                        } else {
                          //aqui ya tenia accessToken
                          validadorPin
                              .validatePin(this.mapaRecibido)
                              .then((onValue) {
                            // _isSubmit(false);
                            provedorDeBloc.addDataToLoadinPinScreen(false);
                            if (onValue[Constantes.estado] ==
                                Constantes.respuesta_estado_ok) {
                              //Navigator.of(contextoBtn).popAndPushNamed(HomePage.nameOfPage);
                              TokenDeviceUpdateProvider
                                  tokenDeviceUpdateProvider =
                                  TokenDeviceUpdateProvider();
                              PushNotificacionProvider
                                  pushNotificacionProvider =
                                  new PushNotificacionProvider();
                              // SE QUEITO TODO ESTO YA QUE NO ESTA AUN EL JSON
                              pushNotificacionProvider
                                  .obtainToken()
                                  .then((token) {
                                print("Token por registro :" + token);
                                tokenDeviceUpdateProvider
                                    .updateTokenDevice(token)
                                    .then((onValue) {
                                  provedorDeBloc
                                      .addDataToLoadinPinScreen(false);
                                  Navigator.of(contextoBtn)
                                      .popAndPushNamed(HomePage.nameOfPage);
                                });
                              });
                            } else {
                              base.showSnackBar(onValue[Constantes.mensaje],
                                  contexto, Colores.COLOR_AZUL_ATC_FARMA);
                            }
                          });
                        }
                      } else {
                        base.showSnackBar(Constantes.error_conexion,
                            contextoBtn, Colores.COLOR_AZUL_ATC_FARMA);
                      }
                    });
                  }
                : null,
            child: Container(
                child: Text("Validar Pin"),
                padding:
                    EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            elevation: 30.0,
            color: Colores.COLOR_BLANCO_LOYALTY,
            textColor: Colores.COLOR_AZUL_WEIDING,
          );
        });
  }

  Widget textFieldCI(BuildContext contextoTextFieldCi) {
    final provedorDeBloc = Provider.of(contextoTextFieldCi);
    return StreamBuilder(
        stream: provedorDeBloc.streamPinValidator,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          print(asyncSnapshot.data);
          return TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.check_circle_outline),
                hintText: "Ingresar Pin",
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(color: Colors.white),
                //labelText: "Ingresar Pin",
                errorText: asyncSnapshot.error),
            textAlign: TextAlign.center,
            onChanged: (value) {
              provedorDeBloc.addDataToStreamPinValidator(value);
            },
          );
        });
  }

  Widget _parteSuperior(BuildContext contextoParteSuperior) {
    final tamanoPhone = MediaQuery.of(contextoParteSuperior).size;
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: tamanoPhone.width * 0.5,
            child: Image(
              image: AssetImage("assets/imagenes/logo_fridolin.png"),
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
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
