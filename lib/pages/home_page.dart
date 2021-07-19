import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:weidling/from_packages/swipped_button.dart';
import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/models/cards.dart';
import 'package:weidling/models/cuenta_puntos.dart';
import 'package:weidling/models/oferta.dart';
import 'package:weidling/pages/account_detail.dart';
import 'package:weidling/pages/carrito.dart';

import 'package:weidling/pages/help_page.dart';
import 'package:weidling/pages/history_transfer.dart';
import 'package:weidling/pages/map.dart';
import 'package:weidling/pages/pdf_viewer.dart';

import 'package:weidling/pages/redeem_one_page.dart';
import 'package:weidling/providers/baseDeDatos/db_provider.dart';

import 'package:weidling/providers/cards_providers.dart';
import 'package:weidling/providers/obtaine_pin.dart';
import 'package:weidling/providers/obtenerPuntosEveryTime.dart';
import 'package:weidling/providers/oferts_provider.dart';
import 'package:weidling/providers/providers.dart';
import 'package:weidling/providers/puntos_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flushbar/flushbar.dart';

class HomePage extends StatefulWidget {
  static final nameOfPage = "HomePage";

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  //esto es para el isolate de verificar sus puntos

  ReceivePort _puertoPuntos;
  Isolate _isolatePuntos;

  ///

  ///esto es para el isolate

  ReceivePort _receivePort;
  Isolate _isolate;

  ///

  /// scaffold key

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ///

