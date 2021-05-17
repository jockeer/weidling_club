import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/pages/register_part_two.dart';
import 'package:weidling/pages/welcome_page.dart';
import 'package:weidling/providers/providers.dart';
import 'dart:io' show Platform;

class RegisterPartOne extends StatefulWidget {
  RegisterPartOne({Key key}) : super(key: key);
  static final nameOfPage = 'RegisterPartOne';

  @override
  _RegisterPartOneState createState() => _RegisterPartOneState();
}

class _RegisterPartOneState extends State<RegisterPartOne> {
  VerificadorInternet verificadorInternet;
  Base base;
  final preferencias = new SharedPreferencesapp();
  Map<String, String> informacionAEnviar;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    verificadorInternet = new VerificadorInternet();
    base = new Base();
    this.informacionAEnviar = Map<String, String>();
  }

  @override
  Widget build(BuildContext context) {
    Size tamanoPhone = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(tamanoPhone.height * 0.001),
          child: AppBar(
            backgroundColor: Colores
                .COLOR_AZUL_WEIDING, // Set any color of status bar you want; or it defaults to your theme's primary color
          )),
      body: Stack(
        children: <Widget>[_fondo(), _demas_elementos(context)],
      ),
    );
  }

  Widget _demas_elementos(BuildContext contextoDemasElementos) {
    Size tamanoPhone = MediaQuery.of(contextoDemasElementos).size;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 5.0,
          ),
          _parteSuperior(contextoDemasElementos),
          Padding(
              padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
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
          textFieldNombre(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          textFieldApellidos(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          textFieldCorreo(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          textFieldPassword(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          _nitCodigo(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          textFieldRazonSocial(contextoCuerpo),
          SizedBox(
            height: 10.0,
          ),
          _codigoCliente(contextoCuerpo),
          SizedBox(
            height: 50.0,
          ),
          btnEnviar(contextoCuerpo),
        ],
      ),
    );
  }

  Widget _nitCodigo(BuildContext contextoBtnCodigo) {
    final provedorDeBloc = Provider.of(contextoBtnCodigo);
    return StreamBuilder(
        stream: provedorDeBloc.codigoConsultStreamRegisterone,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          return TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.closed_caption),
                hintText: "NIT",
                // labelText: "Código consultoría",
                errorStyle: TextStyle(color: Colors.white),
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToCondigoConsRegisterOne(value);
            },
          );
        });
  }

  Widget btnEnviar(BuildContext contextoBtn) {
    final provedorDeBloc = Provider.of(contextoBtn);
    return StreamBuilder(
        stream: provedorDeBloc.validarUsuario,
        builder: (BuildContext contexto, AsyncSnapshot<bool> asyncSnapshot) {
          return RaisedButton(
            onPressed: () {
              if (!asyncSnapshot.hasError &&
                  provedorDeBloc.ultimoValorName != null &&
                  provedorDeBloc.ultimoValorName != "" &&
                  provedorDeBloc.ultimoValorLastName != null &&
                  provedorDeBloc.ultimoValorLastName != "" &&
                  provedorDeBloc.ultimoValorCorreo != null &&
                  provedorDeBloc.ultimoValorCorreo != "" &&
                  provedorDeBloc.ultimoValorPassword2 != null &&
                  provedorDeBloc.ultimoValorPassword2 != "") {
                verificadorInternet.verificarConexion().then((valorRecibido) {
                  if (valorRecibido[Constantes.estado] ==
                      Constantes.respuesta_estado_ok) {
                    String accessToken = this
                        .preferencias
                        .devolverValor(Constantes.access_token, "null");
                    if (accessToken == "null" || accessToken == null) {
                      base.hitAccessTokenApi().then((valor) {
                        //ok aqui mandarlo a la siguiente pagina pero ya con el accessToken
                        //agregado
                        _llenarInformacion(contextoBtn);
                        String nuevoAccessToken = this
                            .preferencias
                            .devolverValor(Constantes.access_token, "null");
                        provedorDeBloc.restablecerValorRegisterPartOne();
                        Navigator.of(contextoBtn).pushReplacementNamed(
                            RegisterPartTwo.nameOfPage,
                            arguments: this.informacionAEnviar);
                      });
                    } else {
                      //aqui mandar a la siguiente pagina pero ya el accessToken ya estava
                      _llenarInformacion(contextoBtn);
                      String nuevoAccessToken = this
                          .preferencias
                          .devolverValor(Constantes.access_token, "null");
                      provedorDeBloc.restablecerValorRegisterPartOne();
                      Navigator.of(contextoBtn).pushReplacementNamed(
                          RegisterPartTwo.nameOfPage,
                          arguments: this.informacionAEnviar);
                    }
                  } else {
                    base.showSnackBar(
                        "Por favor, revisar su conexion a internet",
                        contexto,
                        Colores.COLOR_AZUL_ATC_FARMA);
                  }
                });
              } else {
                final SnackBar snackBar = new SnackBar(
                  backgroundColor: Colores.COLOR_AZUL_ATC_FARMA,
                  content: Text("Llenar todos los campos correctamente"),
                );

                Scaffold.of(contexto).showSnackBar(snackBar);
              }
            },
            child: Container(
                child: Text("Siguiente"),
                padding:
                    EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0)),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            elevation: 30.0,
            color: Colores.COLOR_AZUL_WEIDING,
            textColor: Colors.white,
          );
        });
  }

  void _llenarInformacion(BuildContext contextoEnviar) {
    final preferencias = SharedPreferencesapp();
    final provedorDeBloc = Provider.of(contextoEnviar);
    this.informacionAEnviar = {
      Constantes.access_token:
          preferencias.devolverValor(Constantes.access_token, "null"),
      Constantes.TYPE: (Platform.isAndroid) ? "ANDROID" : "IOS",
      Constantes.NAME: provedorDeBloc.ultimoValorName,
      Constantes.EMAIL: provedorDeBloc.ultimoValorCorreo,
      Constantes.password: provedorDeBloc.ultimoValorPassword2,
      Constantes.LAST_NAME_FATHER: provedorDeBloc.ultimoValorLastName
      // Constantes.CODIGO_CONSULTORIA: "123456"
    };
  }

  Widget textFieldPassword(BuildContext contextoPassword) {
    final provedorDeBloc = Provider.of(contextoPassword);
    return StreamBuilder(
        stream: provedorDeBloc.password2Stream,
        builder: (BuildContext contexto, AsyncSnapshot asyncSnapshot) {
          return TextField(
            keyboardType: TextInputType.text,
            obscureText: true,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.lock_outline),
                hintText: "Contraseña",
                // labelText: "Contraseña",
                errorStyle: TextStyle(color: Colors.white),
                errorText: (provedorDeBloc.ultimoValorPassword2 == "")
                    ? null
                    : asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToStreamPassword2(value);
            },
          );
        });
  }

  Widget textFieldCorreo(BuildContext contextoCorreo) {
    final provedorDeBloc = Provider.of(contextoCorreo);
    return StreamBuilder(
        stream: provedorDeBloc.emailStream,
        builder: (BuildContext contexto, AsyncSnapshot asyncSnapshot) {
          return TextField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.mail),
                hintText: "Correo electrónico",
                //labelText: "Correo electrónico",
                errorStyle: TextStyle(color: Colors.white),
                errorText: (provedorDeBloc.ultimoValorCorreo == "")
                    ? null
                    : asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToStreamEmail(value);
            },
          );
        });
  }

  Widget textFieldApellidos(BuildContext contextoTextFieldApellido) {
    final provedorDeBloc = Provider.of(contextoTextFieldApellido);
    return StreamBuilder(
        stream: provedorDeBloc.lastnamelStream,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          return TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.person),
                hintText: "Apellido(s)",
                // labelText: "Apellido(s)",
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToStreamLastName(value);
            },
          );
        });
  }

  Widget _codigoCliente(BuildContext contextoTextFieldNombre) {
    final provedorDeBloc = Provider.of(contextoTextFieldNombre);
    return StreamBuilder(
        stream: provedorDeBloc.nameStream,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          return TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.person),
                hintText: "Codigo Cliente",
                // labelText: "Nombre(s)",
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToStreamName(value);
            },
          );
        });
  }

  Widget textFieldRazonSocial(BuildContext contextoTextFieldNombre) {
    final provedorDeBloc = Provider.of(contextoTextFieldNombre);
    return StreamBuilder(
        stream: provedorDeBloc.nameStream,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          return TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.person),
                hintText: "Razon Social",
                // labelText: "Nombre(s)",
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToStreamName(value);
            },
          );
        });
  }

  Widget textFieldNombre(BuildContext contextoTextFieldNombre) {
    final provedorDeBloc = Provider.of(contextoTextFieldNombre);
    return StreamBuilder(
        stream: provedorDeBloc.nameStream,
        builder: (BuildContext contexto, AsyncSnapshot<String> asyncSnapshot) {
          return TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                fillColor: Colors.white,
                filled: true,
                prefixIcon: Icon(Icons.person),
                hintText: "Nombre(s)",
                // labelText: "Nombre(s)",
                errorText: asyncSnapshot.error),
            onChanged: (value) {
              provedorDeBloc.addDataToStreamName(value);
            },
          );
        });
  }

  Widget _parteSuperior(BuildContext contextoParteSuperior) {
    final tamanoPhone = MediaQuery.of(contextoParteSuperior).size;
    return SafeArea(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FlatButton(
              onPressed: () {
                // Navigator.pop(context);
                Navigator.popAndPushNamed(context, WelcomePage.nameOfPage);
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
              onPressed: () {
                // Navigator.pop(context);
                Navigator.popAndPushNamed(context, WelcomePage.nameOfPage);
              },
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
      color: Colors.brown,
      width: double.infinity,
      height: double.infinity,
      child: Image(
        image: AssetImage("assets/imagenes/fondo_fridolin.jpg"),
        fit: BoxFit.cover,
      ),
    );
  }
}
