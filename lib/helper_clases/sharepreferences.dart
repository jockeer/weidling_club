
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesapp {

  static final SharedPreferencesapp _singleton = new SharedPreferencesapp._init();

  factory SharedPreferencesapp(){
      return _singleton;
  }
  SharedPreferences _prefs ;
    
  SharedPreferencesapp._init();

  inicializarPreferencias() async{
    _prefs = await SharedPreferences.getInstance();
      
  }
   /// metodos para agregar y quitar valores
   /// 
    
  void agregarValor(String key, String value){
      _prefs.setString(key, value);
  }
      
  String devolverValor(String key, String valorDefault){
       return ( _prefs.getString(key) ) ?? valorDefault;
  }
  void agregarValorBool( String key, bool valor ){
       _prefs.setBool(key, valor);
  }
  bool obtenerValorBool(String key){
      return _prefs.getBool(key);
  }


       

}