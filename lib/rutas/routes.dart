import 'package:flutter/material.dart';
import 'package:weidling/pages/account_detail.dart';
import 'package:weidling/pages/carrito.dart';
import 'package:weidling/pages/change_password.dart';
import 'package:weidling/pages/enter_pin.dart';
import 'package:weidling/pages/help_especifico.dart';
import 'package:weidling/pages/help_page.dart';
import 'package:weidling/pages/history_transfer.dart';
import 'package:weidling/pages/home_page.dart';
import 'package:weidling/pages/login_page.dart';
import 'package:weidling/pages/map.dart';
import 'package:weidling/pages/modoPago.dart';
import 'package:weidling/pages/pdf_viewer.dart';
import 'package:weidling/pages/recover_password.dart';
import 'package:weidling/pages/redeem_one_page.dart';
import 'package:weidling/pages/redeem_two_page.dart';
import 'package:weidling/pages/register_part_one.dart';
import 'package:weidling/pages/register_part_two.dart';
import 'package:weidling/pages/terms_and_conditions.dart';
import 'package:weidling/pages/ultimoPasoPedido.dart';
import 'package:weidling/pages/welcome_page.dart';


Map<String,WidgetBuilder> obtenerRutas(){


        return {
             WelcomePage.nameOfPage       : (BuildContext context) =>  WelcomePage(),
             LoginPage.nameOfPage         : (BuildContext context) => LoginPage(),
             HomePage.nameOfPage          : (BuildContext context) => HomePage(),
             HelpPage.namePage            : (BuildContext context) => HelpPage(),
             ShowHelp.namePage            : (BuildContext context) => ShowHelp(),
             RedeemPageOne.nameOfPage     : (BuildContext context) => RedeemPageOne(),
             RecoverPassword.nameOfPage   : (BuildContext context) => RecoverPassword(),
             RegisterPartOne.nameOfPage   : (BuildContext context) => RegisterPartOne(),
             RegisterPartTwo.nameOfPage   : (BuildContext context) => RegisterPartTwo(),
             EnterPinPage.nameOfPage      : (BuildContext context) => EnterPinPage(),
             TermsAndConditionPage.namePage : (BuildContext context) => TermsAndConditionPage(),
             AccountDetail.namePage         : (BuildContext context) => AccountDetail(),  
             ChangePasswordPage.nameOfPage  : (BuildContext contexto) => ChangePasswordPage(),  
             RedeenTwoPage.nameOfPage       : (BuildContext contexto) => RedeenTwoPage(),
             HistoryTransferPage.nameOfPage : (BuildContext contexto) => HistoryTransferPage(),
             PdfViewer.nameOfPage           : (BuildContext contexto) => PdfViewer(),
             CarritoPage.nameOfPage         : (BuildContext contexto) => CarritoPage(),
             DireccionPage.nameOfPage       : (BuildContext contexto) => DireccionPage(),
             ModoPago.nameOfPage            : (BuildContext contexto) => ModoPago(),
             DetallePedido.nameOfPage       : (BuildContext contexto) => DetallePedido(),


        };
        
}