import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/models/transferencias.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/providers/transfers_providers.dart';

class HistoryTransferPage extends StatefulWidget {
  HistoryTransferPage({Key key}) : super(key: key);

  static final nameOfPage = 'HistoryTransferPage';

  @override
  _HistoryTransferPageState createState() => _HistoryTransferPageState();
}

class _HistoryTransferPageState extends State<HistoryTransferPage> {
  Base base;
  VerificadorInternet verificadorInternet;
  double balance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.base = new Base();
    this.verificadorInternet = new VerificadorInternet();
    this.balance = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    this.balance = ModalRoute.of(context).settings.arguments;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        appBar: ContantsWidgetsDefaults.widgetAppBar(
            context, Colores.COLOR_AZUL_WEIDING),
        body: Stack(
          children: <Widget>[
            _fondoApp(),
            _demasElementos(context),
          ],
        ),
      ),
    );
  }

  Widget _parteSuperior(BuildContext contextoParteSuperior) {
    //final provedorDeBloc = Provider.of(contextoParteSuperior);
    // provedorDeBloc.addDataToStreamEditingOrNot(false);
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Container(
            width: 200,
            height: 139,
            child: Image(
              image: AssetImage("assets/imagenes/logo_fridolin.png"),
            ),
          ),
          GestureDetector(
            onTap: () {
              //  Navigator.of(contextoParteSuperior).popAndPushNamed(HomePage.nameOfPage);
            },
            child: Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Icon(Icons.arrow_back_ios, color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _demasElementos(BuildContext context) {
    final tamanoPhone = MediaQuery.of(context).size;
    return Column(
      children: <Widget>[
        _parteSuperior(context),
        Expanded(
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
              ),
              padding: EdgeInsets.all(20.0),
              width: tamanoPhone.width * 0.9,
              child: Column(
                children: <Widget>[
                  Container(
                    height: tamanoPhone.height * 0.05,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colores.COLOR_AZUL_WEIDING,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Center(
                        child: Text(
                      "DETALLES DE TRANSACCIONES",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    )),
                  ),
                  Expanded(child: _listaDeDesplegable(context)),
                  Container(
                    decoration: BoxDecoration(
                        color: Colores.COLOR_AZUL_WEIDING,
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Saldo",
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        ),
                        Expanded(child: Container()),
                        Text(
                          "Bs " + this.balance.toString(),
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic),
                        )
                      ],
                    ),
                  ),
                ],
              )),
        ),
        SizedBox(
          height: 15.0,
        )
      ],
    );
  }

  Widget _listaDeDesplegable(BuildContext contextoListaDesplegable) {
    HistoryProviders historyProviders = new HistoryProviders();
    return FutureBuilder(
        future:
            historyProviders.obtenerTransferencias(contextoListaDesplegable),
        builder: (BuildContext contexto,
            AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            Map<String, dynamic> mapaDevueltoDelProvider = asyncSnapshot.data;
            if (mapaDevueltoDelProvider[Constantes.estado] ==
                Constantes.respuesta_estado_ok) {
              List<Transferencia> listaTransferenciasDelProvider =
                  mapaDevueltoDelProvider[Constantes.mensaje]
                      as List<Transferencia>;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: listaTransferenciasDelProvider.length,
                itemBuilder: (context, i) {
                  return Theme(
                    data: ThemeData(accentColor: Colores.COLOR_AZUL_WEIDING),
                    child: new ExpansionTile(
                      title: new Text(
                        listaTransferenciasDelProvider[i].fecha,
                        style: new TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                      children: <Widget>[
                        new Column(
                            children: _buildExpandableContent(
                                listaTransferenciasDelProvider[i].data)),
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(mapaDevueltoDelProvider[Constantes.mensaje]),
              );
            }
          } else {
            return Center(
                child: this
                    .base
                    .retornarCircularCargando(Colores.COLOR_AZUL_WEIDING));
          }
        });
  }

  List<Widget> _buildExpandableContent(
      List<DetalleTransferencia> listaDeDetallesDeTransferencias) {
    List<Widget> columnContent = [];

    columnContent.add(new ListTile(
      title: new Text(
        "TRANSACCION",
        style: new TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic),
      ),
      trailing: new Text(
        "MONTO",
        style: new TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic),
      ),
    ));

    for (DetalleTransferencia detalle in listaDeDetallesDeTransferencias)
      columnContent.add(
        new ListTile(
          title: new Text(
            detalle.detail,
            style: new TextStyle(fontSize: 18.0),
          ),
          trailing: new Text(
            detalle.mount.toString(),
            style: new TextStyle(fontSize: 18.0),
          ),
        ),
      );

    return columnContent;
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
