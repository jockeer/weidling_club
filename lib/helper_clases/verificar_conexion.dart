

import 'dart:io';
import 'constantes.dart';

class VerificadorInternet{


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

}