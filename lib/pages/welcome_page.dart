import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/pages/login_page.dart';
import 'package:weidling/pages/register_part_one.dart';
import 'package:weidling/providers/FirebaseMessaging/push_notificacions_provider.dart';
//paquetes para pruebas de imei
//import 'package:unique_identifier/unique_identifier.dart';
//import 'package:device_info/device_info.dart';

class WelcomePage extends StatefulWidget {
  static final nameOfPage = 'WelcomePage';

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  /////
  String imei = "unknown";
  String imeiIos = "unknow";

  PushNotificacionProvider pushNotificacionProvider;

  //todo esto para probar imei
  int _currentPage = 0;
  final preferencias = SharedPreferencesapp();

  PageController _controladorPageView = new PageController(initialPage: 0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this
        .preferencias
        .agregarValor(Constantes.last_page, WelcomePage.nameOfPage);

    Timer.periodic(new Duration(seconds: 3), (Timer timer) {
      if (_currentPage <= 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _controladorPageView.animateToPage(_currentPage,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    });

    // prueba imei
  }

  @override
  Widget build(BuildContext context) {
    this.pushNotificacionProvider = new PushNotificacionProvider();
    this.pushNotificacionProvider.initNotifications();
    Size tamanoPhone = MediaQuery.of(context).size;
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(tamanoPhone.height * 0.001),
            child: AppBar(
              backgroundColor: Colores
                  .COLOR_AZUL_WEIDING, // Set any color of status bar you want; or it defaults to your theme's primary color
            )),
        body: Stack(
          children: <Widget>[_fondoPageView(context), _botonesDeABajo(context)],
        ));
  }

/*
void _obTenerInformacion(){ //prueba imei

   try {
     
   if (Theme.of(context).platform == TargetPlatform.iOS) {
        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        deviceInfo.iosInfo
            .then((onValue){
              IosDeviceInfo iosDeviceInfo = onValue;
              imeiIos =  iosDeviceInfo.identifierForVendor;
              print("identifier ios "+ imeiIos);
            });
    
    // unique ID on iOS
  } else {

     UniqueIdentifier sd = new UniqueIdentifier();   
     UniqueIdentifier.serial
          .then((onValue){
             imei = onValue;
             print("imei android "+ imei);
          });
   // unique ID on Android
  }

      
   } catch ( e ) {
      this.imeiIos = e.toString();
      this.imei    = e.toString();
      print(this.imeiIos);
      print(this.imei);
   }

} */

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

  Future hitAccessTokenApi() async {
    Uri url = Uri.parse(NetworkApp.Base +
        NetworkEndPointsApp.hitAccesToken +
        "?client_id=ItacambaApp&client_secret=MWU5MTFlMTg1NzI5YjkyZWY4YTNiNjhkNDBiOWY2NGU");
    http.Response respuesta;

    try {
      respuesta = await http.get(url);
      Map<String, dynamic> respuestaEnMap = jsonDecode(respuesta.body);
      String accessToke = respuestaEnMap["access_token"];
      this.preferencias.agregarValor(Constantes.access_token, accessToke);
    } catch (exepcion) {
      print(exepcion);
    }
  }

  Widget _botonOne(BuildContext contexto) {
    return SafeArea(
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        onPressed: () {
          Navigator.pushNamed(contexto, LoginPage.nameOfPage);
        },
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        elevation: 10.0,
        color: Colores.COLOR_AZUL_WEIDING,
        child: Text(
          "Ingresar",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _botonTwo(BuildContext contexto) {
    return SafeArea(
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        onPressed: () {
          Navigator.pushNamed(contexto, RegisterPartOne.nameOfPage);
        },
        elevation: 10.0,
        color: Colores.COLOR_AZUL_WEIDING,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Text(
          "Registrarse",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _botonesDeABajo(BuildContext contexto) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 15.0,
            ),
            Expanded(child: _botonOne(contexto)),
            SizedBox(
              width: 30.0,
            ),
            Expanded(child: _botonTwo(contexto)),
            SizedBox(
              width: 15.0,
            ),
          ],
        ),
        SizedBox(
          height: 20.0,
        )
      ],
    );
  }

  Widget _fondoOne(BuildContext contexto, Image imagen) {
    final tamanoPhone = MediaQuery.of(contexto).size;

    return Container(
      width: tamanoPhone.width,
      height: tamanoPhone.height,
      child: imagen,
    );
  }

  Widget _fondoPageView(BuildContext contexto) {
    return Builder(builder: (BuildContext contextoV) {
      verificarConexion().then((onValue) {
        if (onValue[Constantes.estado] == Constantes.respuesta_estado_ok) {
          hitAccessTokenApi();
        } else {
          final SnackBar snackBar = new SnackBar(
            backgroundColor: Colors.brown,
            content: Text("Por favor, revisar su conexion a internet"),
          );

          Scaffold.of(contextoV).showSnackBar(snackBar);
        }
      });

      return /*_fondoOne(
          contexto,
          Image(
            image: AssetImage("assets/imagenes/primera_pagina.png"),
            fit: BoxFit.cover,
          )); */

          PageView(
        controller: _controladorPageView,
        children: <Widget>[
          _fondoOne(
              contexto,
              Image(
                image: AssetImage("assets/imagenes/tercera_pagina.png"),
                fit: BoxFit.cover,
              )),
          _fondoOne(
              contexto,
              Image(
                image: AssetImage("assets/imagenes/primera_pagina.png"),
                fit: BoxFit.cover,
              )),
          _fondoOne(
              contexto,
              Image(
                image: AssetImage("assets/imagenes/segunda_pagina.png"),
                fit: BoxFit.cover,
              )),
        ],
      );
    });
  }
}
