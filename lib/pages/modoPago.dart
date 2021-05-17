

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/models/redencion_one.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/pages/redeem_two_page.dart';
import 'package:weidling/pages/ultimoPasoPedido.dart';
import 'package:weidling/providers/baseDeDatos/db_provider.dart';
import 'package:weidling/providers/carritoProvider.dart';
import 'package:weidling/providers/providers.dart';
import 'package:weidling/providers/redeen_one_provider.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ModoPago extends StatefulWidget {
  
   ModoPago({Key key}) : super(key: key);
   static final nameOfPage = "ModoPago";

  @override
  _ModoPagoState createState() => _ModoPagoState();
}

class _ModoPagoState extends State<ModoPago> {
   Map<String, String> mapaParaEnviarPorStream;
   bool internetAvaible = true;
   List<String> listaDePagos;
   Base       base;
   Map<String,dynamic> mapaLogintudLatidu;

   @override
   void initState() { 
     super.initState();
     this.listaDePagos = List();
     this.listaDePagos.add("Pagos Net");
     this.listaDePagos.add("ATC");
     this.listaDePagos.add("Efectivo");
     this.base = Base();
   }

  @override
  Widget build(BuildContext context) {
    this.mapaLogintudLatidu = ModalRoute.of(context).settings.arguments as Map;
    final provedorDeBloc = Provider.of(context);
    return Scaffold(
         body: StreamBuilder<bool>(
           stream: provedorDeBloc.streamModoPagoLoading,
           builder: (context, snapshot) {
             return ModalProgressHUD(
                    child: Stack(
                      children: <Widget>[
                            _fondo(),
                            _demasElementos( context )
                      ],
                     
               ),
               inAsyncCall: snapshot.data ?? false,
               color: Colors.white,
               dismissible: false,
               progressIndicator: CircularProgressIndicator(
                    valueColor:  new AlwaysStoppedAnimation<Color>(Colores.COLOR_ROJISO_TEXTO_LOYALTY),
               ), 
             );
           }
         ),
    );
  }

   Widget _demasElementos( BuildContext context ){

      return SafeArea(
              child: Column(
            children: <Widget>[
                  _menuArriba(context),
                   Expanded(
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric( horizontal: 15.0 ),
                        child: _contenedorOpciones(context)
                        )
                    ),
                    SizedBox( height: 20.0, )
            ],
        ),
      );

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

