import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/pages/login_page.dart';

class UpdateUserProvider {

  final preferencias = new SharedPreferencesapp();
  Map<String, dynamic> mapaADevolver;

 Future<Map<String, dynamic>>  registerUser( Map<String, String> parametros , BuildContext contexto ) async {

      final String base = NetworkApp.Base;
      final String endPointLogin = NetworkEndPointsApp.modificarUsuario;
      final String urlFinal = base + endPointLogin;

      http.Response respuesta;    
       
       try {

       respuesta =  await http.post(
        urlFinal,
        body: parametros
       );

       } catch (e) {
       
         return  this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_fail,
                      Constantes.mensaje : "Catch error",
                  };

       }


        try{
             final Map<String, dynamic> decodedData = json.decode(respuesta.body);
             if( decodedData[Constantes.status] as bool ){
                  this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_ok,
                      Constantes.mensaje : "La modificacion fue exitosa",
                  };
             }else {

                   if(decodedData[Constantes.error] == Constantes.expired_token){
                         
                          ///desde aqui para recupearar token
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

                            registerUser( parametros, contexto);

                          /////


                   } else {

                      this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_fail,
                      Constantes.mensaje : decodedData[Constantes.message]
                      }; 
                   }

                  
             }
        }catch( e ){
              this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_fail,
                      Constantes.mensaje : "Unknown error"
                  };    
        }
    
     
       return this.mapaADevolver;
        

       
   }

   

  


}