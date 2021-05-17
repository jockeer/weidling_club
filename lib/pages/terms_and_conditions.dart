import 'package:flutter/material.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsAndConditionPage extends StatefulWidget {
  static final String namePage = "TermsAndConditionPage";
  TermsAndConditionPage({Key key}) : super(key: key);

  @override
  _TermsAndConditionPageState createState() => _TermsAndConditionPageState();
}

class _TermsAndConditionPageState extends State<TermsAndConditionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[_fondo(), _cuerpo(context)],
      ),
    );
  }

  _cuerpo(BuildContext contexto) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: double.infinity,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: GestureDetector(
                  child: Icon(Icons.arrow_back_ios,
                      color: Colores.COLOR_AZUL_WEIDING),
                  onTap: () {
                    Navigator.of(contexto).pop();
                  },
                ),
              ),
              Text(
                "Términos y condiciones",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              Icon(Icons.arrow_back_ios, color: Colors.transparent),
            ],
          ),
          SizedBox(
            height: 20.0,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: WebView(
                initialUrl:
                    "https://clubincentivofarmacorp.com.bo//web/app/Terms_conditions",
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fondo() {
    return Container(
      color: Colors.red,
      width: double.infinity,
      height: double.infinity,
      child: Image(
        image: AssetImage("assets/imagenes/fondo_fridolin.jpg"),
        fit: BoxFit.cover,
      ),
    );
  }
}
