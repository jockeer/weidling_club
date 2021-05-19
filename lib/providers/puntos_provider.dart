import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/constantes.dart';

import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/models/cards.dart';
import 'package:weidling/models/cuenta_puntos.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/pages/login_page.dart';


class PuntosProvider {

  Map<String, dynamic> respuestaConDatos;
  final preferencias = new SharedPreferencesapp();
  VerificadorInternet verificadorInternet = new VerificadorInternet();

  void refrescarToken (BuildContext contexto) async{  //este metodo aqui en flutter es el mismo de hitRefreshUserSpecificAccessTokenApi() en el nativo
          final String base           = NetworkApp.Base;
          final String endPointLogin  = NetworkEndPointsApp.loginUser;
          Uri urlFinal = Uri.parse(base + endPointLogin);

          final http.Response respuesta = await http.post(urlFinal, 
              
                  body: {
                      Constantes.grant_type   : Constantes.refreshToken,
                      Constantes.client_id    : Constantes.stellar_app_user,
                      Constantes.refreshToken : this.preferencias.devolverValor(Constantes.refreshToken, "")
                  }

          );

        if( respuesta.statusCode == 200 ){

              try{

                    Map<String, dynamic> respuestaEnMap = respuesta.body as Map<String, dynamic>;
                     this.preferencias.agregarValor(Constantes.userSpecificToken, respuestaEnMap[Constantes.access_token]); 
                     this.preferencias.agregarValor(Constantes.refreshToken, respuestaEnMap[Constantes.refreshToken]);

              }catch( exepcion ){
                     this.preferencias.agregarValorBool(Constantes.is_refresh_token_expired, true); 
                     Navigator.of(contexto).pushReplacementNamed(
                          LoginPage.nameOfPage,
                          arguments: {
                              "fromHome"  : true,
                              "menssage"  : "Sesion expirada porfavor vuelve a iniciar sesion" 
                          }
                     );
              }

        }

  }

 Future< Map<String, dynamic> >  obtenerCuentaPuntos( BuildContext contexto ) async {

     String url                     = NetworkApp.Base + NetworkEndPointsApp.getCustomerPoint;
     String userSpecificAccessToken = this.preferencias.devolverValor(Constantes.userSpecificToken, "");
     url = url + "?access_token=" + userSpecificAccessToken;

   Map<String,dynamic> verificar = await  this.verificadorInternet.verificarConexion();

  if( verificar[Constantes.estado] != Constantes.respuesta_estado_ok ){
      return  this.respuestaConDatos = {
                              Constantes.estado  : Constantes.respuesta_estado_fail,
                              Constantes.mensaje :  Constantes.error_conexion
                          }; 
  }

      http.Response respuesta;

     try {
        respuesta  = await http.get(Uri.parse(url));
     } catch (e) {
      return  this.respuestaConDatos = {
                              Constantes.estado  : Constantes.respuesta_estado_fail,
                              Constantes.mensaje :  Constantes.error_conexion
                          };
     }

      if( respuesta.statusCode == HttpStatus.ok ){

              try{

                  Map<String, dynamic> respuestaEnMap = jsonDecode(  respuesta.body );

                  if( respuestaEnMap.containsKey(Constantes.status ) ){
                      if( respuestaEnMap[Constantes.status] as bool  ){

                             this.respuestaConDatos = {
                                Constantes.estado   : Constantes.respuesta_estado_ok,
                                Constantes.mensaje  : cuentaPuntosFromJson(respuesta.body)
                             };

                      }else {
                           if( respuestaEnMap[Constantes.error] == Constantes.expired_token  ){

                                refrescarToken(contexto);
                                if ( !this.preferencias.obtenerValorBool(Constantes.is_refresh_token_expired) ){
                                      obtenerCuentaPuntos(contexto);
                                }

                           }else {
                              this.respuestaConDatos = {
                              Constantes.estado  : Constantes.respuesta_estado_fail,
                              Constantes.mensaje :  "unknown problem"
                          };
                           }
                      }
                  } else {

                        this.respuestaConDatos = {
                                Constantes.estado  : Constantes.respuesta_estado_fail,
                                Constantes.mensaje : "Recibido false"   
                        };

                  } 

              }catch( error ){
                     this.respuestaConDatos = {
                                Constantes.estado  : Constantes.respuesta_estado_fail,
                                Constantes.mensaje : error.toString()  
                        };
              }


      } else {
           if( respuesta.statusCode == HttpStatus.requestTimeout ) {
                this.respuestaConDatos = {
                        Constantes.estado  : Constantes.respuesta_estado_fail,
                        Constantes.mensaje : Constantes.timeOutRquestNetwork 
                };
           }else {
                   this.respuestaConDatos = {
                        Constantes.estado  : Constantes.respuesta_estado_fail,
                        Constantes.mensaje : "Onother unknown problem."  
                };
           }
      }
    return this.respuestaConDatos;
}  



}