import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/pages/account_detail.dart';
import 'package:weidling/providers/change_passwordProvider.dart';
import 'package:weidling/providers/providers.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ChangePasswordPage extends StatefulWidget {
  static final nameOfPage = 'ChangePasswordPage';
  ChangePasswordPage({Key key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  Base base;
  VerificadorInternet verificadorInternet;
  final preferencias = SharedPreferencesapp();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.base = Base();
    this.verificadorInternet = VerificadorInternet();
  }

  @override
  Widget build(BuildContext context) {
    final provedorBlocLoyalty = Provider.of(context);
    return Scaffold(
      appBar: ContantsWidgetsDefaults.widgetAppBar(
          context, Colores.COLOR_AZUL_WEIDING),
      body: StreamBuilder<bool>(
          stream: provedorBlocLoyalty.streamLoadingChangePass,
          builder: (context, snapshot) {
            return ModalProgressHUD(
              child: Stack(
                children: <Widget>[
                  _fondoApp(),
                  _formulario(context),
                ],
              ),
              inAsyncCall:
                  (snapshot.data == null || !snapshot.data) ? false : true,
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
                /* boxShadow: <BoxShadow>[
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
                  _textFieldContrasenaActual(context),
                  SizedBox(
                    height: 30.0,
                  ),
                  _textFieldContraNueva(context),
                  SizedBox(
                    height: 30.0,
                  ),
                  _textFieldConfirmarContrasena(context),
                  SizedBox(
                    height: 30.0,
                  ),
                  _btnCambiar(context), // este es para probar el imei
                ],
              )),
        ],
      ),
    );
  }

  Widget _btnCambiar(BuildContext contextoCambiar) {
    ChangePassProvider changePassProvider = ChangePassProvider();
    final provedorBlocLoyalty = Provider.of(contextoCambiar);
    return StreamBuilder(
      stream: provedorBlocLoyalty.validarCamposChangePass,
      builder: (BuildContext contexto, AsyncSnapshot<bool> asyncSnapshot) {
        return RaisedButton(
          onPressed: () {
            if (asyncSnapshot.data != null && asyncSnapshot.data) {
              if (verificarCompatibilidad(
                  provedorBlocLoyalty.ultimoValorNuevaContraChangePs,
                  provedorBlocLoyalty.ultimoValorConfirPassChangePs)) {
                this.verificadorInternet.verificarConexion().then((onValue) {
                  if (onValue[Constantes.estado] ==
                      Constantes.respuesta_estado_ok) {
                    provedorBlocLoyalty.addDataToLoadingChangePass(true);
                    //aqui llamar al servicio
                    Map<String, String> parametros =
                        _obtenerParametros(contextoCambiar);
                    changePassProvider
                        .changePass(parametros, contextoCambiar)
                        .then((onValue) {
                      provedorBlocLoyalty.addDataToLoadingChangePass(false);
                      if (onValue[Constantes.estado] ==
                          Constantes.respuesta_estado_ok) {
                        this.base.showSnackBar(onValue[Constantes.mensaje],
                            contextoCambiar, Colores.COLOR_AZUL_ATC_FARMA);
                      } else {
                        this.base.showSnackBar(
                            "Hubo un problema vuelva a intentarlo",
                            contextoCambiar,
                            Colores.COLOR_AZUL_ATC_FARMA);
                      }
                    });
                  } else {
                    this.base.showSnackBar(Constantes.error_conexion,
                        contextoCambiar, Colores.COLOR_AZUL_ATC_FARMA);
                  }
                });
              } else {
                this.base.showSnackBar("Las contraseñas no coinciden",
                    contextoCambiar, Colores.COLOR_AZUL_ATC_FARMA);
              }
            } else {
              this.base.showSnackBar("Llenar correctamente los campos",
                  contextoCambiar, Colores.COLOR_AZUL_ATC_FARMA);
            }
          },
          child: Container(
              child: Text("Cambiar contraseña"),
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          elevation: 30.0,
          color: Colors.white,
          textColor: Colores.COLOR_AZUL_WEIDING,
        );
      },
    );
  }

  Map<String, String> _obtenerParametros(BuildContext contextoObtPara) {
    final provedorBlocLoyalty = Provider.of(contextoObtPara);
    String accessToken =
        this.preferencias.devolverValor(Constantes.userSpecificToken, "");
    return new Map.of({
      Constantes.access_token: accessToken,
      Constantes.CURRENT_PASSWORD:
          provedorBlocLoyalty.ultimoValorContrasenaActualChangePs,
      Constantes.password: provedorBlocLoyalty.ultimoValorNuevaContraChangePs
    });
  }

  bool verificarCompatibilidad(
      String nuevaContra, String confirmacionContrasena) {
    return nuevaContra == confirmacionContrasena;
  }

  Widget _textFieldConfirmarContrasena(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    return StreamBuilder(
        stream: provedorDeBloc.streamConfirPassChangeP,
        builder: (BuildContext contexto, AsyncSnapshot asyncSnapshot) {
          return TextField(
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.lock_outline),
                hintText: "Confirmar contraseña",
                //labelText: "Confirmar contraseña",
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(color: Colors.white),
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToConfirPassChangePas(value);
            },
          );
        });
  }

  Widget _textFieldContraNueva(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    return StreamBuilder(
        stream: provedorDeBloc.streamCNuevaContraChangeP,
        builder: (BuildContext contexto, AsyncSnapshot asyncSnapshot) {
          return TextField(
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.lock_outline),
                hintText: "Nueva contraseña",
                //labelText: "Nueva contraseña",
                fillColor: Colors.white,
                filled: true,
                errorStyle: TextStyle(color: Colors.white),
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToNuevaContraChangePas(value);
            },
          );
        });
  }

  Widget _textFieldContrasenaActual(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    return StreamBuilder(
        stream: provedorDeBloc.streamCContrasenaActualChangeP,
        builder: (BuildContext contexto, AsyncSnapshot asyncSnapshot) {
          return TextField(
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.lock),
                hintText: "Contraseña actual",
                // labelText: "Contraseña actual",
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(color: Colors.white),
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToContrasenaActualChangePas(value);
            },
          );
        });
  }

  Widget _buttonBack(BuildContext context) {
    final tamanoPhone = MediaQuery.of(context).size;
    final provedorDeBloc = Provider.of(context);
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
              onPressed: () {
                // Navigator.pop(context);
                provedorDeBloc.restablecerValorChangePass();
                Navigator.popAndPushNamed(context, AccountDetail.namePage);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colores.COLOR_AZUL_WEIDING,
              )),
          Text(
            "CAMBIAR CONTRASEÑA",
            style: TextStyle(color: Colors.white),
          ),
          Icon(
            Icons.brightness_high,
            color: Colors.transparent,
          ),
          SizedBox(width: tamanoPhone.width * 0.02)
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
