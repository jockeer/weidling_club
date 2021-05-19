

import 'dart:convert';
import 'package:weidling/helper_clases/constantes.dart';

import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
class RegisterProvider {

  final preferencias = new SharedPreferencesapp();
  Map<String, dynamic> mapaADevolver;

 Future<Map<String, dynamic>>  registerUser( Map<String, String> parametros ) async {

      final String base = NetworkApp.Base;
      final String endPointLogin = NetworkEndPointsApp.registrarUser;
      final Uri urlFinal = Uri.parse(base + endPointLogin);

    http.Response respuesta;    
    
    try {
      respuesta =  await http.post(
        urlFinal,
        body: parametros
       );
    } catch (e) {
       return this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_fail,
                      Constantes.mensaje : "Unknown error"
               };  
            }

        try{
             final Map<String, dynamic> decodedData = json.decode(respuesta.body);
             if( decodedData[Constantes.status] as bool ){
                  this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_ok,
                      Constantes.mensaje : "Registro realizado con exito",
                      Constantes.pin     :  decodedData["Pin"]
                  };
             }else {
                   this.mapaADevolver  = {
                      Constantes.estado  : Constantes.respuesta_estado_fail,
                      Constantes.mensaje : decodedData[Constantes.message]
                  };
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