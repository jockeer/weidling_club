import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/models/cities_f.dart';
import 'package:weidling/models/country.dart';
import 'package:weidling/pages/enter_pin.dart';
import 'package:weidling/pages/register_part_one.dart';
import 'package:weidling/pages/terms_and_conditions.dart';
import 'package:weidling/providers/cities_providers.dart';
import 'package:weidling/providers/countries_provider.dart';
import 'package:weidling/providers/providers.dart';
import 'package:intl/intl.dart';
import 'package:weidling/providers/register_provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegisterPartTwo extends StatefulWidget {
  RegisterPartTwo({Key key}) : super(key: key);
  static final nameOfPage = 'RegisterPartTwo';
  @override
  _RegisterPartTwoState createState() => _RegisterPartTwoState();
}

class _RegisterPartTwoState extends State<RegisterPartTwo> {
  bool cargando;
  Base base;
  VerificadorInternet verificadorDeInternet;
  TextEditingController controladorTextEditingCiudadExpedicion,
      controladorTextEditingPaises,
      controladorTextEditingCiudades,
      controladorTextEditingTipo,
      controladorTextEditingFechaNac;
  String selectedCountryId;
  String access_token;
  List<String> listaDeCiudadesExpedicion, listaDetipoDePersonas;
  Map<String, String> mapaObtenidoDePrimerRegistro;
  Map<String, String> mapaParaPasarAlPin;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.controladorTextEditingCiudadExpedicion = new TextEditingController();
    this.controladorTextEditingPaises = new TextEditingController(text: "");
    this.controladorTextEditingCiudades = new TextEditingController(text: "");
    this.controladorTextEditingTipo = new TextEditingController(text: "");
    this.controladorTextEditingFechaNac = TextEditingController();
    this.selectedCountryId = null;
    this.base = new Base();
    this.verificadorDeInternet = new VerificadorInternet();
    this.access_token = null;
    this.listaDeCiudadesExpedicion = new List();
    this.listaDetipoDePersonas = new List();
    _llenarListaCiudadesExpedicion();
    _llenarListaDeTipoDePersonas();
    this.mapaObtenidoDePrimerRegistro = Map<String, String>();
    this.cargando = false;
    this.mapaParaPasarAlPin = Map<String, String>();
  }

  @override
  Widget build(BuildContext context) {
    Size tamanoPhone = MediaQuery.of(context).size;
    this.mapaObtenidoDePrimerRegistro =
        ModalRoute.of(context).settings.arguments as Map;

    final preferencias = new SharedPreferencesapp();
    this.access_token =
        preferencias.devolverValor(Constantes.access_token, "null");

    if (this.access_token == "null" || this.access_token == null) {
      this.verificadorDeInternet.verificarConexion().then((onValue) {
        if (onValue[Constantes.estado] == Constantes.respuesta_estado_ok) {
          this.base.hitAccessTokenApi().then((onValue) {
            this.access_token =
                preferencias.devolverValor(Constantes.access_token, "null");
          });
        } else {
          this
              .base
              .showSnackBar(Constantes.error_conexion, context, Colors.brown);
        }
      });
    }

    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(tamanoPhone.height * 0.001),
          child: AppBar(
            backgroundColor: Colores
                .COLOR_AZUL_WEIDING, // Set any color of status bar you want; or it defaults to your theme's primary color
          )),
      body: ModalProgressHUD(
        child: Stack(
          children: <Widget>[_fondo(), _demas_elementos(context)],
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

  void _llenarListaCiudadesExpedicion() {
    this.listaDeCiudadesExpedicion.add("Santa Cruz");
    this.listaDeCiudadesExpedicion.add("Beni");
    this.listaDeCiudadesExpedicion.add("Pando");
    this.listaDeCiudadesExpedicion.add("La paz");
    this.listaDeCiudadesExpedicion.add("Cochabamba");
    this.listaDeCiudadesExpedicion.add("Potosi");
    this.listaDeCiudadesExpedicion.add("Chuquisaca");
    this.listaDeCiudadesExpedicion.add("Tarija");
    this.listaDeCiudadesExpedicion.add("Oruro");
    this.listaDeCiudadesExpedicion.add("Persona Extranjera");
  }

  void _llenarListaDeTipoDePersonas() {
    this.listaDetipoDePersonas.add("Empresa");
    this.listaDetipoDePersonas.add("Cliente");
  }

  Widget _demas_elementos(BuildContext contextoDemasElementos) {
    Size tamanoPhone = MediaQuery.of(contextoDemasElementos).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20.0,
          ),
          _parteSuperior(contextoDemasElementos),
          Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 1.0),
              child: _cuerpoDeCampos(contextoDemasElementos)),
        ],
      ),
    );
  }

  Widget _cuerpoDeCampos(BuildContext contextoCuerpo) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
      decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0)),
          border: Border.all(color: Colors.white)),
      child: Column(
        children: <Widget>[
          textFieldCI(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          textFieldCiudadExpedicion(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          textFieldFechaNacimiento(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          textFieldPais(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          textFieldCiudad(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          textFieldCelular(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          checkBoxAcept(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          _btnRegister(contextoCuerpo)
        ],
      ),
    );
  }

  Widget checkBoxAcept(BuildContext contextoCheck) {
    final provedorDeBloc = Provider.of(contextoCheck);
    return StreamBuilder(
        stream: provedorDeBloc.streamTandCondition,
        builder: (BuildContext contexto, AsyncSnapshot<bool> asyncSnapshot) {
          print(asyncSnapshot.data);
          return CheckboxListTile(
            activeColor: Colores.COLOR_AZUL_WEIDING,
            title: GestureDetector(
              child: RichText(
                  text: TextSpan(
                      text: "Al crear una cuenta estás aceptando los",
                      style: TextStyle(color: Colores.COLOR_AZUL_WEIDING),
                      children: <TextSpan>[
                    TextSpan(
                        text: " Términos y condiciones",
                        style: TextStyle(
                            color: Colores.COLOR_AZUL_WEIDING,
                            decoration: TextDecoration.underline,
                            fontStyle: FontStyle.italic)),
                    TextSpan(
                        text: " de Weidling",
                        style: TextStyle(color: Colores.COLOR_AZUL_WEIDING))
                  ])),
              onTap: () {
                Navigator.of(contextoCheck)
                    .pushNamed(TermsAndConditionPage.namePage);
              },
            ),
            value: asyncSnapshot.data ?? false,
            onChanged: (newValue) {
              provedorDeBloc.addDataToStreamTAndConditio(newValue);
            },
            controlAffinity: ListTileControlAffinity.leading,
          );
        });
  }

  void _submit() {
    this.setState(() {
      this.cargando = true;
    });
  }

  Widget _btnRegister(BuildContext contextoBntRegister) {
    final preferencias = new SharedPreferencesapp();
    final provedorBlocLoyalty = Provider.of(contextoBntRegister);
    return StreamBuilder(
      stream: provedorBlocLoyalty.validarRegistrosParteTwo,
      builder: (BuildContext contexto, AsyncSnapshot asyncSnapshot) {
        return RaisedButton(
          onPressed: () {
            if (provedorBlocLoyalty.ultimoValorCI_NIT != null &&
                provedorBlocLoyalty.ultimoValorCI_NIT != "" &&
                provedorBlocLoyalty.ultimoValorCiudadExped != null &&
                provedorBlocLoyalty.ultimoValorCiudadExped != "" &&
                provedorBlocLoyalty.ultimoValorFechaNac != null &&
                provedorBlocLoyalty.ultimoValorFechaNac != "" &&
                provedorBlocLoyalty.ultimoValorPais != null &&
                provedorBlocLoyalty.ultimoValorPais != "" &&
                provedorBlocLoyalty.ultimoValorCiudad != null &&
                provedorBlocLoyalty.ultimoValorCiudad != "" &&
                provedorBlocLoyalty.ultimoValorCelular != null &&
                provedorBlocLoyalty.ultimoValorCelular != "" &&
                provedorBlocLoyalty.ultimoValorTermsAndCond != null &&
                provedorBlocLoyalty.ultimoValorTermsAndCond &&
                !asyncSnapshot.hasError) {
              verificadorDeInternet.verificarConexion().then((onValue) {
                RegisterProvider registrarProvedor = new RegisterProvider();
                if (onValue[Constantes.estado] ==
                    Constantes.respuesta_estado_ok) {
                  _submit();
                  this.mapaObtenidoDePrimerRegistro.addAll({
                    Constantes.ID_CARD: provedorBlocLoyalty.ultimoValorCI_NIT,
                    Constantes.EXPEDITION:
                        provedorBlocLoyalty.ultimoValorCiudadExped,
                    Constantes.COUNTRY: provedorBlocLoyalty.ultimoValorPais,
                    Constantes.CITY: provedorBlocLoyalty.ultimoValorCiudad,
                    Constantes.DATE: provedorBlocLoyalty.ultimoValorFechaNac,
                    "type_customer": "Cliente",
                    Constantes.CELL_PHONE:
                        provedorBlocLoyalty.ultimoValorCelular,
                  });
                  print(this.mapaObtenidoDePrimerRegistro);

                  registrarProvedor
                      .registerUser(this.mapaObtenidoDePrimerRegistro)
                      .then((onValue) {
                    if (onValue[Constantes.estado] ==
                        Constantes.respuesta_estado_ok) {
                      print(onValue);
                      this.setState(() {
                        this.cargando = false;
                      });
                      base.showSnackBar(onValue[Constantes.mensaje], contexto,
                          Colores.COLOR_AZUL_ATC_FARMA);
                      preferencias.agregarValor(
                          Constantes.ci,
                          this.mapaObtenidoDePrimerRegistro[
                              Constantes.ID_CARD]);
                      preferencias.agregarValor(
                          Constantes.ciUser,
                          this.mapaObtenidoDePrimerRegistro[
                              Constantes.ID_CARD]);
                      preferencias.agregarValor(
                          Constantes.password,
                          this.mapaObtenidoDePrimerRegistro[
                              Constantes.password]);
                      String pin = onValue[Constantes.pin].toString();
                      llenarElMapaAPasar(pin);
                      Navigator.of(contextoBntRegister).popAndPushNamed(
                          EnterPinPage.nameOfPage,
                          arguments: this.mapaParaPasarAlPin);
                      print(pin);
                    } else {
                      this.setState(() {
                        this.cargando = false;
                      });
                      base.showSnackBar(onValue[Constantes.mensaje], contexto,
                          Colores.COLOR_AZUL_ATC_FARMA);
                    }
                  });
                } else {
                  base.showSnackBar(Constantes.error_conexion, contexto,
                      Colores.COLOR_AZUL_ATC_FARMA);
                }
              });
            } else {
              base.showSnackBar("Llenar los datos correctamente", contexto,
                  Colores.COLOR_AZUL_ATC_FARMA);
            }
          },
          child: Container(
              child: Text("Registrar"),
              padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          elevation: 30.0,
          color: Colores.COLOR_AZUL_WEIDING,
          textColor: Colors.white,
        );
      },
    );
  }

  void llenarElMapaAPasar(String pin) {
    this.mapaParaPasarAlPin.addAll({
      Constantes.grant_type: Constantes.password,
      Constantes.client_id: "ItacambaAppUser", //Constantes.stellar_app_user,
      Constantes.USERNAME:
          this.mapaObtenidoDePrimerRegistro[Constantes.ID_CARD],
      Constantes.password:
          this.mapaObtenidoDePrimerRegistro[Constantes.password],
      Constantes.pin: pin
    });

    print(this.mapaParaPasarAlPin);
  }

  Widget textFieldCelular(BuildContext contextoCelular) {
    final provedorDeBloc = Provider.of(contextoCelular);
    return StreamBuilder(
        stream: provedorDeBloc.streamCelular,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          print(asyncSnapshot.data);
          return TextField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.phone),
                hintText: "Número de celular",
                //labelText: "Número de celular",
                errorStyle: TextStyle(color: Colors.white),
                fillColor: Colors.white,
                filled: true,
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToStreamCelular(value);
            },
          );
        });
  }

  Widget textFieldTipoCliente(BuildContext contextoTipoCliente) {
    final provedorDeBloc = Provider.of(contextoTipoCliente);
    return StreamBuilder(
        stream: provedorDeBloc.streamTipoCliente,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          print(asyncSnapshot.data);
          return TextField(
            controller: this.controladorTextEditingTipo,
            enableInteractiveSelection: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.person_outline),
                hintText: "Tipo de cliente",
                labelText: "Tipo de cliente",
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToStreamTipoCliente(value);
            },
            onTap: () {
              FocusScope.of(contextoTipoCliente).requestFocus(new FocusNode());
              _mostrarDialogKindOClient(contextoTipoCliente);
            },
          );
        });
  }

  void _mostrarDialogKindOClient(BuildContext contexto) {
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
                    itemCount: this.listaDetipoDePersonas.length,
                    itemBuilder: (BuildContext contexto, int indice) {
                      return GestureDetector(
                        child: Card(
                          elevation: 10.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child:
                                    Text(this.listaDetipoDePersonas[indice])),
                          ),
                        ),
                        onTap: () {
                          print(this.listaDetipoDePersonas[indice]);
                          this.controladorTextEditingTipo.text =
                              this.listaDetipoDePersonas[indice];
                          provedorDeBloc.addDataToStreamTipoCliente(
                              this.listaDetipoDePersonas[indice]);
                          Navigator.of(contexto).pop();
                        },
                      );
                    }),
              ),
            ),
          );
        });
  }

  Widget textFieldCiudad(BuildContext contextoCiudad) {
    final provedorDeBloc = Provider.of(contextoCiudad);
    return StreamBuilder(
        stream: provedorDeBloc.streamCiudad,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          print(asyncSnapshot.data);
          return TextField(
            controller: this.controladorTextEditingCiudades,
            enableInteractiveSelection: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.location_city),
                hintText: "Ciudad",
                // labelText: "Ciudad",
                errorStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white,
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              // provedorDeBloc.addDataToStreamCiudad(value);
            },
            onTap: () {
              FocusScope.of(contextoCiudad).requestFocus(new FocusNode());
              this.verificadorDeInternet.verificarConexion().then((onValue) {
                if (onValue[Constantes.estado] ==
                    Constantes.respuesta_estado_ok) {
                  final preferencias = new SharedPreferencesapp();
                  String access_token = preferencias.devolverValor(
                      Constantes.access_token, "null");
                  if (access_token == "null") {
                    this.base.hitAccessTokenApi().then((onValue) {
                      if (this.selectedCountryId == null) {
                        this.base.showSnackBar(Constantes.select_country,
                            contexto, Colores.COLOR_AZUL_ATC_FARMA);
                      } else {
                        _mostrarDialogCities(contexto);
                      }
                    });
                  } else {
                    if (this.selectedCountryId == null) {
                      this.base.showSnackBar(Constantes.select_country,
                          contexto, Colores.COLOR_AZUL_ATC_FARMA);
                    } else {
                      _mostrarDialogCities(contexto);
                    }
                  }
                } else {
                  this.base.showSnackBar(Constantes.error_conexion, contexto,
                      Colores.COLOR_AZUL_ATC_FARMA);
                }
              });
            },
          );
        });
  }

  void _mostrarDialogCities(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    CitiesProvider cities = new CitiesProvider();
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
              height: tamanoPhone.height * 0.3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: FutureBuilder(
                    future: (this.selectedCountryId != null)
                        ? cities.obtenerCities(this.selectedCountryId)
                        : null,
                    builder: (BuildContext contextoRecibod,
                        AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                      if (!asyncSnapshot.hasError && asyncSnapshot.hasData) {
                        Map<String, dynamic> respuestaDelServidor =
                            asyncSnapshot.data;
                        if (respuestaDelServidor[Constantes.estado] ==
                            Constantes.respuesta_estado_ok) {
                          List<Cities> listaRecibida = (asyncSnapshot
                                  .data[Constantes.mensaje] as CityData)
                              .data;
                          return ListView.builder(
                              itemCount: listaRecibida.length,
                              itemBuilder: (BuildContext contexto, int indice) {
                                return GestureDetector(
                                  child: Card(
                                    elevation: 10.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                          child:
                                              Text(listaRecibida[indice].name)),
                                    ),
                                  ),
                                  onTap: () {
                                    print(listaRecibida[indice].id);
                                    this.controladorTextEditingCiudades.text =
                                        listaRecibida[indice].name;
                                    provedorDeBloc.addDataToStreamCiudad(
                                        listaRecibida[indice].id);
                                    Navigator.of(contexto).pop();
                                  },
                                );
                              });
                        } else {
                          return Center(
                            child:
                                Text(respuestaDelServidor[Constantes.mensaje]),
                          );
                        }
                      } else {
                        return Center(
                          child: this.base.retornarCircularCargando(
                              Colores.COLOR_AZUL_ATC_FARMA),
                        );
                      }
                    }),
              ),
            ),
          );
        });
  }

  Widget textFieldPais(BuildContext contextoPais) {
    final provedorDeBloc = Provider.of(contextoPais);
    return StreamBuilder(
        stream: provedorDeBloc.streamPais,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          print(asyncSnapshot.data);
          return TextField(
            controller: this.controladorTextEditingPaises,
            enableInteractiveSelection: false,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.location_city),
                hintText: "País",
                //labelText: "País",
                fillColor: Colors.white,
                filled: true,
                errorStyle: TextStyle(color: Colors.white),
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              //  provedorDeBloc.addDataToStreamPais(value);
            },
            onTap: () {
              FocusScope.of(contextoPais).requestFocus(new FocusNode());
              this.verificadorDeInternet.verificarConexion().then((onValue) {
                if (onValue[Constantes.estado] ==
                    Constantes.respuesta_estado_ok) {
                  final preferencias = new SharedPreferencesapp();
                  String access_token = preferencias.devolverValor(
                      Constantes.access_token, "null");
                  if (access_token == "null") {
                    this.base.hitAccessTokenApi().then((onValue) {
                      _mostrarDialogCountries(contexto);
                    });
                  } else {
                    _mostrarDialogCountries(contexto);
                  }
                } else {
                  this.base.showSnackBar(Constantes.error_conexion, contexto,
                      Colores.COLOR_AZUL_ATC_FARMA);
                }
              });
            },
          );
        });
  }

  void _mostrarDialogCountries(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    Countries countries = new Countries();
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
                child: FutureBuilder(
                    future: countries.obtenerPaises(),
                    builder: (BuildContext contextoRecibod,
                        AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
                      if (!asyncSnapshot.hasError && asyncSnapshot.hasData) {
                        Map<String, dynamic> respuestaDelServidor =
                            asyncSnapshot.data;
                        if (respuestaDelServidor[Constantes.estado] ==
                            Constantes.respuesta_estado_ok) {
                          List<Paises> listaRecibida = (asyncSnapshot
                                  .data[Constantes.mensaje] as CountryData)
                              .data;
                          return ListView.builder(
                              itemCount: listaRecibida.length,
                              itemBuilder: (BuildContext contexto, int indice) {
                                return GestureDetector(
                                  child: Card(
                                    elevation: 10.0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                          child:
                                              Text(listaRecibida[indice].name)),
                                    ),
                                  ),
                                  onTap: () {
                                    print(listaRecibida[indice].id);
                                    this.selectedCountryId =
                                        listaRecibida[indice].id;
                                    this.controladorTextEditingPaises.text =
                                        listaRecibida[indice].name;
                                    provedorDeBloc.addDataToStreamPais(
                                        listaRecibida[indice].id);
                                    Navigator.of(contexto).pop();
                                  },
                                );
                              });
                        } else {
                          return Center(
                            child:
                                Text(respuestaDelServidor[Constantes.mensaje]),
                          );
                        }
                      } else {
                        return Center(
                          child: this.base.retornarCircularCargando(
                              Colores.COLOR_AZUL_ATC_FARMA),
                        );
                      }
                    }),
              ),
            ),
          );
        });
  }

  Widget textFieldFechaNacimiento(BuildContext contextoFechaNaci) {
    final provedorDeBloc = Provider.of(contextoFechaNaci);
    return StreamBuilder(
        stream: provedorDeBloc.streamFechaNacimiento,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          print(asyncSnapshot.data);
          return TextField(
            controller: this.controladorTextEditingFechaNac,
            keyboardType: TextInputType.datetime,
            enableInteractiveSelection: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.timer),
                hintText: "Fecha de nacimiento",
                // labelText: "Fecha de nacimiento",

                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(color: Colors.white),
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToStreamFechaNac(value);
            },
            onTap: () {
              FocusScope.of(contextoFechaNaci).requestFocus(new FocusNode());
              _mostrarDate(context);
            },
          );
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
                buttonTheme:
                    ButtonThemeData(textTheme: ButtonTextTheme.primary),
                colorScheme:
                    ColorScheme.light(primary: Colores.COLOR_AZUL_WEIDING),
                primaryColor: Colores.COLOR_AZUL_WEIDING, //Head background
                accentColor: Colores.COLOR_AZUL_WEIDING //selection color
                //dialogBackgroundColor: Colors.white,//Background color
                ),
            child: child,
          );
        }).then((DateTime fecha) {
      if (fecha != null) {
        String valor = dateFormat.format(fecha);
        provedorDeBloc.addDataToStreamFechaNac(valor);

        ///esto se hara solo para mostrar en la vista pero al servidor se manda otro
        DateFormat formaToVisual = DateFormat("dd-MM-yyyy");
        String formatoVisualString = formaToVisual.format(fecha);
        this.controladorTextEditingFechaNac.text = formatoVisualString;
      }
    });
  }

  Widget textFieldCiudadExpedicion(BuildContext contextoCiudadExpedicion) {
    final provedorDeBloc = Provider.of(contextoCiudadExpedicion);
    return StreamBuilder(
        stream: provedorDeBloc.streamCiudadExpedicion,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          print(asyncSnapshot.data);
          return TextField(
            controller: this.controladorTextEditingCiudadExpedicion,
            enableInteractiveSelection: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.location_city),
                hintText: "Ciudad de expedición",
                // labelText: "Ciudad de expedición",
                fillColor: Colors.white,
                filled: true,
                errorStyle: TextStyle(color: Colors.white),
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToStreamCiudadExp(value);
            },
            onTap: () {
              FocusScope.of(contextoCiudadExpedicion)
                  .requestFocus(new FocusNode());
              _mostrarDialog(contextoCiudadExpedicion);
            },
          );
        });
  }

  void _mostrarDialog(BuildContext contexto) {
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
              height: tamanoPhone.height * 0.3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                    itemCount: this.listaDeCiudadesExpedicion.length,
                    itemBuilder: (BuildContext contexto, int indice) {
                      return GestureDetector(
                        child: Card(
                          elevation: 10.0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: Text(
                                    this.listaDeCiudadesExpedicion[indice])),
                          ),
                        ),
                        onTap: () {
                          print(this.listaDeCiudadesExpedicion[indice]);
                          this.controladorTextEditingCiudadExpedicion.text =
                              this.listaDeCiudadesExpedicion[indice];
                          provedorDeBloc.addDataToStreamCiudadExp(
                              this.listaDeCiudadesExpedicion[indice]);
                          Navigator.of(contexto).pop();
                        },
                      );
                    }),
              ),
            ),
          );
        });
  }

  Widget textFieldCI(BuildContext contextoTextFieldCi) {
    final provedorDeBloc = Provider.of(contextoTextFieldCi);
    return StreamBuilder(
        stream: provedorDeBloc.streamCi_Nit,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          print(asyncSnapshot.data);
          return TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: Icon(Icons.person),
                hintText: "Número de identidad",
                //labelText: "Cédula de identidad",
                filled: true,
                fillColor: Colors.white,
                errorStyle: TextStyle(color: Colors.white),
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToToStreamCi_Nit(value);
            },
          );
        });
  }

  Widget _parteSuperior(BuildContext contextoParteSuperior) {
    final tamanoPhone = MediaQuery.of(contextoParteSuperior).size;
    final provedorBlocLoyalty = Provider.of(contextoParteSuperior);
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FlatButton(
              onPressed: () {
                // Navigator.pop(context);
                provedorBlocLoyalty.addDataToToStreamCi_Nit("");
                provedorBlocLoyalty.addDataToStreamCiudadExp("");
                provedorBlocLoyalty.addDataToStreamFechaNac("");
                provedorBlocLoyalty.addDataToStreamPais("");
                provedorBlocLoyalty.addDataToStreamCiudad("");
                provedorBlocLoyalty.addDataToStreamCelular("");
                provedorBlocLoyalty.addDataToStreamTAndConditio(false);
                Navigator.popAndPushNamed(context, RegisterPartOne.nameOfPage);
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: Colores.COLOR_AZUL_WEIDING,
              )),
          Container(
            width: tamanoPhone.width * 0.5,
            child: Image(
              image: AssetImage("assets/imagenes/logo_fridolin.png"),
              fit: BoxFit.cover,
            ),
          ),
          FlatButton(
              onPressed: () {},
              child: Icon(
                Icons.arrow_back_ios,
                color: Colors.transparent,
              )),
        ],
      ),
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
}
