import 'dart:convert';
import 'dart:io';

import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/models/pedido.dart';
import 'package:weidling/providers/baseDeDatos/db_provider.dart';
import 'package:http/http.dart' as http;
class CarritoProvider{

    static Future<Map<String,dynamic>> enviarElCarrito(double latitud, double longitud, String modoPago, String nota) async {

          print("latitud :" + latitud.toString() );
          print("longitud :"+ longitud.toString());
          
          final preferencias = SharedPreferencesapp();
          List<Pedido> listaDePedidos  = await  DBProvider.db.getAllPedidos();
          Map<String, dynamic> mapaAEnviar = new Map<String, dynamic>();

                    List<Map<String, dynamic>> listaParaParametro = List();

                    for (var pedido in listaDePedidos) {
                          listaParaParametro.add({
                               "id"               : "${pedido.id}",
                               "precio_unitario"  : "${pedido.precioUnitario}",
                               "cantidad"         : "${pedido.cantidad}",
                               "total_producto"   : "${pedido.totalPorProducto}"
                          });
                    }
             
                    mapaAEnviar = {
                        "ci_customer"        : preferencias.devolverValor(Constantes.ciUser, ""),
                        "price_delivery" : "15 Bs",
                        "description_order" : nota,
                        "latitude_order"    : latitud.toString(),
                        "longitude_order"   : longitud.toString(),
                        "type_payment_order" : modoPago,
                        "detail_order"      : json.encode(listaParaParametro) 
                    };

                    print(json.encode(mapaAEnviar));
                    Map<String,dynamic> respuesta = await enviarAlServidor(mapaAEnviar);
 
                   return new Future<Map<String,dynamic>>.value(respuesta);
      

    }

    static enviarAlServidor(Map<String, dynamic> parametros) async {
        Map<String, dynamic> mapaADevolverTwo = Map();
        final String base = NetworkApp.Base;
                    final String endPointLogin = NetworkEndPointsApp.enviarCarritoDeCompra;
                    final Uri urlFinal = Uri.parse(base + endPointLogin);

                    http.Response respuesta;    
                    try {
                        respuesta =  await http.post(
                              urlFinal,
                              body: parametros
                            );
                    } catch (e) {
                          print("error :"+e.toString() );
                    }

                     if( respuesta.statusCode == HttpStatus.ok ){

                        try{

                            Map<String, dynamic> respuestaEnMap = jsonDecode(  respuesta.body );

                            if( respuestaEnMap.containsKey("status") ){
                                if( respuestaEnMap["status"] as bool ){
                                    mapaADevolverTwo = {
                                        Constantes.estado  : Constantes.respuesta_estado_ok,
                                        Constantes.mensaje : respuestaEnMap["message"],
                                        "orden"            : respuestaEnMap["id_order"] 
                                    };
                                }else {
                                       mapaADevolverTwo = {
                                        Constantes.estado  : Constantes.respuesta_estado_fail,
                                        Constantes.mensaje : respuestaEnMap["message"] 
                                    };
                                }
                            } else {

                                   mapaADevolverTwo = {
                                        Constantes.estado  : Constantes.respuesta_estado_fail,
                                        Constantes.mensaje : "fatal error"
                                    };
                            } 

                        }catch( error ){
                                mapaADevolverTwo = {
                                        Constantes.estado  : Constantes.respuesta_estado_fail,
                                        Constantes.mensaje : "fatal error"
                                    }; 
                        }


              } else {
                  if( respuesta.statusCode == HttpStatus.requestTimeout ) {
                           mapaADevolverTwo = {
                                        Constantes.estado  : Constantes.respuesta_estado_fail,
                                        Constantes.mensaje : "Tiempo excedido"
                                    };
                  }else {

                            mapaADevolverTwo = {
                                        Constantes.estado  : Constantes.respuesta_estado_fail,
                                        Constantes.mensaje : "Unknow error"
                                    };
                  }
              }

              return mapaADevolverTwo;
    }

}