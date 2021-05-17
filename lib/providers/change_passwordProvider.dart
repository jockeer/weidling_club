

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/constantes.dart';

import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/pages/login_page.dart';
class ChangePassProvider {

  final preferencias = new SharedPreferencesapp();
  Map<String, String> mapaADevolver;

  void refrescarToken (BuildContext contexto) async{  //este metodo aqui en flutter es el mismo de hitRefreshUserSpecificAccessTokenApi() en el nativo
          final String base           = NetworkApp.Base;
          final String endPointLogin  = NetworkEndPointsApp.loginUser;
          String urlFinal = base + endPointLogin;

          http.Response respuesta;

        try {
          
          respuesta  = await http.post(urlFinal, 
              
                  body: {
                      Constantes.grant_type   : Constantes.refreshToken,
                      Constantes.client_id    : Constantes.stellar_app_user,
                      Constantes.refreshToken : this.preferencias.devolverValor(Constantes.refreshToken, "")
                  }

          );

        } catch (e) {
          return;  
        }

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


 Future<Map<String, String>>  changePass( Map<String, String> parametros, BuildContext contexto ) async {

      final String base = NetworkApp.Base;
      final String endPointLogin = NetworkEndPointsApp.changePassword;
      final String urlFinal = base + endPointLogin;

      http.Response respuesta;    
    
      try {
            respuesta =  await http.post(
            urlFinal,
            body: parametros
          );
      } catch (e) {
         
          return   this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_fail,
                      Constantes.mensaje : "Unknow Problem",
                    };
      }


        try{
             final Map<String, dynamic> decodedData = json.decode(respuesta.body);
             if( decodedData[Constantes.status] as bool ){
                  this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_ok,
                      Constantes.mensaje : "Contraseña modificada con exito",
                  };
             }else {
                   
                   if( decodedData[Constantes.error] == Constantes.expired_token ){
                      refrescarToken(contexto); 
                      this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_fail,
                      Constantes.mensaje : decodedData[Constantes.message],
                    };  
                } else {
                     this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_fail,
                      Constantes.mensaje : "Unknow Problem",
                    };  
                }
             }
        }catch( e ){
              this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_fail,
                      Constantes.mensaje : "Unknown error(catch)"
                  };    
        }
    
     
       return this.mapaADevolver;
        

       
   }  



}