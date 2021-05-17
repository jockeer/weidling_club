import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/constantes.dart';

import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/models/cards.dart';
import 'package:weidling/models/heper_tienda.dart';
import 'package:weidling/models/tienda.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/pages/login_page.dart';


class TiendasProvider {

  List<TiendaInfo> listaDeTiendas;
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

 Future< Map<String,dynamic> >  obtenerTiendas( BuildContext contexto , String idSeleccionado) async {

      this.listaDeTiendas = new List();
      Map<String,dynamic>    mapaADevolver = new Map<String,String>();
      final String base = NetworkApp.Base;
      final String endPointLogin = NetworkEndPointsApp.obtainTienda;
       String urlFinal = base + endPointLogin ;

      String userEspecificParametro = preferencias.devolverValor(Constantes.userSpecificToken, "");
      final String parteEndUrl = "?access_token="+ userEspecificParametro+"&id_option="+idSeleccionado;

      urlFinal = urlFinal + parteEndUrl;
       http.Response respuesta ;
      
      try {
        respuesta =  await http.get(
              urlFinal
            );
      } catch (e) {
          return  mapaADevolver = {
                          Constantes.estado  : Constantes.respuesta_estado_fail,
                          Constantes.mensaje : "Por favor, vuelve a intentarlo"
                    };
      }

      if(respuesta.statusCode == 200){  ///todo ok
          try {

                Tienda tienda = tiendaFromJson(respuesta.body);
                if( tienda.status ){
                     
                      if( tienda.data[0].data.length == 0 ){
                             mapaADevolver = {
                                Constantes.estado  : Constantes.respuesta_estado_fail,
                                Constantes.mensaje : tienda.message
                          };   
                      }else {
                            mapaADevolver = {
                                Constantes.estado  : Constantes.respuesta_estado_ok,
                                Constantes.mensaje : subTiendaFromJson(jsonEncode(tienda.data[0])).data
                          };   
                      }  

                } else {
                    refrescarToken(contexto);
                    mapaADevolver = {
                          Constantes.estado  : Constantes.respuesta_estado_fail,
                          Constantes.mensaje : "Por favor, vuelve a intentarlo"
                    };

                }


          } catch (e) {
             mapaADevolver = {
                          Constantes.estado  : Constantes.respuesta_estado_fail,
                          Constantes.mensaje : "When get store, catch entry"
                    };
          }

      } else {
          if ( respuesta.statusCode == HttpStatus.requestTimeout ) {
                   mapaADevolver = {
                          Constantes.estado  : Constantes.respuesta_estado_fail,
                          Constantes.mensaje : "Por favor, revisa tu conexion a internet. TIMEOUT"
                    };
          } else {
                  mapaADevolver = {
                          Constantes.estado  : Constantes.respuesta_estado_fail,
                          Constantes.mensaje : "UNKNOW PROBLEM"
                    };
          }
      }

       
      print(mapaADevolver);
     return mapaADevolver; 
   }  



}