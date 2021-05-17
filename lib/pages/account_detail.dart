import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/models/cuenta_puntos.dart';
import 'package:weidling/pages/change_password.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/pages/welcome_page.dart';
import 'package:weidling/providers/logout_provider.dart';
import 'package:weidling/providers/providers.dart';
import 'package:weidling/providers/puntos_provider.dart';
import 'package:weidling/providers/user_update_provider.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
//este usando el paquete device_info: ^0.4.2+4

class AccountDetail extends StatefulWidget {
  AccountDetail({Key key}) : super(key: key);
  static final String namePage = "AccountDetail";
  @override
  _AccountDetailState createState() => _AccountDetailState();
}

class _AccountDetailState extends State<AccountDetail> {
  /// probando imei
  ///
  ///

  String _platformImei = 'Unknown';
  String uniqueId = "Unknown";

  ///

  TextEditingController controladorName,
      controladorApellido,
      controladorCorreo,
      controladorContrasena,
      controladorNroCarnet,
      controladorCiudadExpedicion,
      controladorGenero,
      controladorFechaNac,
      controladorCiudad,
      controladorPais,
      controladorCelular;
  Base base;
  VerificadorInternet verificadorInternet;
  CuentaPuntos cuenta;
  bool editando;
  List<String> listaDeGeneros;
  Map<String, String> parametrosParaEnviar;
  final preferencias = SharedPreferencesapp();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.controladorName = new TextEditingController(text: "");
    this.controladorApellido = TextEditingController(text: "");
    this.controladorCorreo = TextEditingController(text: "");
    this.controladorContrasena = TextEditingController(text: "kamsdkmaasdasd");
    this.controladorNroCarnet = TextEditingController(text: "");
    this.controladorCiudadExpedicion = TextEditingController(text: "");
    this.controladorGenero = TextEditingController(text: "");
    this.controladorFechaNac = TextEditingController(text: "");
    this.controladorCiudad = TextEditingController(text: "");
    this.controladorPais = TextEditingController(text: "");
    this.controladorCelular = TextEditingController(text: "");

    this.base = new Base();
    this.verificadorInternet = new VerificadorInternet();
    this.editando = false;
    this.listaDeGeneros = new List();

    new Future.delayed(Duration.zero, () {
      PuntosProvider obtenerCuenta = new PuntosProvider();
      obtenerCuenta.obtenerCuentaPuntos(context).then((onValue) {
        Map<String, dynamic> cuentaRecibida = onValue;
        if (cuentaRecibida[Constantes.estado] ==
            Constantes.respuesta_estado_ok) {
          print("CUENTA ENTRO POR AQUI");

          this.cuenta = cuentaRecibida[Constantes.mensaje] as CuentaPuntos;
          this.controladorName.text = this.cuenta.data.name;
          this.controladorApellido.text = this.cuenta.data.lastname;
          this.controladorCorreo.text = this.cuenta.data.email;
          this.controladorNroCarnet.text = this.cuenta.data.ci;
          this.controladorCiudadExpedicion.text = this.cuenta.data.expedition;
          this.controladorGenero.text =
              (this.cuenta.data.gender == 0 || this.cuenta.data.gender == "0")
                  ? "Seleccione"
                  : ((this.cuenta.data.gender == 2 ||
                          this.cuenta.data.gender == "2")
                      ? "Femenino"
                      : "Masculino");

          String fechaDesdeServe =
              this.cuenta.data.birthdate.toString().split(" ")[0];

          this.controladorFechaNac.text = _formatearFecha(fechaDesdeServe);
          this.controladorCiudad.text = this.cuenta.data.city;
          this.controladorPais.text = this.cuenta.data.country;
          this.controladorCelular.text = this.cuenta.data.cellphone;
          _fillStreamingsDefaults(context);
        } else {
          print("CUENTA FALLO");
        }
      });
    });