  final SwipeController swipeController = SwipeController();
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);
  bool resfrescandoPuntos;
  bool refrescandoOfertas;
  bool internet;
  Future<List<Punto>> puntos;
  Future<List<Offert>> ofertas;
  final preferencias = SharedPreferencesapp();
  Map<String, dynamic> myPointsAndAccount;
  PuntosProvider providerCuentaPuntos;
  Base base;
  VerificadorInternet verificadorInternet;
  int _indexSelected;

  ///esto es del carrito
  int cantidadSeleccionadoDeElementos;
  double totalAPagarPorEseElemento;

  /*
        {
           articulo : plancha,
           cantidad : 10,
           subTotal : 100 
        }
       */

  ////////////
  String mensajeDepuntos;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this._isolate = null;
    this._receivePort = null;

    this._isolatePuntos = null;
    this._puertoPuntos = null;

    this.preferencias.agregarValor(Constantes.last_page, HomePage.nameOfPage);
    this.refrescandoOfertas = false;
    this.resfrescandoPuntos = false;
    this.internet = true;
    this.providerCuentaPuntos = new PuntosProvider();
    this.myPointsAndAccount = null;
    this.base = Base();
    this.verificadorInternet = VerificadorInternet();
    this._indexSelected = 0;
    this.mensajeDepuntos = "";
    this.cantidadSeleccionadoDeElementos = 0;

    // _start();
  }

  @override
  Widget build(BuildContext context) {
    verificarConexion().then((value) {
      if (value[Constantes.estado] == Constantes.respuesta_estado_ok) {
        providerCuentaPuntos.obtenerCuentaPuntos(context).then((onValue) {
          this.myPointsAndAccount = onValue;

          print(this.myPointsAndAccount);
        });
      } else {
        this.myPointsAndAccount = null;
        this.internet = false;
      }
    });

    final blocProvider = Provider.of(context);

    this.puntos = this.obtenerElBloque(context);
    this.ofertas = this.obtenerOfertas();

    return Scaffold(
      key: _scaffoldKey,
      appBar: ContantsWidgetsDefaults.widgetAppBar(
          context, Colores.COLOR_AZUL_WEIDING),
      body: SmartRefresher(
        controller: this.refreshController,
        onRefresh: () {
          this.resfrescandoPuntos = true;
          this.refrescandoOfertas = true;
          this.setState(() {
            this.puntos = obtenerElBloque(context);
            this.ofertas = obtenerOfertas();
            this.puntos.then((value) {
              this.resfrescandoPuntos = false;
              if (!this.refrescandoOfertas) {
                this.refreshController.refreshCompleted();
              }
            });

            this.ofertas.then((value) {
              this.refrescandoOfertas = false;
              if (!this.resfrescandoPuntos) {
                this.refreshController.refreshCompleted();
              }
            });
          });
        },
        header: WaterDropMaterialHeader(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: <Widget>[
              _fondo(),
              _demas(context),
            ],
          ),
        ),
      ),
      floatingActionButton: Container( 
        margin: EdgeInsets.only(top: 100.0),
        child: GestureDetector(
          
          child: Image(
            image: AssetImage('assets/imagenes/homeandcook.png'), 
            width: 60.0,
          ),
          onTap: _launchURL,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  void _stopIsolate() {
    _receivePort.close();
    // _puertoPuntos.close();
    _isolate.kill(priority: Isolate.immediate);
    //_isolatePuntos.kill( priority: Isolate.immediate );
    _isolate = null;
    // _isolatePuntos   = null;
  }

  void _stopIsolatePuntos() {
    //ya no me sirve por ahora
    _puertoPuntos.close();
    _isolatePuntos.kill(priority: Isolate.immediate);
    _isolatePuntos = null;
  }

  void _startIsolatePuntos() async {
    //ya no me sirve por ahora

    if (this._isolatePuntos == null) {
      String ciUser = this.preferencias.devolverValor(Constantes.ciUser, "");
      String userSpecificToken =
          this.preferencias.devolverValor(Constantes.userSpecificToken, "");

      _puertoPuntos = ReceivePort();
      ThreadParams parametros =
          ThreadParams(2000, _puertoPuntos.sendPort, ciUser, userSpecificToken);
      _isolatePuntos = await Isolate.spawn(_verificarPuntos, parametros);
      try {
        _puertoPuntos.listen(_datosTraidos, onDone: () {});
      } catch (e) {
        print("Ya estava escuchando");
      }
    }
  }

  static void _verificarPuntos(ThreadParams threadParams) async {
    //este es el Isolate handlers

    Timer.periodic(Duration(seconds: 30), (t) {
      PointsEveryTimeProvider.obtenerPuntosEveryTime(
              threadParams.userSpecificToken)
          .then((onValue) {
        threadParams.sendPort.send(onValue);
      });
    });
  }

  void _datosTraidos(dynamic data) {
    List<Punto> listaPuntos = [];
    final blocProvider = Provider.of(context);
    String mensaje;
    String puntos = "PUNTOS";
    Punto primerPunto;
    listaPuntos = data;

    if (listaPuntos.isEmpty) {
      this.mensajeDepuntos = "Ninguna informacion";

      puntos = "";
    } else {
      primerPunto = listaPuntos[0];
      if (primerPunto.name == "Revise su conexion a internet") {
        this.mensajeDepuntos = primerPunto.name;
        puntos = "";
      } else {
        if (primerPunto.name == "Error") {
          this.mensajeDepuntos = primerPunto.name;
          puntos = "";
        } else {
          if (primerPunto.name == "iniciar_sesion") {
            Navigator.of(context).popAndPushNamed(HomePage.nameOfPage);
          } else {
            this.mensajeDepuntos = primerPunto.point[0].toString();
            print(mensaje);
          }
        }
      }
    }
    blocProvider.addDataToPuntosActualizar(this.mensajeDepuntos);
  }

  void _start() async {
    if (this._isolate == null) {
      String ciUser = this.preferencias.devolverValor(Constantes.ciUser, "");
      String userSpecificToken =
          this.preferencias.devolverValor(Constantes.userSpecificToken, "");

      _receivePort = ReceivePort();
      ThreadParams threadParams =
          ThreadParams(2000, _receivePort.sendPort, ciUser, userSpecificToken);
      _isolate = await Isolate.spawn(
        _isolateHandler,
        threadParams,
      );
      try {
        _receivePort.listen(_handleMessage, onDone: () {});
      } catch (e) {
        print("Ya estava escuchando");
      }
    }
  }

  void _handleMessage(dynamic data) {
    Map<String, dynamic> respuesta = data as Map;

    _manejarElPin(respuesta["mensaje"]);
    _datosTraidos(respuesta["puntos"]);
    verificarConexion().then((value) {
      if (value[Constantes.estado] == Constantes.respuesta_estado_ok) {
        providerCuentaPuntos.obtenerCuentaPuntos(context).then((onValue) {
          this.myPointsAndAccount = onValue;
          print(this.myPointsAndAccount);
        });
      } else {
        this.myPointsAndAccount = null;
        this.internet = false;
      }
    });
  }

  void _manejarElPin(dynamic data) {
    Map<String, dynamic> respuesta = data as Map;

    if (respuesta[Constantes.estado] == Constantes.respuesta_estado_ok) {
      Future.delayed(Duration.zero, () {
        _mostrarDialogPorTenSeconds(context, respuesta[Constantes.pin]);
      });
    }
    print("Data recibido :" + data.toString());
  }

  void _mostrarDialogPorTenSeconds(
      BuildContext contextoMostrarPin, String mensajePin) {
    final tamanoPhone = MediaQuery.of(contextoMostrarPin).size;
    showDialog(
        context: contextoMostrarPin,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 5), () {
            Navigator.of(context).pop(true);
          });
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: Colores.COLOR_AZUL_ATC_FARMA),
              height: tamanoPhone.height * 0.30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: tamanoPhone.width * 0.5,
                      height: tamanoPhone.width * 0.5,
                      child: Image(
                          image:
                              AssetImage("assets/imagenes/logo_fridolin.png"))),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        mensajePin,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 15.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  static void _isolateHandler(ThreadParams threadParams) async {
    //este es el Isolate handlers

    Map<String, dynamic> resultadoParaAmbos = {"mensaje": "", "puntos": ""};

    Timer.periodic(Duration(seconds: 30), (t) {
      ObtainPinProvider.obtainPin(
              threadParams.ciUser, threadParams.userSpecificToken)
          .then((onValue) {
        resultadoParaAmbos.update("mensaje", (olValue) {
          return onValue;
        });

        PointsEveryTimeProvider.obtenerPuntosEveryTime(
                threadParams.userSpecificToken)
            .then((onValuePuntos) {
          resultadoParaAmbos.update("puntos", (oldValue) {
            return onValuePuntos;
          });
          threadParams.sendPort.send(resultadoParaAmbos);
        });
      });
    });
  }

  Widget _parteSuperior(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Opacity(
              opacity: 0.0,
              child: MaterialButton(
                minWidth: 0.0,
                onPressed: () {},
                child: GestureDetector(
                    onTap: () {
                      // this._stopIsolate();
                      //  Navigator.of(contexto).pushNamed(CarritoPage.nameOfPage);
                    },
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                    )), //Icon(Icons.question_answer, color: Colors.white, size: 30.0,)
              ),
            ),
          ),
          Expanded(
            child: Opacity(
              opacity: 0.0,
              child: MaterialButton(
                minWidth: 0.0,
                onPressed: () {},
                child: Image.asset(
                  "assets/imagenes/preguntas_blanco.png",
                  width: 0.0,
                  height: 0.0,
                ), //Icon(Icons.question_answer, color: Colors.white, size: 30.0,)
              ),
            ),
          ),
          Container(
            width: tamanoPhone.width * 0.4,
            height: tamanoPhone.width * 0.4,
            child: Image(
              fit: BoxFit.contain,
              image: AssetImage(
                  "assets/imagenes/imagenes_farmacorp/logo_fondo_azul.png"),
            ),
          ),
          Expanded(
            child: Builder(builder: (BuildContext contextoButtonHep) {
              return MaterialButton(
                minWidth: 10.0,
                onPressed: () {
                  verificarConexion().then((valor) {
                    if (valor[Constantes.estado] ==
                        Constantes.respuesta_estado_ok) {
                      // _stopIsolate();

                      Navigator.of(contexto).pushNamed(HelpPage.namePage);
                    } else {
                      print("No hay");
                      final snackBar = SnackBar(
                        content:
                            Text('Por favor, revisar su conexion a internet'),
                        backgroundColor: Colors.brown,
                      );

                      // Find the Scaffold in the widget tree and use it to show a SnackBar.
                      Scaffold.of(contextoButtonHep).showSnackBar(snackBar);
                    }
                  });
                },
                child: Image.asset(
                  "assets/imagenes/preguntas_blanco.png",
                  width: 50,
                  height: 50,
                ), //Icon(Icons.question_answer, color: Colors.white, size: 30.0,)
              );
            }),
          ),
          Expanded(
            child: Builder(
              builder: (BuildContext contextoBtnTransfer) {
                return MaterialButton(
                  minWidth: 10.0,
                  onPressed: () {
                    this
                        .verificadorInternet
                        .verificarConexion()
                        .then((onValue) {
                      if (onValue[Constantes.estado] ==
                          Constantes.respuesta_estado_ok) {
                        if (this.myPointsAndAccount != null) {
                          // _stopIsolate();
                        
                          Navigator.of(contexto).popAndPushNamed(
                              HistoryTransferPage.nameOfPage,
                              arguments:
                                  (this.myPointsAndAccount[Constantes.mensaje]
                                          as CuentaPuntos)
                                      .data
                                      .cash
                                      .toDouble());
                        } else {
                          this.base.showSnackBar(
                              "Por favor, vuelva a intentarlo",
                              contextoBtnTransfer,
                              Colors.brown);
                        }
                      } else {
                        this.base.showSnackBar(Constantes.error_conexion,
                            contextoBtnTransfer, Colors.brown);
                      }
                    });
                  },
                  child: Image.asset(
                    "assets/imagenes/transaccion_blanco.png",
                    width: 50,
                    height: 50,
                  ), //Icon(Icons.av_timer, color: Colors.white,size: 30.0,)
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _parteSuperiorTwo(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;
    return Container(
      width: tamanoPhone.width * 0.5,
      height: tamanoPhone.height * 0.2,
      color: Colors.transparent,
      child: Image(
        image: AssetImage("assets/imagenes/logo_fridolin.png"),
      ),
    );
  }

  Widget _cuenta(BuildContext contexto) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0))),
      child: Column(
        children: <Widget>[
          Builder(builder: (BuildContext contextoBuilder) {
            return MaterialButton(
                onPressed: () {
                  //Navigator.of(contexto).pushReplacementNamed(LoginPage.nameOfPage);

                  this.verificadorInternet.verificarConexion().then((onValue) {
                    if (onValue[Constantes.estado] ==
                        Constantes.respuesta_estado_ok) {
                      // _stopIsolate();

                      Navigator.of(contexto)
                          .popAndPushNamed(AccountDetail.namePage);
                    } else {
                      this.base.showSnackBar(Constantes.error_conexion,
                          contextoBuilder, Colors.brown);
                    }
                  });
                },
                child: Icon(
                  Icons.people,
                  color: Colores.COLOR_AZUL_WEIDING,
                  size: 40.0,
                ));
          }),
          Text(
            "Cuenta",
            style: TextStyle(color: Colores.COLOR_AZUL_WEIDING),
          )
        ],
      ),
    );
  }

  Widget _canjearPuntos(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;
    return Builder(builder: (BuildContext contextoBuild) {
      return SwipeButton(
        swipeController: this.swipeController,
        thumb: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
                widthFactor: 0.90,
                child: Icon(
                  Icons.arrow_forward,
                  size: 40.0,
                  color: Colores.COLOR_AZUL_WEIDING,
                )) //esto agregue
          ],
        ),
        content: Center(
          child: Text(
            "Deslizar para canjear",
            style: TextStyle(color: Colors.white, fontSize: 10.0),
          ),
        ),
        onChanged: (result) {
          if (result == SwipePosition.SwipeRight) {
            print("Deslizado");

            if (this.myPointsAndAccount != null &&
                this.internet &&
                this.myPointsAndAccount[Constantes.estado] ==
                    Constantes.respuesta_estado_ok) {
              double balance =
                  (this.myPointsAndAccount[Constantes.mensaje] as CuentaPuntos)
                      .data
                      .cash
                      .toDouble(); // as double;
              print(balance);
              if (balance > 0.0) {
                verificarConexion().then((valor) {
                  if (valor[Constantes.estado] ==
                      Constantes.respuesta_estado_ok) {
                    // _stopIsolate();
                    

                    Navigator.of(contexto)
                        .pushReplacementNamed(RedeemPageOne.nameOfPage);
                  } else {
                    this.swipeController.reset();
                    final snackBar = SnackBar(
                      content: Text('Revisar su conexion a internet'),
                      backgroundColor: Colors.brown,
                    );

                    // Find the Scaffold in the widget tree and use it to show a SnackBar.
                    Scaffold.of(contextoBuild).showSnackBar(snackBar);
                    print("sin internet");
                  }
                });
              } else {
                print("menor o igual a cero");
                Flushbar(
                  boxShadows: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 20.0,
                    )
                  ],
                  borderRadius: 10.0,
                  maxWidth: tamanoPhone.width * 0.9,
                  backgroundColor: Colores.COLOR_AZUL_WEIDING,
                  flushbarPosition: FlushbarPosition.TOP,
                  title: "Mensaje:",
                  message: "Su saldo para redimir debe ser mayor a 0 puntos",
                  duration: Duration(seconds: 5),
                ).show(contexto);

                this.swipeController.reset();
              }
            } else {
              verificarConexion().then((onValue) {
                if (onValue[Constantes.estado] ==
                    Constantes.respuesta_estado_ok) {
                  this.swipeController.reset();
                  final snackBar = SnackBar(
                    content: Text(
                        'Deslizar la pantalla hacia abajo para actualizar'),
                    backgroundColor: Colors.brown,
                  );

                  // Find the Scaffold in the widget tree and use it to show a SnackBar.
                  Scaffold.of(contextoBuild).showSnackBar(snackBar);
                  print("sin internet");
                } else {
                  this.swipeController.reset();
                  final snackBar = SnackBar(
                    content: Text('Revisar su conexion a internet'),
                    backgroundColor: Colors.brown,
                  );

                  // Find the Scaffold in the widget tree and use it to show a SnackBar.
                  Scaffold.of(contextoBuild).showSnackBar(snackBar);
                  print("sin internet");
                }
              });
            }
          } else {
            print("Devuelto atras");
          }
        },
      );
    });
  }

  Widget _bottomMenu(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: _cuenta(contexto),
                ),
                SizedBox(
                  width: tamanoPhone.width * 0.055,
                ),
                Expanded(child: _canjearPuntos(contexto)),
                SizedBox(
                  width: tamanoPhone.width * 0.055,
                )
              ],
            ),
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

  Future<List<Punto>> obtenerElBloque(BuildContext contexto) {
    CardProvider proveedorCard = new CardProvider();

    return verificarConexion().then((value) {
      if (value[Constantes.estado] == Constantes.respuesta_estado_ok) {
        this.internet = true;
        return proveedorCard.obtenerCards(contexto);
      } else {
        this.internet = false;
        return null;
      }
    });
  }

  Future<List<Offert>> obtenerOfertas() {
    OffertProvider provedorDeOfertas = new OffertProvider();

    return verificarConexion().then((value) {
      if (value[Constantes.estado] == Constantes.respuesta_estado_ok) {
        this.internet = true;
        return provedorDeOfertas.obtenerOfertas();
      } else {
        this.internet = false;
        return null;
      }
    });
  }

  Widget _myPoints(BuildContext contexto) {
    List<Punto> listaPuntos = [];
    final blocProvider = Provider.of(context);
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FutureBuilder(
          future: this.puntos,
          builder: (BuildContext contexto, AsyncSnapshot asyncSnapshot) {
            if (asyncSnapshot.hasData) {
              print("PASA");
              String mensaje;
              String puntos = "PUNTOS";
              Punto primerPunto;
              listaPuntos = asyncSnapshot.data;

              if (listaPuntos.isEmpty) {
                this.mensajeDepuntos = "Ninguna informacion";

                puntos = "";
              } else {
                primerPunto = listaPuntos[0];
                if (primerPunto.name == "Revise su conexion a internet") {
                  this.mensajeDepuntos = primerPunto.name;
                  puntos = "";
                } else {
                  if (primerPunto.name == "Error") {
                    this.mensajeDepuntos = primerPunto.name;
                    puntos = "";
                  } else {
                    this.mensajeDepuntos = primerPunto.point[0].toString();
                    print(mensaje);
                  }
                }
              }
              blocProvider.addDataToPuntosActualizar(this.mensajeDepuntos);
              return Column(
                children: <Widget>[
                  _textFieldWithPuntos(contexto),
                  Text(
                    puntos,
                    style: TextStyle(color: Colors.black, fontSize: 40.0),
                  ),
                ],
              );
            } else {
              if (asyncSnapshot.hasError) {
                print(asyncSnapshot.error);
                return Column(
                  children: <Widget>[
                    Text(
                      asyncSnapshot.error.toString(),
                      style: TextStyle(color: Colors.black, fontSize: 40.0),
                    ),
                  ],
                );
              }

              if (!this.internet) {
                return Center(
                  child: Text(
                    "Revisar conexion a internet",
                    style: TextStyle(color: Colors.black, fontSize: 40.0),
                  ),
                );
              }

              print("No hay data aun");
              return CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Colores.COLOR_AZUL_WEIDING),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _textFieldWithPuntos(BuildContext contextTexFieldPuntosAct) {
    final blocProvider = Provider.of(contextTexFieldPuntosAct);
    return StreamBuilder(
        stream: blocProvider.streamActualizarPuntos,
        builder:
            (BuildContext contextoPuntos, AsyncSnapshot<String> asyncSnapshot) {
          return Text(
            (asyncSnapshot.hasData) ? asyncSnapshot.data : "0",
            style: TextStyle(color: Colors.black, fontSize: 40.0),
          );
        });
  }

  Widget _myOferts(BuildContext conteto) {
    final tamanoPhone = MediaQuery.of(conteto).size;
    final provedorDeBloc = Provider.of(conteto);
    return FutureBuilder(
      future: this.ofertas,
      builder: (BuildContext contexto, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          List<Offert> lista = asyncSnapshot.data;
          return GridView.builder(
                    itemCount: lista.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2
                    ),
                    itemBuilder: (BuildContext contexto, int indice) {
                      return GestureDetector(
                        
                        child: Card(
                          color: Colors.white,
                          elevation: 10.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                
                                child: FadeInImage(
                                  fit: BoxFit.fill,
                                  width: tamanoPhone.width*0.35,
                                  height: tamanoPhone.width*0.35,
                                  placeholder:
                                      AssetImage('assets/gifs/pre_loading.gif'),
                                  image: (this.internet)
                                      ? NetworkImage(lista[indice].urlJpg)
                                      : AssetImage("assets/imagenes/no_internet.jpg"),
                              ),
                              ),
                              
                              // SizedBox(
                              //   // height: 5,
                              // ),
                              Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    // width: 200.0,
                                    color: Color(0xff5F6E88),
                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                      child: Text(
                                        lista[indice].subtitle,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: tamanoPhone.width * 0.03,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold
                                        ),
                                        // overflow: TextOverflow.ellipsis,
                                      )
                                  )
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          String pdfUrl = lista[indice].urlPdf;

                          /*   int cantidad = 0;
                                                double precio = 0.0;
                                                String nombreElemento = "";
                                                String idProducto     = "";
                                                try {
                                                  cantidad = int.parse(lista[indice].quantity);
                                                  precio   = double.parse(lista[indice].points);
                                                  nombreElemento = lista[indice].subtitle;
                                                  idProducto     = lista[indice].id;
                                                  this.cantidadSeleccionadoDeElementos = 0;
                                                  this.totalAPagarPorEseElemento       = 0.0;
                                                  provedorDeBloc.addDataToUnidadesDialog( this.cantidadSeleccionadoDeElementos );
                                                  _mostrarDialogCantidad(conteto, idProducto ,cantidad,precio,nombreElemento);
                                                } catch (e) {
                                                  print(e);
                                                } */

                          //_stopIsolate();
                          Navigator.of(conteto).popAndPushNamed(PdfViewer.nameOfPage,
                              arguments: pdfUrl);
                        },
                      );
                    }
          );
              
            
        } else {
          if (!this.internet) {
            return Center(
              child: Text(
                "Revisar conexion a internet",
                style: TextStyle(color: Colors.black, fontSize: 40.0),
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  new AlwaysStoppedAnimation<Color>(Colores.COLOR_AZUL_WEIDING),
            ),
          );
        }
      },
    );
  }

  void _mostrarDialogCantidad(BuildContext contextoCantidadDialog,
      String idProducto, int cantidadDeElemento, double precio, String nombre) {
    final tamanoPhone = MediaQuery.of(contextoCantidadDialog).size;
    showDialog(
        context: contextoCantidadDialog,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: Colors.white),
              height: tamanoPhone.height * 0.46,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(nombre,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 35.0,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text("Bs. " + precio.toString(),
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Divider(
                      thickness: 3.0,
                      color: Color.fromRGBO(204, 204, 204, 1.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text("Unidades",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                        )),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  _seleccionador(
                      contextoCantidadDialog, cantidadDeElemento, precio),
                  SizedBox(
                    height: 3.0,
                  ),
                  Center(
                    child: _textoDeError(contextoCantidadDialog),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Center(
                      child: _btnMandarACarrito(
                          contextoCantidadDialog, precio, nombre, idProducto)),
                  Expanded(child: Container())
                ],
              ),
            ),
          );
        });
  }

  Widget _textoDeError(BuildContext contexto) {
    final provedorDeBloc = Provider.of(contexto);
    return StreamBuilder(
        stream: provedorDeBloc.streamCantidadMAyorACero,
        builder: (BuildContext contexto, AsyncSnapshot<bool> asyncSnapshot) {
          if (!asyncSnapshot.hasData) {
            return Text(
              "",
              style: TextStyle(color: Colors.red),
            );
          } else {
            if (asyncSnapshot.data) {
              return Text(
                "",
                style: TextStyle(color: Colors.red),
              );
            } else {
              return Text(
                "Debe seleccionar al menos una unidad",
                style: TextStyle(color: Colors.red),
              );
            }
          }
        });
  }

  Widget _seleccionador(
      BuildContext contextoSeleccionador, int cantidadStock, double precio) {
    final provedorDeBloc = Provider.of(contextoSeleccionador);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 80.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(204, 204, 204, 1.0)),
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    if (this.cantidadSeleccionadoDeElementos != 0) {
                      this.cantidadSeleccionadoDeElementos--;
                      this.totalAPagarPorEseElemento =
                          this.cantidadSeleccionadoDeElementos * precio;
                      provedorDeBloc.addDataToUnidadesDialog(
                          this.cantidadSeleccionadoDeElementos);
                      if (this.cantidadSeleccionadoDeElementos == 0) {
                        provedorDeBloc.addDataToCantidadMAyorACero(false);
                      } else {
                        provedorDeBloc.addDataToCantidadMAyorACero(true);
                      }
                    }
                  },
                  child: Icon(Icons.remove)),
              StreamBuilder(
                  stream: provedorDeBloc.streamUnidadesDialog,
                  builder: (BuildContext contextoBuilder,
                      AsyncSnapshot<int> asyncSnapshot) {
                    return Text(
                        (asyncSnapshot.hasData)
                            ? asyncSnapshot.data.toString()
                            : "0",
                        style: TextStyle(fontSize: 20.0));
                  }),
              GestureDetector(
                  onTap: () {
                    if (this.cantidadSeleccionadoDeElementos < cantidadStock) {
                      this.cantidadSeleccionadoDeElementos++;
                      provedorDeBloc.addDataToCantidadMAyorACero(true);
                      this.totalAPagarPorEseElemento =
                          this.cantidadSeleccionadoDeElementos * precio;
                      provedorDeBloc.addDataToUnidadesDialog(
                          this.cantidadSeleccionadoDeElementos);
                    }
                  },
                  child: Icon(Icons.add))
            ],
          ),
        ),
      ),
    );
  }

  Widget _btnMandarACarrito(BuildContext contextoBtnMandarAlCarrito,
      double precioUnitario, String nombre, String idProducto) {
    final tamanoPhone = MediaQuery.of(contextoBtnMandarAlCarrito).size;
    return RaisedButton(
      onPressed: () {
        if (this.cantidadSeleccionadoDeElementos != 0) {
          final pedido = Pedido(
              id: idProducto,
              totalPorProducto: this.totalAPagarPorEseElemento.toString(),
              cantidad: this.cantidadSeleccionadoDeElementos.toString(),
              nombreProducto: nombre,
              precioUnitario: precioUnitario.toString());

          DBProvider.db.nuevoPedido(pedido).then((res) {
            if (res != 0) {
              this._scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content:
                          Text("El producto fue añadido al carrito de compra"),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.brown,
                    ),
                  );
            } else {
              this._scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text(
                          "El producto fue modificado en el carrito de compra"),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.brown,
                    ),
                  );
            }
            Navigator.of(contextoBtnMandarAlCarrito).pop();
          });
        } else {
          final provedorDeBloc = Provider.of(contextoBtnMandarAlCarrito);
          provedorDeBloc.addDataToCantidadMAyorACero(false);
        }
      },
      child: Container(
        width: tamanoPhone.width * 0.4,
        height: tamanoPhone.width * 0.1,
        child: Center(child: Text("Enviar al carrito")),
        // padding: EdgeInsets.symmetric( horizontal: 50.0, vertical: 15.0)
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      elevation: 30.0,
      color: Colores.COLOR_ROJISO_TEXTO_LOYALTY,
      textColor: Colores.COLOR_BLANCO_LOYALTY,
    );
  }

  Widget _cuerpor(BuildContext contexto) {
    final tamanoPhone = MediaQuery.of(contexto).size;
    final selectedColor = Colores.COLOR_AZUL_WEIDING;
    return new DefaultTabController(
      length: 2,
      child: Container(
        width: tamanoPhone.width * 0.9,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TabBar(
                      indicatorColor: Colors.transparent,
                      onTap: (int indice) {
                        if (indice == 1) {
                          verificarConexion().then((valorDevuelto) {
                            if (valorDevuelto[Constantes.estado] !=
                                Constantes.respuesta_estado_ok) {
                              this.internet = false;
                            } else {
                              this.internet = true;
                            }
                          });
                        }

                        this.setState(() {
                          this._indexSelected = indice;
                        });
                      },
                      unselectedLabelColor: Colores.COLOR_AZUL_WEIDING,
                      tabs: [
                        Tab(
                          child: Container(
                            decoration: BoxDecoration(
                                color: _indexSelected == 0
                                    ? selectedColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(50.0),
                                border: Border.all(
                                    width: 1,
                                    color: Colores.COLOR_AZUL_WEIDING)),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("MIS PUNTOS"),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            decoration: BoxDecoration(
                                color: _indexSelected == 1
                                    ? selectedColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(50.0),
                                border: Border.all(
                                    width: 1,
                                    color: Colores.COLOR_AZUL_WEIDING)),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text("OFERTAS"),
                            ),
                          ),
                        ),
                      ]),
                ),
                Expanded(
                  child: TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      _myPoints(contexto),
                      
                      _myOferts(contexto),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _demas(BuildContext contexto) {
    return Column(
      children: <Widget>[
        _parteSuperior(contexto),
        //  _parteSuperiorTwo(contexto),
        Expanded(child: _cuerpor(contexto)),
        _bottomMenu(contexto),
      ],
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

  void _launchURL() async{
    await canLaunch('https://homeandcook.com.bo/')? await launch('https://homeandcook.com.bo/') : throw 'Could not launch';
  }
}

class ThreadParams {
  ThreadParams(this.val, this.sendPort, this.ciUser, this.userSpecificToken);

  int val;
  String ciUser;
  String userSpecificToken;
  SendPort sendPort;
}
