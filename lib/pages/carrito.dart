
import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/models/pedido.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/pages/map.dart';
import 'package:weidling/providers/baseDeDatos/db_provider.dart';
import 'package:weidling/providers/providers.dart';
import 'package:flutter/material.dart';


class CarritoPage extends StatefulWidget {
  CarritoPage({Key key}) : super(key: key);
  static final nameOfPage = "CarritoPage";
  @override
  _CarritoPageState createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {

  Base base;
  VerificadorInternet verificadorInternet;

    final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    this.base = Base();
    this.verificadorInternet = VerificadorInternet();


  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldkey,
        body: Stack(
             children: <Widget>[
                  _fondo(),
                  _demasElementos( context )
             ],
         ),
    );
  }

  Widget _contenedorOpciones( BuildContext context ){
      final tamanoPhone = MediaQuery.of(context).size;
          return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all( Radius.circular(10.0) )
              ),  
              padding: EdgeInsets.symmetric( horizontal: 15.0 ),
              width: tamanoPhone.width * 0.9,
              child: Column(
                   children: <Widget>[
                       Text("Carrito de compra", style: TextStyle( fontSize: 30.0 ),),
                       SizedBox( height: 20.0, ),
                       Expanded(child: _detalleDeCompra()),
                       _btnEnviarCompra(context),
                      SizedBox( height: 20.0, )
                   ],  
                ),
            );
    } 

  Widget _btnEnviarCompra(BuildContext contexto){

    return    RaisedButton(
                     onPressed: (){

                        DBProvider.db.getAllPedidos()
                          .then((value) {
                              if( value.isEmpty ){
                                    
                                    this._scaffoldkey.currentState.showSnackBar(
                                      SnackBar(content: Text("No tiene elementos para la compra"), backgroundColor: Colors.brown,)
                                    );
                              }else {
                                Navigator.of(contexto).pushNamed(DireccionPage.nameOfPage); 
                              }
                          });

                            
                     },     
                    child: Container(
                              child: Text("Comprar"),
                              padding: EdgeInsets.symmetric( horizontal: 80.0, vertical: 15.0) 
                          ),
                      shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0)
                            ),
                          elevation: 30.0,
                          color: Colores.COLOR_ROJISO_TEXTO_LOYALTY,
                          textColor: Colores.COLOR_BLANCO_LOYALTY,

                );

  }  

  Widget _detalleDeCompra(){

   return FutureBuilder<List<Pedido>>(
                  future: DBProvider.db.getAllPedidos(),
                  builder: ( BuildContext contextoBuild , AsyncSnapshot<List<Pedido>> asyncSnapshot ){
                      if( !asyncSnapshot.hasData ){
                          return Center(
                              child: this.base.retornarCircularCargando(Colors.brown),
                          );
                      }
                      if( asyncSnapshot.hasError ){
                            return Center(
                                  child: Text("Hubo un problema, por favor vuelve a intentarlo",
                                      style: TextStyle( fontSize: 20.0 )
                                  ),
                            );
                      }

                      if( asyncSnapshot.hasData ){
                          List<Pedido> listaDePedidos = asyncSnapshot.data;

                         if( listaDePedidos.length == 0){
                              return  Center(
                                  child: Text("Carrito vació", style: TextStyle( fontSize: 25.0 ) ),
                            );
                         }

                          return ListView.builder(
                                 itemCount: listaDePedidos.length,
                                itemBuilder: ( BuildContext contextoListView , int indice ){
                                      return Column(
                                           mainAxisAlignment: MainAxisAlignment.start,
                                           crossAxisAlignment: CrossAxisAlignment.start, 
                                           children: <Widget>[
                                                Text("Nombre del producto :      "+ listaDePedidos[indice].nombreProducto, style: TextStyle( fontSize: 15.0 ),),
                                                Text("Precio unitario             :      "+" Bs."+ listaDePedidos[indice].precioUnitario, style: TextStyle( fontSize: 15.0 ),),
                                                Text("Cantidad                      :      "+ listaDePedidos[indice].cantidad, style: TextStyle( fontSize: 15.0 ),),
                                                Text("Total                             :      "+" Bs."+ listaDePedidos[indice].totalPorProducto, style: TextStyle( fontSize: 15.0 ),),
                                                Divider(),
                                                SizedBox( height: 10.0, )
                                           ],
                                      );
                                }
                             
                             );
                      }

                      return Center(
                              child: this.base.retornarCircularCargando(Colors.brown),
                         );
                  }
                );

  }  

  Widget _demasElementos( BuildContext context ){

      return SafeArea(
              child: Column(
            children: <Widget>[
                  _menuArriba(context),
                   Expanded(
                      child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.symmetric( horizontal: 15.0 ),
                        child: _contenedorOpciones(context)
                        )
                    ),
                    SizedBox( height: 20.0, )
            ],
        ),
      );

   }  

  Widget _menuArriba(BuildContext contexto){
     final tamanoPhone = MediaQuery.of(contexto).size;
     final provedorDeBloc = Provider.of(contexto);
      return Container(
        padding: EdgeInsets.symmetric( horizontal: 15.0 ),
        child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             crossAxisAlignment: CrossAxisAlignment.start,
             children: <Widget>[
                 GestureDetector(
                       child: Icon(Icons.arrow_back_ios, color: Colors.white,),
                      onTap: () {
                          Navigator.of(contexto).popAndPushNamed(HomePage.nameOfPage);
                     },
                   ),
                 Container(
                           width: 200,
                           height: 139,
                           child: Image(
                                     image: AssetImage("assets/imagenes/logo_fridolin.png"),
                                  ),
                          ),
                 Icon(Icons.call, color: Colors.transparent,) 
             ],
        ),
      );
  }

  Widget _fondo(){

          return Container(
              color: Colors.red,
              width: double.infinity,
              height: double.infinity,
              child:  Image( image: AssetImage("assets/imagenes/fondo_fridolin.jpg") , fit: BoxFit.cover,),
          );

    }

}