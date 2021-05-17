import 'package:flutter/material.dart';
import 'package:weidling/blocs/bloc.dart';

export 'package:weidling/blocs/bloc.dart';

class Provider extends InheritedWidget {

  static Provider _instancia;
  factory Provider({ Key key, Widget child }) {
    if ( _instancia == null ) {
      _instancia = new Provider._internal(key: key, child: child );
    }
    return _instancia;
  }

  Provider._internal({ Key key, Widget child })
    : super(key: key, child: child );


  final blocLoyalty = BlocLoyalty();

  // Provider({ Key key, Widget child })
  //   : super(key: key, child: child );

 
  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  static BlocLoyalty of ( BuildContext context ) {
    return context.dependOnInheritedWidgetOfExactType<Provider>().blocLoyalty;
    
    // return ( context.inheritFromWidgetOfExactType(Provider) as Provider ).blocLoyalty;
    
    //return ( context.dependOnInheritedWidgetOfExactType() as Provider ).loginBloc;
  }

}