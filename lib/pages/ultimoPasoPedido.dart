
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/models/pedido.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/providers/baseDeDatos/db_provider.dart';
import 'package:weidling/providers/carritoProvider.dart';
import 'package:weidling/providers/providers.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class DetallePedido extends StatefulWidget {
  DetallePedido({Key key}) : super(key: key);
  static final nameOfPage = "DetallePedido";

  @override
  _DetallePedidoState createState() => _DetallePedidoState();
}

class _DetallePedidoState extends State<DetallePedido> {

   Base       base;
   Map<String, dynamic> mapaConDetalles ;
   String modoPagoEditar, notaEditar, direccionEditar;
   double precioEnvio , precioSubTotal , precioTotal;
   List<String> listaDeModoDePago ; 

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.base = Base();
    this.modoPagoEditar = this.notaEditar = this.direccionEditar = "";
     this.precioSubTotal = this.precioTotal = 0.0;
     this.precioEnvio = 15.0;
     _inicializarLista();
  }

  _inicializarLista(){

      this.listaDeModoDePago = List(); 
      this.listaDeModoDePago.add("Pagos Net");
      this.listaDeModoDePago.add("ATC");
      this.listaDeModoDePago.add("Efectivo");

  }

  _obtenerLosDetalless(){

      this.modoPagoEditar   = this.mapaConDetalles["modo_pago"];
      this.notaEditar       = this.mapaConDetalles["nota"];
      this.direccionEditar  = this.mapaConDetalles["direccion_literal"];

  }

  @override
  Widget build(BuildContext context) {
     final provedorDeBloc = Provider.of(context);
     provedorDeBloc.addDataToSubTotalDetalle(0.0); 
    this.mapaConDetalles = ModalRoute.of(context).settings.arguments as Map;
    if( this.mapaConDetalles != null ){
        _obtenerLosDetalless();
    }
    print(this.mapaConDetalles);
       return Scaffold(
           appBar: AppBar(
                title: Text("Detalle de pedido"),
                centerTitle: true,
           ),
           body: 
                 
                 StreamBuilder<bool>(
                   stream: provedorDeBloc.streamModoPagoLoading,
                   builder: (context, snapshot) {
                     return ModalProgressHUD(
                         inAsyncCall: snapshot.data ?? false,
                        color: Colors.white,
                        dismissible: false,
                        progressIndicator: CircularProgressIndicator(
                              valueColor:  new AlwaysStoppedAnimation<Color>(Colores.COLOR_ROJISO_TEXTO_LOYALTY),
                        ), 
                        child: SingleChildScrollView(
                                child: Column( 
                                children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only( left: 10.0, top: 10.0 ),
                                            child: Text("¡Último paso!",  style: TextStyle( fontWeight: FontWeight.bold, fontSize: 30.0 ), ),
                                          ),
                                          Container(
                                              height: MediaQuery.of(context).size.height * 0.4,
                                              child: _detalleDeCompra(context)
                                            ),
                                          Divider(  ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric( horizontal: 10.0 ),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                    
                                                  Text("SubTotal", style: TextStyle( fontWeight: FontWeight.bold ), ),
                                                      
                                                    StreamBuilder<double>(
                                                      stream: provedorDeBloc.streamSubTotalDetalle,
                                                      builder: (context, snapshot) {
                                            
                                                        return Text( 'Bs . ${ ( snapshot.data != null && snapshot.hasData ) ? snapshot.data.toString() : "0" }'  );
                                                      }
                                                    ),
                                                ], 
                                            ),
                                          ),
                                          SizedBox( height: 10.0,),
                                          Padding(
                                            padding: const EdgeInsets.symmetric( horizontal: 10.0 ),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                    Text("Envio" , style: TextStyle( fontWeight: FontWeight.bold ),),
                                                    Text("Bs. 15"),
                                                ], 
                                            ),
                                          ),
                                          SizedBox( height: 10.0,),
                                          Padding(
                                              padding: const EdgeInsets.symmetric( horizontal: 10.0 ),
                                              child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                      Text("Total", style: TextStyle( fontWeight: FontWeight.bold ),),
                                                      StreamBuilder<double>(
                                                        stream: provedorDeBloc.streamSubTotalDetalle,
                                                        builder: (context, snapshot) {
                                                          this.precioTotal =  ( snapshot.data != null && snapshot.hasData ) ? snapshot.data : 0.0;
                                                          this.precioTotal += this.precioEnvio;
                                                          return Text( 'Bs . ${ this.precioTotal }'   );
                                                        }
                                                      ),
                                                  ], 
                                              ),
                                            ),
                                          Divider(),
                                          ListTile(
                                              title: Text("Modo de pago"),
                                              subtitle: StreamBuilder<String>(
                                                stream: provedorDeBloc.streamModoPagoSelec,
                                                builder: (context, snapshot) {
                                                  return Text( ( snapshot.data != null && snapshot.hasData ) ? snapshot.data : this.modoPagoEditar );
                                                }
                                              ) ,
                                              trailing: GestureDetector(
                                                  onTap: (){
                                                      _modoDePagoActualizar(context);
                                                  },
                                                  child: Icon( Icons.edit, color: Colores.COLOR_ROJISO_TEXTO_LOYALTY, )
                                                ),
                                          ),  
                                          ListTile(
                                              title: Text("Nota"),
                                              subtitle: StreamBuilder<String>(
                                                stream: provedorDeBloc.streamNotaModoPago,
                                                builder: (context, snapshot) {
                                                  return Text( ( snapshot.data != null && snapshot.hasData ) ? snapshot.data : this.notaEditar );
                                                }
                                              ) ,
                                              trailing: GestureDetector(
                                                  onTap: (){
                                                      _actualizarNota(context);
                                                  },
                                                  child: Icon( Icons.edit, color: Colores.COLOR_ROJISO_TEXTO_LOYALTY, )
                                                ),
                                          ),
                                          ListTile(
                                              title: Text("Direccion"),
                                              subtitle: StreamBuilder<String>(
                                                stream: provedorDeBloc.streamDireccionEditarDetalleCompr,
                                                builder: (context, snapshot) {
                                                  return Text( ( snapshot.data != null && snapshot.hasData ) ? snapshot.data : this.direccionEditar );
                                                }
                                              ),
                                              trailing: GestureDetector(
                                                  onTap: (){
                                                      _actualizarDireccion(context);
                                                  },
                                                  child: Icon( Icons.edit, color: Colores.COLOR_ROJISO_TEXTO_LOYALTY, )
                                                ),
                                          ),
                                          _btnEnviarPedido(context),
                                ],
                          ),
           ),
                     );
                   }
                 ),
       );
  }


   void _actualizarNota(BuildContext contexto){

      final tamanoPhone = MediaQuery.of(contexto).size;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
      return Dialog(

        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0)), //this right here
        child: Container(

          decoration: BoxDecoration(
             borderRadius: BorderRadius.all(Radius.circular(20.0)),
             color: Colors.white
          ),
          height: tamanoPhone.height * 0.45,
          child:Column(
              children: <Widget>[
                   Text("Agregar referencia", style: TextStyle( color: Colors.black, fontSize: 25.0 ),),
                   SizedBox( height: 20.0, ),
                   Padding(
                     padding: EdgeInsets.symmetric( horizontal: 10.0 ),
                     child: _textFieldActualizarNota(contexto)
                    ),
                    SizedBox( height: 10.0, ),
                    _btnAceptar(contexto)
              ],
          ),
        ),
      );
    });
 }


   Widget _textFieldActualizarNota( BuildContext contexto){
      final provedorDeBloc = Provider.of(contexto);
      return TextField(  
                 style: TextStyle( color: Colors.black ), 
                 maxLines: 5, 
                 onChanged: (value){
                    this.notaEditar = value;
                    provedorDeBloc.addDataToModoPagoNota(value);
                 },
                 decoration: InputDecoration(
                      border: new OutlineInputBorder(  
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                      enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black, width: 0.5),
                            ),  
                      hintText: "Agregar referencias o dirección mas exacta",
                      hintStyle: TextStyle( color: Colors.black )
                  ),  
            );

  }


  void _actualizarDireccion(BuildContext contexto){

      final tamanoPhone = MediaQuery.of(contexto).size;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
      return Dialog(

        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0)), //this right here
        child: Container(

          decoration: BoxDecoration(
             borderRadius: BorderRadius.all(Radius.circular(20.0)),
             color: Colors.white
          ),
          height: tamanoPhone.height * 0.45,
          child:Column(
              children: <Widget>[
                   Text("Agregar referencia", style: TextStyle( color: Colors.black, fontSize: 25.0 ),),
                   SizedBox( height: 20.0, ),
                   Padding(
                     padding: EdgeInsets.symmetric( horizontal: 10.0 ),
                     child: _textFieldActualizarDireccion(contexto)
                    ),
                    SizedBox( height: 10.0, ),
                    _btnAceptar(contexto)
              ],
          ),
        ),
      );
    });
 }

  Widget _btnAceptar( BuildContext  contexto){

      return RaisedButton(
                    onPressed: (){
                              Navigator.pop(contexto);
                          },
                    child: Container(
                              child: Text("Listo"),
                              padding: EdgeInsets.symmetric( horizontal: 50.0, vertical: 15.0) 
                          ),
                      shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)
                            ),
                          elevation: 30.0,
                          color: Colores.COLOR_ROJISO_TEXTO_LOYALTY,
                          textColor: Colors.white,

                );

  }

   Widget _textFieldActualizarDireccion( BuildContext contexto){
      final provedorDeBloc = Provider.of(contexto);
      return TextField(  
                 style: TextStyle( color: Colors.black ), 
                 maxLines: 5, 
                 onChanged: (value){
                    this.direccionEditar = value;
                    provedorDeBloc.addDataToDireccionEditarDetalleComp(this.direccionEditar);
                    print('Direccion literal ${this.direccionEditar}');
                 },
                 decoration: InputDecoration(
                      border: new OutlineInputBorder(  
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                      enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black, width: 0.5),
                            ),  
                      hintText: "Agregar referencias o dirección mas exacta",
                      hintStyle: TextStyle( color: Colors.black )
                  ),  
            );

  }


  void _modoDePagoActualizar(BuildContext contexto){
      final provedorDeBloc = Provider.of(contexto);
      final tamanoPhone = MediaQuery.of(contexto).size;
      showDialog(
      context: context,
      builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0)), //this right here
        child: Container(
          decoration: BoxDecoration(
             borderRadius: BorderRadius.all(Radius.circular(20.0)),
             color: Colors.white
          ),
          height: tamanoPhone.height * 0.25,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView.builder(
                  itemCount: this.listaDeModoDePago.length,
                  itemBuilder: ( BuildContext contexto, int indice ){
                            return GestureDetector(
                                                  child:  Card(
                                                      elevation: 10.0,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Center(child: Text(this.listaDeModoDePago[indice])),
                                                      ) ,  
                                                  ),
                                                  onTap: (){
                                                        this.modoPagoEditar = this.listaDeModoDePago[indice];
                                                        print(this.modoPagoEditar);
                                                        provedorDeBloc.addDataToModoPago(this.modoPagoEditar);
                                                        Navigator.of(contexto).pop();
                                                  },
                                  );  
                  }
              ),
          ),
        ),
      );
    });
  } 

  _btnEnviarPedido(BuildContext contexto){

   return RaisedButton(
                              
                              onPressed:   () {

                                      _enviarAlaBaseDeDatos(contexto);

                                  } ,  
                             
                              child: Container(
                                    child: Text("Enviar pedido"),
                                    padding: EdgeInsets.symmetric( horizontal: 80.0, vertical: 15.0) 
                              ),
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)
                              ),
                              elevation: 30.0,
                              color: Colores.COLOR_ROJISO_TEXTO_LOYALTY,
                              textColor: Colores.COLOR_BLANCO_LOYALTY,
                          );

  }


   Future<Map<String, dynamic>> verificarConexion() async {

            Map<String, dynamic> resultadoDeVerificacion;
                   try {
                      final result = await InternetAddress.lookup('google.com');
                      if( result.isNotEmpty && result[0].rawAddress.isNotEmpty ){
                            resultadoDeVerificacion = {
                                Constantes.estado   : Constantes.respuesta_estado_ok,
                                Constantes.mensaje  : "conectado"
                            };
                      }else {
                        resultadoDeVerificacion = {
                                Constantes.estado   : Constantes.respuesta_estado_fail,
                                Constantes.mensaje  : "Por favor, revisar su conexion a internet"
                            };
                      }  
                   }catch(e ){

                        resultadoDeVerificacion = {
                                Constantes.estado   : Constantes.respuesta_estado_fail,
                                Constantes.mensaje  : "Por favor, revisar su conexion a internet"
                            };

                   }
        return resultadoDeVerificacion;
}


  _enviarAlaBaseDeDatos(BuildContext contexto){
      final provedorDeBloc = Provider.of(contexto);
       verificarConexion()
                                  .then((onValue){
                                        if( onValue[Constantes.estado] == Constantes.respuesta_estado_ok ){
                                       
                                           // print(this.mapaParaEnviarPorStream);
                                            provedorDeBloc.addDataToModoPagoLoading(true);
                                            /// traido desde el map
                                            
                                              CarritoProvider.enviarElCarrito(this.mapaConDetalles["latitud"],      
                                                                              this.mapaConDetalles["longitud"], this.modoPagoEditar, this.notaEditar )
                                                   .then((value) {
                                                            if( value[Constantes.estado] == Constantes.respuesta_estado_ok ){
                                                              DBProvider.db.deleteAll();
                                                               mostrarResultado(context, value[Constantes.mensaje], value["orden"].toString());
                                                                                                                                     
                                                                      }else {
                                                                       this.base.showSnackBar("Hubo un problema, vuelva a intentarlo", context, Colors.brown);
                                                              }
                                                              provedorDeBloc.addDataToModoPagoLoading(false);
                                                        });

                                            ///
                                       
                                            

                                        }else {
                                            final snackBar = SnackBar(
                                                content: Text('Revisar su conexion a internet'),
                                                backgroundColor: Colors.brown,
                                                );

                                              // Find the Scaffold in the widget tree and use it to show a SnackBar.
                                              Scaffold.of(contexto).showSnackBar(snackBar);
                                        }
                                  }); 
  }

   void mostrarResultado(BuildContext contexto, String mensaje, String orden){

      final tamanoPhone = MediaQuery.of(contexto).size;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
      return Dialog(

        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0)), //this right here
        child: Container(

          decoration: BoxDecoration(
             borderRadius: BorderRadius.all(Radius.circular(20.0)),
             color: Color.fromRGBO(102, 10, 11, 1.0)
          ),
          height: tamanoPhone.height * 0.45,
          child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: <Widget>[
                      SizedBox( height: 10, ),
                      Container(
                        width: tamanoPhone.width * 0.45,
                        height: tamanoPhone.width * 0.45,
                        child: Image(image: AssetImage("assets/imagenes/fondo_1100x652.png"))
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text( mensaje + " orden nro: "+ orden, textAlign: TextAlign.center,  style: TextStyle( color: Colors.white, ), ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric( horizontal: 10.0 ),
                        child: RaisedButton(
                     onPressed: (){
                            Navigator.of(contexto).popAndPushNamed(HomePage.nameOfPage);   
                     },     
                    child: Container(
                                child: Text("Listo de acuerdo"),
                                padding: EdgeInsets.symmetric( horizontal: 30.0, vertical: 15.0) 
                            ),
                        shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)
                              ),
                            elevation: 30.0,
                            color: Colores.COLOR_ROJISO_TEXTO_LOYALTY,
                            textColor: Colores.COLOR_BLANCO_LOYALTY,

                ),
                      ),
                     
               ],
          ),
        ),
      );
    });


  }

  Widget _detalleDeCompra(BuildContext contexto){
     final provedorDeBloc = Provider.of(contexto);
   return FutureBuilder<List<Pedido>>(
                  future: DBProvider.db.getAllPedidos(),
                  builder: ( BuildContext contextoBuild , AsyncSnapshot<List<Pedido>> asyncSnapshot ){
                      if( !asyncSnapshot.hasData ){
                          return Center(
                              child: this.base.retornarCircularCargando(Colors.brown),
                          );
                      }
                      if( asyncSnapshot.hasError ){
                            return Center(
                                  child: Text("Hubo un problema, por favor vuelve a intentarlo",
                                      style: TextStyle( fontSize: 20.0 )
                                  ),
                            );
                      }

                      if( asyncSnapshot.hasData ){
                          List<Pedido> listaDePedidos = asyncSnapshot.data;

                         if( listaDePedidos.length == 0){
                              return  Center(
                                  child: Text("Carrito vació", style: TextStyle( fontSize: 25.0 ) ),
                            );
                         }

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: listaDePedidos.length,
                                  itemBuilder: ( BuildContext contextoListView , int indice ){

                                       this.precioSubTotal += double.parse(listaDePedidos[indice].totalPorProducto);  
                                       provedorDeBloc.addDataToSubTotalDetalle(this.precioSubTotal);                                        

                                        return Column(
                                             mainAxisAlignment: MainAxisAlignment.start,
                                             crossAxisAlignment: CrossAxisAlignment.start, 
                                             children: <Widget>[
                                                  Text("Nombre del producto :      "+ listaDePedidos[indice].nombreProducto, style: TextStyle( fontSize: 15.0 ),),
                                                  Text("Precio unitario             :      "+" Bs."+ listaDePedidos[indice].precioUnitario, style: TextStyle( fontSize: 15.0 ),),
                                                  Text("Cantidad                       :      "+ listaDePedidos[indice].cantidad, style: TextStyle( fontSize: 15.0 ),),
                                                  Text("Total                              :      "+" Bs."+ listaDePedidos[indice].totalPorProducto, style: TextStyle( fontSize: 15.0 ),),
                                                  Divider(),
                                                  SizedBox( height: 10.0, )
                                             ],
                                        );
                                  }
                               
                               ),
                          );
                      }

                      return Center(
                              child: this.base.retornarCircularCargando(Colors.brown),
                         );
                  }
                );

  } 





}