    this._llenarListaGenero();
  }

  String _formatearFecha(String fecha) {
    try {
      DateTime formatoFecha = DateTime.parse(fecha);
      DateFormat formato = new DateFormat("dd-MM-yyyy");
      String nuevaFecha = formato.format(formatoFecha);
      return nuevaFecha;
    } catch (e) {
      return "00-00-0000";
    }
  }

  _fillStreamingsDefaults(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    provedorDeBloc.addDataToStreamNameDetalleCuenta(this.controladorName.text);
    provedorDeBloc
        .addDataToStreamLastNameDetalleCuen(this.controladorApellido.text);
    provedorDeBloc
        .addDataToStreamEmailDetalleCuenta(this.controladorCorreo.text);
    provedorDeBloc.addDataToStreamGeneroDetalleCue(this.controladorGenero.text);
    provedorDeBloc
        .addDataToStreamFechaNacDetalleCuenta(this.controladorFechaNac.text);
  }

  _llenarListaGenero() {
    this.listaDeGeneros.add("Masculino");
    this.listaDeGeneros.add("Femenino");
  }

  @override
  Widget build(BuildContext context) {
    final provedorDeBloc = Provider.of(context);
    return Scaffold(
      appBar: ContantsWidgetsDefaults.widgetAppBar(
          context, Colores.COLOR_AZUL_WEIDING),
      body: StreamBuilder<bool>(
          stream: provedorDeBloc.streamCargandoDetalleCuenta,
          builder: (context, snapshot) {
            return ModalProgressHUD(
              child: Stack(
                children: <Widget>[_fondoApp(), _demasElementos(context)],
              ),
              inAsyncCall:
                  (snapshot.data != null && snapshot.data) ? true : false,
              color: Colors.white,
              dismissible: false,
              progressIndicator: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.brown),
              ),
            );
          }),
    );
  }

  Widget _parteSuperior(BuildContext contextoParteSuperior) {
    final provedorDeBloc = Provider.of(contextoParteSuperior);
    provedorDeBloc.addDataToStreamEditingOrNot(false);
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(contextoParteSuperior)
                  .popAndPushNamed(HomePage.nameOfPage);
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child:
                  Icon(Icons.arrow_back_ios, color: Colores.COLOR_AZUL_WEIDING),
            ),
          ),
          Text(
            "DETALLES DE LA CUENTA",
            style: TextStyle(color: Colores.COLOR_AZUL_WEIDING),
          ),
          StreamBuilder<bool>(
              stream: provedorDeBloc.validarCamposDetalleCuenta,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return GestureDetector(
                  onTap: () {
                    if (provedorDeBloc.ultimoValorStreamEditingOrNot) {
                      FocusScope.of(contextoParteSuperior)
                          .requestFocus(new FocusNode());

                      _guardarDAtos(snapshot, context);
                    }
                    provedorDeBloc.addDataToStreamEditingOrNot(
                        !provedorDeBloc.ultimoValorStreamEditingOrNot);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: StreamBuilder(
                        stream: provedorDeBloc.streamEditingOrNot,
                        builder: (BuildContext contexto,
                            AsyncSnapshot<bool> asyncSnapshot) {
                          if (!asyncSnapshot.hasData) {
                            return Icon(Icons.edit, color: Colors.white);
                          }

                          if (!asyncSnapshot.data) {
                            return Icon(Icons.edit, color: Colors.white);
                          }

                          if (asyncSnapshot.data) {
                            return Icon(Icons.check, color: Colors.white);
                          }
                          return Icon(Icons.edit, color: Colors.white);
                        }),
                  ),
                );
              }),
        ],
      ),
    );
  }

  void _guardarDAtos(AsyncSnapshot asyncSnapshot, BuildContext contexto) {
    UpdateUserProvider updateUserProvider = UpdateUserProvider();
    final provedorDeBloc = Provider.of(contexto);
    if (asyncSnapshot.data != null && asyncSnapshot.data) {
      print("GUARDANDO....");
      this.parametrosParaEnviar = {
        Constantes.access_token:
            this.preferencias.devolverValor(Constantes.userSpecificToken, ""),
        Constantes.NAME: provedorDeBloc.ultimoValorNameDetalleCuenta,
        Constantes.LAST_NAME: provedorDeBloc.ultimoValorLastNameDetalleCuenta,
        Constantes.EMAIL: provedorDeBloc.ultimoValorEmailDetalleCuenta,
        Constantes.ci: this.controladorNroCarnet.text,
        Constantes.EXPEDITION: this.controladorCiudadExpedicion.text,
        Constantes.DATE: provedorDeBloc.ultimoValorFechaNacDetalleCu,
        Constantes.CELLPHONE: this.controladorCelular.text,
        Constantes.COUNTRY: this.controladorPais.text,
        Constantes.CITY: this.controladorCiudad.text
      };

      if (provedorDeBloc.ultimoValorGeneroDetalleCuen != null &&
          provedorDeBloc.ultimoValorGeneroDetalleCuen != "") {
        this.parametrosParaEnviar.addAll({
          Constantes.GENDER:
              (provedorDeBloc.ultimoValorGeneroDetalleCuen == "Femenino")
                  ? "2"
                  : "1"
        });
      }

      this.verificadorInternet.verificarConexion().then((onValue) {
        if (onValue[Constantes.estado] == Constantes.respuesta_estado_ok) {
          provedorDeBloc.addDataToCargandoDetalleCuenta(true);
          updateUserProvider
              .registerUser(this.parametrosParaEnviar, contexto)
              .then((onValue) {
            if (onValue[Constantes.estado] == Constantes.respuesta_estado_ok) {
              this.base.showSnackBar(onValue[Constantes.mensaje], contexto,
                  Colores.COLOR_AZUL_ATC_FARMA);
              provedorDeBloc.addDataToCargandoDetalleCuenta(false);
            } else {
              this
                  .base
                  .showSnackBar("There was a problem", contexto, Colors.brown);
              provedorDeBloc.addDataToCargandoDetalleCuenta(false);
            }
          });
        } else {
          this
              .base
              .showSnackBar(Constantes.error_conexion, contexto, Colors.brown);
        }
      });

      print(this.parametrosParaEnviar);
    } else {
      this.base.showSnackBar(
          "Llenar todos los campos correctamente", contexto, Colors.brown);
    }
  }

  Widget _demasElementos(BuildContext contexto) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(width: double.infinity),
          _parteSuperior(contexto),
          _cuerpoDeDatos(contexto),
        ],
      ),
    );
  }

  Widget _cuerpoDeDatos(BuildContext contexto) {
    PuntosProvider cuenta = new PuntosProvider();
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        color: Colores.COLOR_AZUL_WEIDING,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: FutureBuilder(
              future: cuenta.obtenerCuentaPuntos(contexto),
              builder: (BuildContext contexto,
                  AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                if (asyncSnapshot.hasData && !asyncSnapshot.hasError) {
                  if (asyncSnapshot.data[Constantes.estado] ==
                      Constantes.respuesta_estado_ok) {
                    this.cuenta =
                        asyncSnapshot.data[Constantes.mensaje] as CuentaPuntos;
                    print(this.cuenta);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "INFORMACION PRINCIPAL",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        _textFieldName(contexto),
                        SizedBox(
                          height: 10.0,
                        ),
                        _textFieldApellido(contexto),
                        SizedBox(
                          height: 10.0,
                        ),
                        _textFieldCorreoElec(contexto),
                        SizedBox(
                          height: 10.0,
                        ),
                        _textFieldContrasena(contexto),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          "INFORMACION ADICIONAL",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        _textFieldNroCarnet(contexto),
                        SizedBox(
                          height: 10.0,
                        ),
                        _textFieldCiudadExpedicion(contexto),
                        SizedBox(
                          height: 10.0,
                        ),
                        _textFieldGenero(contexto),
                        SizedBox(
                          height: 10.0,
                        ),
                        _textFieldFechaNac(contexto),
                        SizedBox(
                          height: 10.0,
                        ),
                        _textFieldCiudad(contexto),
                        SizedBox(
                          height: 10.0,
                        ),
                        _textFieldPais(contexto),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          "INFORMACION DE CONTACTO",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        _textFieldNroCelular(contexto),
                        SizedBox(
                          height: 15.0,
                        ),
                        _btnSalir(contexto)
                      ],
                    );
                  } else {
                    return Container(
                      height: MediaQuery.of(contexto).size.height * 0.9,
                      child: Center(
                        child: Text(
                          asyncSnapshot.data[Constantes.mensaje],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                } else {
                  if (asyncSnapshot.hasError) {
                    return Container(
                      height: MediaQuery.of(contexto).size.height * 0.9,
                      child: Center(
                        child: Text(
                          asyncSnapshot.error.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  return Container(
                    height: MediaQuery.of(contexto).size.height * 0.9,
                    child: Center(
                      child: this.base.retornarCircularCargando(
                          Colores.COLOR_NARANJA_ATC_FARMA),
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }

  Widget _btnSalir(BuildContext contexto) {
    return Center(
      child: RaisedButton(
        onPressed: () {
          _dialogSalir(contexto);
        },
        child: Container(
            child: Text("Salir"),
            padding: EdgeInsets.symmetric(horizontal: 80.0, vertical: 15.0)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        elevation: 30.0,
        color: Colors.white,
        textColor: Colores.COLOR_AZUL_WEIDING,
      ),
    );
  }

  void _dialogSalir(BuildContext contextoBtnSalir) {
    final tamanoPhone = MediaQuery.of(contextoBtnSalir).size;
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
              height: tamanoPhone.height * 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(50.0),
                    child: Image(
                        image: AssetImage(
                            "assets/imagenes/imagenes_farmacorp/farmacorp_logo.png")),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Text(
                      "¿Estás seguro que deseas salir de la aplicación?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filaBotones(contextoBtnSalir),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _filaBotones(BuildContext contextoFilaBotones) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: RaisedButton(
              onPressed: () {
                this.verificadorInternet.verificarConexion().then((onValue) {
                  if (onValue[Constantes.estado] ==
                      Constantes.respuesta_estado_ok) {
                    LogoutProvider logoutProvider = new LogoutProvider();
                    logoutProvider.logOutUser().then((onValue) {
                      this.preferencias.agregarValor(
                          Constantes.last_page, WelcomePage.nameOfPage);
                      Navigator.of(contextoFilaBotones)
                          .popAndPushNamed(WelcomePage.nameOfPage);
                    });
                  } else {
                    this.base.showSnackBar(Constantes.error_conexion,
                        contextoFilaBotones, Colores.COLOR_AZUL_ATC_FARMA);
                  }
                });
              },
              child: Container(
                  child: Text("Salir"),
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              elevation: 30.0,
              color: Colors.white,
              textColor: Colores.COLOR_AZUL_WEIDING,
            ),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: RaisedButton(
              onPressed: () {
                Navigator.of(contextoFilaBotones).pop();
              },
              child: Container(
                  child: Text("Cancelar"),
                  padding:
                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              elevation: 30.0,
              color: Colors.white,
              textColor: Colores.COLOR_AZUL_WEIDING,
            ),
          ),
        )
      ],
    );
  }

  Widget _textFieldNroCelular(BuildContext contextoCelular) {
    return TextField(
        controller: this.controladorCelular,
        enableInteractiveSelection: false,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.phone_android),
          hintText: "Nro de teléfono",
          labelText: "Nro de teléfono",
        ),
        onChanged: (value) {},
        onTap: () {
          FocusScope.of(contextoCelular).requestFocus(new FocusNode());
        });
  }

  void _dialogGenero(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    final tamanoPhone = MediaQuery.of(contexto).size;
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
                  color: Colors.white),
              height: tamanoPhone.height * 0.15,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                    itemCount: this.listaDeGeneros.length,
                    itemBuilder: (BuildContext contexto, int indice) {
                      return GestureDetector(
                        child: Card(
                          elevation: 10.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: Text(this.listaDeGeneros[indice])),
                          ),
                        ),
                        onTap: () {
                          print(this.listaDeGeneros[indice]);
                          this.controladorGenero.text =
                              this.listaDeGeneros[indice];
                          provedorDeBloc.addDataToStreamGeneroDetalleCue(
                              this.listaDeGeneros[indice]);
                          Navigator.of(contexto).pop();
                        },
                      );
                    }),
              ),
            ),
          );
        });
  }

  Widget _textFieldPais(BuildContext contextoPais) {
    return TextField(
        controller: this.controladorPais,
        enableInteractiveSelection: false,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.location_city),
          hintText: "País",
          labelText: "País",
        ),
        onChanged: (value) {},
        onTap: () {
          FocusScope.of(contextoPais).requestFocus(new FocusNode());
        });
  }

  Widget _textFieldCiudad(BuildContext contextoCiudad) {
    return TextField(
        controller: this.controladorCiudad,
        enableInteractiveSelection: false,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.location_city),
          hintText: "Ciudad",
          labelText: "Ciudad",
        ),
        onChanged: (value) {},
        onTap: () {
          FocusScope.of(contextoCiudad).requestFocus(new FocusNode());
        });
  }

  Widget _textFieldFechaNac(BuildContext contextoFecha) {
    final provedorDeBloc = Provider.of(contextoFecha);
    return StreamBuilder<bool>(
        stream: provedorDeBloc.streamEditingOrNot,
        builder: (context, snapshot) {
          return TextField(
              controller: this.controladorFechaNac,
              enableInteractiveSelection: false,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.person),
                hintText: "Fecha Nacimiento",
                labelText: "Fecha Nacimiento",
              ),
              onChanged: (value) {},
              onTap: (!snapshot.hasData || !snapshot.data)
                  ? () {
                      FocusScope.of(contextoFecha)
                          .requestFocus(new FocusNode());
                    }
                  : () {
                      FocusScope.of(contextoFecha)
                          .requestFocus(new FocusNode());
                      _mostrarDate(contextoFecha);
                    });
        });
  }

  void _mostrarDate(BuildContext context) {
    final provedorDeBloc = Provider.of(context);
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    showDatePicker(
        locale: Locale('es'),
        context: context,
        firstDate: DateTime(1900, 0),
        initialDate: DateTime.now(),
        lastDate: new DateTime(2101),
        builder: (BuildContext contexto, Widget child) {
          return Theme(
              data: ThemeData.light().copyWith(
                  colorScheme: ColorScheme.fromSwatch(
                    primarySwatch: Colores.COLOR_AZUL_WEIDING,
                    primaryColorDark: Colores.COLOR_AZUL_WEIDING,
                    accentColor: Colores.COLOR_AZUL_WEIDING,
                  ),
                  dialogBackgroundColor: Colors.white),
              child: child);
        }).then((DateTime fecha) {
      if (fecha != null) {
        String valor = dateFormat.format(fecha);
        provedorDeBloc.addDataToStreamFechaNacDetalleCuenta(valor);

        //esto es para solo mostrar visual
        DateFormat dateFormatVisual = DateFormat("dd-MM-yyyy");
        String formatoVisual = dateFormatVisual.format(fecha);
        this.controladorFechaNac.text = formatoVisual;
      }
    });
  }

  Widget _textFieldGenero(BuildContext contextoGenero) {
    final provedorDeBloc = Provider.of(contextoGenero);
    return StreamBuilder<bool>(
        stream: provedorDeBloc.streamEditingOrNot,
        builder: (context, snapshot) {
          return TextField(
              controller: this.controladorGenero,
              enableInteractiveSelection: false,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.perm_identity),
                hintText: "Género",
                labelText: "Género",
              ),
              onChanged: (value) {},
              onTap: (!snapshot.hasData || !snapshot.data)
                  ? () {
                      FocusScope.of(contextoGenero)
                          .requestFocus(new FocusNode());
                    }
                  : () {
                      FocusScope.of(contextoGenero)
                          .requestFocus(new FocusNode());
                      _dialogGenero(contextoGenero);
                    });
        });
  }

  Widget _textFieldCiudadExpedicion(BuildContext contextoCiudadExp) {
    return TextField(
        controller: this.controladorCiudadExpedicion,
        enableInteractiveSelection: false,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.location_city),
          hintText: "Ciudad de expedición",
          labelText: "Ciudad de expedición",
        ),
        onChanged: (value) {},
        onTap: () {
          FocusScope.of(contextoCiudadExp).requestFocus(new FocusNode());
        });
  }

  Widget _textFieldNroCarnet(BuildContext contextoNroCarnet) {
    return TextField(
        controller: this.controladorNroCarnet,
        enableInteractiveSelection: false,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.perm_identity),
          hintText: "No Carnet de identidad",
          labelText: "No Carnet de identidad",
        ),
        onChanged: (value) {},
        onTap: () {
          FocusScope.of(contextoNroCarnet).requestFocus(new FocusNode());
        });
  }

  Widget _textFieldContrasena(BuildContext contextoContrasena) {
    return TextField(
        controller: this.controladorContrasena,
        enableInteractiveSelection: false,
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.lock),
          hintText: "Contraseña",
          labelText: "Contraseña",
        ),
        onChanged: (value) {},
        onTap: () {
          FocusScope.of(contextoContrasena).requestFocus(new FocusNode());
          Navigator.of(contextoContrasena)
              .popAndPushNamed(ChangePasswordPage.nameOfPage);
        });
  }

  Widget _textFieldCorreoElec(BuildContext contextoCorreo) {
    final provedorDeBloc = Provider.of(contextoCorreo);
    return StreamBuilder(
        stream: provedorDeBloc.streamEmailDetalleCuenta,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          return StreamBuilder<bool>(
              stream: provedorDeBloc.streamEditingOrNot,
              builder: (context, snapshot) {
                return TextField(
                    controller: this.controladorCorreo,
                    enableInteractiveSelection: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        errorStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.email),
                        hintText: "Correo Electrónico",
                        labelText: "Correo Electrónico",
                        errorText: asyncSnapshot.error),
                    onChanged: (value) {
                      provedorDeBloc.addDataToStreamEmailDetalleCuenta(value);
                    },
                    onTap: (!snapshot.hasData || !snapshot.data)
                        ? () {
                            FocusScope.of(contextoCorreo)
                                .requestFocus(new FocusNode());
                          }
                        : null);
              });
        });
  }

  Widget _textFieldApellido(BuildContext contextoApellido) {
    final provedorDeBloc = Provider.of(contextoApellido);
    return StreamBuilder(
        stream: provedorDeBloc.streamLastNamedDetalleCuenta,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          return StreamBuilder<bool>(
              stream: provedorDeBloc.streamEditingOrNot,
              builder: (context, snapshot) {
                return TextField(
                    controller: this.controladorApellido,
                    enableInteractiveSelection: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.person),
                        hintText: "Apellidos",
                        labelText: "Apellidos",
                        errorText: asyncSnapshot.error,
                        errorStyle: TextStyle(color: Colors.white)),
                    onChanged: (value) {
                      provedorDeBloc.addDataToStreamLastNameDetalleCuen(value);
                    },
                    onTap: (!snapshot.hasData || !snapshot.data)
                        ? () {
                            FocusScope.of(contextoApellido)
                                .requestFocus(new FocusNode());
                          }
                        : null);
              });
        });
  }

  Widget _textFieldName(BuildContext contextoTextName) {
    final provedorDeBloc = Provider.of(contextoTextName);

    return StreamBuilder(
        stream: provedorDeBloc.streamNameDetalleCuenta,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          return StreamBuilder<bool>(
              stream: provedorDeBloc.streamEditingOrNot,
              builder: (context, snapshot) {
                return TextField(
                    controller: this.controladorName,
                    enableInteractiveSelection: false,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.person),
                        hintText: "Nombre",
                        labelText: "Nombre",
                        errorStyle: TextStyle(color: Colors.white),
                        errorText: asyncSnapshot.error),
                    onChanged: (value) {
                      provedorDeBloc.addDataToStreamNameDetalleCuenta(value);
                    },
                    onTap: (!snapshot.hasData || !snapshot.data)
                        ? () {
                            FocusScope.of(contextoTextName)
                                .requestFocus(new FocusNode());
                          }
                        : null);
              });
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
