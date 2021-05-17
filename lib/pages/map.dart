

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/pages/modoPago.dart';
import 'package:weidling/providers/providers.dart';



class DireccionPage extends StatefulWidget {
   DireccionPage({Key key}) : super(key: key);
   static final nameOfPage = 'DireccionPage';


  @override
  _DireccionPageState createState() => _DireccionPageState();
}

class _DireccionPageState extends State<DireccionPage> {

   GoogleMapController mapController;
   var currentLocation;
   Base base;
   VerificadorInternet verificadorInternet;
   double latituded,longituded;
   String direccionLitera;

   //esto es del paquete de location
      Location location;
   //

  @override
  void initState() { 
    super.initState();
   
   this.base = Base();
   this.verificadorInternet = VerificadorInternet();
   this.latituded = 0.0;
   this.longituded = 0.0;
   this.direccionLitera = "Ninguna";
    
    //del paquete de location
    location = Location();
  ///

  }


  Future<LocationData> obtenerUbicacion() async{

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return Future.value(null);
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return Future.value(null);
        }
      }

    return  _locationData = await location.getLocation();

  }  


  void _ingresarDireccionLiteral(BuildContext contexto){

      final tamanoPhone = MediaQuery.of(contexto).size;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
      return Dialog(

        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0)), //this right here
        child: Container(

          decoration: BoxDecoration(
             borderRadius: BorderRadius.all(Radius.circular(20.0)),
             color: Colors.white
          ),
          height: tamanoPhone.height * 0.45,
          child:Column(
              children: <Widget>[
                   Text("Agregar referencia", style: TextStyle( color: Colors.black, fontSize: 25.0 ),),
                   SizedBox( height: 20.0, ),
                   Padding(
                     padding: EdgeInsets.symmetric( horizontal: 10.0 ),
                     child: _textFieldDireccion(contexto)
                    ),
                    SizedBox( height: 10.0, ),
                    _btnAceptar(contexto)
              ],
          ),
        ),
      );
    });


  }

  Widget _btnAceptar( BuildContext  contexto){

      return RaisedButton(
                    onPressed: (){
                              Navigator.pop(contexto);
                          },
                    child: Container(
                              child: Text("Listo"),
                              padding: EdgeInsets.symmetric( horizontal: 50.0, vertical: 15.0) 
                          ),
                      shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)
                            ),
                          elevation: 30.0,
                          color: Colores.COLOR_ROJISO_TEXTO_LOYALTY,
                          textColor: Colors.white,

                );

  }

  Widget _textFieldDireccion( BuildContext contexto){
      final provedorDeBloc = Provider.of(contexto);
      return TextField(  
                 style: TextStyle( color: Colors.black ), 
                 maxLines: 5, 
                 onChanged: (value){
                    this.direccionLitera = value;
                    print('Direccion literal ${this.direccionLitera}');
                 },
                 decoration: InputDecoration(
                      border: new OutlineInputBorder(  
                            borderRadius: const BorderRadius.all(
                              const Radius.circular(10.0),
                            ),
                          ),
                      enabledBorder: const OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black, width: 0.5),
                            ),  
                      hintText: "Agregar referencias o dirección mas exacta",
                      hintStyle: TextStyle( color: Colors.black )
                  ),  
            );

  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("ENVIO DE COMPRA"),
            centerTitle: true,
            actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only( right: 10 ),
                  child: Icon( Icons.shopping_cart ),
                ),
                
            ],  
        ),
        body: Column(
             children: <Widget>[
                Expanded(
                   child: FutureBuilder<LocationData>(
                      future: this.obtenerUbicacion(),
                      builder: ( BuildContext contextoBuilder , AsyncSnapshot<LocationData> asyncSnapshot){

                        if( !asyncSnapshot.hasData ){
                              return Center(
                                  child: this.base.retornarCircularCargando(Colores.COLOR_ROJISO_TEXTO_LOYALTY),
                              );
                        }else if( asyncSnapshot.data == null ){
                               return Center(
                                  child: this.base.retornarCircularCargando(Colores.COLOR_ROJISO_TEXTO_LOYALTY),
                              );
                        }else {
                            this.currentLocation = asyncSnapshot.data;
                            this.latituded = currentLocation.latitude;
                            this.longituded = currentLocation.longitude;
                             return  Stack(
                                 children: <Widget>[
                                      
                                      GoogleMap(
                                            initialCameraPosition: CameraPosition(target: LatLng(this.latituded,      
                                                    this.longituded), zoom: 18),
                                            onMapCreated: (GoogleMapController googleMapController){
                                                this.mapController = googleMapController;
                                            }, 
                                            onCameraMove:  ( CameraPosition position ){
                                                    this.latituded = position.target.latitude;
                                                    this.longituded = position.target.longitude;

                                                    print('Latitud ${this.latituded} y Logintud ${this.longituded}');  
                                            },
                                            myLocationButtonEnabled: true,
                                            myLocationEnabled: false,
                                            mapType: MapType.normal,
                                          ),
                                          Center(
                                          child: Icon(Icons.pin_drop, color: Colores.COLOR_ROJISO_TEXTO_LOYALTY),
                                      ),
                                          
                                         Align(
                                                       alignment: Alignment.bottomCenter,
                                                       child: Container(
                                                       width: double.infinity,
                                                       height: MediaQuery.of(context).size.height * 0.3 ,
                                                       color: Colors.white,
                                                       child: Column(
                                                           mainAxisAlignment: MainAxisAlignment.center,
                                                           children: <Widget>[
                                                               Text("¿Es esta tu ubicación?", textAlign: TextAlign.center,  style: TextStyle( color: Colores.COLOR_ROJISO_TEXTO_LOYALTY  ,fontSize: 20.0 ), ),
                                                               SizedBox( height: MediaQuery.of(context).size.height * 0.015, ),
                                                               Text("Necesitamos tu ubicación exacta para realizar el envió", textAlign: TextAlign.center ,style: TextStyle( fontSize: 15.0 ),),
                                                               SizedBox( height: MediaQuery.of(context).size.height * 0.015, ),
                                                               RaisedButton(
                                                                 onPressed: (){

                                                                    _ingresarDireccionLiteral(context);
                                                                   
                                                                 },
                                                                  child: Container(
                                                                       child: Text("Agregar dirección"),
                                                                       padding: EdgeInsets.symmetric( horizontal: 50.0, vertical: 15.0) 
                                                                  ),
                                                                shape: RoundedRectangleBorder(
                                                                       borderRadius: BorderRadius.circular(5.0)
                                                                      ),
                                                                    elevation: 30.0,
                                                                    color: Colores.COLOR_BLANCO_LOYALTY,
                                                                    textColor: Colores.COLOR_ROJISO_TEXTO_LOYALTY,
                                                                 ),
                                                               SizedBox( height: 5.0,),  
                                                               RaisedButton(
                                                                 onPressed: (){

                                                                      Navigator.of(context).pushNamed(ModoPago.nameOfPage,
                                                                        arguments: {
                                                                           "latitud"  : this.latituded ,
                                                                           "longitud" : this.longituded,
                                                                           "direccion_literal" : this.direccionLitera
                                                                        }
                                                                      );
                                                                   
                                                                 },
                                                                  child: Container(
                                                                       child: Text("Confirmar ubicación"),
                                                                       padding: EdgeInsets.symmetric( horizontal: 50.0, vertical: 15.0) 
                                                                  ),
                                                                shape: RoundedRectangleBorder(
                                                                       borderRadius: BorderRadius.circular(5.0)
                                                                      ),
                                                                    elevation: 30.0,
                                                                    color: Colores.COLOR_ROJISO_TEXTO_LOYALTY,
                                                                    textColor: Colores.COLOR_BLANCO_LOYALTY,
                                                                 ),
                                                           ],
                                                       ), 
                                                  ),
                                         ),
                                 ],
                             );
                        }

                      }
                     ),
                ),
             ],
        ),
    );
  }
}