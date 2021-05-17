import 'dart:async';

class Validador {
  

  //-------------------------- JOSE DEYBBIE------------------------------------------------------------------------


  final validarCI = StreamTransformer<String,String>.fromHandlers(
      handleData: ( String ultimoValorIngresadoEnCI, EventSink sink ){
           if( ultimoValorIngresadoEnCI.length >= 5 ){
              sink.add(ultimoValorIngresadoEnCI);
           }else{
                sink.addError("CI debe ser mayor a 5 caracteres");
           }
      }
  );
  
  final validarCINIT = StreamTransformer<String,String>.fromHandlers(
    handleData: (String ultimoValorIngresadorEnCINIT, EventSink sink){
        if ( ultimoValorIngresadorEnCINIT.length>=5){
          sink.add(ultimoValorIngresadorEnCINIT);
        }else{
          sink.addError("CI debe ser mayor a 5 caracteres");
        }
    }
  );


   final validarCelular = StreamTransformer<String,String>.fromHandlers(
    handleData: (String ultimoValorIngresadorEnCelular, EventSink sink){
        if ( ultimoValorIngresadorEnCelular.length>=5){
          sink.add(ultimoValorIngresadorEnCelular);
        }else{
          sink.addError("Celular debe ser mayor a 5 caracteres");
        }
    }
  );
  
  
  final validarEmail = StreamTransformer<String, String>.fromHandlers(
  handleData:  ( String email, EventSink<String> sink ) {
      Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp   = new RegExp(pattern);

      if ( regExp.hasMatch( email ) ) {
        sink.add( email );
      } else {
        sink.addError('Email no es correcto');
      }

   }
);

  final validarApellidoDetalleCuenta = StreamTransformer<String, String>.fromHandlers(
      handleData: ( String apellido , EventSink<String> sink ){
            if( apellido == "" ){
                sink.addError("Apellido no valido");
            }else {
                  sink.add(apellido);
            }
      }
  );

  final validarContrasenaActual = StreamTransformer<String, String>.fromHandlers(
      handleData: ( String apellido , EventSink<String> sink ){
            if( apellido == "" || apellido.length <= 5  ){
                sink.addError("Debe tener mínimo 6 caracteres");
            }else {
                  if( apellido.contains(" ") ){
                        sink.addError("Las contraseñas no deben tener espacio");
                  }else {
                        sink.add(apellido);
                  }
                  
            }
      }
  );

   final validarNombreDetalleCuenta = StreamTransformer<String, String>.fromHandlers(
      handleData: ( String apellido , EventSink<String> sink ){
            if( apellido == "" ){
                sink.addError("Nombre no valido");
            }else {
                  sink.add(apellido);
            }
      }
  );


   final validarTienda = StreamTransformer<String, String>.fromHandlers(
      handleData: ( String tienda , EventSink<String> sink ){
            if( tienda == "" ){
                sink.addError("Debe seleccionar una tienda");
            }else {
                  sink.add(tienda);
            }
      }
  );

   final validarMonto = StreamTransformer<String, String>.fromHandlers(
      handleData: ( String monto , EventSink<String> sink ){
           try {
            var montoEntero = int. parse(monto);
            if( montoEntero <= 0 ){
                  sink.addError("La cantidad debe ser mayor a cero");
            }   else {
                  sink.add(monto);
            }
           } catch (e) {

              try {
                  if( monto.length == 0 ){
                      sink.addError("Debe ingresar un monto");
                  }else {
                      sink.addError("No se aceptan caracteres extraños");
                  }
              } catch (e) {
                   sink.addError("No se aceptan caracteres extraños");
              }

             
           }
      }
  );


  final validarFechaNac = StreamTransformer<String,String>.fromHandlers(
      handleData: ( String fechaNac , EventSink<String> sink ){

          if( fechaNac == "" ){
              sink.addError("Fecha no es correcta");
          }else{
            sink.add(fechaNac);
          }

      }
  );


final validarPin = StreamTransformer<String, String>.fromHandlers(
  handleData:  ( String email, EventSink<String> sink ) {
     
        if( email != "" ){
           if( email.length == 4 ){
                sink.add(email);
           } else {
                sink.addError("El número pin tiene 4 digitos");
           }
        }

   }
);
 


final validarStreamRefreshing = StreamTransformer<bool,bool>.fromHandlers(
     handleData: ( bool newValue, EventSink sink ) {
            sink.add(newValue);
     }
);

  final validarLastName = StreamTransformer<String, String>.fromHandlers(
    handleData: (String lastname, EventSink sink){
        sink.add(lastname);
    }
  );


//-----------------------------------------------------------------------------------------------------------------------------

final validarContrasena = StreamTransformer<String,String>.fromHandlers(
    handleData: (String valorNuevoIngresadoPassword, EventSink sink ){
          if(valorNuevoIngresadoPassword.length >= 6){
              sink.add(valorNuevoIngresadoPassword);
          }else{
            sink.addError("Debe contener mínimo 6 caracteres");
          }
    }
);

final validarCodigoConsultoria = StreamTransformer<String,String>.fromHandlers(
      handleData: ( String consultoria , EventSink sink){
             if( consultoria != "" ){
                sink.add(consultoria);
              }else {
                 sink.addError("Código no debe quedar vació");
              }
      }
);

final validaNumeroCelular = StreamTransformer<String,String>.fromHandlers(
     handleData: ( String newVal, EventSink sink ){
       
       if( newVal != "" ){
           String primerCaracter = newVal[0];
        if( primerCaracter == "7" || primerCaracter == "6" ){
              sink.add(newVal);
        }else{
             sink.addError("Debe empezar con 7 o 6");
        }
       }
     }
);

///from jose
final validarName = StreamTransformer<String, String>.fromHandlers(
    handleData: (String name, EventSink sink ){
        sink.add(name);
    }
  );

  
////

}

