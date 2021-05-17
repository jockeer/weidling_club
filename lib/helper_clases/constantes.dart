import 'package:flutter/material.dart';

class ConstantesApp {
  static final String NombreApp = "Loyalty Clubs Venta";
}

class NetworkApp {
  static final String Base = "http://weidlingclubs.com.bo/";
}

class ContantsWidgetsDefaults {
  static PreferredSizeWidget widgetAppBar(BuildContext contexto, Color color) {
    Size tamanoPhone = MediaQuery.of(contexto).size;
    return PreferredSize(
        preferredSize: Size.fromHeight(tamanoPhone.height * 0.001),
        child: AppBar(
          backgroundColor:
              color, // Set any color of status bar you want; or it defaults to your theme's primary color
        ));
  }
}

class NetworkEndPointsApp {
  static final String loginUser = "oauth2/token";
  static final String obtenerPuntosAcumulados =
      "ste/api-v1/services/get_clubs_accumulate_beauty"; // este llama para poner los puntos
  static final String obtenerOfertas = "ste/api-v1/services/get_publicity";
  static final String hitAccesToken = "web/Token/Token";
  static final String getContact = "ste/api-v1/services/get_contact_us";
  static final String getQuestionFaqs = "ste/api-v1/services/get_questions";
  static final String sendMessageFromContact =
      "ste/api-v1/services/message_contact_us_customer";
  static final String getCustomerPoint =
      "ste/api-v1/services/get_customer"; // y este para obtener tanto datos de la persona como sus puntos
  static final String getOptionsRedeenOne =
      "ste/api-v1/services/get_redemption_option";
  static final String recoverPassword = "ste/api-v1/Customers/validate_email";
  static final String obtenerPaises = "ste/api-v1/Customers/Get_Country";
  static final String obtenerCiudades = "ste/api-v1/Customers/Get_City";
  static final String registrarUser = "ste/api-v1/customers/customers";
  static final String validatePinUser = "oauth2/Token/validate";
  static final String modificarUsuario = "ste/api-v1/services/post_customer";
  static final String logoutUser = "oauth2/revoke_token";
  static final String changePassword = "ste/api-v1/services/post_password";
  static final String obtainTienda = "ste/api-v1/services/get_redemption_field";
  static final String insertarRedencion =
      "ste/api-v1/services/set_redemption_beauty_app";
  static final String obtenerTransferencias =
      "ste/api-v1/services/get_all_transaction";
  static final String actualizarTokenDevice =
      "ste/api-v1/Services/Notification";
  static final String obtenerPin = "ste/api_v1/Services/verify_redemption";
  static final String enviarCarritoDeCompra =
      "ste/api_v1/Services/insert_loyalty_order";
}

class Styles {
  static final TextStyle estiloGlobalTextos =
      new TextStyle(color: Colors.white);
}

class Colores {
  //COLORES WEIDING
  static Color COLOR_AZUL_WEIDING = Color.fromRGBO(32, 47, 74, 1);
  //COLORES FARMACORP-ATC

  static Color COLOR_AZUL_ATC_FARMA = Color.fromRGBO(32, 47, 74, 1);
  static Color COLOR_NARANJA_ATC_FARMA = Color.fromRGBO(32, 47, 74, 1);

  ///

  static Color COLOR_BLANCO_LOYALTY = Color.fromRGBO(254, 254, 254, 1.0);
  static Color COLOR_ROJISO_TEXTO_LOYALTY = Color.fromRGBO(216, 30, 30, 1.0);
  static Color COLOR_CAFE_CONTENEDOR_LOYALTY = Color.fromRGBO(65, 7, 16, 0.5);
  static Color COLOR_ROJO_BOTON_BIENVENIDA_LOYALTY =
      Color.fromRGBO(255, 26, 26, 1.0);
  static Color COLOR_PESTANA_DESLIZAR_LOYALTY_HOME =
      Color.fromRGBO(239, 37, 35, 1.0);
}

class Constantes {
  ///esto es de gana puntos

  static String CODIGO_CONSULTORIA = "director_code";

  ///para actualizar el deviceToken

  static final String USER_ID = "user_id";
  static final String DEVICE_TYPE = "device_type";

  ///esto es de cambiar contrasena

  static final String CURRENT_PASSWORD = "current_password";

  //estos campos son de para el registro parte 1

  static final String TYPE = "type";
  static final String NAME = "name";
  static final String EMAIL = "email";
  static final String LAST_NAME_FATHER = "lastname_father";
  static final String LAST_NAME = "lastname";
  static final String MENSAJE_PIN =
      "Para poder ver tu pin de validación presiona el botón ver pin de validación en la parte inferior de la pantalla";

  //estos campos son para el registro parte 2

  static final String ID_CARD = "id_card";
  static final String EXPEDITION = "expedition";
  static final String COUNTRY = "country";
  static final String CITY = "city";
  static final String DATE = "date";
  static final String CELL_PHONE = "cell_phone";
  static final String TIPO_CLIENTE = "type_customer";
  static final String GENDER = "gender";
  static final String CELLPHONE = "cellphone";

  //constantes de mensajes para snack bar

  static final String error_conexion =
      "Por favor, revisar su conexion a internet";
  static final String select_country = "Por favor, seleccione un país";

  //constantes solo usadas por david
  static final String estado = "estado";
  static final String mensaje = "mensaje_recibido";
  static final String respuesta_estado_ok = "correcto";
  static final String respuesta_estado_fail = "incorrecto";
  static final String timeOutRquestNetwork =
      "Tiempo de espera excedido, por favor, revisa tu conexion";
  static final String pin = "pin";
  //

  static final String message = "Message";
  static final String access_token = "access_token";
  static final String last_page = "last_page";
  static final String userSpecificToken = "userSpecificToken";
  static final String refreshToken = "refreshToken";

  static final String grant_type = "grant_type";
  static final String stellar_app_user = "ItacambaAppUser";
  static final String USERNAME = "username";

  static final String client_id = "client_id";

  static final String is_login = "IsLogin";
  static final String userType = "UserType";
  static final String device_token = "DeviceToken";
  static final String DEVICE_TOKEN = "device_token";
  static final String id_no = "IdNo";
  static final String is_refresh_token_expired = "is_expired";
  static final String ci = "ci";
  static final String pass = "password";

  //cosas del usuario

  static final String ciUser = "ci_user";
  static final String password = "password";

  //these constantes for the login page where ci and password

  static final String last_ci = "last_ci";
  static final String last_password = "last_password";

  //cosas de red

  static final String error = "error";
  static final String expired_token = "expired_token";
  static final String status = "Status";
  static final String data = "Data";
}
