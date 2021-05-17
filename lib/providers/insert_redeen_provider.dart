import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/constantes.dart';

import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/models/cards.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/pages/login_page.dart';


class InsertRedeenProvider {

  Map<String, String > mapaADevolver;
  final preferencias = new SharedPreferencesapp();

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

 Future< Map<String, String> >  insertarRedencion( BuildContext contexto, String monto, String id_tienda ) async {

      this.mapaADevolver = new Map();
      final String base = NetworkApp.Base;
      final String endPointLogin = NetworkEndPointsApp.insertarRedencion;
       String urlFinal = base + endPointLogin ;

      String userSpecificToken = preferencias.devolverValor(Constantes.userSpecificToken, "");
      String tipo              = ( Theme.of(contexto).platform == TargetPlatform.iOS ) ? "IOS" : "ANDROID";
      
      
      http.Response respuesta;
      try {
        
            respuesta   =  await http.post(
                urlFinal, 
                body: {
                  "access_token" : userSpecificToken,
                  "Fields[1][id]": "20",
                  "Fields[0][id]": "13",
                  "Fields[0][content]" : id_tienda,
                  "Fields[1][content]" : monto,
                  "type"               : tipo  
                } 
              );

      } catch (e) {
        return this.mapaADevolver = {
                                         Constantes.estado  : Constantes.respuesta_estado_fail,
                                         Constantes.mensaje : "Por favor, vuelve a reintentarlo nuevamente" 
                                      };
      }

      if(respuesta.statusCode == 200){  ///todo ok
          try {

                final jsonRecibido =   jsonDecode(respuesta.body) as Map<String,dynamic>;
                if( !jsonRecibido[Constantes.status] as bool ){
                      if( jsonRecibido.containsKey(Constantes.error) ){
                              if( jsonRecibido[Constantes.error] == Constantes.expired_token ){
                                      refrescarToken(contexto);
                                      this.mapaADevolver = {
                                         Constantes.estado  : Constantes.respuesta_estado_fail,
                                         Constantes.mensaje : "Por favor, vuelve a reintentarlo nuevamente" 
                                      };

                              }else {
                                //aqui es un problema desconocido
                                this.mapaADevolver = {
                                         Constantes.estado  : Constantes.respuesta_estado_fail,
                                         Constantes.mensaje : "Unknow problem" 
                                      };
                              }


                      }else {

                        this.mapaADevolver = {
                                         Constantes.estado  : Constantes.respuesta_estado_fail,
                                         Constantes.mensaje : jsonRecibido[Constantes.message], 
                                  };

                                ///aqui es mas probable que sea false porque saldo es insuficiente

                      }

                }else {
                      this.mapaADevolver = {
                          Constantes.estado  : Constantes.respuesta_estado_ok,
                          Constantes.pin     : jsonRecibido["Pin"].toString(),
                      };
                }

          }catch( e ){
                //aqui es un problema desconocido
                print(e);
                this.mapaADevolver = {
                                         Constantes.estado  : Constantes.respuesta_estado_fail,
                                         Constantes.mensaje : "Unknow problem" 
                                      };
          } 

     
   } else {
      
         this.mapaADevolver = {
                                         Constantes.estado  : Constantes.respuesta_estado_fail,
                                         Constantes.mensaje : "Por favor revisar su conexion a internet" 
                                      };

   } 
      return this.mapaADevolver;
 }
 
  

}