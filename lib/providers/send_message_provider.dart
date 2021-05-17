

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:http/http.dart' as http;
import 'package:weidling/pages/login_page.dart';

class SendMessageProvider {

   final preferencias = new SharedPreferencesapp();
   Map<String,String> mapaRespuesta;


     void refrescarToken (BuildContext contexto) async{  //este metodo aqui en flutter es el mismo de hitRefreshUserSpecificAccessTokenApi() en el nativo
          final String base           = NetworkApp.Base;
          final String endPointLogin  = NetworkEndPointsApp.loginUser;
          String urlFinal = base + endPointLogin;

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


   Future<Map<String,String>> enviarMensaje(String mensajeAEnviar, BuildContext context) async {
        this.mapaRespuesta = new Map();
        String userSpecificAccessToken = this.preferencias.devolverValor(Constantes.userSpecificToken, "");

        String urlFinal = NetworkApp.Base + NetworkEndPointsApp.sendMessageFromContact;
        http.Response respuesta;
        
        try {
          respuesta  =  await http.post(
          urlFinal,
           body: {
             "message"        : mensajeAEnviar,
             "access_token"   : userSpecificAccessToken
           }
          );
          } catch (e) {
             this.mapaRespuesta.addAll({
                                "estado"                : "incorrecto",
                                "mensaje_del_servidor"  : "catch error",
                        });     
                   return this.mapaRespuesta;     
        }

       if( respuesta.statusCode == HttpStatus.ok ){
            try{

                String x = respuesta.body;
               final Map<String, dynamic> respuestaEnMap = json.decode(respuesta.body);
                if( respuestaEnMap.containsKey(Constantes.status) ){
                    if ( respuestaEnMap[Constantes.status] as bool == true ){
                        this.mapaRespuesta.addAll({
                                "estado"                : "correcto",
                                "mensaje_del_servidor"  : respuestaEnMap[Constantes.message],
                        });
                    } else {
                        this.mapaRespuesta.addAll({
                                "estado"                : "incorrecto",
                                "mensaje_del_servidor"  : respuestaEnMap[Constantes.message],
                        }); 
                    }
                } else {
                     if( respuestaEnMap.containsKey(Constantes.error) ){
                            if( respuestaEnMap[Constantes.error] == Constantes.expired_token ){
                                  refrescarToken(context);
                                  enviarMensaje(mensajeAEnviar, context);
                            }
                     }
                } 

            }catch( e ){
                      this.mapaRespuesta.addAll({
                                "estado"                : "incorrecto",
                                "mensaje_del_servidor"  : "Mal formato, recibido",
                        }); 
            }

       } else {
            if( respuesta.statusCode == HttpStatus.requestTimeout ){
                    this.mapaRespuesta.addAll({
                                "estado"                : "incorrecto",
                                "mensaje_del_servidor"  : "Por favor, revisa tu conexion a internet",
                        }); 
            }else {
                 this.mapaRespuesta.addAll({
                                "estado"                : "incorrecto",
                                "mensaje_del_servidor"  : "Error desconocido, vuelve a intentarlo",
                        });   
            }
       }
    return this.mapaRespuesta;
   }

}