    Widget _contenedorOpciones( BuildContext context ){
      final tamanoPhone = MediaQuery.of(context).size;
          return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all( Radius.circular(10.0) )
              ),  
              padding: EdgeInsets.symmetric( horizontal: 15.0 ),
              width: tamanoPhone.width * 0.9,
              child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                            Text("Modo de pago", style: TextStyle( color: Colors.black,  fontSize: 35.0 ) , ),
                            SizedBox(  height: 15, ),
                            Text("Selecione...", style: TextStyle( color: Colors.black,  fontSize: 25.0 ) , ),
                            SizedBox( height: 30.0, ),
                           Expanded(child: _textFieldSeleccionar( context )),
                           _btnDialogNota(context),
                           SizedBox( height: 20.0, ), 
                           _btnEnviar(context) ,
                           SizedBox( height: 10.0, ) 
                      ],
              ),
          );
    }  

  Widget _btnDialogNota(BuildContext contexto){
        final provedorDeBloc = Provider.of(contexto);
       return StreamBuilder<Map<String,String>>(
         stream: provedorDeBloc.radioStream ,
         builder: (context, snapshot) {
           return Builder(
                    builder: ( BuildContext contextoRedeen ){
                      return    RaisedButton(
                          onPressed: (){
                                mostrarNota(contexto);
                          },
                    child: Container(
                              child: Text("Agregar nota"),
                              padding: EdgeInsets.symmetric( horizontal: 50.0, vertical: 15.0) 
                          ),
                      shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)
                            ),
                          elevation: 30.0,
                          color: Colors.white,
                          textColor: Colores.COLOR_ROJISO_TEXTO_LOYALTY,

                );
             } 
             
             );
         }
       );
   }  

  void mostrarNota(BuildContext contexto){
    
    final tamanoPhone = MediaQuery.of(contexto).size;
    showDialog(
      barrierDismissible: true,
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
          child: Column(
              children: <Widget>[
                   Text("Agregar nota", style: TextStyle( color: Colors.black, fontSize: 25.0 ),),
                   SizedBox( height: 20.0, ),
                   Padding(
                     padding: EdgeInsets.symmetric( horizontal: 10.0 ),
                     child: _textFieldNota(contexto)
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

  Widget _textFieldNota( BuildContext contexto){
      final provedorDeBloc = Provider.of(contexto);
      return TextField(  
                 style: TextStyle( color: Colors.black ), 
                 maxLines: 5, 
                 onChanged: (value){
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
                      hintText: "Nota...",
                      hintStyle: TextStyle( color: Colors.black )
                  ),  
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

   Widget _btnEnviar(BuildContext contexto){
        final provedorDeBloc = Provider.of(contexto);
       return StreamBuilder<Map<String,String>>(
         stream: provedorDeBloc.radioStream ,
         builder: (context, snapshot) {
           return Builder(
                    builder: ( BuildContext contextoRedeen ){
                      return    RaisedButton(
                          onPressed: ( snapshot.hasData ) ? (){


                              this.mapaLogintudLatidu.addAll({
                                   "nota" : ( provedorDeBloc.ultimoValorModoPagoNota != null && provedorDeBloc.ultimoValorModoPagoNota != "" ) ? provedorDeBloc.ultimoValorModoPagoNota : "vacio" ,
                                   "modo_pago" :  provedorDeBloc.ultimoValorSeleccionadoRadi["id"]
                              }); 

                              print(this.mapaLogintudLatidu);

                              Navigator.of(contexto).pushNamed(DetallePedido.nameOfPage,
                                  arguments: this.mapaLogintudLatidu
                              );

                            /*  verificarConexion()
                                  .then((onValue){
                                        if( onValue[Constantes.estado] == Constantes.respuesta_estado_ok ){
                                       
                                            print(this.mapaParaEnviarPorStream);
                                            provedorDeBloc.addDataToModoPagoLoading(true);
                                            /// traido desde el map
                                            
                                              CarritoProvider.enviarElCarrito(this.mapaLogintudLatidu["latitud"],      
                                                                              this.mapaLogintudLatidu["longitud"], provedorDeBloc.ultimoValorSeleccionadoRadi["id"], ( provedorDeBloc.ultimoValorModoPagoNota != null && provedorDeBloc.ultimoValorModoPagoNota != "" ) ? provedorDeBloc.ultimoValorModoPagoNota : "vacio" )
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
                                              Scaffold.of(contextoRedeen).showSnackBar(snackBar);
                                        }
                                  }); */

                    } : null,
                    child: Container(
                              child: Text("Siguiente"),
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
             
             );
         }
       );
   }

  Widget radioTile ( BuildContext contexto, int indice, String title, String value ) {
     final provedorDeBloc = Provider.of(contexto);
    return StreamBuilder<Map<String, String>>(
      stream: provedorDeBloc.radioStream,
      builder: (context, snapshot) {
        return Card(
              elevation: 10.0,
             child: RadioListTile(
                activeColor: Colors.brown,
                title: Text(title),
                value: value, 
                groupValue: (snapshot.data != null) ? snapshot.data["id"]   : "-1",
                onChanged: (value) {
                    this.mapaParaEnviarPorStream = {
                        "id"    : value,
                        "title" : title
                    };
                    provedorDeBloc.addDataToStreamRadioRedeen(this.mapaParaEnviarPorStream);
                }
            ),
        );
      }
    );
  }  

  Future< Map<String, dynamic> > obtenerOpciones(){
         RedeenOneProvider redeenOneProvider = new RedeenOneProvider();
        return verificarConexion()
            .then((valorRecibido){
                 if( valorRecibido[Constantes.estado] == Constantes.respuesta_estado_ok ){
                   this.internetAvaible = true;
                      return   redeenOneProvider.obtainOptionsRedeen();
                 }else {
                     this.internetAvaible = false;
                    return null;
                 }
            });

     }

   Widget _textFieldSeleccionar( BuildContext context ){
       
        Map<String, dynamic> respuesDesdeElprovider;
            return FutureBuilder(
                          future: obtenerOpciones(),  
                          builder: ( BuildContext contexto, AsyncSnapshot<Map<String, dynamic>> asyncSnapshot) {  
                              if( !asyncSnapshot.hasError && asyncSnapshot.hasData ){
                                     respuesDesdeElprovider = asyncSnapshot.data;
                                     if( respuesDesdeElprovider.containsKey(Constantes.estado) ){
                                        if( respuesDesdeElprovider[Constantes.estado] == Constantes.respuesta_estado_ok ){
                                               List<Option> opcionesLista =  (respuesDesdeElprovider[Constantes.mensaje] as RedencionOne).data;  
                                                 return  ListView.builder(
                                                    itemCount: this.listaDePagos.length,
                                                    itemBuilder: ( BuildContext contexto , int indice )  {
                                                         return radioTile(contexto, indice,this.listaDePagos[indice],this.listaDePagos[indice]);
                                                    }
                                              );
                                        }  else {
                                           return Center(child: Text("HUBO UN PROBLEMA VUELVA INTENTARLO"));
                                        }
                                     }    else {
                                       return Center(child: Text("HUBO UN PROBLEMA VUELVA INTENTARLO"));
                                     }     

                                 
                              }else {

                                    if( !this.internetAvaible ){
                                           return Center(child: Text("SIN CONEXION A INTERNET"));  
                                    }  

                                    if( asyncSnapshot.hasError ){
                                          return Center(child: Text("HUBO UN PROBLEMA VUELVA INTENTARLO"));
                                    }else {
                                       return Center( 
                                          child: CircularProgressIndicator( 
                                              valueColor: new AlwaysStoppedAnimation<Color>(Colors.brown),
                                           ),
                                        );
                                    }
                              }  

                          } ,
                       
            );      
    }

    Widget _fondo(){

          return Container(
              color: Colors.red,
              width: double.infinity,
              height: double.infinity,
              child:  Image( image: AssetImage("assets/imagenes/fondo_fridolin.jpg") , fit: BoxFit.cover,),
          );

    }

  Widget _menuArriba(BuildContext contexto){
     final tamanoPhone = MediaQuery.of(contexto).size;
     final provedorDeBloc = Provider.of(contexto);
      return Container(
        padding: EdgeInsets.symmetric( horizontal: 15.0 ),
        child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: <Widget>[
                 GestureDetector(
                       child: Icon(Icons.arrow_back_ios, color: Colors.white,),
                      onTap: () {
                          Navigator.of(contexto).pop();
                     },
                   ),
                 Container(
                           width: 200,
                           height: 139,
                           child: Image(
                                     image: AssetImage("assets/imagenes/logo_fridolin.png"),
                                  ),
                          ),
                 Icon(Icons.call, color: Colors.transparent,) 
             ],
        ),
      );
  }
}