import 'package:weidling/blocs/transformers.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class BlocLoyalty with Validador {
  //Stream para direccion  en detalle de pedidos

  final _streamControllerDireccionEditarDetalleCompr =
      BehaviorSubject<String>();
  Stream<String> get streamDireccionEditarDetalleCompr =>
      _streamControllerDireccionEditarDetalleCompr.stream;
  Function(String) get addDataToDireccionEditarDetalleComp =>
      _streamControllerDireccionEditarDetalleCompr.sink.add;
  String get ultimoValorDireccionEditarDetalleComp =>
      _streamControllerDireccionEditarDetalleCompr.value;

  ///Stream para el subTotal

  final _streamControllerSubTotalDetalle = BehaviorSubject<double>();
  Stream<double> get streamSubTotalDetalle =>
      _streamControllerSubTotalDetalle.stream;
  Function(double) get addDataToSubTotalDetalle =>
      _streamControllerSubTotalDetalle.sink.add;
  double get ultimoValorDeSubTotalDetalle =>
      _streamControllerSubTotalDetalle.value;

  ///
  ///Nota del modo de pago

  final _streamControllerNotaModoPago = BehaviorSubject<String>();
  Stream<String> get streamNotaModoPago => _streamControllerNotaModoPago.stream;
  Function(String) get addDataToModoPagoNota =>
      _streamControllerNotaModoPago.sink.add;
  String get ultimoValorModoPagoNota => _streamControllerNotaModoPago.value;

  ///
  ///loading para el modo de pago
  final _streamControllerLoadingModoPago = BehaviorSubject<bool>();
  Stream<bool> get streamModoPagoLoading =>
      _streamControllerLoadingModoPago.stream;
  Function(bool) get addDataToModoPagoLoading =>
      _streamControllerLoadingModoPago.sink.add;
  bool get ultimoValorModoPagoLoading => _streamControllerLoadingModoPago.value;

  ///

  ///essto es el stream para el modo de pago

  final _streamControllerModoDePagoSelecc = BehaviorSubject<String>();
  Stream<String> get streamModoPagoSelec =>
      _streamControllerModoDePagoSelecc.stream;
  Function(String) get addDataToModoPago =>
      _streamControllerModoDePagoSelecc.sink.add;
  String get ultimoValorModoPago => _streamControllerModoDePagoSelecc.value;

  ///
  ///

  //esto es el stream para verificar si cantidad de elementos elegidos es mayor a cero

  final _streamControllerCantidadMayorACero = BehaviorSubject<bool>();
  Stream<bool> get streamCantidadMAyorACero =>
      _streamControllerCantidadMayorACero.stream;
  Function(bool) get addDataToCantidadMAyorACero =>
      _streamControllerCantidadMayorACero.sink.add;
  bool get ultimoValorCantidadMayorACero =>
      _streamControllerCantidadMayorACero.value;

  ////

  ///esto es el stream para la cantidad de articulos que se selecciona

  final _streamControllerUnidadesDialog = BehaviorSubject<int>();
  Stream<int> get streamUnidadesDialog =>
      _streamControllerUnidadesDialog.stream;
  Function(int) get addDataToUnidadesDialog =>
      _streamControllerUnidadesDialog.sink.add;
  int get ultimoValorUnidadesDialog => _streamControllerUnidadesDialog.value;
  //

  ///esto es el stream para la verficacion constante de los puntos

  final _streamControllerPuntosAct = BehaviorSubject<String>();
  Stream<String> get streamActualizarPuntos =>
      _streamControllerPuntosAct.stream;
  Function(String) get addDataToPuntosActualizar =>
      _streamControllerPuntosAct.sink.add;
  String get ultimoValorPuntosActualizar => _streamControllerPuntosAct.value;

  ///

  // TODO ESTO ES STREAMINGS DE LA PANTALLA DE REDENCION DOS
  final _streamControllerLoadingRedeenTwo = BehaviorSubject<bool>();
  Stream<bool> get streamLoadingReedenTwo =>
      _streamControllerLoadingRedeenTwo.stream;
  Function(bool) get addDataToLoadingReedenTwo =>
      _streamControllerLoadingRedeenTwo.sink.add;
  bool get ultimoValorLoadingRedeenTwo =>
      _streamControllerLoadingRedeenTwo.value;

  final _streamControllerTiendaRedeenTwo = BehaviorSubject<String>();
  Stream<String> get streamTiendaRedeenTwo =>
      _streamControllerTiendaRedeenTwo.stream.transform(validarTienda);
  Function(String) get addDataToTiendaRedeenTwo =>
      _streamControllerTiendaRedeenTwo.sink.add;
  String get ultimoValorTiendaRedeenTwo =>
      _streamControllerTiendaRedeenTwo.value;

  final _streamControllerMontoRedeenTwo = BehaviorSubject<String>();
  Stream<String> get streamMontoRedeenTwo =>
      _streamControllerMontoRedeenTwo.stream.transform(validarMonto);
  Function(String) get addDataToMontoRedeenTwo =>
      _streamControllerMontoRedeenTwo.sink.add;
  String get ultimoValorMontRedeenTwo => _streamControllerMontoRedeenTwo.value;

  Stream<bool> get validarCamposRedeenTwo =>
      Observable.combineLatest2(streamTiendaRedeenTwo, streamMontoRedeenTwo,
          (valor, valor1) {
        return true;
      });

  //TODO ESTO ES STREAMINGS DE LA PANTALLA DE CAMBIAR CONTRASENA

  final _streamControllerLoadingChangePass = BehaviorSubject<bool>();
  Stream<bool> get streamLoadingChangePass =>
      _streamControllerLoadingChangePass.stream;
  Function(bool) get addDataToLoadingChangePass =>
      _streamControllerLoadingChangePass.sink.add;
  bool get ultimoValorDeLoadingChangePass =>
      _streamControllerLoadingChangePass.value;

  final _streamControllerChangePassConrasenaActual = BehaviorSubject<String>();
  Stream<String> get streamCContrasenaActualChangeP =>
      _streamControllerChangePassConrasenaActual.stream
          .transform(validarContrasenaActual);
  Function(String) get addDataToContrasenaActualChangePas =>
      _streamControllerChangePassConrasenaActual.sink.add;
  String get ultimoValorContrasenaActualChangePs =>
      _streamControllerChangePassConrasenaActual.value;

  final _streamControllerChangePassNuevaContrasena = BehaviorSubject<String>();
  Stream<String> get streamCNuevaContraChangeP =>
      _streamControllerChangePassNuevaContrasena.stream
          .transform(validarContrasenaActual);
  Function(String) get addDataToNuevaContraChangePas =>
      _streamControllerChangePassNuevaContrasena.sink.add;
  String get ultimoValorNuevaContraChangePs =>
      _streamControllerChangePassNuevaContrasena.value;

  final _streamControllerChangePassConfirmPass = BehaviorSubject<String>();
  Stream<String> get streamConfirPassChangeP =>
      _streamControllerChangePassConfirmPass.stream
          .transform(validarContrasenaActual);
  Function(String) get addDataToConfirPassChangePas =>
      _streamControllerChangePassConfirmPass.sink.add;
  String get ultimoValorConfirPassChangePs =>
      _streamControllerChangePassConfirmPass.value;

  Stream<bool> get validarCamposChangePass => Observable.combineLatest3(
          streamCContrasenaActualChangeP,
          streamCNuevaContraChangeP,
          streamConfirPassChangeP, (valor1, valor2, valor3) {
        return true;
      });

  ///TODO ESTO ES STREAMINGS DE LA PANTALLA DE DETALLE DE CUENTA

  final _streamControllerEditingOrNot = BehaviorSubject<bool>();
  Stream<bool> get streamEditingOrNot => _streamControllerEditingOrNot.stream;
  Function(bool) get addDataToStreamEditingOrNot =>
      _streamControllerEditingOrNot.sink.add;
  bool get ultimoValorStreamEditingOrNot => _streamControllerEditingOrNot.value;

  final _streamControllerCargandoDetalleCuenta = BehaviorSubject<bool>();
  Stream<bool> get streamCargandoDetalleCuenta =>
      _streamControllerCargandoDetalleCuenta.stream;
  Function(bool) get addDataToCargandoDetalleCuenta =>
      _streamControllerCargandoDetalleCuenta.sink.add;
  bool get ultimoValorCargandoDetalleCuenta =>
      _streamControllerCargandoDetalleCuenta.value;

  final _streamControllerEmailDetalleCuenta = BehaviorSubject<String>();
  Stream<String> get streamEmailDetalleCuenta =>
      _streamControllerEmailDetalleCuenta.stream.transform(validarEmail);
  Function(String) get addDataToStreamEmailDetalleCuenta =>
      _streamControllerEmailDetalleCuenta.sink.add;
  String get ultimoValorEmailDetalleCuenta =>
      _streamControllerEmailDetalleCuenta.value;

  final _streamControllerLastNameDetalleCuenta = BehaviorSubject<String>();
  Stream<String> get streamLastNamedDetalleCuenta =>
      _streamControllerLastNameDetalleCuenta.stream
          .transform(validarApellidoDetalleCuenta);
  Function(String) get addDataToStreamLastNameDetalleCuen =>
      _streamControllerLastNameDetalleCuenta.sink.add;
  String get ultimoValorLastNameDetalleCuenta =>
      _streamControllerLastNameDetalleCuenta.value;

  final _streamControllerNameDetalleCuenta = BehaviorSubject<String>();
  Stream<String> get streamNameDetalleCuenta =>
      _streamControllerNameDetalleCuenta.stream
          .transform(validarNombreDetalleCuenta);
  Function(String) get addDataToStreamNameDetalleCuenta =>
      _streamControllerNameDetalleCuenta.sink.add;
  String get ultimoValorNameDetalleCuenta =>
      _streamControllerNameDetalleCuenta.value;

  final _streamControllerGeneroDetalleCuenta = BehaviorSubject<String>();
  Stream<String> get streamGeneroDetalleCuenta =>
      _streamControllerGeneroDetalleCuenta.stream;
  Function(String) get addDataToStreamGeneroDetalleCue =>
      _streamControllerGeneroDetalleCuenta.sink.add;
  String get ultimoValorGeneroDetalleCuen =>
      _streamControllerGeneroDetalleCuenta.value;

  final _streamControllerFechaNacDetalleCuenta = BehaviorSubject<String>();
  Stream<String> get streamFechaNacDetalleCuenta =>
      _streamControllerFechaNacDetalleCuenta.stream.transform(validarFechaNac);
  Function(String) get addDataToStreamFechaNacDetalleCuenta =>
      _streamControllerFechaNacDetalleCuenta.sink.add;
  String get ultimoValorFechaNacDetalleCu =>
      _streamControllerFechaNacDetalleCuenta.value;

  Stream<bool> get validarCamposDetalleCuenta => Observable.combineLatest4(
          streamNameDetalleCuenta,
          streamLastNamedDetalleCuenta,
          streamEmailDetalleCuenta,
          streamFechaNacDetalleCuenta, (valor, valor1, valor2, valor3) {
        return true;
      });

  ////////////////////////////////

  ///y esto es para el inicio de sesion
  final _streamControllerPassword = BehaviorSubject<String>();
  final _streamControllerCI = BehaviorSubject<String>();
  //esto es de la pantalla de ayuda de enviar mensaje
  final _streamControllerMensaje = BehaviorSubject<String>();
  //esto es para la reden pantalla one
  final _streamControllerRadioRedeen = BehaviorSubject<Map<String, String>>();
  //esto es para el registro one
  final _streamControllerName = BehaviorSubject<String>();
  final _streamControllerLastName = BehaviorSubject<String>();
  final _streamControllerEmail = BehaviorSubject<String>();
  final _streamControllerPassword2 = BehaviorSubject<String>();

  // este lo usaremos para verificar si se debe mostrar el cargador
  final _streamControllerRefreshing = BehaviorSubject<bool>();

  //TODO ESTO ES PARA LA PANTALLA DE VER PIN DE VALIDACION

  final _streamControllerValidarPin = BehaviorSubject<String>();
  final _streamControllerLoadingPinScreen = BehaviorSubject<bool>();
  Stream<bool> get streamLoadingPinScreen =>
      _streamControllerLoadingPinScreen.stream;
  Stream<String> get streamPinValidator =>
      _streamControllerValidarPin.stream.transform(validarPin);
  Function(bool) get addDataToLoadinPinScreen =>
      _streamControllerLoadingPinScreen.sink.add;
  Function(String) get addDataToStreamPinValidator =>
      _streamControllerValidarPin.sink.add;
  bool get ultimoValorLoadingPinScreen =>
      _streamControllerLoadingPinScreen.value;
  String get ultimoValorPinValidator => _streamControllerValidarPin.value;

  /////

  //TODO ESTO ES PARA LA PANTALLA DE RECUPERACION DE CONTRASENA
  //este es el streamController para la recuperacion de contrasena

  final _streamControllerEmailRecoverPassword = BehaviorSubject<String>();

  Stream<String> get streamEmailRecoverPassword =>
      _streamControllerEmailRecoverPassword.stream.transform(validarEmail);
  Function(String) get addDataToStreamEmailRecoverPass =>
      _streamControllerEmailRecoverPassword.sink.add;
  String get ultimoValorEmailRecoverPass =>
      _streamControllerEmailRecoverPassword.value;

  ///////TODOOO ESTO ES PARA EL REGISTRO NUMERO DOS
  //estos streams seran para la pantalla de registro dos

  final _streamControllerCi_nit = BehaviorSubject<String>();
  final _streamControllerCiudadExpedicion = BehaviorSubject<String>();
  final _streamControllerFechaNacimiento = BehaviorSubject<String>();
  final _streamControllerPais = BehaviorSubject<String>();
  final _streamControllerCiudad = BehaviorSubject<String>();
  final _streamControllerTipoCliente = BehaviorSubject<String>();
  final _streamControllerCelular = BehaviorSubject<String>();
  final _streamControllerTandC = BehaviorSubject<bool>();

  Stream<String> get streamCi_Nit => _streamControllerCi_nit.stream;
  Stream<String> get streamCiudadExpedicion =>
      _streamControllerCiudadExpedicion.stream;
  Stream<String> get streamFechaNacimiento =>
      _streamControllerFechaNacimiento.stream;
  Stream<String> get streamPais => _streamControllerPais.stream;
  Stream<String> get streamCiudad => _streamControllerCiudad.stream;
  Stream<String> get streamTipoCliente => _streamControllerTipoCliente.stream;
  Stream<String> get streamCelular =>
      _streamControllerCelular.stream.transform(validaNumeroCelular);
  Stream<bool> get streamTandCondition => _streamControllerTandC.stream;

  Function(String) get addDataToToStreamCi_Nit =>
      _streamControllerCi_nit.sink.add;
  Function(String) get addDataToStreamCiudadExp =>
      _streamControllerCiudadExpedicion.sink.add;
  Function(String) get addDataToStreamFechaNac =>
      _streamControllerFechaNacimiento.sink.add;
  Function(String) get addDataToStreamPais => _streamControllerPais.sink.add;
  Function(String) get addDataToStreamCiudad =>
      _streamControllerCiudad.sink.add;
  Function(String) get addDataToStreamTipoCliente =>
      _streamControllerTipoCliente.sink.add;
  Function(String) get addDataToStreamCelular =>
      _streamControllerCelular.sink.add;
  Function(bool) get addDataToStreamTAndConditio =>
      _streamControllerTandC.sink.add;

  String get ultimoValorCI_NIT => _streamControllerCi_nit.value;
  String get ultimoValorCiudadExped => _streamControllerCiudadExpedicion.value;
  String get ultimoValorFechaNac => _streamControllerFechaNacimiento.value;
  String get ultimoValorPais => _streamControllerPais.value;
  String get ultimoValorCiudad => _streamControllerCiudad.value;
  String get ultimoValorTipoCliente => _streamControllerTipoCliente.value;
  String get ultimoValorCelular => _streamControllerCelular.value;
  bool get ultimoValorTermsAndCond => _streamControllerTandC.value;

  Stream<bool> get validarRegistrosParteTwo => Observable.combineLatest7(
          streamCi_Nit,
          streamCiudadExpedicion,
          streamFechaNacimiento,
          streamPais,
          streamCiudad,
          streamCelular,
          streamTandCondition,
          (valor2, valor3, valor4, valor5, valor7, valor8, valor9) {
        print(valor2);
        print(valor3);
        print(valor4);
        print(valor5);
        print(valor7);
        print(valor8);
        print(valor9);
        return true;
      });

