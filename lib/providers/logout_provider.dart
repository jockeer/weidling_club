import 'dart:convert';
import 'package:weidling/helper_clases/constantes.dart';

import 'package:http/http.dart' as http;
import 'package:weidling/helper_clases/sharepreferences.dart';
class LogoutProvider {

  final preferencias = new SharedPreferencesapp();
  Map<String, dynamic> mapaADevolver;

 Future<bool>  logOutUser( ) async {

      final String base = NetworkApp.Base;
      final String endPointLogin = NetworkEndPointsApp.logoutUser;
      final Uri urlFinal = Uri.parse(base + endPointLogin);


  String accessToken = this.preferencias.devolverValor(Constantes.userSpecificToken, "");
      http.Response respuesta;
   try {

     respuesta  =  await http.post(
        urlFinal,
        body: {
              Constantes.access_token  : accessToken ,
        }
       );

     } catch (e) {
  
          return false;
   }


        
    
     
       return true;
        

       
   }  



}