import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/sharepreferences.dart';
import 'package:weidling/pages/welcome_page.dart';
import 'package:weidling/providers/providers.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:weidling/rutas/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = new SharedPreferencesapp();
  await prefs.inicializarPreferencias();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final preferencias = SharedPreferencesapp();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
        /* FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
              
             } */
      },
      child: Provider(
        child: MaterialApp(
          localizationsDelegates: [
            // ... app-specific localization delegate[s] here
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en'), // English
            const Locale('es'), // Hebrew
          ],
          debugShowCheckedModeBanner: false,
          title: 'Weidling Club',
          theme: ThemeData.light().copyWith(
            primaryColor: Colores.COLOR_AZUL_WEIDING,
            secondaryHeaderColor: Colores.COLOR_AZUL_WEIDING,
            appBarTheme: AppBarTheme(
              brightness: Brightness.dark
            )
          ),
          initialRoute: preferencias.devolverValor(
              Constantes.last_page, WelcomePage.nameOfPage),
          routes: obtenerRutas(),
        ),
      ),
    );
  }
}
