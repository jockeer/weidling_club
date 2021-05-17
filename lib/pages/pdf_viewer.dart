import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import 'package:weidling/helper_clases/base.dart';
import 'package:weidling/helper_clases/constantes.dart';
import 'package:weidling/helper_clases/verificar_conexion.dart';
import 'package:weidling/pages/home_page.dart';

class PdfViewer extends StatefulWidget {
  PdfViewer({Key key}) : super(key: key);
  static final nameOfPage = 'PdfViewer';

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  String url;
  Base base;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.url = "";
    this.base = new Base();
  }

  @override
  Widget build(BuildContext context) {
    final tamanoPhone = MediaQuery.of(context).size;
    this.url = ModalRoute.of(context).settings.arguments;

    final extensionDir = url.substring(url.length - 3);
    print(extensionDir);
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(tamanoPhone.height * 0.001),
          child: AppBar(
            // Here we create one to set status bar color
            backgroundColor: Colores
                .COLOR_AZUL_WEIDING, // Set any color of status bar you want; or it defaults to your theme's primary color
          )),
      body: SafeArea(
          child: Column(
        children: <Widget>[
          SizedBox(
            height: tamanoPhone.height * 0.01,
          ),
          _parteSuperior(context),
          Expanded(
            child: Center(
              child: (extensionDir == "pdf") ? _esPdf() : _esImagen(),
            ),
          ),
        ],
      )),
    );
  }

  Widget _parteSuperior(BuildContext contextoParteSuperior) {
    final tamanoPhone = MediaQuery.of(contextoParteSuperior).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colores.COLOR_AZUL_WEIDING,
            ),
            onTap: () {
              Navigator.of(contextoParteSuperior)
                  .popAndPushNamed(HomePage.nameOfPage);
            },
          ),
        ],
      ),
    );
  }

  Widget _esPdf() {
    try {
      return FutureBuilder(
          future: PDFDocument.fromURL(this.url),
          builder: (BuildContext contexto,
              AsyncSnapshot<PDFDocument> asyncSnapshot) {
            if (asyncSnapshot.hasData) {
              return Theme(
                data: ThemeData.light().copyWith(
                    buttonTheme:
                        ButtonThemeData(textTheme: ButtonTextTheme.primary),
                    primaryColor:
                        Color.fromRGBO(102, 10, 11, 1.0), //Head background
                    accentColor:
                        Color.fromRGBO(102, 10, 11, 1.0) //selection color

                    //dialogBackgroundColor: Colors.white,//Background color
                    ),
                child: PDFViewer(
                    showPicker: false,
                    indicatorBackground: Colores.COLOR_AZUL_WEIDING,
                    document: asyncSnapshot.data),
              );
            } else {
              return this.base.retornarCircularCargando(Colors.brown);
            }
          });
    } catch (e) {
      return Text("Hubo un problema vuelve a intentarlo");
    }
  }

  Widget _esImagen() {
    try {
      return Container(
        child: FadeInImage(
          fit: BoxFit.contain,
          placeholder: AssetImage('assets/gifs/pre_loading.gif'),
          image: NetworkImage(this.url),
        ),
      );
    } catch (e) {
      return Text("Hubo un problema vuelve a intentarlo");
    }
  }
}