/////////////////////////////////////////

//esto es para el login
  Stream<String> get contrasenaStream =>
      _streamControllerPassword.stream.transform(validarContrasena);
  Stream<String> get ciStream =>
      _streamControllerCI.stream.transform(validarCI);

//este stream es para ver el cargador
  Stream<bool> get refreshingStream =>
      _streamControllerRefreshing.stream.transform(validarStreamRefreshing);
  //este es el stream de mensaje de ayuda

  Stream<String> get mensajeStream => _streamControllerMensaje.stream;
  Stream<bool> get cargandoStream => _streamControllerRefreshing.stream;

  //este es el stream de la pantalla de reden
  Stream<Map<String, String>> get radioStream =>
      _streamControllerRadioRedeen.stream;

  //esto es de la primera pantalla de registro
  Stream<String> get nameStream =>
      _streamControllerName.stream.transform(validarName);
  Stream<String> get lastnamelStream =>
      _streamControllerLastName.stream.transform(validarLastName);
  Stream<String> get emailStream =>
      _streamControllerEmail.transform(validarEmail);
  Stream<String> get password2Stream =>
      _streamControllerPassword2.stream.transform(validarContrasena);

  final _streamControllerCodigoConsultRegisterOne = BehaviorSubject<String>();
  Stream<String> get codigoConsultStreamRegisterone =>
      _streamControllerCodigoConsultRegisterOne.stream
          .transform(validarCodigoConsultoria);
  Function(String) get addDataToCondigoConsRegisterOne =>
      _streamControllerCodigoConsultRegisterOne.sink.add;
  String get ultimoValorCodigoConsRegisterOne =>
      _streamControllerCodigoConsultRegisterOne.value;

  //validador de login
  Stream<bool> get validarCampos =>
      Observable.combineLatest2(contrasenaStream, ciStream, (valor, valor1) {
        print("==================");
        print(valor);
        print("==================");
        return true;
      });

  //validador de registro pantalla 1
  Stream<bool> get validarUsuario => Observable.combineLatest4(
          nameStream, lastnamelStream, emailStream, password2Stream,
          (valor2, valor3, valor4, valor5) {
        print("==================");
        print(valor2);
        print("==================");
        return true;
      });

  Function(String) get addDataToStreamPassword =>
      _streamControllerPassword.sink.add;
  Function(String) get addDataToStreamCI => _streamControllerCI.sink.add;
  Function(bool) get addDataToStreamRefresing =>
      _streamControllerRefreshing.sink.add;
  Function(String) get addDataToStreamMensaje =>
      _streamControllerMensaje.sink.add;
  Function(bool) get addDataToStreamCargando =>
      _streamControllerRefreshing.sink.add;
  Function(Map<String, String>) get addDataToStreamRadioRedeen =>
      _streamControllerRadioRedeen.sink.add;
  Function(String) get addDataToStreamName => _streamControllerName.sink.add;
  Function(String) get addDataToStreamLastName =>
      _streamControllerLastName.sink.add;
  Function(String) get addDataToStreamEmail => _streamControllerEmail.sink.add;
  Function(String) get addDataToStreamPassword2 =>
      _streamControllerPassword2.sink.add;

  String get ultimoValorContrasena => _streamControllerPassword.value;
  String get ultimoValorCI => _streamControllerCI.value;
  bool get ultimoValorEmitido => _streamControllerRefreshing.value;
  String get ultimoValorEmitidoMensaje => _streamControllerMensaje.value;
  bool get ultimoValorDeCargando => _streamControllerRefreshing.value;
  Map<String, String> get ultimoValorSeleccionadoRadi =>
      _streamControllerRadioRedeen.value;
  String get ultimoValorName => _streamControllerName.value;
  String get ultimoValorLastName => _streamControllerLastName.value;
  String get ultimoValorCorreo => _streamControllerEmail.value;
  String get ultimoValorPassword2 => _streamControllerPassword2.value;

  void restablecerValor() {
    this._streamControllerEmailRecoverPassword.sink.add("");
  }

  void restablecerValorRegisterPartOne() {
    this._streamControllerName.sink.add("");
    this._streamControllerLastName.sink.add("");
    this._streamControllerEmail.sink.add("");
    this._streamControllerPassword2.sink.add("");
  }

  void restablecerValorChangePass() {
    this._streamControllerChangePassConrasenaActual.sink.add("");
    this._streamControllerChangePassNuevaContrasena.sink.add("");
    this._streamControllerChangePassConfirmPass.sink.add("");
  }

  void restablecerValorRedeenTwo() {
    this._streamControllerMontoRedeenTwo.sink.add("");
    this._streamControllerTiendaRedeenTwo.sink.add("");
  }

  dispose() {
    //en detalle de pedidos

    _streamControllerSubTotalDetalle?.close();
    _streamControllerDireccionEditarDetalleCompr?.close();

    ///
    _streamControllerModoDePagoSelecc?.close();
    _streamControllerLoadingModoPago?.close();
    _streamControllerNotaModoPago?.close();

    ///
    ///esto es del dialog de unidades que se quiere

    _streamControllerUnidadesDialog?.close();
    _streamControllerCantidadMayorACero?.close();

    ///

    _streamControllerPuntosAct?.close();
    _streamControllerPassword?.close();
    _streamControllerCI?.close();
    _streamControllerRefreshing?.close();
    _streamControllerMensaje?.close();
    _streamControllerRefreshing?.close();
    _streamControllerRadioRedeen?.close();
    _streamControllerName?.close();
    _streamControllerLastName?.close();
    _streamControllerEmail?.close();
    _streamControllerPassword2?.close();
    _streamControllerCodigoConsultRegisterOne?.close();

    ///de registro parte dos
    _streamControllerCi_nit?.close();
    _streamControllerCiudadExpedicion?.close();
    _streamControllerFechaNacimiento?.close();
    _streamControllerPais?.close();
    _streamControllerCiudad?.close();
    _streamControllerTipoCliente?.close();
    _streamControllerCelular?.close();
    _streamControllerTandC?.close();

    //de recuperar contrasena
    _streamControllerEmailRecoverPassword?.close();
    //de la pantalla de validacion pin para ingresar
    _streamControllerLoadingPinScreen?.close();
    _streamControllerValidarPin?.close();

    //de la pantalla de cuenta
    _streamControllerEditingOrNot?.close();
    _streamControllerEmailDetalleCuenta?.close();
    _streamControllerLastNameDetalleCuenta?.close();
    _streamControllerNameDetalleCuenta?.close();
    _streamControllerGeneroDetalleCuenta?.close();
    _streamControllerFechaNacDetalleCuenta?.close();
    _streamControllerCargandoDetalleCuenta?.close();

    //de la pantalla de cambiar Contrasena

    _streamControllerLoadingChangePass?.close();
    _streamControllerChangePassConrasenaActual?.close();
    _streamControllerChangePassNuevaContrasena?.close();
    _streamControllerChangePassConfirmPass?.close();

    //de la pantalla de redencion dos

    _streamControllerLoadingRedeenTwo?.close();
    _streamControllerTiendaRedeenTwo?.close();
    _streamControllerMontoRedeenTwo?.close();
  }
}
