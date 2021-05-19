import 'dart:convert';
import 'dart:io';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';


class  ObtainPinProvider {

 

 
 static Future<Map<String, dynamic>>  obtainPin(String ciUserParam, String userSpecificToken) async {

         Map<String, dynamic> mapaResultadoADevolver;

       final String base = NetworkApp.Base;
       final String endPointLogin = NetworkEndPointsApp.obtenerPin;
       Uri urlFinal = Uri.parse(base + endPointLogin) ;

       String ciUser      =   ciUserParam;
       String accessToke  =   userSpecificToken; 

        http.Response respuesta;
      
      try {

          respuesta =  await http.post(
        urlFinal,
        body: {
           "ci_customer" :  ciUser ,
           "access_token":  accessToke,  
        }
       );

      } catch (e) {
        return  mapaResultadoADevolver = {
                      Constantes.estado   : Constantes.respuesta_estado_fail,
                      Constantes.mensaje  : "No hay redencion"
                    }; 
      }

      if(respuesta.statusCode == 200){  ///todo ok

          try {

                    final decodedata = jsonDecode(respuesta.body);
                    if( decodedata[Constantes.status] as bool ){
                             mapaResultadoADevolver = {
                                  Constantes.estado   : Constantes.respuesta_estado_ok,
                                  Constantes.mensaje  : "Pin encontrado",
                                  Constantes.pin      : decodedata[Constantes.message]  
                           };  
                    }else {
                           mapaResultadoADevolver = {
                      Constantes.estado   : Constantes.respuesta_estado_fail,
                      Constantes.mensaje  : "No hay redencion"
                    }; 
                    }    
             
          } catch (e) {
               mapaResultadoADevolver = {
                      Constantes.estado   : Constantes.respuesta_estado_fail,
                      Constantes.mensaje  : "No hay redencion"
                    }; 
          }

      } else {
            final decodedata = jsonDecode(respuesta.body);
          if ( respuesta.statusCode == HttpStatus.requestTimeout ) {
                   mapaResultadoADevolver = {
                      Constantes.estado   : Constantes.respuesta_estado_fail,
                      Constantes.mensaje  : "Tiempo de espera excedido, por favor revisar su conexion"
              };  
          } else {
                  
                   if( decodedata[Constantes.status] as bool ){
                             mapaResultadoADevolver = {
                                  Constantes.estado   : Constantes.respuesta_estado_ok,
                                  Constantes.mensaje  : "Pin encontrado",
                                  Constantes.pin      : decodedata[Constantes.message]  
                           };  
                    }else {
                           mapaResultadoADevolver = {
                            Constantes.estado   : Constantes.respuesta_estado_fail,
                            Constantes.mensaje  : "No hay redencion"
                          }; 
                    } 
          }
        }
      

  return mapaResultadoADevolver;
}

}